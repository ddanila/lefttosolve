"""Check the standalone A071052 statement/proof and independent OEIS simulation."""
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
    statement = (ROOT/'statements/oeis-a071052.lean').read_text()
    proof = (ROOT/'proofs/oeis-a071052.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a071052-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a071052.lean'
        module.parent.mkdir()
        module.write_text(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        p = base/'Proof.lean'
        p.write_text(proof + '\nexample : type_of% @_root_.OMA.S_oeis_a071052.main := _root_.OMA.solution\n#print axioms OMA.solution\n')
        log += run([lean, str(p)], cwd=tmp, env=env)
        found = re.search(r"'OMA.solution' depends on axioms: \[([^\]]*)\]", log)
        assert found, log
        axioms = set(map(str.strip, found[1].split(',')))
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, axioms
        samples = base/'Samples.lean'
        samples.write_text('import OMAStatements.S_oeis_a071052\nopen OMA.S_oeis_a071052\n'
                          'example : (List.range 5).map zeroCount = [0,0,2,2,6] := by decide\n'
                          'example : cell 3 (-1) = false ∧ cell 3 7 = false := by decide\n')
        log += run([lean, str(samples)], cwd=tmp, env=env)
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    terms = {}
    for line in (HERE/'sources/b071052.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, value = map(int, line.split())
            terms[n] = value
    # Independent Wolfram-number truth table, using a padded trusted interval.
    for l in (0,1):
        for c in (0,1):
            for r in (0,1):
                assert ((150 >> (4*l+2*c+r)) & 1) == (l ^ c ^ r)
    N = 256
    grid = [int(i==0) for i in range(-2*N,2*N+1)]
    leftmost = -2*N
    rows, counts = [], []
    def polymul(a,b):
        out = 0
        while b:
            if b & 1:
                out ^= a
            a <<= 1
            b >>= 1
        return out
    def polynomial_row(n):
        result, base = 1, 0b111
        while n:
            if n & 1:
                result = polymul(result,base)
            base = polymul(base,base)
            n >>= 1
        return result
    for n in range(N+1):
        crop = grid[-n-leftmost:n-leftmost+1]
        bits = polynomial_row(n)
        assert crop == [(bits >> i) & 1 for i in range(2*n+1)]
        assert sum(crop) == sum(grid)
        zeros = len(crop)-sum(crop)
        if n in terms:
            assert zeros == terms[n], (n,zeros,terms[n])
        rows.append(crop)
        counts.append(zeros)
        if n < N:
            grid = [(150 >> (4*l+2*c+r)) & 1 for l,c,r in zip(grid,grid[1:],grid[2:])]
            leftmost += 1
    for n in range(N//2+1):
        assert rows[2*n][::2] == rows[n]
        assert all(x==0 for x in rows[2*n][1::2])
        assert counts[2*n] == counts[n]+2*n
    report = dict(terms_checked=len(terms), max_index=max(terms), simulated_through=N, doubling_cases=N//2+1, isolated_proof=True,
                  axioms=sorted(axioms), lean_samples=7, truth_table_cases=8, polynomial_rows_checked=N+1, exact_target_guard=True,
                  statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
                  proof_sha256=hashlib.sha256(proof.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
