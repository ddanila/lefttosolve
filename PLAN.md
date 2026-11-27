# Plan

Per-problem plans live with each problem. Status checked on 2026-11-27 against GitHub; saved observations are in `reviews/submission-status.json`.

## A283508 — proof merged

- Statement merged in [PR #5506](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/5506).
- Our proof [PR #6231](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6231) merged at **13:00:05 UTC** on 2026-11-27.
- Competing proof [PR #6200](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6200) closed at 13:04:40 UTC that day.
- [x] Record the merged proof outcome and update the README.

Process notes are in `LESSONS.md`. Merge status does not itself certify a separate human semantic review.

## A267622 — proof CI accepted, competing proof merged

- Statement [PR #6406](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6406) merged at 14:14:02 UTC on 2026-11-27.
- Proof [PR #7242](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7242) is open; CI completed successfully and its downloaded verdict is accepted. Competing proof #7360 merged at 15:07:44 UTC and the site credits caa1982; ours remains open despite earlier submission and CI completion.
- [ ] Monitor the proof verdict, merge, and site credit; record the final outcome.

Publication and automatic monitoring are authorized. See [`problems/a267622/PLAN.md`](problems/a267622/PLAN.md).

## A267623 — statement merged, proof CI accepted

Statement, proof, archived sources, simulation, isolated axiom audit, and official local checker rehearsals are complete. All 1,001 source terms match. Full publication and submission are now authorized, including coordination notes and automatic follow-through without further approvals.

- [x] Obtain a fresh independent statement review before publication.
- [x] Recheck live activity and current upstream/toolchain pins before submitting.
- [x] Submit statement: [PR #7472](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7472).
- [x] Statement #7472 merged at 14:58:01 UTC; exact-target proof check passed.
- [x] Submit proof: [PR #7656](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7656).
- [ ] Monitor proof verdict, merge, and site credit.

See [`problems/a267623/PLAN.md`](problems/a267623/PLAN.md). Follow the authorized sequence in the per-problem plan.

## A267920 and A267921 — statements submitted

Develop both Rule 243 encodings together. Each has a standalone statement/proof and source archive. Full publication, leases, coordination notes, statement/proof submissions and monitoring are authorized without further approvals.

- [x] Complete local validation and official checker rehearsals.
- [x] Obtain independent statement reviews; both passed without corrections.
- [x] Submit statements: A267920 #8024 (CI accepted), A267921 #7966 (CI accepted).
- [ ] Recheck and submit each proof after its statement merges; monitor verdicts.

See [A267920 plan](problems/a267920/PLAN.md) and [A267921 plan](problems/a267921/PLAN.md). Proceed with the authorized per-problem submission sequences.
