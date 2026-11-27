# A267622 — local implementation plan

Scope updated 2026-11-27: Danila authorized publication, leases, notes, statement and proof submissions, and automatic monitoring/waits without further per-step approval.

- [x] Archive the original OEIS definition/program and b-file; document offset, rule orientation, crop, and decimal encoding.
- [x] Write a standalone Mathlib-only statement of both source conjectures, based on the cellular automaton rather than the conjectured recurrence.
- [x] Prove the Rule 187 moving-hole invariant, the row encoding, recurrence, and generating function. Reuse the established argument from A283508 with explicit attribution.
- [x] Compare an independent finite simulation with all published terms and check crop boundaries/orientation; compile the statement and proof in isolation and audit axioms.
- [x] Run the official checker locally, record results and hashes, and document correctness and future submission requirements.

The source recurrence is stated only for n > 2. The generating function is expressed as a product identity over formal power series over integers; its denominator has constant coefficient 1.

## Completed locally

Both official checker rehearsals accepted. The isolated proof audit permits only `propext`, `Classical.choice`, and `Quot.sound`. Independent simulation matches all 1,001 source terms. The semantic review is in README.md; evidence and immutable source hashes are in `reviews/` and `sources/provenance.json`.

Publication is now authorized. Recheck live activity and platform state before each submission.

## Follow-up polish and independent review

- [x] Harden the non-terminal simplification, restore the source title, and polish proof documentation.
- [x] Archive the platform brief with provenance.
- [x] Obtain a fresh statement review against the OEIS source alone.
- [x] Normalize temporary paths; verify repeated check output is stable and include A267622 in the root check.
- [x] Refresh local official-check evidence for the final hashes.

The earlier local-only boundary was honored; the user has now authorized publishing the completed work for public provenance.

Follow-up validation: root `python3 scripts/check.py` passes for both problems. A standalone A267622 run followed by the root run produced byte-identical `lean-check.txt` and `local-check.json`. Both official checks accepted the final source hashes. Fresh independent review found no semantic corrections and preserves its separate simulator.

## Authorized submission sequence

- [x] Publish completed research and verify current platform pins.
- [x] Take lease, post PLAN note, check and submit statement.
- [x] Monitor statement CI/merge; catalog readiness tracked alongside proof submission.
- [x] Verify merged statement, recheck and submit proof.
- [ ] Monitor proof verdict and record final outcome.

Statement submitted: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6406. Local checker accepted; one added statement file verified. PLAN note #30583 links the already-published complete proof. Submission client released the statement lease. CI queued at 12:44 UTC.

Statement merged unchanged at 14:14:02 UTC (f103df62bbea7a03460e7938aba8b2adfbdf12ef). Official proof recheck accepted against main 790c424f. Catalog remains stale, but the official client and checker recognize the tracked merged statement and exact proof target; proof submission can proceed. Monitor site credit separately if catalog deployment lags. Proof PLAN note #36216 posted under a new lease.

Proof submitted: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7242. One added proof file, exact approved hash verified from GitHub. Client released lease; CI queued at 14:16 UTC.
