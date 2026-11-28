"""Local source-integrity and independent finite-model checks; not a Lean proof."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent

def simulate(rule, horizon):
    # Evolve a shrinking dependency cone, so no boundary value is guessed.
    radius = 2*horizon
    grid = [[int(x == 0 and y == 0) for y in range(-radius,radius+1)]
            for x in range(-radius,radius+1)]
    counts = []
    for t in range(horizon+1):
        counts.append(sum(sum(row[radius-t:radius+t+1])
                          for row in grid[radius-t:radius+t+1]))
        if t == horizon:
            break
        grid = [[(rule >> (grid[x][y] + 2*(grid[x-1][y]+grid[x+1][y]+
                    grid[x][y-1]+grid[x][y+1]))) & 1
                 for y in range(1,len(grid)-1)] for x in range(1,len(grid)-1)]
        radius -= 1
    return counts

def main():
    for item in json.loads((HERE/'sources/provenance.json').read_text()):
        assert hashlib.sha256((HERE/'sources'/item['file']).read_bytes()).hexdigest() == item['sha256']
    nmax = 6
    counts = {r:simulate(r,2**nmax-1) for r in [833,849,131]}
    sampled = {str(r):[c[2**n-1] for n in range(nmax+1)] for r,c in counts.items()}
    a = sampled['833']
    terms = dict(map(int,line.split()) for line in (HERE/'sources/b273676.txt').read_text().splitlines()
                 if line.strip() and not line.startswith('#'))
    assert a == sampled['849']
    assert a[2:] == sampled['131'][2:]
    for n,v in enumerate(a):
        assert v == terms[n]
        if n>1:
            assert v == 3*4**n-4*2**n+1
        if n>4:
            assert v == 7*a[n-1]-14*a[n-2]+8*a[n-3]
    # Coefficients of the product with (1-X)(1-2X)(1-4X).
    product = [sum(d*a[n-k] for k,d in enumerate([1,-7,14,-8]) if k<=n)
               for n in range(nmax+1)]
    assert product == [1,-3,19,-22,8,0,0]
    report = dict(sampled_counts=sampled,stages_checked=64,matched_bfile_terms=7,
                  generating_function_coefficients=product,
                  scope='finite simulation and source hashes only; no all-n proof or external artifact build')
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__ == '__main__':
    main()
