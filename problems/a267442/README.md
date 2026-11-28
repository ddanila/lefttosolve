# A267442 — prior-work audit; skipped

User chose to stop with the prior-work audit on 2026-11-28. No new statement,
proof, lease, public note, push or submission was prepared for this problem.

The OEIS claim is A267442(n) = A043545(n) for n > 0:
Rule 129 centre equals the spread of binary digits. The positive-index restriction is essential at the initial seed.

## Verified prior work

Derek Blair, *Binary submasks and the middle column of Rules 126 and 129*.
[Inspected Lean source](https://github.com/derekblair/math-proofs/blob/f0817a0d34d89555cc7270126b93627fc0394340/lean/Mathproofs/Dynamics/Rule129MiddleColumn.lean)
and [paper](https://github.com/derekblair/math-proofs/blob/f0817a0d34d89555cc7270126b93627fc0394340/papers/rule129/paper.tex).

Exact theorem `a267442_eq_a043545` proves the stated positive-index identity.
Its A043545 definition uses max minus min of the binary digits, matching OEIS.

Both automata start from one ON cell on the infinite integer line. At positive
times Rule 129 has an ON background outside the light cone, so counts must use
the finite crop [-n,n], as in the OEIS program, rather than all integer cells.

The paper is dated October 28, 2026. GitHub's
[proof-completion commit](https://github.com/derekblair/math-proofs/commit/8f3c0b393e491a2d26e4ed7d73978cb5b3576976)
is dated **2026-10-29 12:17:46 UTC**. The inspected snapshot is pinned to
`f0817a0d34d89555cc7270126b93627fc0394340` (November 25, directory reorganization).
This distinguishes a dated statement/preprint from the completed proof artifact.

Earlier platform statement PRs were withdrawn by their authors for prior work:
- [#18449](https://github.com/lefttosolve2/open-math-agents/pull/18449)

## Evidence and limits

OEIS entries, b-files and PR records are archived in sources/ with SHA-256
hashes in provenance.json. The shared paper and four Lean modules are referenced by pinned upstream links
and recorded hashes only; copies were removed because no redistribution license
was identified. This audit inspected source and matched definitions;
it did not rebuild the external Lean project or certify its full dependency
closure. No platform-ready proof is claimed. The authors' withdrawals are not
an independent platform ruling that formalization submissions are prohibited.

The current platform agent brief and problem API both returned HTTP 404;
the OEIS entry and archived withdrawn PR supply the target for this audit.
