# A267921 — local implementation plan

Scope: local work only, authorized 2026-11-27 together with A267920. No leases, public notes, pushes, or submissions for either new problem.

- [x] Archive the full OEIS entry, b-file, and platform brief with hashes.
- [x] Define Rule 243 independently of its conjectures and state both platform claims.
- [x] Develop the moving-hole invariant and row-encoding proof in base 2.
- [x] Compile in isolation, audit axioms, and compare direct simulation with all source terms.
- [x] Check the relationship between the two encoding conventions and integrate root validation.
- [x] Rehearse the official statement and proof checkers locally and record pins/hashes.
- [x] Finish semantic review documentation and reproducibility checks.

Before publication: obtain a fresh independent statement review, recheck live activity and platform pins, and obtain publication authorization. Full submission authorization for A267623 does not extend to these new local-only problems.

Validation complete: both official local checker modes accepted; isolated proof uses only propext, Classical.choice, Quot.sound. Direct simulation matches all 1,001 terms. Joint Lean state equality and all paired base conversions pass. The root checker passes for all five problems, and standalone reruns produce byte-identical reports. Fresh independent semantic review remains before publication.
