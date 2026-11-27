"""Independent source-based Rule 187 centre-column check; no project imports."""
from pathlib import Path


def main():
    source = Path(__file__).resolve().parents[1] / 'sources' / 'b267623.txt'
    expected = dict(tuple(map(int, line.split())) for line in source.read_text().splitlines()
                    if line.strip() and not line.lstrip().startswith('#'))
    assert set(expected) == set(range(1001))
    # Wolfram neighborhoods ordered 111,110,...,000.
    table = {tuple(map(int, f'{i:03b}')): int('10111011'[7-i]) for i in range(8)}
    standard = reflected = {0: 1}
    background = 0
    decimal_digits = 0
    values = []
    for n in range(1001):
        assert standard[0] == reflected[0]
        decimal_digits = 10 * decimal_digits + standard[0]
        assert decimal_digits == expected[n], n
        values.append(decimal_digits)
        standard = {x: table[tuple(standard.get(y, background) for y in (x-1,x,x+1))]
                    for x in range(-n-1,n+2)}
        reflected = {x: table[tuple(reflected.get(y, background) for y in (x+1,x,x-1))]
                     for x in range(-n-1,n+2)}
        background = table[(background,)*3]
    for n, value in enumerate(values):
        coefficient = value - (11*values[n-1] if n>=1 else 0) + (10*values[n-2] if n>=2 else 0)
        assert coefficient == {0:1,1:-1,2:1}.get(n,0), n
    print('PASS: 1001 source terms, reflected-centre agreement, and GF coefficients.')


if __name__ == '__main__':
    main()
