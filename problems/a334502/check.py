"""Isolated kernel audit of the reduction, all four steps, and their exact composition."""
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
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def run(args, **kwargs):
    result = subprocess.run(args, text=True, capture_output=True, **kwargs)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout


def axioms(log, name):
    found = re.search(r"'" + re.escape(name) + r"' depends on axioms: \[([^\]]*)\]", log)
    assert found, log
    result = set(filter(None, map(str.strip, found[1].split(','))))
    assert result <= ALLOWED, result
    return result


def main():
    run(['python3', str(HERE/'generate.py'), '--check'], cwd=ROOT)
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    paths = run([lake, 'env', 'printenv', 'LEAN_PATH'], cwd=ROOT).strip()
    paths = os.pathsep.join(p for p in paths.split(os.pathsep)
                           if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    lean = run([lake, 'env', 'which', 'lean'], cwd=ROOT).strip()
    statement = (HERE/'sources/statement.lean').read_bytes()
    reduction = (ROOT/'reductions/oeis-a334502.R1.lean').read_text()
    proofs = [(ROOT/f'proofs/oeis-a334502.R1.H{i}.lean').read_text() for i in range(1,5)]
    assert re.findall(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', statement.decode()) == ['sorry']
    for source in [reduction, *proofs]:
        assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b', source)
    logs, audited = [], {}
    with tempfile.TemporaryDirectory(prefix='a334502-check-') as tmp:
        base = Path(tmp)
        env = dict(os.environ, LEAN_PATH=tmp+os.pathsep+paths)
        module = base/'OMAStatements/S_oeis_a334502.lean'
        module.parent.mkdir()
        module.write_bytes(statement)
        logs.append(run([lean, '-j', '2', str(module), '-o', str(module.with_suffix('.olean'))],
                        cwd=tmp, env=env))
        module = base/'OMAReductions/R_oeis_a334502_R1.lean'
        module.parent.mkdir()
        name = 'OMA.R_oeis_a334502_R1.main'
        module.write_text(reduction+'\n#print axioms '+name+'\n')
        log = run([lean, '-j', '2', str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        audited[name] = sorted(axioms(log, name)); logs.append(log)
        for i, source in enumerate(proofs, 1):
            # Namespace alpha-renaming permits importing all standalone steps together.
            # The unchanged production files are also tested by tools/check.sh.
            source = re.sub(r'\bCompact\b', f'A334502CompactH{i}', source)
            source = re.sub(r'\bA334502Local\b', f'A334502LocalH{i}', source)
            name = f'A334502Audit.step{i}'
            source = source.replace('theorem OMA.solution', 'theorem '+name)
            module = base/f'Step{i}.lean'
            module.write_text(source+'\n#print axioms '+name+'\n')
            log = run([lean, '-j', '2', str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
            audited[name] = sorted(axioms(log, name)); logs.append(log)
            print(f'H{i}: kernel accepted; standard axioms only', flush=True)
        guard = base/'Complete.lean'
        name = 'A334502Audit.complete'
        guard.write_text(''.join(f'import Step{i}\n' for i in range(1,5)) +
            f'theorem {name} : type_of% @OMA.S_oeis_a334502.main :=\n' +
            '  OMA.R_oeis_a334502_R1.main '+
            ' '.join(f'A334502Audit.step{i}' for i in range(1,5))+'\n'+
            '#print axioms '+name+'\n')
        log = run([lean, '-j', '2', str(guard)], cwd=tmp, env=env)
        audited[name] = sorted(axioms(log, name)); logs.append(log)
        full_log = '\n'.join(logs).replace(tmp, '<isolated-check>')
    (HERE/'reviews/lean-check.txt').write_text(full_log)
    files = {'statement': hashlib.sha256(statement).hexdigest(),
             'reduction': hashlib.sha256(reduction.encode()).hexdigest()}
    files.update({f'H{i}': hashlib.sha256(p.encode()).hexdigest() for i,p in enumerate(proofs,1)})
    report = dict(status='complete_local_reduction_and_four_steps',
        unconditional_target_proved=True, exact_target_guard=True,
        namespace_renaming_for_composition=True, axioms=audited, sha256=files)
    (HERE/'reviews/local-check.json').write_text(json.dumps(report, indent=2)+'\n')
    print('PASS: all four steps compose to the exact unconditional platform target')


if __name__ == '__main__':
    main()
