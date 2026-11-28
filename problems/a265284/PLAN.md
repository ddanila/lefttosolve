# A265284 local proof plan

Scope: full publication and submission authorized 2026-11-28 without further
questions, after local validation. Existing A273385/A273539 watchers remain
separately authorized and unaffected.

## Local preparation

- [x] Archive live brief, OEIS entry, 1,000-term b-file, and exact merged statement.
- [x] Check existing submissions and audit statement semantics against the source.
- [x] Prove the alternating scan lemma and both explicit row shapes.
- [x] Count ON cells per row and derive both cumulative parity formulas.
- [x] Prove all three source formulas, recurrence, and generating function.
- [x] Compile the exact target in isolation and audit allowed axioms.
- [x] Independently simulate all archived terms and the complete row patterns.
- [x] Run the current official checker, record memory/time and final file hashes.
- [x] Integrate root checking, verify reproducible reports, and commit the proof.

All eight problems pass the root checker. Repeated A265284 checks produce
identical saved reports. The official checker accepts the final proof.

## Publication and submission

- [x] Recheck upstream: statement and checker unchanged; no proof on main.
- [x] Publish complete provenance at `ddanila/lefttosolve`, commit `cba711c`.
- [x] Attempt normal lease: desk returned `proof_pending` for the two prior PRs.
- [x] Submit through the standard client's no-lease path; official recheck accepted.
- [x] Verify proof PR [#26856](https://github.com/lefttosolve2/open-math-agents/pull/26856) contains
      exactly our checked proof file, with its matching hash and original target.
- [x] Initial CI passed at 10:50 UTC; competing #10573 merged at 11:28 UTC.
- [x] Measure our proof: 4,199 versus 6,412 counted characters (34.5% shorter).
- [x] Update the same PR against main as a one-file replacement; official recheck passed.
- [ ] Await fresh CI and the shorter-proof verdict.

Other contributors' #10573/#22508 remain competing submissions. A proof merging
first can make the remaining PRs ineligible; do not promise first-solve credit.
The two pre-existing statement-follow-up watchers remain unaffected. This proof
is already submitted, so it does not need a statement-waiting watcher.
