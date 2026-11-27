"""Reproduce the build, independent validation, Lean computations, and axiom audit."""
import json
import re
import shutil
import subprocess
from pathlib import Path
from validate import validate

ROOT = Path(__file__).resolve().parent.parent

def main():
    import os
    os.chdir(ROOT)
    lake = shutil.which('lake') or str(Path.home()/'.elan/bin/lake')
    subprocess.run([lake, 'build'], check=True)
    validation = validate()
    result = subprocess.run([lake, 'env', 'lean', 'scripts/Checks.lean'],
                            text=True, capture_output=True, check=True)
    print(result.stdout)
    assert '[1, 10, 101, 1011, 10111, 101111, 1011111]' in result.stdout
    allowed = {'propext', 'Classical.choice', 'Quot.sound'}
    audits = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", result.stdout)
    # Lean prints a separate form for declarations with no axioms.
    no_axioms = re.findall(r"'([^']+)' does not depend on any axioms", result.stdout)
    assert len(audits) + len(no_axioms) == 7, result.stdout
    for name, axioms in audits:
        assert set(filter(None, map(str.strip, axioms.split(',')))) <= allowed, (name,axioms)
    for path in [*Path('A283508').glob('*.lean'), Path('A283508.lean')]:
        assert not re.search(r'\b(sorry|admit|axiom|native_decide|unsafe)\b',path.read_text()), path
    Path('reviews/validation.json').write_text(json.dumps(validation,indent=2)+'\n')
    Path('reviews/lean-checks.txt').write_text(result.stdout)
    print('PASS: build, independent simulations, Lean samples, and allowed axioms.')

if __name__ == '__main__': main()
