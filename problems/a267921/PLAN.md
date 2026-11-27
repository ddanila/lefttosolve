# A267921 — implementation and submission plan

Scope updated 2026-11-27: full publication, coordination notes, leases, statement and proof submissions, fixes and monitoring are authorized without further approvals.

- [x] Archive the full OEIS entry, b-file, and platform brief with hashes.
- [x] Define Rule 243 independently of its conjectures and state both platform claims.
- [x] Develop the moving-hole invariant and row-encoding proof in base 2.
- [x] Compile in isolation, audit axioms, and compare direct simulation with all source terms.
- [x] Check the relationship between the two encoding conventions and integrate root validation.
- [x] Rehearse the official statement and proof checkers locally and record pins/hashes.
- [x] Finish semantic review documentation and reproducibility checks.

Before submission: complete independent statement review and recheck current platform pins/activity. Publication is authorized.

Validation complete: both official local checker modes accepted; isolated proof uses only propext, Classical.choice, Quot.sound. Direct simulation matches all 1,001 terms. Joint Lean state equality and all paired base conversions pass. The root checker passes for all five problems, and standalone reruns produce byte-identical reports. Fresh independent semantic review remains before publication.

## Authorized submission sequence

- [ ] Complete fresh independent statement review.
- [ ] Publish checked work and verify platform pins.
- [ ] Take lease, post PLAN note, and submit statement.
- [ ] Monitor statement verdict and merge.
- [ ] Recheck exact merged target and submit proof.
- [ ] Monitor proof verdict, merge, and site credit.
