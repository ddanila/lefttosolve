"""Check the Rule 243 statements agree on dynamics and their tables on base conversion."""
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(args, **kwargs):
    p = subprocess.run(args, text=True, capture_output=True, **kwargs)
    if p.returncode:
        raise RuntimeError(p.stdout + p.stderr)
    return p.stdout


def table(num):
    rows = {}
    for line in (ROOT/f'problems/a{num}/sources/b{num}.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, value = line.split()
            rows[int(n)] = value
    return rows


def main():
    decimal, binary = table(267920), table(267921)
    assert decimal.keys() == binary.keys()
    for n, digits in decimal.items():
        assert set(digits) <= {'0', '1'}
        assert int(digits, 2) == int(binary[n]), n
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT).strip()
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT).strip()
    hashes = {}
    with tempfile.TemporaryDirectory(prefix='rule243-pair-') as tmp:
        folder = Path(tmp)/'OMAStatements'
        folder.mkdir()
        env = dict(os.environ, LEAN_PATH=tmp + os.pathsep + paths)
        log = ''
        for n in [267920, 267921]:
            data = (ROOT/f'statements/oeis-a{n}.lean').read_bytes()
            hashes[str(n)] = hashlib.sha256(data).hexdigest()
            module = folder/f'S_oeis_a{n}.lean'
            module.write_bytes(data)
            log += run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        proof = Path(tmp)/'Pair.lean'
        proof.write_text('''import OMAStatements.S_oeis_a267920
import OMAStatements.S_oeis_a267921

theorem same_state (n : ℕ) :
    OMA.S_oeis_a267920.state n = OMA.S_oeis_a267921.state n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    change OMA.S_oeis_a267920.step (OMA.S_oeis_a267920.state n) =
      OMA.S_oeis_a267921.step (OMA.S_oeis_a267921.state n)
    rw [ih]
    rfl

#print axioms same_state
''')
        log += run([lean, str(proof)], cwd=tmp, env=env)
        found = re.search(r"'same_state' depends on axioms: \[([^\]]*)\]", log)
        if found:
            axioms = set(map(str.strip, found[1].split(',')))
        else:
            assert "'same_state' does not depend on any axioms" in log, log
            axioms = set()
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, log
    report = dict(terms_compared=len(decimal), same_state_proved=True,
                  state_equality_axioms=sorted(axioms), statement_sha256=hashes)
    (ROOT/'reviews/rule243-pair.json').write_text(json.dumps(report,indent=2)+'\n')
    (ROOT/'reviews/rule243-pair-lean.txt').write_text(log.replace(tmp, '<isolated-check>'))
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
