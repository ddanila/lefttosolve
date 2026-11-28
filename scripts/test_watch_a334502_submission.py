import unittest
from watch_a334502_submission import verdict, target_state, sha, file_prs


class SubmissionGuards(unittest.TestCase):
    def setUp(self):
        self.context = dict(statement_sha256=sha(b'statement'), reduction_sha256=sha(b'reduction'))

    def test_exact_target_required(self):
        self.assertEqual(target_state(b'statement', None, False, self.context), 'waiting_for_reduction')
        self.assertEqual(target_state(b'statement', b'reduction', False, self.context), 'ready')
        self.assertEqual(target_state(b'changed', b'reduction', False, self.context), 'statement_changed')
        self.assertEqual(target_state(b'statement', b'changed', False, self.context), 'reduction_changed')
        self.assertEqual(target_state(b'statement', b'reduction', True, self.context), 'competing_proof_merged')

    def test_merged_wins_over_stale_rejection(self):
        pr = dict(mergedAt='now', state='CLOSED', comments=[dict(author=dict(login='github-actions'), body='Not merged: duplicate')])
        self.assertEqual(verdict(pr), 'merged')
        pr.update(mergedAt=None, state='OPEN')
        self.assertEqual(verdict(pr), 'needs_review')

    def test_ci_failure_and_pending(self):
        self.assertEqual(verdict(dict(state='OPEN', statusCheckRollup=[dict(conclusion='FAILURE')])), 'needs_review')
        self.assertEqual(verdict(dict(state='OPEN', statusCheckRollup=[dict(conclusion='SUCCESS')])), 'pending')

    def test_duplicate_guard_uses_file_not_title(self):
        prs = [dict(number=1, files=[dict(path='reductions/p.R1.lean')]),
               dict(number=2, files=[dict(path='proofs/p.R1.H1.lean')])]
        self.assertEqual(file_prs(prs, 'proofs/p.R1.H1.lean'), [prs[1]])


if __name__ == '__main__':
    unittest.main()
