# OEIS A283508: Rule 643 in Lean

The closed-form conjecture and recurrence are proved for the infinite-grid interpretation of the OEIS reference program. The project builds with **Lean 4.33.1** and the exact Mathlib revision used by formal-conjectures commit `9097e2f90e66d2f6244209cb1c07f7120d17ec53`.

For every `n > 0`, the Lean kernel checks

```text
a(n) = (91 * 10^n - 10) / 90
```

The stronger exact identity `90*a(n)+10 = 91*10^n` also holds, so natural-number division has not weakened the claim. For `n > 2`, the source's recurrence is proved as well:

```text
a(n) = 11*a(n-1) - 10*a(n-2)
```

This is local work. No problem lease, submission, remote repository, or claim of a newly discovered mathematical result has been made. The separate generating-function conjecture and equality with A267623 are not formalized here.

## Why the proof is short

Initially only the origin is ON. At step 1, every cell is ON except the four orthogonal neighbours of the origin. At step 2, every cell is ON except the eight cells surrounding the origin. The latter configuration is fixed under Rule 643.

The proof checks cells in `[-2,2] × [-2,2]` by kernel reduction and handles all remaining cells using an exterior lemma. Induction then proves stability forever. Reading the horizontal axis gives `1`, `10`, `101`, `1011`, and so on. The final arithmetic proof uses the decimal append operation `v ↦ 10*v+1`.

## Reproduce

Python 3 and elan are required. With elan installed:

```sh
export PATH="$HOME/.elan/bin:$PATH"
lake exe cache get
python3 scripts/check.py
```

The pinned toolchain and dependencies download when needed. A fresh setup needs several GB; this checkout already has the toolchain and cache. `scripts/check.py` runs the build, both independent simulators, the Lean computation samples, and the axiom audit. It writes the latest validation results into `reviews/`.

The completed run checks all 32 neighbourhoods and all 127 supplied OEIS terms, indexed 0 through 126. Lean additionally checks direct computations at indices 0–3 and evaluates indices 0–6. The main proof has no `sorry`, added axioms, `native_decide`, or unsafe implementation. Its only axioms are `propext`, `Classical.choice`, and `Quot.sound`.

## Files

- `A283508/Basic.lean`: rule bits, infinite grid, evolution, observation and decimal encoding.
- `A283508/Proof.lean`: first two steps, fixed configuration, axis pattern, formula, exact identity and recurrence.
- `A283508/Locality.lean`: independence from arbitrary, time-varying boundary values when sufficiently padded.
- `scripts/validate.py`: independent sparse bit-rule and dense readable-rule simulations.
- `scripts/check.py` and `scripts/Checks.lean`: reproducible checks and axiom audit.
- `sources/`: saved source material and SHA-256 provenance manifest.
- `reviews/`: raw local-model requests/responses, review disposition, and verification output.

## Source and semantic audit

Source: [OEIS A283508](https://oeis.org/A283508), its [internal entry and Mathematica program](https://oeis.org/A283508/internal), and [Robert Price's table](https://oeis.org/A283508/b283508.txt), retrieved 2026-11-27. OEIS material is attributed to the OEIS Foundation and the contributors named in the archived entry and is provided under its [CC BY-SA 4.0 terms](https://oeis.org/wiki/The_OEIS_End-User_License_Agreement). Source snapshots retain their original content.

The translation decisions are:

1. **Rule indexing.** `IntegerDigits[643,2,10]` lists bits most significant first. The source indexes that list at `10-(c+2*k)`, which selects zero-based bit `c+2*k`. Lean defines that bit using division and remainder, then proves the readable truth table for both centre states and all neighbour counts 0–4.
2. **Simultaneous updates.** Every next cell reads only the previous grid. The neighbourhood is the centre plus the four orthogonal neighbours. Their order does not matter because only their count is used.
3. **Background.** The infinite initially OFF background becomes ON at step 1 because bit 0 is 1. There is no special first-step rule and no permanently OFF infinite exterior. At later times the uniform ON background stays ON because bit 9 is 1.
4. **Observation window.** “Right edge” means the displayed crop at position `n`, not the boundary of a finite ON population: the grid already has infinitely many ON cells at time 1. Read `x=0..n` on `y=0` after exactly `n` updates.
5. **Decimal encoding.** The source explicitly uses `FromDigits[...,10]`. Thus `1011` denotes decimal 1011, despite its digits being cell bits. Lean's recursive encoding uses base 10.
6. **Padding.** The dense validator stores coordinates through `±(2*N+1)`, freezes that outermost border OFF, and updates the interior through `±2*N`. `observed_window_correct` proves arbitrary border behavior cannot affect any read digit for `n ≤ N`. This justifies the independent finite simulation; we do not claim to have executed or formally verified Mathematica itself.
7. **Source inconsistency.** The linked diagrams explicitly say Rule 641 and show an OFF origin at odd steps. The entry, program and sequence table specify Rule 643. We follow the latter three and do not use those diagrams as validation evidence.

The remaining trust boundary is the human interpretation of the OEIS entry and program as this infinite-grid automaton. The code, truth-table check, independent simulations, exact sample agreement and padding theorem support that interpretation. Lean verifies the resulting statement and proof; upstream human review has not occurred.
