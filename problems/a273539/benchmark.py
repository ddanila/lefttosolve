"""Measure isolated proof compilation for A273385 and A273539 on this host.

Uses /usr/bin/time (Darwin -l or GNU -v). Prints JSON; no tracked report is changed.
These are host measurements, not a GitHub-runner memory-cap test.
"""
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def run(args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()


def main():
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT)
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT)
    darwin = platform.system() == 'Darwin'
    report = dict(host_system=platform.system(), host_machine=platform.machine(),
                  lean=run([lean, '--version']), capped_memory_test=False, proofs={})
    with tempfile.TemporaryDirectory(prefix='a273539-resources-') as tmp:
        for problem in ['a273385', 'a273539']:
            folder = Path(tmp)/problem
            module = folder/'OMAStatements'/f'S_oeis_{problem}.lean'
            module.parent.mkdir(parents=True)
            statement = (ROOT/'statements'/f'oeis-{problem}.lean').read_bytes()
            proof = (ROOT/'proofs'/f'oeis-{problem}.lean').read_bytes()
            module.write_bytes(statement)
            p = folder/'Proof.lean'
            p.write_bytes(proof+b'\n#print axioms OMA.solution\n')
            env = dict(os.environ, LEAN_PATH=paths)
            run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=folder, env=env)
            env['LEAN_PATH'] = str(folder)+os.pathsep+paths
            result = subprocess.run(['/usr/bin/time', '-l' if darwin else '-v', lean, str(p)],
                                    cwd=folder, env=env, text=True, capture_output=True, check=True)
            assert 'sorryAx' not in result.stdout
            pattern = r'(\d+)\s+maximum resident set size' if darwin else r'Maximum resident set size \(kbytes\):\s*(\d+)'
            rss = int(re.search(pattern, result.stderr)[1]) * (1 if darwin else 1024)
            report['proofs'][problem] = dict(peak_rss_bytes=rss, proof_bytes=len(proof),
                proof_sha256=hashlib.sha256(proof).hexdigest(),
                statement_sha256=hashlib.sha256(statement).hexdigest(),
                timing=result.stderr.strip(), axiom_report=result.stdout.strip())
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
