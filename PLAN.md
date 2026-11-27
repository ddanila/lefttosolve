# Plan

## Gaps

Found by auditing the Lean statement against the saved OEIS entry (`sources/A283508.html`) and the Left to Solve brief (`sources/agent.txt`) on 2026-11-27. The definitions in `A283508/Basic.lean` and the ranges of `formula` (`n > 0`) and `recurrence` (`n > 2`) match the source; the gaps below are about what is missing around them.

### 1. Deliverable is not in the format the brief asks for

The brief asks for a statement file, not a proof:

- path `statements/oeis-a283508.lean`
- `import Mathlib`
- namespace `OMA.S_oeis_a283508`
- definitions with no `sorry` and no `axiom`
- a single `theorem main` whose body is the only `sorry`

The repo instead has a fully proved `A283508.formula` and `A283508.recurrence` under a different namespace and layout, with narrow Mathlib imports. It would not pass `tools/oma.sh check oeis-a283508` as is.

To close: add `statements/oeis-a283508.lean` that reuses the definitions from `A283508/Basic.lean` and states `main` as the conjunction of the source conjectures (see gap 2 for which ones).

### 2. Two of the four source conjectures are not stated

The OEIS entry lists:

| Source conjecture | Status |
| --- | --- |
| `a(n) = (91*10^n - 10) / 90` for `n > 0` | stated and proved (`formula`, `exact_identity`) |
| `a(n) = 11*a(n-1) - 10*a(n-2)` for `n > 2` | stated and proved (`recurrence`) |
| G.f. `(1 - x + x^2) / ((1 - x)*(1 - 10*x))` | not stated |
| `a(n) = A267623(n)` | not stated |

- **Generating function.** It is equivalent to the closed form together with `a 0 = 1`, and `a 0 = 1` is currently only an `example` in `scripts/Checks.lean`. To close: state it as a theorem, either as a `PowerSeries ℤ` identity `mk a * ((1 - X) * (1 - 10 * X)) = 1 - X + X^2` or as the coefficient facts `a 0 = 1`, `a 1 = 10`, `a 2 = 101` plus the recurrence.
- **A267623.** This needs a second automaton defined from the A267623 entry, whose source is not yet saved under `sources/`. To close: archive that entry, define its sequence, and state `∀ n, a n = A267623.a n`.

### 3. `Locality.lean` does not cover the Mathematica reference program

`window_correct` justifies the repo's own dense validator, which freezes an OFF border. The OEIS Mathematica program is different: `ListConvolve[..., a, 2]` is cyclic, so it runs on a 257×257 torus.

Applied to that torus, the generic light-cone bound in `window_correct` only guarantees the read cells up to about `n = 63`, not the published `n = 126`. The full range holds for a different reason: the torus is the infinite grid with seeds on the lattice `(257ℤ)²`, and the cell `(m, 0)` with `m ≤ n` at step `n` depends only on initial cells within L1 distance `n`, while the nearest other seed is at distance `257 - n > n`.

This does not affect the correctness of the statement, and the 127 b-file terms agree with the infinite-grid model. To close (optional): prove that two initial grids agreeing on the L1 ball of radius `n` around a cell give the same value there after `n` steps, and apply it to the periodic seed configuration; also correct README item 6 if it is read as covering the Mathematica program.

### 4. Natural-number arithmetic in the statements (no action needed)

`formula` and `recurrence` use truncating `-` and `/` in `ℕ`. This does not weaken either claim: `exact_identity` shows the division is exact, and the `ℕ` recurrence implies the `ℤ` one because `a n > 0`. A reviewer may still prefer the recurrence stated in `ℤ`; decide when writing the statement file for gap 1.
