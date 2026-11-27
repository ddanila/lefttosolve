"""Submission-boundary tests; no network calls or real leases."""
import base64
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('watch', Path(__file__).with_name('watch_rule243_submission.py'))
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)


class SubmissionBoundary(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        base = Path(self.tmp.name)
        self.root, self.platform, self.state = [base / x for x in ('root', 'platform', 'state')]
        self.state.mkdir()
        self.n = '267920'
        self.problem = 'oeis-a' + self.n
        for dest in (self.root, self.platform):
            for folder in ('statements', 'proofs'):
                (dest / folder).mkdir(parents=True)
                shutil.copyfile(w.ROOT / folder / (self.problem + '.lean'), dest / folder / (self.problem + '.lean'))
        (self.platform / 'data').mkdir()
        (self.platform / 'data/catalog.json').write_text(json.dumps({'meta': {'upstreamCommit': w.PIN}}))
        for folder in ('leases', 'briefs'):
            (self.platform / '.oma' / folder).mkdir(parents=True)
        for name, value in [('ROOT', self.root), ('PLATFORM', self.platform), ('STATE', self.state)]:
            p = patch.object(w, name, value)
            p.start()
            self.addCleanup(p.stop)
        self.calls = []
        self.claim_ok = True
        self.teammate = False
        self.no_pr_url = False
        self.remote_mismatch = False
        self.status = {}

    def command(self, args, **kwargs):
        self.calls.append(args)
        out, rc = '', 0
        if args[:2] == ['tools/oma.sh', 'next']:
            if not self.claim_ok:
                return subprocess.CompletedProcess(args, 1, 'HTTP 500')
            (self.platform / '.oma/leases' / self.problem).write_text('private-test-lease')
            (self.platform / '.oma/briefs' / (self.problem + '.txt')).write_text('Archived source context')
            out = 'PROBLEM ' + self.problem + '\nTEAMMATES ' + ('@someone' if self.teammate else 'none right now')
            out += '\nNOTES ON THIS PROBLEM\n--- #1 @ddanila\nPLAN: previously published proof'
        elif args[:2] == ['git', 'ls-files']:
            rc = 1
        elif args[0] == 'tools/check.sh':
            Path(args[2]).write_text(json.dumps({'verdict': 'accepted'}))
        elif args[:2] == ['tools/oma.sh', 'submit']:
            out = '' if self.no_pr_url else 'https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/123'
        elif args[:3] == ['gh', 'pr', 'view']:
            out = json.dumps({'number': 123, 'url': 'https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/123',
                              'state': 'OPEN', 'headRefOid': 'abc', 'author': {'login': 'ddanila'},
                              'files': [{'path': 'proofs/' + self.problem + '.lean'}]})
        elif args[:2] == ['gh', 'api']:
            content = b'wrong' if self.remote_mismatch else (self.root / 'proofs' / (self.problem + '.lean')).read_bytes()
            out = json.dumps({'content': base64.b64encode(content).decode()})
        return subprocess.CompletedProcess(args, rc, out)

    def exercise(self):
        with patch.object(w, 'run', self.command):
            w.submit(self.n, self.status, lambda: None)

    def test_desk_failure_does_not_submit(self):
        self.claim_ok = False
        self.exercise()
        self.assertEqual(self.status[self.n]['phase'], 'waiting_for_lease')
        self.assertEqual(len(self.calls), 1)

    def test_teammate_requires_review(self):
        self.teammate = True
        with self.assertRaisesRegex(RuntimeError, 'Coordination'):
            self.exercise()
        self.assertEqual(len(self.calls), 1)

    def test_changed_statement_prevents_submission(self):
        (self.platform / 'statements' / (self.problem + '.lean')).write_text('changed')
        with self.assertRaisesRegex(RuntimeError, 'reviewed hash'):
            self.exercise()
        self.assertFalse(any(c[:2] == ['tools/oma.sh', 'submit'] for c in self.calls))

    def test_uncertain_submission_is_not_marked_complete(self):
        self.no_pr_url = True
        with self.assertRaisesRegex(RuntimeError, 'no PR URL'):
            self.exercise()
        self.assertEqual(self.status[self.n]['phase'], 'submitting')

    def test_remote_proof_must_match(self):
        self.remote_mismatch = True
        with self.assertRaisesRegex(RuntimeError, 'Remote proof differs'):
            self.exercise()
        self.assertEqual(self.status[self.n]['phase'], 'submitting')

    def test_verified_submission_after_official_check(self):
        self.exercise()
        self.assertEqual(self.status[self.n]['phase'], 'proof_submitted')
        check = next(i for i, c in enumerate(self.calls) if c[0] == 'tools/check.sh')
        submit = next(i for i, c in enumerate(self.calls) if c[:2] == ['tools/oma.sh', 'submit'])
        self.assertLess(check, submit)
        self.assertNotIn('private-test-lease', json.dumps(self.status))


if __name__ == '__main__':
    unittest.main()
