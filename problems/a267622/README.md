# A267622 — Rule 187 row encoding

Local implementation of both OEIS conjectures: the recurrence and generating function. The sequence is defined from the cellular automaton itself, not from either conjectured formula.

- Statement: `../../statements/oeis-a267622.lean`
- Proof: `../../proofs/oeis-a267622.lean`
- Reproduce isolated compilation, axiom audit, and independent simulation: `python3 problems/a267622/check.py` from the repository root.
- The root `python3 scripts/check.py` also runs the A267622 check.
- Source snapshot, platform agent brief, and all 1,001 published terms: `sources/` (OEIS Foundation and contributors, CC BY-SA 4.0).
- Validation evidence: `reviews/`.

## Mathematical argument

Rule 187 is equivalent to `not centre OR right`. From the single ON origin, its first row is ON everywhere except at 0. Each subsequent update moves that single OFF cell one position left. Thus at time n ≥ 1 the hole is at 1−n.

The source crops positions −n through n and writes the bits as decimal digits. The hole is at the second position in that crop, giving `101`, `10111`, `1011111`, and so on. Passing to the next row appends two ones, so a(n+1) = 100 a(n) + 11 for n ≥ 1. Subtracting adjacent instances gives the source recurrence. The same recurrence cancels every coefficient of the generating-function product above degree two; the initial coefficients are 1, 0, and 10.

The moving-hole argument and power-series coefficient technique are adapted from our A283508 proof. This proof is standalone apart from its proposed statement and Mathlib; it does not import or assume the earlier conjecture.

## Statement review

| Source feature | Lean interpretation | Check |
|---|---|---|
| Offset 0, one ON cell | `initial x = decide (x = 0)`; `state 0 = initial` | Source offset/program and b-file start at 0 |
| Wolfram Rule 187 | Bit at index `4*left + 2*centre + right` of 187 | All eight cases proved in `rule187`; independent simulator uses direct bit shifts |
| Infinite OFF starting background | Rows are functions `ℤ → Bool`; all cells update | Avoids incorrectly keeping the exterior OFF after time 0 |
| Mathematica `Take` crop | Positions −n through n, exactly 2n+1 cells | `encode (state n) (-n) (2*n+1)` |
| `FromDigits` without base | Decimal digit accumulation, leftmost most significant | Matches `1,101,10111,...`, not base-two values `1,5,23,...` |
| Recurrence for n > 2 | Natural index with hypothesis `2 < n`, equality over integers | No natural subtraction truncation on the right-hand side |
| Generating function | Formal series over integers, indexed from 0 | Product with `(1-X)*(1-100*X)` equals `1+10*X²`; denominator constant term is 1 |

The statement has one intentional placeholder in `main`, as the platform requires. The solution proves its exact type and does not invoke the placeholder theorem; the axiom audit excludes `sorryAx`.

The independent Python simulation starts on [−2N,2N] and shrinks its valid window at every step. At time n ≤ N, its valid interval still contains [−n,n], so no boundary condition can affect any compared bit. It matches the full b-file through n=1000. These finite comparisons check the interpretation; the Lean proof establishes the two claims for all indices.

## Review and reproducibility

A fresh statement review is recorded in `reviews/independent-statement-review.md`. The reviewer was asked to compare only the statement and original OEIS evidence, without relying on this explanation or the proof.

The check normalizes temporary paths to `<isolated-check>` before writing its Lean log. Repeated runs should produce identical `lean-check.txt` and `local-check.json` files. Archived source hashes include the platform brief as retrieved, whose generated timestamp describes that snapshot only.

## Publication boundary

The user authorized publication and the full statement/proof submission sequence on 2026-11-27, including automatic monitoring and routine follow-up without additional approvals. See PLAN.md for progress. Local official-check evidence remains a rehearsal until CI and the platform verdict confirm a submission.

Recheck current agents/notes/PRs and platform pins before submission. Follow `../../LESSONS.md`; a lease does not reserve the problem exclusively. This problem's plan remains separate from the A283508 submission.
