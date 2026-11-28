# A267610 — checked counterexample, prepared locally

The printed conjecture `a(n) = A267700(n) - n` is false at **n=2**:
the left side is 2, while the right side is 2−2=0. Both OEIS offsets are zero.
The [statement](../../statements/oeis-a267610.lean) preserves the source's two
formula claims and their original indices. The [disproof](../../proofs/oeis-a267610.lean)
refutes their conjunction via the first claim. It does **not** refute the
separate generating function.

The first Rule 182 crops are `1`, `111`, `10101`. The sequence counts OFF cells
cumulatively through the current row, giving 0,0,2. A267700's published program
and its binary-containment interpretation both give 0,1,2.

## Validation

- Isolated Lean compilation verifies the exact root-qualified negated target.
- Official, unmodified checker accepts both statement and disproof in a local
  checkout containing the proposed statement. This is not an upstream acceptance.
- Only propext, Classical.choice and Quot.sound are used by the disproof.
- Proof length: 276 counted characters.
- Official proof check: 11.18 s, 5,855,084,544 bytes peak macOS RSS (including build).
- Independent simulation matches all 1,001 A267610 b-file terms; binary-subset
  enumeration checks all 70 A267700 terms; digit sums check 16,384 A006046 terms.
- The cleared generating-function identity matches 1,001 coefficients.
- The shifted relation `a(n) = A267700(n+1) - (n+1)` passes through n=1000;
  no all-n proof of that corrected relation is claimed.

Run `python3 problems/a267610/check.py` or the root `python3 scripts/check.py`.
The local report normalizes temporary paths. Source hashes are checked.

## Submission readiness

Everything remains local: no lease, notes, push or PR. The platform still needs
a first statement, human review, then a disproof submission against the merged
statement. Drafts: [statement PR](statement-pr.md), [disproof PR](proof-pr.md).
The draft clearly discloses the counterexample before statement review; it does
not silently repair the conjecture. See [PLAN.md](PLAN.md).

Relevant prior mathematics is recorded in [the source review](reviews/source-review.md).
No claim to first discovery is made.
