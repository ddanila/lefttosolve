#!/usr/bin/env python3
"""Monitor the authorized A334502 reduction and submit its four checked steps.

Stops on a competing merged proof, changed targets/tools, rejection, or failed CI.
Uses an exclusive lock and persistent per-step state to prevent duplicate submissions.
"""
import argparse
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT/'.oma/a334502-watch'
PLATFORM = ROOT/'.oma/a334502-submit'
CONTEXT = ROOT/'problems/a334502/reviews/submission-context.json'
UPSTREAM = 'lefttosolve2/open-math-agents'
ID = 'oeis-a334502'
REDUCTION = f'reductions/{ID}.R1.lean'
STATEMENT = f'statements/{ID}.lean'
ENV = dict(os.environ, OMA_AGENT='codex', OMA_MODEL='gpt-6',
           OMA_FC=str(ROOT/'.oma/a334502-fc'),
           PATH=str(Path.home()/'.elan/bin')+':/opt/homebrew/opt/coreutils/libexec/gnubin:'+os.environ['PATH'])
ENV.pop('OMA_CHECK', None)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def run(args, required=True, timeout=180):
    retryable = args[:2] == ['git', 'fetch'] or args[:3] in (
        ['gh', 'pr', 'view'], ['gh', 'pr', 'list'])
    for attempt in range(3 if retryable else 1):
        try:
            p = subprocess.run(args, cwd=PLATFORM, env=ENV, capture_output=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            if not retryable or attempt == 2:
                raise
            time.sleep(10)
            continue
        if p.returncode == 0 or not retryable or attempt == 2:
            break
        time.sleep(10)
    if required and p.returncode:
        (STATE/'command-private.log').write_bytes(p.stdout+p.stderr)
        raise RuntimeError(f'{args[0]} failed ({p.returncode}); see command-private.log')
    return p


def api(args):
    return json.loads(run(['gh', *args]).stdout)


def verdict(pr):
    if pr.get('mergedAt'):
        return 'merged'
    if pr.get('state') == 'CLOSED':
        return 'closed'
    if any(c.get('conclusion') in ('FAILURE', 'CANCELLED', 'TIMED_OUT')
           for c in pr.get('statusCheckRollup', [])):
        return 'needs_review'
    for c in pr.get('comments', []):
        if c.get('author', {}).get('login') in ('github-actions', 'github-actions[bot]') and 'Not merged:' in c.get('body', ''):
            return 'needs_review'
    return 'pending'


def target_state(statement, reduction, proof_exists, context):
    if proof_exists:
        return 'competing_proof_merged'
    if statement is None or sha(statement) != context['statement_sha256']:
        return 'statement_changed'
    if reduction is None:
        return 'waiting_for_reduction'
    return 'ready' if sha(reduction) == context['reduction_sha256'] else 'reduction_changed'


def file_prs(prs, path):
    return [p for p in prs if any(f['path'] == path for f in p.get('files', []))]


def blob(path):
    p = run(['git', 'show', f'upstream/main:{path}'], required=False)
    return p.stdout if p.returncode == 0 else None


def pr_info(number):
    return api(['pr', 'view', str(number), '--repo', UPSTREAM, '--json',
                'number,url,state,mergedAt,comments,statusCheckRollup,files,author,headRefOid'])


def save(state):
    state['updated_utc'] = dt.datetime.now(dt.timezone.utc).isoformat()
    p = STATE/'status.tmp'
    p.write_text(json.dumps(state, indent=2)+'\n')
    p.replace(STATE/'status.json')


def fetch_state(context):
    run(['git', 'fetch', 'upstream', 'main'])
    return target_state(blob(STATEMENT), blob(REDUCTION), blob(f'proofs/{ID}.lean') is not None, context)


def preflight(context):
    assert api(['api', f'repos/{UPSTREAM}'])['full_name'] == UPSTREAM, 'Repository moved'
    assert run(['gh', 'api', 'user', '--jq', '.login']).stdout.strip() == b'ddanila'
    assert sha((ROOT/REDUCTION).read_bytes()) == context['reduction_sha256']
    assert sha((ROOT/'problems/a334502/sources/statement.lean').read_bytes()) == context['statement_sha256']
    for i in range(1, 5):
        assert sha((ROOT/f'proofs/{ID}.R1.H{i}.lean').read_bytes()) == context['step_sha256'][str(i)]
    assert run(['git', '-C', ENV['OMA_FC'], 'rev-parse', 'HEAD']).stdout.decode().strip() == context['formal_conjectures_commit']


def submit_step(i, context, state):
    path = f'proofs/{ID}.R1.H{i}.lean'
    step = state['steps'].setdefault(str(i), {})
    pending = api(['pr', 'list', '--repo', UPSTREAM, '--state', 'open', '--search', ID,
                   '--limit', '100', '--json', 'number,url,files,author'])
    matches = file_prs(pending, path)
    if matches:
        assert len(matches) == 1 and matches[0]['author']['login'] == 'ddanila', 'Another step proof is pending'
        step.update(pr=matches[0]['number'], url=matches[0]['url'], phase='submitted')
        save(state)
        return
    branch = f'oma/{ID}.R1.H{i}'
    assert not run(['git', 'ls-remote', '--heads', 'origin', f'refs/heads/{branch}']).stdout.strip(), 'Remote branch exists without PR; inspect before retrying'
    assert not run(['git', 'status', '--porcelain']).stdout.strip(), 'Submission checkout is dirty'
    run(['git', 'checkout', '--detach', 'upstream/main'])
    pin = json.loads((PLATFORM/'data/catalog.json').read_text())['meta']['upstreamCommit']
    assert pin == context['formal_conjectures_commit'], 'Dependency pin changed'
    for name, digest in context['tools_sha256'].items():
        assert sha((PLATFORM/'tools'/name).read_bytes()) == digest, f'Checker changed: {name}'
    query = urllib.parse.urlencode(dict(handle='ddanila', agent='codex', problem=f'{ID}.R1.H{i}'))
    try:
        with urllib.request.urlopen('https://lefttosolve.com/api/desk/next?'+query, timeout=60) as response:
            lease = json.load(response)['lease']
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            step['phase'] = 'waiting_for_step_catalogue'; save(state)
            return
        raise
    (PLATFORM/path).write_bytes((ROOT/path).read_bytes())
    step['phase'] = 'checking'; save(state)
    report = STATE/f'H{i}-check.json'
    run(['tools/check.sh', path, str(report)], timeout=2400)
    assert json.loads(report.read_text())['verdict'] == 'accepted'
    assert fetch_state(context) == 'ready', 'Target changed during check'
    assert blob(path) is None, 'Step already merged during check'
    pending = api(['pr', 'list', '--repo', UPSTREAM, '--state', 'open', '--search', ID,
                   '--limit', '100', '--json', 'number,url,files,author'])
    assert not file_prs(pending, path), 'A step PR appeared during checking'
    run(['git', 'checkout', '--detach', 'upstream/main'])
    body = (ROOT/f'problems/a334502/submission/H{i}-pr.md').read_text().split('\n', 1)[1].lstrip()
    body_path = STATE/f'H{i}-body.txt'
    body_path.write_text(f'Lease: {lease}\nAgent: codex\nModel: gpt-6\n\nProblem: https://lefttosolve.com/p/{ID}.R1.H{i}\n\n'+body)
    run(['git', 'add', '--', path]); run(['git', 'commit', '-m', f'proof: {ID}.R1.H{i}', '--', path])
    step.update(phase='submitting', lease=lease); save(state)
    run(['git', 'push', 'origin', f'HEAD:refs/heads/{branch}'])
    output = run(['gh', 'pr', 'create', '--repo', UPSTREAM, '--head', 'ddanila:'+branch,
                  '--title', f'{ID}.R1.H{i}', '--body-file', str(body_path)]).stdout.decode().strip()
    info = pr_info(output)
    assert [f['path'] for f in info['files']] == [path]
    step.update(phase='submitted', pr=info['number'], url=info['url']); save(state)
    url = 'https://lefttosolve.com/api/desk/release?'+urllib.parse.urlencode(dict(lease=lease, reason='submitted'))
    try:
        urllib.request.urlopen(urllib.request.Request(url, method='POST'), timeout=30).close()
    except (urllib.error.URLError, TimeoutError):
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true')
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    assert args.run or args.check_only, 'Choose --run or --check-only'
    STATE.mkdir(parents=True, exist_ok=True)
    lock = (STATE/'lock').open('w')
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    context = json.loads(CONTEXT.read_text())
    preflight(context)
    if args.check_only:
        print('PASS: account, exact prepared artifacts and dependency pin'); return
    state = json.loads((STATE/'status.json').read_text()) if (STATE/'status.json').exists() else dict(phase='monitoring', steps={})
    assert state['phase'] in ('monitoring','waiting_for_reduction','submitting_steps','monitoring_steps','monitoring_expired'), 'Terminal state needs inspection'
    assert not any(s.get('phase') == 'submitting' for s in state['steps'].values()), 'Uncertain submission needs inspection'
    (STATE/'pid').write_text(str(os.getpid())+'\n')
    deadline = time.time()+48*3600
    try:
        while time.time() < deadline:
            info = pr_info(context['reduction_pr'])
            state['reduction'] = info
            phase = fetch_state(context)
            if phase not in ('ready','waiting_for_reduction'):
                state['phase'] = phase; save(state); return
            status = verdict(info)
            if status in ('closed','needs_review'):
                state['phase'] = status; save(state); return
            if phase == 'ready' and status == 'merged':
                state['phase'] = 'submitting_steps'; save(state)
                for i in range(1,5):
                    path = f'proofs/{ID}.R1.H{i}.lean'
                    step = state['steps'].setdefault(str(i), {})
                    if blob(path) is not None:
                        step['phase'] = 'merged'; continue
                    if 'pr' not in step:
                        submit_step(i, context, state)
                        if 'pr' not in step:
                            break
                    step['info'] = pr_info(step['pr'])
                    step['phase'] = verdict(step['info'])
                    if step['phase'] in ('closed','needs_review'):
                        state['phase'] = 'needs_review'; save(state); return
                if len(state['steps']) == 4 and all(s['phase'] == 'merged' for s in state['steps'].values()):
                    state['phase'] = 'complete'; save(state); return
                state['phase'] = 'monitoring_steps'
            else:
                state['phase'] = 'waiting_for_reduction'
            save(state)
            time.sleep(60)
        state['phase'] = 'monitoring_expired'; save(state)
    except Exception as exc:
        state.update(phase='needs_review', reason=str(exc)); save(state)
        raise


if __name__ == '__main__':
    main()
