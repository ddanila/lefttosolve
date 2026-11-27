# A267622 — local implementation plan

Scope: local planning, formalization, proof, and validation only. No lease, platform notes, submission, or remote push is authorized for this task.

- [x] Archive the original OEIS definition/program and b-file; document offset, rule orientation, crop, and decimal encoding.
- [x] Write a standalone Mathlib-only statement of both source conjectures, based on the cellular automaton rather than the conjectured recurrence.
- [x] Prove the Rule 187 moving-hole invariant, the row encoding, recurrence, and generating function. Reuse the established argument from A283508 with explicit attribution.
- [x] Compare an independent finite simulation with all published terms and check crop boundaries/orientation; compile the statement and proof in isolation and audit axioms.
- [x] Run the official checker locally, record results and hashes, and document correctness and future submission requirements.

The source recurrence is stated only for n > 2. The generating function is expressed as a product identity over formal power series over integers; its denominator has constant coefficient 1.

## Completed locally

Both official checker rehearsals accepted. The isolated proof audit permits only `propext`, `Classical.choice`, and `Quot.sound`. Independent simulation matches all 1,001 source terms. The semantic review is in README.md; evidence and immutable source hashes are in `reviews/` and `sources/provenance.json`.

Future publication is a separate, unapproved phase: check current activity and PRs, obtain authorization, and revalidate current platform state before any lease, note, push, or submission.

## Follow-up polish and independent review

- [x] Harden the non-terminal simplification, restore the source title, and polish proof documentation.
- [x] Archive the platform brief with provenance.
- [x] Obtain a fresh statement review against the OEIS source alone.
- [x] Normalize temporary paths; verify repeated check output is stable and include A267622 in the root check.
- [x] Refresh local official-check evidence for the final hashes.

Publication decision: retain the explicit local-only boundary. LESSONS.md recommends public provenance when publication is authorized; it does not override that boundary. The source is committed locally, with no claim that the local commit establishes an independent public timestamp.

Follow-up validation: root `python3 scripts/check.py` passes for both problems. A standalone A267622 run followed by the root run produced byte-identical `lean-check.txt` and `local-check.json`. Both official checks accepted the final source hashes. Fresh independent review found no semantic corrections and preserves its separate simulator.
