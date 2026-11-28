"""Check the standalone A273385 statement/proof and independent OEIS simulation."""
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
RULES = [659,667,723,731,931,939,947,955,995,1003,1011,1019]


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
    statement = (ROOT/'statements/oeis-a273385.lean').read_text()
    proof = (ROOT/'proofs/oeis-a273385.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a273385-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a273385.lean'
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
        samples.write_text(
            'import OMAStatements.S_oeis_a273385\nopen OMA.S_oeis_a273385\n' +
            '\n'.join(
                f'example : (List.range 3).map (fun n => count {r} (2^n-1)) = '
                f'{[1, 8, 49] if r == 5 else [1, 5, 49]} := by decide'
                for r in RULES + [5]) + '\n')
        log += run([lean, str(samples)], cwd=tmp, env=env)
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    # Direct local evolution in a shrinking valid window. At t <= N the
    # initial margin 2N still contains the full source crop [-t,t]^2.
    # All background cells evolve. No closed form is used to compute states.
    N = 31
    observations = {}
    for rule_number in RULES + [5]:
        table = list(map(int, f'{rule_number:010b}'))
        grid = [[int(x == 0 and y == 0) for y in range(-2*N,2*N+1)]
                for x in range(-2*N,2*N+1)]
        counts = []
        for t in range(N+1):
            lower = -2*N+t
            lo, hi = -t-lower, t-lower+1
            counts.append(sum(sum(row[lo:hi]) for row in grid[lo:hi]))
            if t == N:
                break
            size = len(grid)
            grid = [[table[9-grid[x][y]-2*(grid[x-1][y]+grid[x+1][y]+
                                          grid[x][y-1]+grid[x][y+1])]
                     for y in range(1,size-1)] for x in range(1,size-1)]
        observations[rule_number] = counts
        for t in range(3,N+1):
            expected = 0 if rule_number == 5 and t % 2 == 0 else (2*t+1)**2
            assert counts[t] == expected, (rule_number,t,counts[t],expected)
        assert counts[:2] == ([1,8] if rule_number == 5 else [1,5])

    # Reproduce the reference program's fixed cyclic grid independently and
    # compare every crop with the infinite-grid simulation, including its edge.
    T = 15
    for r in RULES + [5]:
        size = 2*T+1
        grid = [[int(x==T and y==T) for y in range(size)] for x in range(size)]
        for t in range(T+1):
            got = sum(sum(row[T-t:T+t+1]) for row in grid[T-t:T+t+1])
            assert got == observations[r][t], (r,t,'cyclic crop mismatch')
            grid = [[(r >> (grid[x][y]+2*(grid[(x-1)%size][y]+
                         grid[(x+1)%size][y]+grid[x][(y-1)%size]+
                         grid[x][(y+1)%size]))) & 1
                     for y in range(size)] for x in range(size)]

    terms = {}
    for line in (HERE/'sources/b273385.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, value = map(int,line.split())
            terms[n] = value
    assert set(terms) == set(range(16))
    for n,value in terms.items():
        assert value == (1 if n == 0 else 5 if n == 1 else (2**(n+1)-1)**2)
        if 2**n-1 <= N:
            for r in RULES:
                assert observations[r][2**n-1] == value
            if n >= 2:
                assert observations[5][2**n-1] == value
        if n >= 2:
            assert value == 4*4**n-4*2**n+1
        if n > 4:
            assert value == 7*terms[n-1]-14*terms[n-2]+8*terms[n-3]
        coeff = value-7*terms.get(n-1,0)+14*terms.get(n-2,0)-8*terms.get(n-3,0)
        assert coeff == {0:1,1:-2,2:28,3:-56,4:32}.get(n,0)
    report = dict(isolated_proof=True, axioms=sorted(axioms),
                  simulated_rules=RULES+[5], simulated_times=list(range(N+1)),
                  source_terms_compared_with_simulation=6,
                  source_terms_compared_with_formula=len(terms),
                  cyclic_crop_times=list(range(T+1)), lean_samples=39,
                  statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
                  proof_sha256=hashlib.sha256(proof.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
