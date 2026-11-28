"""Validate finite witnesses and their exact Lean table rendering.

This Python check is diagnostic. The universal proof is Lean's kernel-checked
closure induction, followed by the bridge to the source cellular automaton.
"""
import json
from functools import lru_cache
from pathlib import Path

HERE = Path(__file__).resolve().parent


def tree(values, start=0):
    """Balanced lookup keeps kernel evaluation logarithmic in table length."""
    if len(values) == 1:
        return values[0]
    mid = len(values) // 2
    return (f'(if k < {start+mid} then {tree(values[:mid], start)} '
            f'else {tree(values[mid:], start+mid)})')


def term(v):
    s, mask, t, i, j = v
    return '⟨' + ','.join([str(s)] + ['true' if mask >> b & 1 else 'false'
                                     for b in [2, 1, 0]] + list(map(str, [t, i, j]))) + '⟩'


def verify(proof):
    d = json.loads((HERE/'data/certificate.json').read_text())
    tr, out = d['trans'], d['outputs']
    discovered = json.loads((HERE/'data/discovered-automaton.json').read_text())
    assert tr[:87] == discovered['trans'] and out[:87] == discovered['outputs']
    assert len(tr) == len(out) == 90
    assert all(len(row) == 8 and all(0 <= v < 90 for v in row) for row in tr)
    assert all(out[tr[s][0]] == out[s] for s in range(90))

    @lru_cache(None)
    def ev(s, t, i, j):
        if t+i+j == 0:
            return out[s]
        return ev(tr[s][4*(t%2)+2*(i%2)+j%2], t//2, i//2, j//2)

    def advance(term, digit):
        s, mask, t, i, j = term
        v = [((digit >> b & 1) if mask >> b & 1 else 0) + offset
             for b, offset in zip([2, 1, 0], [t, i, j])]
        return [tr[s][4*(v[0]%2)+2*(v[1]%2)+v[2]%2], mask, *(x//2 for x in v)]

    assert len(d['certificates']) == len(d['next']) == 451
    for k, (kind, terms) in enumerate(d['certificates']):
        vals = [ev(s, t, i, j) for s, mask, t, i, j in terms]
        assert vals[0] == (vals[1] and vals[2] if kind else sum(vals[1:]) in (1, 2))
        assert len(d['next'][k]) == 8
        for b, target in enumerate(d['next'][k]):
            assert d['certificates'][target] == [kind, [advance(v, b) for v in terms]]
    assert len(d['boundary']) == len(d['boundary_next']) == 10
    for k, (s, zi, oi, zj, oj) in enumerate(d['boundary']):
        assert out[s] == bool(zi or oi or zj or oj)
        for bi in range(2):
            for bj in range(2):
                target = d['boundary_next'][k][2*bi+bj]
                assert d['boundary'][target] == [tr[s][4+2*bi+bj], zi and bi==0,
                    oi and bi==1, zj and bj==0, oj and bj==1]

    tables = {
        'transitions': ('ℕ', [str(x) for row in tr for x in row]),
        'outputs': ('Bool', ['true' if x else 'false' for x in out]),
        'certificates': ('Certificate', ['⟨'+('true' if k else 'false')+','+
            ','.join(term(t) for t in ts)+'⟩' for k, ts in d['certificates']]),
        'certificateTransitions': ('ℕ', [str(x) for row in d['next'] for x in row]),
    }
    for name, (typ, values) in tables.items():
        expected = f'private def {name} (k : ℕ) : {typ} :=\n  {tree(values)}\n'
        assert expected in proof, f'Lean table differs from certificate: {name}'
    return dict(machine_states=90, discovered_states=87, recurrence_certificates=451,
                closure_transitions=3608, boundary_states=10, kernel_closure_block_rows=32)


if __name__ == '__main__':
    print(json.dumps(verify((HERE.parents[1]/'proofs/oeis-a273539.lean').read_text()), indent=2))
