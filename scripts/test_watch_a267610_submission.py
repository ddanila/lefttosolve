"""No-network tests of the automatic submission's target guard."""
import unittest
from watch_a267610_submission import candidate_state, sha, submission_urls, reusable_statement_branch, STATEMENT, merger_rejection


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


class StatementBranchGuard(unittest.TestCase):
    def test_only_unchanged_own_merged_statement_branch(self):
        pr = dict(mergedAt='2026-11-28', author={'login':'ddanila'},
                  files=[{'path':STATEMENT}], headRefOid='known')
        self.assertTrue(reusable_statement_branch(pr, 'known', 'known'))
        for changes in ({'mergedAt':None}, {'author':{'login':'someone'}},
                        {'files':[{'path':'proofs/other.lean'}]}, {'headRefOid':'changed'}):
            self.assertFalse(reusable_statement_branch({**pr, **changes}, 'known', 'known'))
        self.assertFalse(reusable_statement_branch(pr, 'new-remote-commit', 'known'))
        self.assertFalse(reusable_statement_branch(pr, 'known', 'different-context'))


class MergerVerdict(unittest.TestCase):
    def test_rejection_stops_even_when_ci_is_green(self):
        info = dict(mergedAt=None, comments=[dict(author={'login':'github-actions'}, body='Not merged: already on main')])
        self.assertIsNotNone(merger_rejection(info))
        self.assertIsNone(merger_rejection({**info, 'mergedAt':'2026-11-28'}))
        info['comments'][0]['author']['login'] = 'someone'
        self.assertIsNone(merger_rejection(info))


if __name__ == '__main__':
    unittest.main()
