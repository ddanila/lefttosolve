# A283508: submission plan

## Current state (2026-11-27)

Everything needed to submit the statement is done; the history is in git (`95ef7cc` … `0e14928`).

- **Statement:** `statements/oeis-a283508.lean` states all four source conjectures. The official `tools/oma.sh check` accepted it, and an independent agent review found no mismatch with the two OEIS entries. SHA-256 `41b9b5dd…9285`.
- **Proof:** `proofs/oeis-a283508.lean` (257 lines) proves `OMA.solution` directly on the statement's definitions. The platform's `tools/check.sh` accepted it in a local rehearsal, on `propext`, `Classical.choice`, `Quot.sound` only.
- **Lease:** taken under @ddanila at 10:31 UTC, role lead. Nothing has been submitted.
- **Repo:** published at https://github.com/ddanila/lefttosolve; `python3 scripts/check.py` passes.

P1–P4 were completed before submission at Danila’s request. The statement file is unchanged. The remaining submission order is: submit the statement first (Stage 1), improve the proof while the statement waits for human review (Stage 2), then submit the proof (Stage 3).

Steps that are visible to others (lease, notes, submit, pull requests) need Danila's confirmation each time.

## Stage 1 — Submit the statement

- [ ] **S1 — Confirm the lease is alive.**
  - The platform expects `tools/oma.sh beat oeis-a283508` every 7 minutes while a lease is held; a 410 response means it expired. No beat has been recorded since the lease was taken.
  - If it expired, take it again with `tools/oma.sh next --problem oeis-a283508` and re-copy the statement.
  - Done when: a beat succeeds, or a fresh lease is held.

- [ ] **S2 — Final pre-flight.**
  - Re-fetch the problem page and confirm it is still unformalized and nobody else has stated it.
  - Confirm `.oma/platform/statements/oeis-a283508.lean` still has SHA-256 `41b9b5dd…9285`.
  - Run `tools/oma.sh check oeis-a283508` under the lease.
  - Done when: the check prints "accepted" for that hash.

- [ ] **S3 — Submit.**
  - `tools/oma.sh submit oeis-a283508`. The pull request must contain only the one statement file.
  - Done when: the pull request URL is recorded in `reviews/`.

- [ ] **S4 — Update the docs.**
  - Replace the README's "no lease, no submission" wording and update `reviews/lease-acquired.json`.

## Stage 2 — Improve the proof while the statement is in review

P1–P4 completed locally on 2026-11-27. No lease, note, or submission action was performed during this proof-polishing work.

- [x] **P1 — Harden the tactics against a Mathlib bump.**
  - **Completed / evidence:** Replaced non-terminal simplification in stable_axis and step187_initial with the explicit simp? lemma lists. Restructured generating_function so its general simp calls are terminal. The final local check and unmodified official tools/check.sh both pass; see reviews/proof-preflight.json.
  - Human review of the statement may take days, and the platform could move its Mathlib pin in that time. Three places would be the first to break:
    - `stable_axis` and `step187_initial`: a bare `simp [...]` followed by `omega`.
    - `generating_function`: a bare `simp` followed by `simpa`, after a long `simp only`.
  - Replace each non-terminal `simp` with `simp only [...]` using the lemma list from `simp?`, or restructure so `simp` closes the goal.
  - Done when: no `simp` without `only` is followed by another tactic, and both the local check and `tools/check.sh` still accept the file.

- [x] **P2 — Keep one copy of the argument in the repo.**
  - **Completed / evidence:** The proof file is now the single argument source. Removed the three duplicate proof modules, scripts/Certificate.lean, and unused first/stable reference definitions. scripts/ReferenceBridge.lean proves state_matches_statement and observed_statement_torus_correct. check.py compiles the proof in isolation and audits the retained reference results plus the bridge; README file list updated.
  - The same proof now exists three times: `A283508/Proof.lean` + `GeneratingFunction.lean` + `Rule187.lean`, the bridge in `scripts/Certificate.lean`, and the submitted `proofs/oeis-a283508.lean`. A fix in one will not reach the others.
  - Make the proof file the single source: delete those three modules and the certificate, and let `check.py` rely on the isolated compile of the proof file, which it already runs.
  - Keep `A283508/Basic.lean`, `Locality.lean` and `Torus.lean`: they hold the reference-program results that the submitted proof does not need. Add one lemma tying `A283508.state` to the statement's `state` so the torus theorem is about the published definitions.
  - Done when: `check.py` passes, `scripts/Checks.lean` audits only what remains, and the README file list matches.

- [x] **P3 — Tidy the generating-function proof.** Optional.
  - **Completed / evidence:** Added coeff_series_mul_X and recurrence_coefficient. The generating-function proof now ends with four short coefficient cases, using initial values for 0, 1, 2 and the recurrence thereafter. Both checker runs pass.
  - It is the least readable part (20 lines of coefficient bookkeeping). Split out a lemma giving the coefficient of `series * X^k`, so the main proof is a four-way case split with one line per case.
  - Skip if P1 already leaves it clear enough.

- [x] **P4 — Fresh-eyes read of the proof.** Optional.
  - **Completed / evidence:** Fresh reviewer read only the proof file with no history. Three low-severity comment suggestions were addressed; a second read confirmed no remaining findings. Final SHA-256 94f8bcdcf0afde79daa4281f459da276b231475160dcbdad37e567f8c1b8e0fa; see reviews/proof-readability-review.md.
  - The kernel settles correctness, so this is only about whether the outline and lemma names let a reader follow the argument. A reviewer with no history reads the file top to bottom and reports what was unclear.

## Stage 3 — Submit the proof

Only after the statement pull request is merged.

- [ ] **F1 — Re-validate against the merged statement.**
  - If review changed the statement, its hash differs and the proof must be adapted. Either way, re-run `tools/check.sh proofs/oeis-a283508.lean` against the merged file and against the platform's current pin.
  - Done when: the verdict is "accepted" with the merged statement's hash.

- [ ] **F2 — Take the proof lease and follow the lead-role rules.**
  - `tools/oma.sh next --problem oeis-a283508` writes `proofs/oeis-a283508.lean` with the exact import line and target; our file must start with that same line.
  - As lead, post a `PLAN:` note within the first 10 minutes (the outline at the top of the proof is the text), and beat every 7 minutes.

- [ ] **F3 — Check and submit.**
  - `tools/oma.sh check oeis-a283508`, then `tools/oma.sh submit oeis-a283508`. One new file in the pull request, nothing else changed.
  - Describe the result plainly in the pull request: an elementary proof of an OEIS conjecture tagged "easy", not a new hard result.

- [ ] **F4 — Record the outcome.**
  - Save the pull request URL and the CI verdict in `reviews/`, and update the README.
