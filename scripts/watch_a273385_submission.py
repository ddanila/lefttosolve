#!/usr/bin/env python3
"""Submit the authorized, checked A273385 proof when its statement reaches main.

Use --check-only for validation or --run to watch for up to 48 hours. No statement
PR is created. A changed target, existing proof, or uncertain submission stops
work; the standard client's documented missing-lease path handles desk outages.
"""
import argparse
import base64
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
PROBLEM = ROOT/'problems/a273385'
STATE = ROOT/'.oma/a273385-watch'
PLATFORM = STATE/'platform'
UPSTREAM = 'lefttosolve2/open-math-agents'
LEGACY_UPSTREAM = 'GuillaumeBAUD-coder/open-math-agents'
FORK = 'ddanila/open-math-agents'
ID = 'oeis-a273385'
STATEMENT = f'statements/{ID}.lean'
PROOF = f'proofs/{ID}.lean'
ENV = {**os.environ, 'OMA_AGENT': 'codex', 'OMA_MODEL': 'gpt-6',
       'OMA_FC': str(ROOT/'.oma/a273385-fc'),
       'PATH': str(Path.home()/'.elan/bin')+':'+os.environ['PATH']}
ENV.pop('OMA_CHECK', None)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def submission_urls(output):
    # The pinned client may print the former name; normalize redirected PR URLs.
    repos = '|'.join(map(re.escape, (UPSTREAM, LEGACY_UPSTREAM)))
    numbers = re.findall(r'https://github.com/(?:'+repos+r')/pull/(\d+)\b', output)
    return [f'https://github.com/{UPSTREAM}/pull/{n}' for n in numbers]


def candidate_state(statement, proof_exists, expected):
    if proof_exists:
        return 'already_proved'
    if statement is None:
        return 'waiting_for_statement'
    if sha(statement) != expected:
        return 'statement_changed'
    return 'ready'


def run(args, cwd=PLATFORM, required=True, timeout=180):
    p = subprocess.run(args, cwd=cwd, env=ENV, capture_output=True, text=True, timeout=timeout)
    if required and p.returncode:
        (STATE/'last-command-private.log').write_text(p.stdout+p.stderr)
        raise RuntimeError(f'{args[0]} failed with exit {p.returncode}; inspect private log')
    return p


def save(phase, **fields):
    data = dict(phase=phase, updated_utc=dt.datetime.now(dt.timezone.utc).isoformat(), **fields)
    temp = STATE/'status.tmp'
    temp.write_text(json.dumps(data,indent=2)+'\n')
    temp.replace(STATE/'status.json')


def preflight(context):
    repo = json.loads(run(['gh','api',f'repos/{UPSTREAM}'],cwd=ROOT).stdout)
    assert repo['full_name'] == UPSTREAM, 'Upstream moved again; update search scope before submitting'
    assert sha((PROBLEM/'sources/pr-22075-statement.lean').read_bytes()) == context['statement_sha256']
    assert sha((PROBLEM/'submission/oeis-a273385.lean').read_bytes()) == context['proof_sha256']
    assert json.loads((PROBLEM/'reviews/pr-22075-proof-check.json').read_text())['verdict'] == 'accepted'
    assert run(['git','rev-parse','HEAD'],cwd=Path(ENV['OMA_FC'])).stdout.strip() == context['formal_conjectures_commit']
    assert run(['gh','api','user','--jq','.login'],cwd=ROOT).stdout.strip() == 'ddanila'


def monitor(url, deadline):
    while time.time() < deadline:
        result = run(['gh','pr','view',url,'--json','state,mergedAt,statusCheckRollup,comments'],required=False)
        if result.returncode:
            time.sleep(60)
            continue
        info = json.loads(result.stdout)
        checks = [{k:c.get(k) for k in ('name','status','conclusion','detailsUrl')} for c in info['statusCheckRollup']]
        if info['mergedAt']:
            save('merged',url=url,merged_at=info['mergedAt'],checks=checks)
            return
        if info['state'] == 'CLOSED':
            save('closed',url=url,checks=checks)
            return
        if any(c.get('conclusion') in ('FAILURE','CANCELLED','TIMED_OUT') for c in checks):
            save('needs_review',url=url,reason='Proof CI requires attention',checks=checks)
            return
        save('proof_submitted',url=url,checks=checks)
        time.sleep(60)
    save('monitoring_expired',url=url)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run',action='store_true')
    parser.add_argument('--check-only',action='store_true')
    args = parser.parse_args()
    if not (args.run or args.check_only):
        parser.error('choose --run or --check-only')
    STATE.mkdir(parents=True,exist_ok=True)
    lock = (STATE/'lock').open('w')
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    context = json.loads((PROBLEM/'reviews/pr-22075-context.json').read_text())
    preflight(context)
    if args.check_only:
        print('PASS: checked proof, exact pending statement, dependency pin, and GitHub account')
        return
    if (STATE/'status.json').exists():
        old = json.loads((STATE/'status.json').read_text())
        if old['phase'] in ('submitting','needs_review','statement_changed','already_proved','merged','closed'):
            raise RuntimeError('Previous terminal/uncertain state needs inspection; refusing to resubmit')
        if old.get('url'):
            monitor(old['url'],time.time()+48*3600)
            return
    (STATE/'pid').write_text(str(os.getpid())+'\n')
    if not (PLATFORM/'.git').exists():
        run(['git','clone','--no-hardlinks',str(ROOT/'.oma/a273385-platform'),str(PLATFORM)],cwd=ROOT)
        run(['git','remote','set-url','origin',f'https://github.com/{FORK}.git'])
        run(['git','remote','add','upstream',f'https://github.com/{UPSTREAM}.git'])
    # Existing clones need the new canonical remote too.
    run(['git','remote','set-url','upstream',f'https://github.com/{UPSTREAM}.git'])
    deadline = time.time()+48*3600
    while time.time() < deadline:
        fetched = run(['git','fetch','upstream','main'],required=False)
        if fetched.returncode:
            save('waiting_for_network')
            time.sleep(60)
            continue
        statement = run(['git','show',f'upstream/main:{STATEMENT}'],required=False)
        exists = run(['git','cat-file','-e',f'upstream/main:{PROOF}'],required=False).returncode == 0
        phase = candidate_state(statement.stdout.encode() if statement.returncode == 0 else None,
                                exists,context['statement_sha256'])
        save(phase)
        if phase == 'waiting_for_statement':
            time.sleep(60)
            continue
        if phase != 'ready':
            return
        preflight(context)
        run(['git','checkout','--detach','upstream/main'])
        pin = json.loads((PLATFORM/'data/catalog.json').read_text())['meta']['upstreamCommit']
        assert pin == context['formal_conjectures_commit'], 'Upstream dependency pin changed'
        for name in ('check.sh','lint.py','oma.sh'):
            assert sha((PLATFORM/'tools'/name).read_bytes()) == context['tools_sha256'][name], 'Checker/client changed'
        pending = json.loads(run(['gh','pr','list','--repo',UPSTREAM,'--state','open','--author','ddanila',
                                  '--search',ID,'--json','number,url']).stdout)
        assert not pending, 'An own PR already exists; inspect before submitting'
        branch = f'refs/heads/oma/{ID}'
        assert not run(['git','ls-remote','--heads','origin',branch]).stdout.strip(), 'Submission branch already exists'
        shutil.copyfile(PROBLEM/'submission/oeis-a273385.lean',PLATFORM/PROOF)
        run(['tools/check.sh',PROOF,str(STATE/'merged-proof-check.json')],timeout=2400)
        assert json.loads((STATE/'merged-proof-check.json').read_text())['verdict'] == 'accepted'
        # Recheck after compilation in case another proof merged meanwhile.
        run(['git','fetch','upstream','main'])
        latest = run(['git','show',f'upstream/main:{STATEMENT}'])
        exists = run(['git','cat-file','-e',f'upstream/main:{PROOF}'],required=False).returncode == 0
        phase = candidate_state(latest.stdout.encode(),exists,context['statement_sha256'])
        if phase != 'ready':
            save(phase)
            return
        # Fast-forward the fork so the standard client bases the one-file PR on
        # the merged statement. Never force a divergent fork or existing branch.
        run(['git','push','origin','HEAD:main'])
        run(['git','fetch','origin','main'])
        run(['git','remote','set-head','origin','main'])
        claim = run(['tools/oma.sh','next','--problem',ID,'--exact'],required=False)
        (STATE/'claim-private.log').write_text(claim.stdout+claim.stderr)
        # Missing/expired leases and desk errors are explicitly supported by
        # the unmodified client; a 410 settled response still stops submission.
        save('submitting')
        result = run(['tools/oma.sh','submit',ID],required=False,timeout=2400)
        (STATE/'submit-private.log').write_text(result.stdout+result.stderr)
        urls = submission_urls(result.stdout)
        assert result.returncode == 0 and urls, 'Submission outcome uncertain; do not retry blindly'
        url = urls[-1]
        pr = json.loads(run(['gh','pr','view',url,'--json','number,url,files,author,headRefOid']).stdout)
        assert pr['author']['login'] == 'ddanila' and [f['path'] for f in pr['files']] == [PROOF]
        blob = json.loads(run(['gh','api',f'repos/{UPSTREAM}/contents/{PROOF}?ref={pr["headRefOid"]}']).stdout)
        assert sha(base64.b64decode(blob['content'])) == context['proof_sha256']
        (STATE/'proof-submission.json').write_text(json.dumps(pr,indent=2)+'\n')
        save('proof_submitted',url=url)
        monitor(url,deadline)
        return
    save('waiting_expired')


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        if STATE.exists():
            save('needs_review',reason=str(e))
        raise
