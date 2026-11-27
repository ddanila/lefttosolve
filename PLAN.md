# A283508: submission plan

## Current state (2026-11-27)

Stage 1 is complete: PR #5506 merged at 2026-11-27T11:46:06Z. F1 passed against the unchanged merged statement and current checker. F2 onward await confirmation.

- **Statement:** `statements/oeis-a283508.lean`, SHA-256 `41b9b5dd…9285`. Accepted by the official `tools/oma.sh check`; independently reviewed against both OEIS entries.
- **Proof:** `proofs/oeis-a283508.lean` (257 lines), SHA-256 `94f8bcdc…e0fa`. Accepted by the platform's `tools/check.sh` in a local rehearsal, on `propext`, `Classical.choice`, `Quot.sound` only.
- **Lease:** the previous lease expired; reacquired under @ddanila at 2026-11-27T10:56:12.739629+00:00, role lead; released by the client after statement submission in PR #5506.
- **Repo:** https://github.com/ddanila/lefttosolve; `python3 scripts/check.py` passes.

Every step below is visible to others, so Danila confirms each one before it runs.

## Stage 1 — Submit the statement

- [x] **S1 — Confirm the lease is alive.**
  - **Result:** previous lease expired; reacquired under @ddanila at 2026-11-27T10:56:12.739629+00:00. Role lead, zero other agents. Final statement recopied and its approved hash verified.
  - Run `tools/oma.sh beat oeis-a283508`; the platform expects one every 7 minutes, and a 410 response means the lease expired.
  - If it expired, take it again with `tools/oma.sh next --problem oeis-a283508` and re-copy the statement.

- [x] **S2 — Final pre-flight.**
  - **Result:** accepted at 2026-11-27T10:57:46.872949+00:00 for SHA-256 `41b9b5ddced91483eff7ffd2faa972326e0b71f5086d138eea3f91b59b699285`. Live page/API still unformalized, no statement/module or solution, one active agent. Evidence: `reviews/official-check.json` and `sources/problem-preflight.json`.
  - Re-fetch the problem page: still unformalized, nobody else has stated it.
  - Confirm `.oma/platform/statements/oeis-a283508.lean` has SHA-256 `41b9b5dd…9285`.
  - Run `tools/oma.sh check oeis-a283508` under the lease; it must print "accepted".

- [x] **S3 — Submit.**
  - **Result:** https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/5506. Verified exactly one changed file, `statements/oeis-a283508.lean`, with the approved SHA-256. Local checker accepted; submission client released the lease. See `reviews/statement-submission.json`.
  - `tools/oma.sh submit oeis-a283508`. The pull request must contain only the statement file.
  - Record the pull request URL in `reviews/`.

- [x] **S4 — Update the docs.**
  - **Result:** README and lease record updated with PR #5506 and lease release. Timestamped PR/CI status saved in `reviews/statement-status.json`. The proof remains unsubmitted.
  - Replace the README's "no lease, no submission" wording and update `reviews/lease-acquired.json`.

## Stage 2 — Submit the proof

Only after the statement pull request is merged.

- [x] **F1 — Re-validate against the merged statement.**
  - **Result:** accepted at 2026-11-27T12:08:29.255924+00:00 against merged statement commit `d7aafc35d87ea8a01ef897545dd19a962231992d` and current platform checkout `f96ff582976e5629766be93e564301dfd51ad708`. Statement, proof, and Lean/Mathlib pins unchanged; only allowed axioms. Evidence: `reviews/merged-proof-check.json`.
  - If review changed the statement, adapt the proof.
  - Either way, re-run `tools/check.sh proofs/oeis-a283508.lean` against the merged file and the platform's current pin; it must print "accepted".

- [ ] **F2 — Take the proof lease.**
  - `tools/oma.sh next --problem oeis-a283508` writes a skeleton with the exact import line; our file must start with that same line.
  - As lead, post a `PLAN:` note within 10 minutes (use the outline at the top of the proof) and beat every 7 minutes.

- [ ] **F3 — Check and submit.**
  - `tools/oma.sh check oeis-a283508`, then `tools/oma.sh submit oeis-a283508`. One new file in the pull request, nothing else.
  - Describe the result plainly: an elementary proof of an OEIS conjecture tagged "easy", not a new hard result.

- [ ] **F4 — Record the outcome.**
  - Save the pull request URL and CI verdict in `reviews/`, and update the README.
