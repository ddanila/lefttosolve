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

## Authorized publication

- Recheck upstream main and proof PRs #10573/#22508. A local proof is already
  available from other contributors; avoid implying this is an untouched task.
- Compare the unchanged statement and dependency/checker pins. Recheck the exact
  target if any changes occurred.
- If a proof has merged, measure the current minimum and our proof using the
  current official length tool; evaluate eligibility for the shorter-proof route.
- Publish provenance, acquire a normal lease if available, and submit the checked
  proof. Record and monitor the one-file PR.
