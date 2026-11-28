"""Check the standalone A265284 statement/proof and independent OEIS simulation."""
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
    statement = (ROOT/'statements/oeis-a265284.lean').read_text()
    proof = (ROOT/'proofs/oeis-a265284.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a265284-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a265284.lean'
        module.parent.mkdir()
        module.write_text(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        p = base/'Proof.lean'
        p.write_text(proof + '\nexample : type_of% @_root_.OMA.S_oeis_a265284.main := _root_.OMA.solution\n#print axioms OMA.solution\n')
        log += run([lean, str(p)], cwd=tmp, env=env)
        found = re.search(r"'OMA.solution' depends on axioms: \[([^\]]*)\]", log)
        assert found, log
        axioms = set(map(str.strip, found[1].split(',')))
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, axioms
        samples = base/'Samples.lean'
        samples.write_text('import OMAStatements.S_oeis_a265284\nopen OMA.S_oeis_a265284\n'
                          'example : (List.range 9).map a = [1,4,8,14,20,28,36,46,56] := by decide\n'
                          'example : (List.range 7).map productCoeff = [1,2,0,0,-1,0,0] := by decide\n')
        log += run([lean, str(samples)], cwd=tmp, env=env)
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    # Check the Boolean statement rule against the numbered Wolfram truth table.
    for left in (0,1):
        for center in (0,1):
            for right in (0,1):
                assert ((94 >> (4*left+2*center+right)) & 1) == int(
                    (left != right) or (not left and center and not right))
    terms = {}
    for line in (HERE/'sources/b265284.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, value = map(int, line.split())
            terms[n] = value
    N = max(terms)
    # Fixed padded infinite-grid simulation, shrinking the trusted interval.
    # Rule 94 leaves an all-OFF exterior OFF at every generation.
    grid = [int(i == 0) for i in range(-2*N, 2*N+1)]
    leftmost = -2*N
    statement_row = [1]
    observations = []
    total = 0
    for n in range(N+1):
        crop = grid[-n-leftmost:n-leftmost+1]
        assert crop == statement_row
        assert sum(grid) == sum(crop)
        if n >= 2:
            k = (n-2)//2
            expected = ([1,1,0] + [1,0]*(2*k) + [1,1] if n % 2 == 0 else
                        [1,1,1,0] + [1,0]*(2*k) + [1,1,1])
            assert crop == expected, n
        total += sum(crop)
        assert total == terms[n], (n,total,terms[n])
        observations.append(total)
        if n < N:
            grid = [(94 >> (4*l+2*c+r)) & 1 for l,c,r in zip(grid,grid[1:],grid[2:])]
            leftmost += 1
            l = c = 0
            out = []
            for r in statement_row + [0,0]:
                out.append(int((l != r) or (not l and c and not r)))
                l,c = c,r
            statement_row = out
    for n in range(1,N+1):
        assert 4*observations[n] == 2*n*n+12*n-(-1)**n+1
        assert 2*observations[n] == n*n+6*n+(n%2)
    for n in range(5,N+1):
        assert observations[n] == 2*observations[n-1]-2*observations[n-3]+observations[n-4]
    for n in range(N+1):
        coeff = observations[n] - (2*observations[n-1] if n>=1 else 0) + (2*observations[n-3] if n>=3 else 0) - (observations[n-4] if n>=4 else 0)
        assert coeff == (1 if n==0 else 2 if n==1 else -1 if n==4 else 0)
    report = dict(terms_checked=len(terms), max_index=N, isolated_proof=True,
                  axioms=sorted(axioms), lean_samples=16, truth_table_cases=8, row_patterns_checked=N-1, exact_target_guard=True,
                  statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
                  proof_sha256=hashlib.sha256(proof.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
