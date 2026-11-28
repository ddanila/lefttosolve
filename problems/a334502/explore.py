"""Reproducible experiments, not a proof for unbounded widths."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def step(n, w):
    mask = (1 << n) - 1
    left = ((w << 1) | (w >> (n-1))) & mask
    right = ((w >> 1) | (w << (n-1))) & mask
    return ((~left & (w | right)) | (left & ~w)) & mask


def table_step(n, w):
    # Independently evaluate the Wolfram truth table at each labelled site.
    return sum(((62 >> (4*((w >> ((i-1) % n)) & 1) +
                             2*((w >> i) & 1) + ((w >> ((i+1) % n)) & 1))) & 1) << i
               for i in range(n))


def expected(n):
    if n <= 3:
        return 1
    return {4: 8, 5: 5, 7: 14, 13: 26}.get(n, 3)


def orbit(n):
    seen, w, t = {}, 1, 0
    while w not in seen:
        assert t <= 4*n+100, ('experiment horizon exceeded', n, t)
        seen[w] = t
        v = step(n, w)
        if n <= 64:
            assert v == table_step(n, w)
        w, t = v, t+1
    return seen[w], t-seen[w]


def predicted_entry(n):
    # Empirical formula only. This is not needed by any Lean theorem yet.
    return [n//2-1, 3*(n-1)//2, n//2-2, (n-5)//2,
            3*n//2+3, (3*n+29)//2, n//2, (3*n+15)//2][n % 8]


def main():
    data = [[n, *orbit(n)] for n in range(1, 1501)]
    for n, transient, period in data:
        assert period == expected(n), (n, transient, period)
        if n >= 14:
            assert transient == predicted_entry(n), (n, transient)
    terms = dict(map(int, line.split()) for line in (HERE/'sources/b334502.txt').read_text().splitlines()
                 if line.strip() and not line.startswith('#'))
    assert max(terms) <= 1500
    for n, value in terms.items():
        assert data[n-1][2] == value
    report = dict(status='finite_experiment_only', widths=[1, 1500],
        independent_truth_table_widths=[1, 64], oeis_terms_checked=len(terms),
        first_orbits=data[:40], all_orbits_sha256=hashlib.sha256(json.dumps(data).encode()).hexdigest(),
        entry_time_formula_checked=[14, 1500], universal_claim_proved=False)
    (HERE/'reviews/simulation.json').write_text(json.dumps(report, indent=2)+'\n')
    print('PASS: widths 1..1500; finite evidence only')


if __name__ == '__main__':
    main()
