# A267445 — prior-work audit; skipped

User chose to stop with the prior-work audit on 2026-11-28. No new statement,
proof, lease, public note, push or submission was prepared for this problem.

The OEIS claim is A267445(n) = A071050(n) for n > 0:
ON cells of Rule 129 equal OFF cells of Rule 126. The positive-index restriction is essential at the initial seed.

## Verified prior work

Derek Blair, *Binary submasks and the middle column of Rules 126 and 129*.
[Inspected Lean source](https://github.com/derekblair/math-proofs/blob/f0817a0d34d89555cc7270126b93627fc0394340/lean/Mathproofs/Dynamics/Rule129MiddleColumn.lean)
and [paper](https://github.com/derekblair/math-proofs/blob/f0817a0d34d89555cc7270126b93627fc0394340/papers/rule129/paper.tex).

The theorem `ecaOrbit_129_eq_not_126` establishes complementation for every
integer cell and every positive generation. Summing over the same crop [-n,n]
gives this count identity immediately. This is a consequence of the existing
formal theorem, not a separately named count theorem found in the inspected file.

Both automata start from one ON cell on the infinite integer line. At positive
times Rule 129 has an ON background outside the light cone, so counts must use
the finite crop [-n,n], as in the OEIS program, rather than all integer cells.

The paper is dated October 28, 2026. GitHub's
[proof-completion commit](https://github.com/derekblair/math-proofs/commit/8f3c0b393e491a2d26e4ed7d73978cb5b3576976)
is dated **2026-10-29 12:17:46 UTC**. The inspected snapshot is pinned to
`f0817a0d34d89555cc7270126b93627fc0394340` (November 25, directory reorganization).
This distinguishes a dated statement/preprint from the completed proof artifact.

Earlier platform statement PRs were withdrawn by their authors for prior work:
- [#17521](https://github.com/lefttosolve2/open-math-agents/pull/17521)
- [#33652](https://github.com/lefttosolve2/open-math-agents/pull/33652)

## Evidence and limits

OEIS entries, b-files and PR records are archived in sources/ with SHA-256
hashes in provenance.json. The shared paper and four Lean modules are referenced by pinned upstream links
and recorded hashes only; copies were removed because no redistribution license
was identified. This audit inspected source and matched definitions;
it did not rebuild the external Lean project or certify its full dependency
closure. No platform-ready proof is claimed. The authors' withdrawals are not
an independent platform ruling that formalization submissions are prohibited.
