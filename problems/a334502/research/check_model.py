"""SMT evidence for the discovery model, not a Lean proof. Requires z3-solver."""
import hashlib
import json
from pathlib import Path
import time
import z3

HERE = Path(__file__).resolve().parent
TREE = json.loads((HERE / 'tree.json').read_text())


def features(n, t, x):
    return [n, t, x, n-x, 2*t-n, x-t, x+t-n, 4*x-2*t-n, 4*x-2*t+3*n,
            2*t-3*n, 2*x-n, n%8, (t+x-n)%3, (4*t-x)%12, (4*t-x+n)%12,
            (4*t-x+2*n)%12, (4*t-x+3*n)%12, t%4, x%4,
            (t+x-n/2)%3, (t+x+n/2)%3, (4*t-x-n/2)%12]


def model(n, t, x):
    fs = [z3.simplify(f) for f in features(n, t, x)]

    def visit(node):
        if isinstance(node, bool):
            return z3.BoolVal(node)
        condition = z3.simplify(fs[node['feature']] <= node['threshold'])
        if z3.is_true(condition):
            return visit(node['left'])
        if z3.is_false(condition):
            return visit(node['right'])
        return z3.If(condition, visit(node['left']), visit(node['right']))

    return z3.simplify(visit(TREE))


def query(constraints):
    solver = z3.Solver()
    solver.set(timeout=120000)
    solver.add(*constraints)
    result = solver.check()
    if result != z3.unsat:
        raise RuntimeError(f'{result}: {solver.model() if result == z3.sat else "timeout"}')


def main():
    n, t, x = z3.Ints('n t x')
    common = [n >= 14, t >= 0, x >= 0, x < n]
    endpoints = []
    for name, constraints in [
        ('initial', [t == 0, model(n, t, x) != (x == 0)]),
        ('period_at_12n', [t == 12*n, model(n, t+3, x) != model(n, t, x)]),
        ('not_fixed_at_12n', [t == 12*n, x == 2, model(n, t+1, x) == model(n, t, x)])]:
        query(common + constraints)
        endpoints.append(dict(name=name, result='unsat'))
    N, T, X = z3.Ints('N T X')
    count = 0
    for rn in range(24):
        for rt in range(12):
            for rx in range(12):
                nn, tt, xx = 24*N+rn, 12*T+rt, 12*X+rx
                for place in ['inner', 'left', 'right']:
                    if place == 'left' and rx != 0:
                        continue
                    if place == 'right' and rx != (rn-1)%12:
                        continue
                    left = model(nn, tt, xx-1 if place != 'left' else nn-1)
                    centre = model(nn, tt, xx)
                    right = model(nn, tt, xx+1 if place != 'right' else z3.IntVal(0))
                    rule = z3.Or(z3.And(z3.Not(left), z3.Or(centre, right)),
                                 z3.And(left, z3.Not(centre)))
                    condition = {'inner': [xx > 0, xx < nn-1],
                                 'left': [xx == 0], 'right': [xx == nn-1]}[place]
                    query([nn >= 14, tt >= 0, xx >= 0, xx < nn, *condition,
                           model(nn, tt+1, xx) != rule])
                    count += 1
        print(f'width residue {rn}: {count} update cases checked', flush=True)
    report = dict(status='SMT evidence only; not kernel checked',
                  model_sha256=hashlib.sha256((HERE/'tree.json').read_bytes()).hexdigest(),
                  update_cases=count, failures=[], endpoints=endpoints,
                  division_convention='Euclidean integer division; all divisors positive')
    (HERE.parent/'reviews/symbolic-model.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
