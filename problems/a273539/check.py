"""Check the standalone A273539 statement/proof and independent OEIS simulation."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from certificate import verify

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RULES = [779,795,843,859]


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
    statement = (ROOT/'statements/oeis-a273539.lean').read_text()
    proof = (ROOT/'proofs/oeis-a273539.lean').read_text()
    certificate = verify(proof)
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a273539-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a273539.lean'
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
            'import OMAStatements.S_oeis_a273539\nopen OMA.S_oeis_a273539\n' +
            '\n'.join(
                f'example : (List.range 3).map (fun n => count {r} (2^n-1)) = '
                f'{[1, 5, 37]} := by decide'
                for r in RULES) + '\n')
        log += run([lean, str(samples)], cwd=tmp, env=env)
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    # Independent direct evolution: use the source's reversed binary rule table
    # on a shrinking padded window, updating the infinite background as well.
    N = 63
    observations = {}
    reference_states = []
    for r in RULES:
        table = list(map(int, f'{r:010b}'))
        grid = [[int(x == 0 and y == 0) for y in range(-2*N, 2*N+1)]
                for x in range(-2*N, 2*N+1)]
        counts = []
        for t in range(N+1):
            lower = -2*N+t
            lo, hi = -t-lower, t-lower+1
            crop = [row[lo:hi] for row in grid[lo:hi]]
            counts.append(sum(map(sum, crop)))
            digest = hashlib.sha256(bytes(v for row in grid for v in row)).hexdigest()
            if r == 779:
                reference_states.append(digest)
            else:
                assert digest == reference_states[t], (r, t, 'state mismatch')
            if t > 0 and (t+1)&t == 0:
                off = {(x-t, y-t) for x, row in enumerate(crop)
                       for y, v in enumerate(row) if not v}
                shell = {(x, y) for x in range(-t, t+1) for y in range(-t, t+1)
                         if abs(x)+abs(y) == t}
                assert off == shell and len(off) == 4*t, (r, t)
            if t == N:
                break
            size = len(grid)
            grid = [[table[9-grid[x][y]-2*(grid[x-1][y]+grid[x+1][y]+
                        grid[x][y-1]+grid[x][y+1])]
                     for y in range(1, size-1)] for x in range(1, size-1)]
        observations[r] = counts

    # Independent source-style cyclic grid: bit extraction instead of a string
    # table. Compare crops at EVERY time through the fixed horizon, not just 2^n-1.
    T = 15
    for r in RULES:
        side = 2*T+1
        grid = [[int(x == T and y == T) for y in range(side)] for x in range(side)]
        for t in range(T+1):
            got = sum(sum(row[T-t:T+t+1]) for row in grid[T-t:T+t+1])
            assert got == observations[r][t], (r, t, 'cyclic crop mismatch')
            grid = [[(r >> (grid[x][y]+2*(grid[(x-1)%side][y]+
                        grid[(x+1)%side][y]+grid[x][(y-1)%side]+grid[x][(y+1)%side]))) & 1
                     for y in range(side)] for x in range(side)]

    terms = {}
    for line in (HERE/'sources/b273539.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, v = map(int, line.split())
            terms[n] = v
    assert set(terms) == set(range(16))
    for n, v in terms.items():
        assert v == 5-2**(3+n)+4**(1+n)
        if 2**n-1 <= N:
            for r in RULES:
                assert observations[r][2**n-1] == v
        if n > 2:
            assert v == 7*terms[n-1]-14*terms[n-2]+8*terms[n-3]
        coeff = v-7*terms.get(n-1, 0)+14*terms.get(n-2, 0)-8*terms.get(n-3, 0)
        assert coeff == {0:1, 1:-2, 2:16}.get(n, 0)
    report = dict(isolated_proof=True, axioms=sorted(axioms), certificate=certificate,
        simulated_rules=RULES, simulated_times=list(range(N+1)),
        source_terms_compared_with_simulation=7, source_terms_compared_with_formula=len(terms),
        full_state_alternative_rule_comparisons=3*(N+1),
        diamond_times=[1, 3, 7, 15, 31, 63], cyclic_crop_times=list(range(T+1)), lean_samples=12,
        statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
        proof_sha256=hashlib.sha256(proof.encode()).hexdigest(), proof_bytes=len(proof.encode()))
    (HERE/'reviews/local-check.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
