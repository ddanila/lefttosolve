# A267920 — implementation and submission plan

Scope updated 2026-11-27: full publication, coordination notes, leases, statement and proof submissions, fixes and monitoring are authorized without further approvals.

- [x] Archive the full OEIS entry, b-file, and platform brief with hashes.
- [x] Define Rule 243 independently of its conjectures and state both platform claims.
- [x] Develop the moving-hole invariant and row-encoding proof in base 10.
- [x] Compile in isolation, audit axioms, and compare direct simulation with all source terms.
- [x] Check the relationship between the two encoding conventions and integrate root validation.
- [x] Rehearse the official statement and proof checkers locally and record pins/hashes.
- [x] Finish semantic review documentation and reproducibility checks.

Before submission: complete independent statement review and recheck current platform pins/activity. Publication is authorized.

Validation complete: both official local checker modes accepted; isolated proof uses only propext, Classical.choice, Quot.sound. Direct simulation matches all 1,001 terms. Joint Lean state equality and all paired base conversions pass. The root checker passes for all five problems, and standalone reruns produce byte-identical reports. Fresh independent semantic review passed without corrections.

## Authorized submission sequence

- [x] Complete fresh independent statement review.
- [x] Publish checked work and verify platform pins.
- [x] Take lease, post PLAN note, and submit statement.
- [ ] Monitor statement verdict and merge.
- [ ] Recheck exact merged target and submit proof.
- [ ] Monitor proof verdict, merge, and site credit.

Publication commit 5611381 contains both complete checked proofs. Refreshed platform main f9464184 has unchanged checker/dependency pin. Independent reviews are in `reviews/independent-statement-review.md`. Lease acquisition currently receives HTTP 500 from the desk; retrying without bypassing coordination.

Desk recovered; statement submitted as https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/8024 . Exactly one added file verified against the reviewed hash. PLAN note #40536; client released lease. CI queued.
