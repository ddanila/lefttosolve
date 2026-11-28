"""Heuristic discovery, NOT the proof. Writes a candidate to the supplied path.

Run: python3 problems/a273539/discover.py /tmp/a273539-machine.json
The archived candidate is independently justified by the Lean certificates.
"""
import argparse
import json
from pathlib import Path
import random


def discover():
    horizon = 2048
    rows = [1]
    history = [rows]
    for t in range(1, horizon+1):
        following = []
        for i in range(t+1):
            a = rows[i] if i < t else 0
            b = rows[i-1] if i > 0 else 0
            c, d = a << 1, b << 1
            # Boolean polynomial e1+e2: true for exactly one or two parents.
            following.append(a ^ b ^ c ^ d ^ (a & b) ^ (a & c) ^ (a & d) ^
                             (b & c) ^ (b & d) ^ (c & d))
        rows = following
        history.append(rows)
    rng = random.Random(273539)
    samples = [(t, i, j) for t in range(5) for i in range(t+2) for j in range(t+2)]
    samples += sorted({(rng.randrange(16), rng.randrange(18), rng.randrange(18))
                       for _ in range(1500)})

    def value(t, i, j):
        return 0 if i > t or j > t else history[t][i] >> j & 1

    def fingerprint(q, a, b, c):
        if q*15+a > horizon:
            raise RuntimeError('Discovery exceeded the simulated horizon')
        return bytes(value(q*t+a, q*i+b, q*j+c) for t, i, j in samples)

    # Residual (q,a,b,c) means D(q*t+a, q*i+b, q*j+c). Equal sample
    # fingerprints suggest a merge; only the later certificate proves it valid.
    states = [(1, 0, 0, 0)]
    indices = {fingerprint(*states[0]): 0}
    transitions = []
    for q, a, b, c in states:
        row = []
        for digit in range(8):
            child = (2*q, a+q*(digit >> 2), b+q*(digit >> 1 & 1), c+q*(digit & 1))
            signature = fingerprint(*child)
            if signature not in indices:
                indices[signature] = len(states)
                states.append(child)
            row.append(indices[signature])
        transitions.append(row)
        if len(states) > 2000:
            raise RuntimeError('Discovery exceeded the candidate-state budget')
    return dict(states=states, trans=transitions,
                outputs=[value(a, b, c) for q, a, b, c in states])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    result = discover()
    args.output.write_text(json.dumps(result)+'\n')
    print(f"Discovered {len(result['states'])} candidate states; kernel certification is separate.")
