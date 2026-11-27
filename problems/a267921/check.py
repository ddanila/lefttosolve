"""Check the standalone A267921 statement/proof and independent OEIS simulation."""
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
    for item in json.loads((HERE/'sources/provenance.json').read_text()):
        assert hashlib.sha256((HERE/'sources'/item['file']).read_bytes()).hexdigest() == item['sha256']
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT).strip()
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT).strip()
    statement = (ROOT/'statements/oeis-a267921.lean').read_text()
    proof = (ROOT/'proofs/oeis-a267921.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a267921-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a267921.lean'
        module.parent.mkdir()
        module.write_text(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        p = base/'Proof.lean'
        p.write_text(proof + '\n#print axioms OMA.solution\n')
        log += run([lean, str(p)], cwd=tmp, env=env)
        found = re.search(r"'OMA.solution' depends on axioms: \[([^\]]*)\]", log)
        assert found, log
        axioms = set(map(str.strip, found[1].split(',')))
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, axioms
        samples = base/'Samples.lean'
        samples.write_text('import OMAStatements.S_oeis_a267921\nopen OMA.S_oeis_a267921\n'
                          'example : (List.range 5).map a = [1,5,29,125,509] := by decide\n')
        log += run([lean, str(samples)], cwd=tmp, env=env)
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    # Direct truth-table evolution, with a shrinking valid window. Starting with
    # margin 2N leaves the entire crop [-n,n] valid through time N. No conjectured
    # pattern or recurrence is used to produce the simulated observations.
    terms = {}
    for line in (HERE/'sources/b267921.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, a = map(int, line.split())
            terms[n] = a
    N = max(terms)
    row = [int(i == 0) for i in range(-2*N, 2*N+1)]
    left = -2*N
    observations = []
    for n in range(N+1):
        crop = row[-n-left:n-left+1]
        value = 0
        for bit in crop:
            value = 2*value + bit
        assert value == terms[n], (n, value, terms[n])
        observations.append(value)
        if n < N:
            row = [(243 >> (4*l+2*c+r)) & 1 for l,c,r in zip(row,row[1:],row[2:])]
            left += 1
    # Independently check the conjectured recurrence and all available product coefficients.
    for n in range(3,N+1):
        assert observations[n] == 5*observations[n-1]-4*observations[n-2]
    for n in range(N+1):
        coeff = observations[n] - (5*observations[n-1] if n>=1 else 0) + (4*observations[n-2] if n>=2 else 0)
        assert coeff == (1 if n==0 else 8 if n==2 else 0)
    report = dict(terms_checked=len(terms), max_index=N, isolated_proof=True,
                  axioms=sorted(axioms), lean_samples=5,
                  statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
                  proof_sha256=hashlib.sha256(proof.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
