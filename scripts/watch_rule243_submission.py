#!/usr/bin/env python3
"""Finish the two authorized Rule 243 proof submissions after the desk recovers.

Runs in an isolated platform clone. Public status contains no lease credentials.
Stops each task after a verified proof PR or an unexpected submission/check error.
Use --check-only for read-only validation; --run watches for up to 24 hours.
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
STATE = ROOT / '.oma/rule243-watch'
PLATFORM = STATE / 'platform'
UPSTREAM = 'GuillaumeBAUD-coder/open-math-agents'
FORK = 'ddanila/open-math-agents'
PIN = '9097e2f90e66d2f6244209cb1c07f7120d17ec53'
HASHES = {
    '267920': ('bd414fdb4120fff7da2dcf0423627b5620cb121348a553d187c5868d2ad4da62',
               'f54bdcae0a996d52712f5c45584b1dad54f3174655a346eaf004f9c66a40acfe'),
    '267921': ('60be3d94c9ffc78e86068353b69c50da6af16ed4f279ccaaf2b6d27ca8ec0607',
               'd6d4e56f5bc9776150bc84e7de2676bc6d4aa072806bdeda0c92120651405fff'),
}
ENV = {**os.environ, 'OMA_AGENT': 'codex', 'OMA_MODEL': 'gpt-6',
       'OMA_FC': '/tmp/lefttosolve-formal-conjectures',
       'PATH': str(Path.home() / '.elan/bin') + ':' + os.environ['PATH']}


def run(args, cwd=PLATFORM, timeout=180, required=True):
    p = subprocess.run(args, cwd=cwd, env=ENV, text=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    if required and p.returncode:
        # Output can contain credentials. Keep it private, never in public status.
        (STATE / 'last-command-private.log').write_text(p.stdout)
        raise RuntimeError(f'{args[0]} command failed (exit {p.returncode}); inspect private log')
    return p


def verify_files(n, directory):
    for folder, expected in zip(('statements', 'proofs'), HASHES[n]):
        p = directory / folder / f'oeis-a{n}.lean'
        if hashlib.sha256(p.read_bytes()).hexdigest() != expected:
            raise RuntimeError(f'{folder} file for A{n} differs from reviewed hash')


def preflight():
    for n in HASHES:
        verify_files(n, ROOT)
        check = json.loads((ROOT / f'problems/a{n}/reviews/merged-proof-check.json').read_text())
        if check['verdict'] != 'accepted':
            raise RuntimeError(f'No accepted merged-target check for A{n}')
    if run(['git', 'rev-parse', 'HEAD'], cwd=Path(ENV['OMA_FC'])).stdout.strip() != PIN:
        raise RuntimeError('Local formal-conjectures checkout moved from the reviewed pin')
    if run(['gh', 'api', 'user', '--jq', '.login'], cwd=ROOT).stdout.strip() != 'ddanila':
        raise RuntimeError('GitHub account is not ddanila')


def prepare():
    if not (PLATFORM / '.git').exists():
        run(['git', 'clone', '--no-hardlinks', str(ROOT / '.oma/platform'), str(PLATFORM)], cwd=ROOT)
        run(['git', 'remote', 'set-url', 'origin', f'https://github.com/{FORK}.git'])
        run(['git', 'remote', 'add', 'upstream', f'https://github.com/{UPSTREAM}.git'])
    run(['git', 'fetch', 'upstream', 'main'])
    run(['git', 'checkout', '--detach', 'upstream/main'])
    run(['git', 'fetch', 'origin'])
    run(['git', 'remote', 'set-head', 'origin', 'main'])
    for n in HASHES:
        dest = PLATFORM / f'proofs/oeis-a{n}.lean'
        if run(['git', 'ls-files', '--error-unmatch', str(dest.relative_to(PLATFORM))], required=False).returncode:
            shutil.copyfile(ROOT / f'proofs/oeis-a{n}.lean', dest)


def verified_pr(n, url):
    p = json.loads(run(['gh', 'pr', 'view', url, '--json',
                       'number,url,state,headRefOid,files,author']).stdout)
    filename = f'proofs/oeis-a{n}.lean'
    if p['author']['login'] != 'ddanila' or [x['path'] for x in p['files']] != [filename]:
        raise RuntimeError('Unexpected author or changed files in proof PR')
    blob = json.loads(run(['gh', 'api', f'repos/{UPSTREAM}/contents/{filename}?ref={p["headRefOid"]}']).stdout)
    if base64.b64decode(blob['content']) != (ROOT / filename).read_bytes():
        raise RuntimeError('Remote proof differs from checked file')
    p.update(remote_file_matches=True, source_sha256=HASHES[n][1])
    (STATE / f'a{n}-proof-submission.json').write_text(json.dumps(p, indent=2) + '\n')
    return p


def submit(n, state, save):
    problem = f'oeis-a{n}'
    # The client preserves our files and prints no lease token. Capture everything anyway.
    claim = run(['tools/oma.sh', 'next', '--problem', problem], required=False)
    if claim.returncode:
        state[n] = {'phase': 'waiting_for_lease', 'last_attempt_utc': now()}
        save()
        return
    state[n] = {'phase': 'lease_acquired', 'at_utc': now()}
    save()
    (STATE / f'a{n}-lease-output-private.log').write_text(claim.stdout)
    # Preserve and read the returned coordination context before proceeding.
    brief = PLATFORM / f'.oma/briefs/{problem}.txt'
    if not brief.exists() or not brief.read_text().strip():
        raise RuntimeError('Desk did not supply a problem brief')
    # Verify the lease was issued for the requested problem, not a random task.
    if not (PLATFORM / f'.oma/leases/{problem}').exists() or problem not in claim.stdout:
        raise RuntimeError('Lease response did not match requested problem')
    # Any teammates/notes require contextual review instead of blindly racing them.
    note_authors = re.findall(r'--- #\d+ @([A-Za-z0-9-]+)', claim.stdout)
    if 'none right now' not in claim.stdout or any(a != 'ddanila' for a in note_authors):
        raise RuntimeError('Coordination notes or teammates need review; lease retained')
    run(['git', 'fetch', 'upstream', 'main'])
    run(['git', 'checkout', '--detach', 'upstream/main'])
    if run(['git', 'ls-files', '--error-unmatch', f'proofs/{problem}.lean'], required=False).returncode == 0:
        raise RuntimeError('A proof is already on upstream main; review needed')
    verify_files(n, PLATFORM)
    if json.loads((PLATFORM / 'data/catalog.json').read_text())['meta']['upstreamCommit'] != PIN:
        raise RuntimeError('Platform dependency pin changed; review needed')
    run(['git', 'push', 'origin', 'upstream/main:main'])
    verdict = STATE / f'a{n}-final-proof-check.json'
    run(['tools/check.sh', f'proofs/{problem}.lean', str(verdict)], timeout=2400)
    if json.loads(verdict.read_text())['verdict'] != 'accepted':
        raise RuntimeError('Official merged-target proof check did not accept')
    run(['tools/oma.sh', 'beat', problem])
    note = STATE / f'a{n}-proof-plan.txt'
    note.write_text(f'PLAN: Submit our complete published proof for A{n} against the unchanged merged statement. '
                    'The official checker accepted the exact merged target. Independent statement review and all '
                    '1,001 source terms passed. The proof establishes the Rule 243 moving-hole invariant, recurrence, '
                    'and generating function. Public provenance: https://github.com/ddanila/lefttosolve/commit/428b761 .\n')
    run(['tools/oma.sh', 'note', problem, str(note)])
    state[n] = {'phase': 'submitting', 'at_utc': now()}
    save()  # An interrupted submission must never be retried blindly.
    sent = run(['tools/oma.sh', 'submit', problem], timeout=2400, required=False)
    (STATE / f'a{n}-submit-private.log').write_text(sent.stdout)
    urls = re.findall(r'https://github\.com/GuillaumeBAUD-coder/open-math-agents/pull/\d+', sent.stdout)
    if not urls:
        raise RuntimeError('Submission returned no PR URL; inspect GitHub before retrying')
    p = verified_pr(n, urls[-1])
    state[n] = {'phase': 'proof_submitted', 'url': p['url'], 'at_utc': now()}
    save()


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-only', action='store_true')
    parser.add_argument('--run', action='store_true')
    args = parser.parse_args()
    if args.check_only == args.run:
        parser.error('choose --check-only or --run')
    os.umask(0o077)
    STATE.mkdir(parents=True, exist_ok=True)
    preflight()
    if args.check_only:
        print('Reviewed file hashes, accepted merged checks, and GitHub identity verified.')
        return
    lock = (STATE / 'watch.lock').open('w')
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    (STATE / 'pid').write_text(str(os.getpid()) + '\n')
    status = STATE / 'status.json'
    state = json.loads(status.read_text()) if status.exists() else {}

    def save():
        tmp = STATE / 'status.tmp'
        tmp.write_text(json.dumps(state, indent=2) + '\n')
        tmp.replace(status)
        print(now(), json.dumps(state), flush=True)

    prepare()
    deadline = time.monotonic() + 24 * 3600
    while time.monotonic() < deadline:
        pending = [n for n in HASHES if state.get(n, {}).get('phase') not in
                   ('proof_submitted', 'needs_review', 'submitting')]
        if not pending:
            break
        for n in pending:
            try:
                submit(n, state, save)
            except Exception as e:
                state[n] = {'phase': 'needs_review', 'reason': str(e), 'at_utc': now()}
                save()
            time.sleep(60)  # At most one lease request per minute across the pair.
    else:
        state['watch'] = {'phase': 'expired_after_24h', 'at_utc': now()}
        save()


if __name__ == '__main__':
    main()
