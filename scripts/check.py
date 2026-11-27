"""Build the reference model, check the sole proof in isolation, and audit axioms."""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from validate import validate

ROOT = Path(__file__).resolve().parent.parent
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}
FORBIDDEN = r'\b(sorry|admit|axiom|native_decide|unsafe)\b'


def audit(output, expected):
    audits = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", output)
    empty = re.findall(r"'([^']+)' does not depend on any axioms", output)
    assert {name for name, _ in audits} | set(empty) == set(expected), output
    for name, axioms in audits:
        assert set(filter(None, map(str.strip, axioms.split(',')))) <= ALLOWED, (name, axioms)


def run(args, **kwargs):
    result = subprocess.run(args, text=True, capture_output=True, **kwargs)
    if result.returncode:
        raise RuntimeError(f"{args}\n{result.stdout}\n{result.stderr}")
    return result.stdout


def main():
    os.chdir(ROOT)
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    print(run([lake, 'build']))
    for item in json.loads(Path('sources/provenance.json').read_text()):
        assert hashlib.sha256((Path('sources')/item['file']).read_bytes()).hexdigest() == item['sha256']
    for path in [*Path('A283508').glob('*.lean'), Path('A283508.lean'),
                 Path('scripts/ReferenceBridge.lean'), Path('scripts/Checks.lean')]:
        assert not re.search(FORBIDDEN, path.read_text()), path
    statement = Path('statements/oeis-a283508.lean').read_text()
    assert statement.startswith('import Mathlib\n')
    assert re.findall(r'^import (.+)$', statement, re.M) == ['Mathlib']
    assert re.findall(FORBIDDEN, statement) == ['sorry']
    assert statement.count('theorem main :') == 1
    assert 'def Target' not in statement
    assert 'Source: https://oeis.org/A283508' in statement
    assert 'Credit: @ddanila' in statement
    assert statement.count('def bit ') == 1
    assert len(re.findall(r'^theorem ', statement, re.M)) == 1
    proof = Path('proofs/oeis-a283508.lean').read_text()
    # The proof is maintained by hand and works directly on the statement's definitions.
    assert proof.startswith('import OMAStatements.S_oeis_a283508\nimport Mathlib\n')
    assert not re.search(FORBIDDEN, proof)
    assert '"' not in proof and not re.search(r'^#(eval|print|check|reduce|synth)\b', proof, re.M)
    assert proof.count('theorem OMA.solution : type_of% @OMA.S_oeis_a283508.main') == 1
    assert not re.search(r'^(def|abbrev|theorem|lemma) ', proof.split('theorem OMA.solution')[0], re.M), \
        'helpers must be private'
    full_path = run([lake, 'env', 'printenv', 'LEAN_PATH']).strip()
    lean = run([lake, 'env', 'which', 'lean']).strip()
    isolated_path = os.pathsep.join(p for p in full_path.split(os.pathsep)
                                   if Path(p).resolve() != ROOT/'.lake/build/lib/lean')
    # Empty cwd and dependency-only path: no project module can be imported.
    with tempfile.TemporaryDirectory(prefix='a283508-check-') as tmp:
        env = dict(os.environ, LEAN_PATH=isolated_path)
        isolated = Path(tmp)/'Statement.lean'
        isolated.write_text(statement)
        standalone_output = run([lean, str(isolated)], cwd=tmp, env=env)
        assert 'declaration uses' in standalone_output and 'sorry' in standalone_output
        # Only the proposed upstream statement and Mathlib are available to the proof.
        module = Path(tmp)/'OMAStatements/S_oeis_a283508.lean'
        module.parent.mkdir()
        module.write_text(statement)
        run([lean, str(module), '-o', str(module.with_suffix('.olean'))], cwd=tmp, env=env)
        proof_file = Path(tmp)/'Proof.lean'
        proof_file.write_text(proof+'\n#print axioms OMA.solution\n')
        proof_output = run([lean, str(proof_file)], cwd=tmp,
                           env=dict(env, LEAN_PATH=tmp+os.pathsep+isolated_path))
        bridge = Path(tmp)/'ReferenceBridge.lean'
        bridge.write_text(Path('scripts/ReferenceBridge.lean').read_text() +
                          '\n#print axioms A283508.state_matches_statement\n' +
                          '#print axioms A283508.observed_statement_torus_correct\n')
        bridge_output = run([lean, str(bridge)], cwd=tmp,
                            env=dict(env, LEAN_PATH=tmp+os.pathsep+full_path))
    audit(proof_output, ['OMA.solution'])
    audit(bridge_output, ['A283508.state_matches_statement',
                          'A283508.observed_statement_torus_correct'])
    checks = Path('scripts/Checks.lean').read_text()
    result = run([lake, 'env', 'lean', 'scripts/Checks.lean'])
    assert '[1, 10, 101, 1011, 10111, 101111, 1011111]' in result
    audit(result, re.findall(r'^#print axioms (.+)$', checks, re.M))
    official = 'unverified'
    report_path = Path('reviews/official-check.json')
    if report_path.exists():
        report = json.loads(report_path.read_text())
        if report['statement_sha256'] == hashlib.sha256(statement.encode()).hexdigest():
            official = report['verdict']['verdict']
    validation = validate()
    validation.update(standalone_mathlib_only=True, reference_state_consistency=True,
                      isolated_followup_proof=True, official_checker=official,
                      statement_intentional_placeholders=1,
                      audited_theorems=len(re.findall(r'^#print axioms ', checks, re.M)),
                      allowed_axioms=sorted(ALLOWED), source_hashes_verified=True)
    Path('reviews/validation.json').write_text(json.dumps(validation, indent=2)+'\n')
    Path('reviews/lean-checks.txt').write_text(result)
    Path('reviews/proof-checks.txt').write_text(proof_output.replace(tmp, '<isolated-check>'))
    # Remove temporary directory names to keep the saved report reproducible.
    Path('reviews/statement-checks.txt').write_text(
        standalone_output.replace(tmp, '<isolated-check>'))
    print(result)
    Path('reviews/reference-bridge-checks.txt').write_text(bridge_output.replace(tmp, '<isolated-check>'))
    print(proof_output)
    print(bridge_output)
    print(run([sys.executable, str(ROOT/'problems/a267622/check.py')]))
    print(run([sys.executable, str(ROOT/'problems/a267623/check.py')]))
    print(run([sys.executable, str(ROOT/'problems/a267920/check.py')]))
    print(run([sys.executable, str(ROOT/'problems/a267921/check.py')]))
    print(run([sys.executable, str(ROOT/'scripts/check_rule243_pair.py')]))
    print('PASS: all five problems, isolated proofs, simulations, and axiom audits.')


if __name__ == '__main__':
    main()
