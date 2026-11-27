# A283508: pre-submission plan

## Current state

Done and verified locally by `python3 scripts/check.py` (see README for details):

- `statements/oeis-a283508.lean` states all four source conjectures and compiles with only Mathlib.
- All four are proved, and `scripts/Certificate.lean` proves the exact target of `main`.
- The 257×257 cyclic reference grid is proved equivalent to the infinite grid for every published term.

Nothing has been leased or submitted. The workspace is published at https://github.com/ddanila/lefttosolve. Publication and clean-checkout validation are tracked below. The earlier gap audit and its eleven completed tasks are in git history (`95ef7cc`, `0688014`, `b17fb73`).

Stages A–C are complete. The final statement passed the official checker and an independent formulation review; the follow-up proof passed isolated and official rehearsal checks. Stage D remains pending Danila’s per-step confirmations. Upstream human review has not yet occurred.

## Stage A — Polish the statement file

These change `statements/oeis-a283508.lean`. After each one, update `scripts/Certificate.lean` and the assertions in `scripts/check.py` to match, and re-run the check.

- [x] **A1 — Inline the proposition into `main`.**
  - **Evidence (2026-11-27):** Removed Target; main and certified inline the same conjunction. type_of% checks exact agreement. Full check passed after this change.
  - Today `main : Target` hides the claim behind a `def`. The brief's skeleton and style examples put the proposition directly in the theorem.
  - Remove `Target` and write the four-part conjunction as the type of `main`.
  - Done when: the certificate proves the same inlined proposition and `check.py` passes.

- [x] **A2 — Use the standard Rule 187 orientation.**
  - **Evidence (2026-11-27):** Lean and Python now use 4*left + 2*centre + right. rule_readable is centre OFF or right ON; state_succ places the hole at -n. All 1001 terms still match.
  - The Lean rule indexes the bit as `left + 2*centre + 4*right`, following the Maple program literally. Wolfram's numbering, which the name "Rule 187" and the entry's Mathematica program use, is `4*left + 2*centre + right`. The two are mirror images.
  - The sequence is unchanged (symmetric seed, centre column), but a reviewer checking against the standard convention would see the wrong rule.
  - Switch to the Wolfram indexing, adapt `A283508/Rule187.lean` (the OFF cell then travels left instead of right), and say in a comment that the Maple program mirrors it.
  - Done when: `rule_readable` reads "centre OFF or right ON", `sequence_eq` still holds, and the Python Rule 187 simulator uses the same indexing and still matches all 1001 terms.

- [x] **A3 — Match the skeleton header.**
  - **Evidence (2026-11-27):** Added the title, Source, and Credit: @ddanila, using the handle confirmed in this session. Full check passed.
  - Add the skeleton's title line and the `Source:` and `Credit: @<GitHub handle>` lines. **Needs the handle from Danila.**
  - Done when: the header has the same fields as the skeleton in `sources/agent.txt`.

- [x] **A4 — Record every interpretation choice in the file itself.**
  - **Evidence (2026-11-27):** Recorded offset, background, crop, bit order, decimal encoding, diagram conflict, cyclic/infinite reading, Rule 187 reflection, primary definition choice, and unit denominator in the statement. Full check passed.
  - The brief requires ambiguous readings to be stated in a comment citing the source. The reviewer sees only this file, not the README.
  - Add short comments for: the background is updated like any other cell; "right edge" means position `n` at stage `n`; the digits are bits written in base 10; offset 0; the generating function is stated as a product because the denominator is a unit; A267623 is defined from its primary "middle column" description, not its secondary Rule 643 comment, which conflicts with its own terms.
  - Done when: each choice in the README's source audit that affects the statement has a one-line counterpart in the file.

- [x] **A5 — Trim the file to what the statement needs.**
  - **Evidence (2026-11-27):** Removed the duplicate bit definition; every remaining definition feeds main. Retained explicit arithmetic/decimal recursion for readability; rationale in reviews/platform-review.md. Full check passed.
  - Check for duplicated or unused definitions (for example the second `bit` inside `A267623`) and prefer Mathlib where it fits (`Bool.toNat`, `Nat.testBit`, `Nat.ofDigits`), but only where it makes the statement easier to read.
  - Done when: every definition is used by `main`, and the file reads top to bottom without the README.

## Stage B — Check against the platform's real rules

- [x] **B1 — Read the platform instructions.**
  - **Evidence (2026-11-27):** Archived join.txt with provenance. Recorded real statement/proof rules in reviews/platform-review.md. One conjunctive main is accepted; follow-up proofs import OMAStatements and prove OMA.solution with type_of%.
  - Read https://lefttosolve.com/join.txt once, as the brief says, and save a copy under `sources/` with provenance.
  - Note anything that contradicts the assumptions in this plan: file layout, allowed imports, how credit is given, whether one `main` may hold several conjectures, and how proofs are submitted after a statement is merged.

- [x] **B2 — Match the platform's toolchain.**
  - **Evidence (2026-11-27):** All Lean and dependency revisions match the real checker pin. Checked against formal-conjectures 9097e2f90e66d2f6244209cb1c07f7120d17ec53; no pin changes needed.
  - Find the Lean and Mathlib versions the platform's checker uses and compare with `lean-toolchain` and `lake-manifest.json`. The current pin follows a formal-conjectures commit, which is an assumption.
  - Done when: the statement compiles on the platform's versions, or the pin is changed to them and `check.py` passes.

- [x] **B3 — Run the official checker.**
  - **Evidence (2026-11-27):** Unmodified tools/oma.sh check oeis-a283508 accepted the final file without a lease. reviews/official-check.json pins the verdict to its SHA-256; scripts/platform_check.py reproduces it.
  - Obtain `tools/oma.sh` and run `tools/oma.sh check oeis-a283508`. Do not run `next` or `submit` yet.
  - If `check` cannot run without a lease, record that and move this task to Stage D.
  - Done when: the check passes, and `official_checker` in `reviews/validation.json` is no longer "unverified".

- [x] **B4 — Refresh the live data.**
  - **Evidence (2026-11-27):** Archived refreshed page, brief, API response, and both OEIS entries with provenance. Still unformalized, zero live agents, no solution; source conjecture lines unchanged. Refresh again on the eventual submission day.
  - Re-fetch the problem page and the OEIS entry. Confirm the problem is still open, nobody else holds it or has already stated it, and the conjecture lines in the entry are unchanged.
  - Done when: `sources/` and its hashes reflect the day of submission.

## Stage C — Final review and housekeeping

- [x] **C1 — Prepare the proof for the follow-up.**
  - **Evidence (2026-11-27):** proofs/oeis-a283508.lean is assembled by scripts/package_proof.py in the required import/type_of% format. It compiles in isolation against only Mathlib and the proposed statement; OMA.solution uses only the three allowed axioms.
  - Once the statement is merged it becomes provable by everyone, and we already have the proof. Assemble it into the form B1 says proofs must take (most likely one file importing only Mathlib that proves `main`).
  - Done when: that file compiles in isolation and its axioms are only `propext`, `Classical.choice`, `Quot.sound`.

- [x] **C2 — Independent read of the final statement.**
  - **Evidence (2026-11-27):** Fresh review agent read only the final statement and two OEIS entries, with no inherited history. Signed off on SHA-256 41b9b5ddced91483eff7ffd2faa972326e0b71f5086d138eea3f91b59b699285; see reviews/independent-statement-review.md. Upstream human review remains separate.
  - Someone who has not worked on it reads the final file against the two OEIS entries only. **Danila, or a fresh reviewer.**
  - Done when: the reviewer signs off or their comments are resolved.

- [x] **C3 — Put the repo on a remote.**
  - Danila authorized a public repository under ddanila. Created https://github.com/ddanila/lefttosolve and pushed main (implementation commit f81bd08). Official submissions use a separate upstream fork.
  - Done when: `main` is pushed.

- [x] **C4 — Bring the docs up to date.**
  - Updated README for the inline proposition, standard Rule 187 orientation, official acceptance, public remote, and follow-up proof format. `python3 scripts/check.py` passed from clean detached checkout f81bd08, reusing only the dependency cache; tracked files remained unchanged.
  - Done when: `check.py` passes on a clean checkout and the README matches the files.

## Stage D — Submit (last)

Only after every task above is done or explicitly waived. These steps are visible to others, so Danila confirms before each one.

- [ ] **D1** — `tools/oma.sh next --problem oeis-a283508` to take the lease, then put the final statement in place.
- [ ] **D2** — `tools/oma.sh check oeis-a283508` once more.
- [ ] **D3** — `tools/oma.sh submit oeis-a283508`.
- [ ] **D4** — Update the README's "no lease, no submission" line and record the submission reference.
- [ ] **D5** — After the statement is merged, submit the proof prepared in C1.
