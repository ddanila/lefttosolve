"""Check the standalone A267610 statement/proof and independent OEIS simulation."""
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
    statement = (ROOT/'statements/oeis-a267610.lean').read_text()
    proof = (ROOT/'proofs/oeis-a267610.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', proof)
    with tempfile.TemporaryDirectory(prefix='a267610-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a267610.lean'
        module.parent.mkdir()
        module.write_text(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        p = base/'Proof.lean'
        p.write_text(proof + '\nexample : type_of% @_root_.OMA.S_oeis_a267610.main := _root_.OMA.solution\n#print axioms OMA.solution\n')
        log += run([lean, str(p)], cwd=tmp, env=env)
        found = re.search(r"'OMA.solution' depends on axioms: \[([^\]]*)\]", log)
        assert found, log
        axioms = set(map(str.strip, found[1].split(',')))
        assert axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, axioms
    (HERE/'reviews/lean-check.txt').write_text(log.replace(tmp, '<isolated-check>'))

    def terms(name):
        return dict(map(int,line.split()) for line in (HERE/'sources'/name).read_text().splitlines()
                    if line.strip() and not line.startswith('#'))
    ca_terms, tree_terms, pascal_terms = map(terms,['b267610.txt','b267700.txt','b006046.txt'])
    limit = max(ca_terms)
    row, total, values = [1], 0, []
    crops = []
    for n in range(limit+1):
        assert row.count(0)+2 == 2**bin(n+1).count('1')
        total += row.count(0)
        values.append(total)
        if n<3: crops.append(''.join(map(str,row)))
        assert total == ca_terms[n], (n,total,ca_terms[n])
        padded=[0,0]+row+[0,0]
        row=[(182 >> (4*l+2*c+r)) & 1 for l,c,r in zip(padded,padded[1:],padded[2:])]
    # Independently enumerate positive binary-subset pairs for the tree sequence.
    for n,expected in tree_terms.items():
        pairs=sum(1 for j in range(1,n+1) for i in range(1,j+1) if i & j == i)
        assert pairs == expected == sum(2**bin(k).count('1')-1 for k in range(n+1))
    running = 0
    for n in range(max(pascal_terms)+1):
        assert running == pascal_terms[n]
        running += 2**bin(n).count('1')
    # Check the GF after clearing denominators, through the simulated horizon.
    def at(xs,n): return xs[n] if n>=0 else 0
    for n in range(limit+1):
        lhs=at(values,n-2)-2*at(values,n-3)+at(values,n-4)
        rhs=at(pascal_terms,n)-2*at(pascal_terms,n-1)+at(pascal_terms,n-2)-int(n in [1,2])
        assert lhs==rhs,(n,lhs,rhs)
    for n in range(limit+1):
        b=sum(2**bin(k).count('1')-1 for k in range(n+2))
        assert values[n]==b-(n+1)
    assert values[2]==2 and tree_terms[2]-2==0
    report=dict(ca_terms_checked=len(ca_terms),tree_terms_checked=len(tree_terms),
                pascal_terms_checked=len(pascal_terms),first_crops=crops,
                printed_relation_counterexample=dict(n=2,lhs=values[2],rhs=tree_terms[2]-2),
                gf_coefficients_checked=limit+1,shifted_relation_tested_through=limit,
                shifted_relation_proved=True, row_count_proved=True, generating_function_proved=True,axioms=sorted(axioms),exact_target_guard=True,
                statement_sha256=hashlib.sha256(statement.encode()).hexdigest(),
                proof_sha256=hashlib.sha256(proof.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__ == "__main__":
    main()
