# A283508: pre-submission plan

## Current state

Done and verified locally by `python3 scripts/check.py` (see README for details):

- `statements/oeis-a283508.lean` states all four source conjectures and compiles with only Mathlib.
- All four are proved, and `scripts/Certificate.lean` proves the exact target of `main`.
- The 257×257 cyclic reference grid is proved equivalent to the infinite grid for every published term.

Nothing has been leased, pushed, or submitted. The earlier gap audit and its eleven completed tasks are in git history (`95ef7cc`, `0688014`, `b17fb73`).

What remains is making the statement survive human review and the official checker on the first attempt. Submission is the last step and is not to be started before Stage C is finished.

## Stage A — Polish the statement file

These change `statements/oeis-a283508.lean`. After each one, update `scripts/Certificate.lean` and the assertions in `scripts/check.py` to match, and re-run the check.

- [ ] **A1 — Inline the proposition into `main`.**
  - Today `main : Target` hides the claim behind a `def`. The brief's skeleton and style examples put the proposition directly in the theorem.
  - Remove `Target` and write the four-part conjunction as the type of `main`.
  - Done when: the certificate proves the same inlined proposition and `check.py` passes.

- [ ] **A2 — Use the standard Rule 187 orientation.**
  - The Lean rule indexes the bit as `left + 2*centre + 4*right`, following the Maple program literally. Wolfram's numbering, which the name "Rule 187" and the entry's Mathematica program use, is `4*left + 2*centre + right`. The two are mirror images.
  - The sequence is unchanged (symmetric seed, centre column), but a reviewer checking against the standard convention would see the wrong rule.
  - Switch to the Wolfram indexing, adapt `A283508/Rule187.lean` (the OFF cell then travels left instead of right), and say in a comment that the Maple program mirrors it.
  - Done when: `rule_readable` reads "centre OFF or right ON", `sequence_eq` still holds, and the Python Rule 187 simulator uses the same indexing and still matches all 1001 terms.

- [ ] **A3 — Match the skeleton header.**
  - Add the skeleton's title line and the `Source:` and `Credit: @<GitHub handle>` lines. **Needs the handle from Danila.**
  - Done when: the header has the same fields as the skeleton in `sources/agent.txt`.

- [ ] **A4 — Record every interpretation choice in the file itself.**
  - The brief requires ambiguous readings to be stated in a comment citing the source. The reviewer sees only this file, not the README.
  - Add short comments for: the background is updated like any other cell; "right edge" means position `n` at stage `n`; the digits are bits written in base 10; offset 0; the generating function is stated as a product because the denominator is a unit; A267623 is defined from its primary "middle column" description, not its secondary Rule 643 comment, which conflicts with its own terms.
  - Done when: each choice in the README's source audit that affects the statement has a one-line counterpart in the file.

- [ ] **A5 — Trim the file to what the statement needs.**
  - Check for duplicated or unused definitions (for example the second `bit` inside `A267623`) and prefer Mathlib where it fits (`Bool.toNat`, `Nat.testBit`, `Nat.ofDigits`), but only where it makes the statement easier to read.
  - Done when: every definition is used by `main`, and the file reads top to bottom without the README.

## Stage B — Check against the platform's real rules

- [ ] **B1 — Read the platform instructions.**
  - Read https://lefttosolve.com/join.txt once, as the brief says, and save a copy under `sources/` with provenance.
  - Note anything that contradicts the assumptions in this plan: file layout, allowed imports, how credit is given, whether one `main` may hold several conjectures, and how proofs are submitted after a statement is merged.

- [ ] **B2 — Match the platform's toolchain.**
  - Find the Lean and Mathlib versions the platform's checker uses and compare with `lean-toolchain` and `lake-manifest.json`. The current pin follows a formal-conjectures commit, which is an assumption.
  - Done when: the statement compiles on the platform's versions, or the pin is changed to them and `check.py` passes.

- [ ] **B3 — Run the official checker.**
  - Obtain `tools/oma.sh` and run `tools/oma.sh check oeis-a283508`. Do not run `next` or `submit` yet.
  - If `check` cannot run without a lease, record that and move this task to Stage D.
  - Done when: the check passes, and `official_checker` in `reviews/validation.json` is no longer "unverified".

- [ ] **B4 — Refresh the live data.**
  - Re-fetch the problem page and the OEIS entry. Confirm the problem is still open, nobody else holds it or has already stated it, and the conjecture lines in the entry are unchanged.
  - Done when: `sources/` and its hashes reflect the day of submission.

## Stage C — Final review and housekeeping

- [ ] **C1 — Prepare the proof for the follow-up.**
  - Once the statement is merged it becomes provable by everyone, and we already have the proof. Assemble it into the form B1 says proofs must take (most likely one file importing only Mathlib that proves `main`).
  - Done when: that file compiles in isolation and its axioms are only `propext`, `Classical.choice`, `Quot.sound`.

- [ ] **C2 — Independent read of the final statement.**
  - Someone who has not worked on it reads the final file against the two OEIS entries only. **Danila, or a fresh reviewer.**
  - Done when: the reviewer signs off or their comments are resolved.

- [ ] **C3 — Put the repo on a remote.**
  - The repo has no git remote, so the work exists only on this machine. **Needs a remote URL from Danila.**
  - Done when: `main` is pushed.

- [ ] **C4 — Bring the docs up to date.**
  - Update the README for A1–A5 and B2–B3, and remove statements that are no longer true.
  - Done when: `check.py` passes on a clean checkout and the README matches the files.

## Stage D — Submit (last)

Only after every task above is done or explicitly waived. These steps are visible to others, so Danila confirms before each one.

- [ ] **D1** — `tools/oma.sh next --problem oeis-a283508` to take the lease, then put the final statement in place.
- [ ] **D2** — `tools/oma.sh check oeis-a283508` once more.
- [ ] **D3** — `tools/oma.sh submit oeis-a283508`.
- [ ] **D4** — Update the README's "no lease, no submission" line and record the submission reference.
- [ ] **D5** — After the statement is merged, submit the proof prepared in C1.
