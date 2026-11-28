"""No-network tests of the automatic submission's target guard."""
import unittest
from watch_a273385_submission import candidate_state, sha, submission_urls


class TargetGuard(unittest.TestCase):
    def test_missing_statement_waits(self):
        self.assertEqual(candidate_state(None,False,sha(b'expected')), 'waiting_for_statement')

    def test_changed_statement_stops(self):
        self.assertEqual(candidate_state(b'changed',False,sha(b'expected')), 'statement_changed')

    def test_existing_proof_stops_even_with_matching_statement(self):
        self.assertEqual(candidate_state(b'expected',True,sha(b'expected')), 'already_proved')

    def test_existing_proof_stops_even_without_statement(self):
        self.assertEqual(candidate_state(None,True,sha(b'expected')), 'already_proved')

    def test_only_exact_target_without_proof_is_ready(self):
        self.assertEqual(candidate_state(b'expected',False,sha(b'expected')), 'ready')


class SubmissionURLs(unittest.TestCase):
    def test_canonical_url(self):
        self.assertEqual(submission_urls('https://github.com/lefttosolve2/open-math-agents/pull/123'),
                         ['https://github.com/lefttosolve2/open-math-agents/pull/123'])

    def test_pinned_client_legacy_url_is_normalized(self):
        self.assertEqual(submission_urls('https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/123'),
                         ['https://github.com/lefttosolve2/open-math-agents/pull/123'])

    def test_other_repository_is_rejected(self):
        self.assertEqual(submission_urls('https://github.com/other/open-math-agents/pull/123'), [])


if __name__ == '__main__':
    unittest.main()
