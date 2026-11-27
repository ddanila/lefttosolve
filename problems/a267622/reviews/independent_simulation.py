"""Independent Rule 187 simulation for the statement review; no project imports."""

from pathlib import Path


def main() -> None:
    source = Path(__file__).resolve().parents[1] / "sources" / "b267622.txt"
    expected = {
        int(n): int(value)
        for line in source.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
        for n, value in [line.split()]
    }
    assert set(expected) == set(range(1001)), "Expected archived indices 0..1000"

    # Independent finite window with exact evolving uniform exterior.
    # Wolfram's displayed bit string lists neighborhoods 111 down to 000.
    lookup = {
        tuple(map(int, f"{i:03b}")): int("10111011"[7 - i])
        for i in range(8)
    }
    row = {0: 1}
    exterior = 0
    values = []
    for t in range(max(expected) + 1):
        value = int("".join(str(row[x]) for x in range(-t, t + 1)))
        assert value == expected[t], (t, value, expected[t])
        values.append(value)
        row = {
            x: lookup[tuple(row.get(y, exterior) for y in (x - 1, x, x + 1))]
            for x in range(-t - 1, t + 2)
        }
        exterior = lookup[(exterior, exterior, exterior)]

    for n in range(len(values)):
        coefficient = (
            values[n]
            - (101 * values[n - 1] if n >= 1 else 0)
            + (100 * values[n - 2] if n >= 2 else 0)
        )
        assert coefficient == {0: 1, 2: 10}.get(n, 0), n
    print(
        f"Independent truth-table simulation matches {len(values)} OEIS terms "
        "and GF coefficient identity over entire range."
    )


if __name__ == "__main__":
    main()
