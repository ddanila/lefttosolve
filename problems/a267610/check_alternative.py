"""Check the GF-only A267610 adaptation against its exact archived statement."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def run(args, **kwargs):
    p = subprocess.run(args, text=True, capture_output=True, **kwargs)
    if p.returncode:
        raise RuntimeError(p.stdout + p.stderr)
    return p.stdout


def main():
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT).strip()
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT).strip()
    statement = (HERE/'alternatives/ppleskov/statement.lean').read_text()
    proof = (HERE/'alternatives/ppleskov/proof.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a267610-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a267610.lean'
        module.parent.mkdir()
        module.write_text(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        p = base/'Proof.lean'
        p.write_text(proof + '\nexample : type_of% @_root_.OMA.S_oeis_a267610.main := _root_.OMA.solution\n#print axioms OMA.solution\n')
        log += run([lean, str(p)], cwd=tmp, env=env)
        found = re.search(r"'OMA.solution' depends on axioms: \[([^\]]*)\]", log)
        assert found, log
        axioms = set(map(str.strip, found[1].split(',')))
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, axioms
    (HERE/'reviews/ppleskov-lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    (HERE/'reviews/ppleskov-local-check.json').write_text(json.dumps(dict(
        statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
        proof_sha256=hashlib.sha256(proof.encode()).hexdigest(),
        axioms=sorted(axioms), exact_target_guard=True),indent=2)+'\n')
    print("PASS: rival statement, exact target and standard axioms")

if __name__ == "__main__":
    main()
