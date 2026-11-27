"""Run the unmodified official checker in a separate upstream checkout, without a lease."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('platform', type=Path, help='open-math-agents checkout')
    parser.add_argument('formal_conjectures', type=Path, help='pinned checkout with Mathlib cache')
    args = parser.parse_args()
    platform, fc = args.platform.resolve(), args.formal_conjectures.resolve()
    relative = 'statements/oeis-a283508.lean'
    tracked = subprocess.run(['git', 'ls-files', '--error-unmatch', relative],
                             cwd=platform, capture_output=True)
    if tracked.returncode == 0:
        raise RuntimeError('Statement is already tracked upstream: review live status before proceeding.')
    expected = json.loads((platform/'data/catalog.json').read_text())['meta']['upstreamCommit']
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=fc, text=True).strip()
    assert revision == expected, (revision, expected)
    assert (fc/'lean-toolchain').read_bytes() == (ROOT/'lean-toolchain').read_bytes()
    def revisions(base):
        return {p['name']: p['rev'] for p in json.loads((base/'lake-manifest.json').read_text())['packages']}
    assert revisions(fc) == revisions(ROOT)
    shutil.copyfile(ROOT/relative, platform/relative)
    env = dict(os.environ, OMA_FC=str(fc), PATH=str(Path.home()/'.elan/bin')+os.pathsep+os.environ['PATH'])
    # Do not allow a caller's checker override to turn this into a stub.
    env.pop('OMA_CHECK', None)
    result = subprocess.run(['tools/oma.sh', 'check', 'oeis-a283508'], cwd=platform,
                            env=env, text=True, capture_output=True)
    print(result.stdout, end='')
    print(result.stderr, end='')
    verdict = json.loads((platform/'.oma/verdict.json').read_text())
    report = dict(verdict=verdict, statement_sha256=hashlib.sha256((ROOT/relative).read_bytes()).hexdigest(),
                  platform_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=platform,text=True).strip(),
                  formal_conjectures_commit=revision, lean=(fc/'lean-toolchain').read_text().strip(),
                  dependencies=revisions(fc), command='tools/oma.sh check oeis-a283508',
                  lease_required=False)
    (ROOT/'reviews/official-check.json').write_text(json.dumps(report,indent=2)+'\n')
    if result.returncode or verdict['verdict'] != 'accepted':
        raise SystemExit(result.returncode or 1)


if __name__ == '__main__':
    main()
