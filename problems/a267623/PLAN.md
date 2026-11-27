# A267623 — implementation and submission plan

Scope updated 2026-11-27: full publication, leases, coordination notes, statement and proof submission, fixes, and automatic monitoring are authorized without further approvals.

- [x] Archive the authoritative OEIS entry, b-file, and platform brief with hashes.
- [x] Formulate both platform conjectures from the actual Rule 187 centre column.
- [x] Adapt the moving-hole proof and derive the recurrence and generating function.
- [x] Compile in isolation, audit axioms, and compare direct simulation with every b-file term.
- [x] Rehearse both official checker modes locally and record exact hashes/pins.
- [x] Document source interpretation, reproduction, and remaining publication requirements.

Fresh independent statement review passed with no corrections; live activity and current platform pins have been checked. Publish under the authorization above. The OEIS entry also lists two empirical closed forms; the platform brief requests only the recurrence and generating function.

Completed: both official checker rehearsals accepted; the root checker passes for all three problems. Direct simulation matches all 1,001 terms. A standalone rerun produces byte-identical reports. Allowed proof axioms: propext, Classical.choice, Quot.sound. No external writes were made during the initial local-only phase.

## Authorized submission sequence

- [x] Complete fresh independent statement review.
- [x] Publish research and recheck current platform pins.
- [x] Take lease, post PLAN note, check and submit statement.
- [x] Monitor statement verdict and merge.
- [x] Recheck against the exact merged target and submit proof promptly.
- [ ] Monitor proof verdict, merge, and site credit; record final outcome.

Statement submitted as https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7472 . Exactly one added statement file, remotely verified against the reviewed hash. PLAN note #37424 links the public proof; lease released by client. CI pending.

Statement CI run 46017748192 completed successfully; downloaded verdict accepted. Merge is pending. Evidence: `reviews/statement-ci-verdict.json`.

Statement merged unchanged at 14:58:01 UTC. The official proof recheck against tracked main f57cd04a accepted the exact target. Catalog still lags, but the official client recognizes the merged statement; proof submission is proceeding. PLAN note #38603 posted under a new lease.

Proof submitted: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7656 . Exactly one added proof file verified against the checked hash. Client released lease. CI pending.

Proof CI run 46020841281 completed successfully; downloaded verdict accepted the proof. Merge remains pending. Evidence: `reviews/proof-ci-verdict.json`.
