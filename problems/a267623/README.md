# A267623 — Rule 187 middle column

Local statement and proof of the two conjectures selected by the [platform](https://lefttosolve.com/p/oeis-a267623), from [OEIS A267623](https://oeis.org/A267623). The complete work is published. Statement [PR #7472](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7472) merged unchanged at 14:58:01 UTC. The official exact-target proof recheck passed; proof [PR #7656](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7656) is submitted. Progress is tracked in PLAN.md.

The row at time 1 is ON everywhere except at the origin. The hole moves left at each later step. Consequently the centre column, read downwards from time 0, is 1,0,1,1,... . Decimal encoding of its first n+1 bits gives 1,10,101,1011,... . For n>=1, a(n+1)=10a(n)+1; this implies both requested identities.

## Statement fidelity

| Source convention | Lean definition |
| --- | --- |
| Single ON cell on infinite OFF background | `initial : ℤ → Bool` |
| Wolfram Rule 187, simultaneous updates | `rule`, `step`, `state` |
| Middle cell of each row | `state m 0` |
| First n+1 centre bits, oldest first | `column (n+1)` |
| Mathematica `FromDigits` defaults to decimal | `10 * column m + bit (state m 0)` |
| Offset 0 | `a 0 = 1` |
| Recurrence only for n>2 | `∀ n : ℕ, 2 < n → ...`, over integers |
| (1-x+x²)/((1-x)(1-10x)) | Formal power-series product identity over ℤ |

The denominator has constant coefficient 1, so the product identity specifies the unique formal quotient. No convergence assumption is introduced. The Maple source uses a reflected spatial coordinate convention; reflection fixes the centre, so it gives the same time column. The Mathematica source directly matches the Lean orientation. This is a temporal column, not the spatial row crop used in A267622.

The full OEIS entry also has empirical closed-form observations. These are outside the two-conjecture platform target. The conjectured recurrence is not used to define the sequence.

## Reproduction

Run `python3 problems/a267623/check.py`, or `python3 scripts/check.py` for all three problems. The problem checker builds statement and proof in isolation, audits allowed axioms, evaluates initial Lean terms, and simulates the truth table directly on a shrinking finite window. It compares all available b-file terms and checks the recurrence and generating-function coefficients separately. Temporary paths in saved logs are normalized.

The proof reuses the moving-hole argument from our A267622 proof, itself adapted from A283508. It imports only its own statement and Mathlib. A fresh independent source-to-statement review found no corrections; see `reviews/independent-statement-review.md`. Its separate simulator matched all 1,001 terms and verified reflected-orientation agreement.

## Validation result

Both official checker rehearsals accepted. The isolated proof uses only `propext`, `Classical.choice`, and `Quot.sound`. Direct simulation matches all 1,001 OEIS terms (indices 0–1000). The root check passes for all three problems; a standalone rerun produces byte-identical saved reports. Exact source hashes, toolchain pins, and checker verdicts are preserved under `sources/` and `reviews/`.
