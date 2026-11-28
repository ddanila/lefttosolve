"""Validate local reductions; success does NOT mean the open target is proved."""
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
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT).strip()
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT).strip()
    statement = (HERE/'sources/statement.lean').read_bytes()
    lemmas = (HERE/'lemmas.lean').read_text()
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement.decode()) == ['sorry']
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', lemmas)
    declarations = ['return_at_cycle', 'period_eq', 'small_values', 'expected_gf',
                    'target_of_largeCycles']
    with tempfile.TemporaryDirectory(prefix='a334502-check-') as tmp:
        base = Path(tmp)
        module = base/'OMAStatements/S_oeis_a334502.lean'
        module.parent.mkdir()
        module.write_bytes(statement)
        env = dict(os.environ, LEAN_PATH=paths)
        log = run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        env['LEAN_PATH'] = tmp + os.pathsep + paths
        proof = base/'Lemmas.lean'
        proof.write_text(lemmas + '\nexample : A334502Local.LargeCycles → '
            'type_of% @_root_.OMA.S_oeis_a334502.main := '
            '_root_.A334502Local.target_of_largeCycles\n' +
            '\n'.join('#print axioms A334502Local.' + name for name in declarations) + '\n')
        log += run([lean, str(proof)], cwd=tmp, env=env)
        all_axioms = set()
        for name in declarations:
            found = re.search(r"'A334502Local\." + name + r"' depends on axioms: \[([^\]]*)\]", log)
            assert found, log
            all_axioms.update(filter(None, map(str.strip, found[1].split(','))))
        assert all_axioms <= {'propext', 'Classical.choice', 'Quot.sound'}, all_axioms
        log = log.replace(tmp, '<isolated-check>')
    (HERE/'reviews/lean-check.txt').write_text(log)
    report = dict(status='partial_reduction_only', unconditional_target_proved=False,
        conditional_exact_target_guard=True, missing_lemma='A334502Local.LargeCycles',
        kernel_checked_widths=[0, 14], axioms=sorted(all_axioms),
        statement_sha256=hashlib.sha256(statement).hexdigest(),
        lemmas_sha256=hashlib.sha256(lemmas.encode()).hexdigest())
    (HERE/'reviews/local-check.json').write_text(json.dumps(report, indent=2)+'\n')
    print('PASS: partial lemmas and exact conditional target; LargeCycles remains unproved')


if __name__ == '__main__':
    main()
