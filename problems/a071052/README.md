# A071052 — Rule 150 zero-count recurrence

Complete local Lean proof against the exact merged statement by @seanm27lol.
Publication and submission authorized; exact current-main validation passed.

- [Unchanged upstream statement](../../statements/oeis-a071052.lean).
- [Standalone proof](../../proofs/oeis-a071052.lean).
- [Source audit and prior-proof comparison](reviews/source-review.md).
- [Official checker result](reviews/official-proof.json).
- [Submission plan](PLAN.md) and [draft PR description](proof-pr.md).

## Argument

Two Rule 150 updates cancel repeated XOR terms. Consequently row 2n is row n
with one OFF cell inserted between every pair of adjacent cells. Its even
positions reproduce row n, and its 2n odd positions are all OFF. Therefore
`a(2n) = a(n) + 2n`, including n=0.

The proof establishes the pointwise identity for all integer coordinates before
counting the finite row. It imports only the upstream statement and uses no
polynomial infrastructure, large tables, native decision procedure or extra axiom.

## Validation and size

Run `python3 problems/a071052/check.py`, or the root `python3 scripts/check.py`.
The isolated checker checks the exact root-qualified target and allows only
`propext`, `Classical.choice` and `Quot.sound`. Independent numbered-rule and
F₂-polynomial simulations agree through time 256; all 67 archived terms and
129 doubled-row comparisons pass, with seven additional small Lean values.

The official checker accepts the proof. Its complete local invocation took
3.20 seconds at 1,381,072,896 bytes peak macOS RSS. This is not a capped Linux
runner measurement. Temporary paths are normalized in reproducible reports.

The official length tool counts 1,481 characters, versus 2,193 in @agchua's
pending [PR #21850](https://github.com/lefttosolve2/open-math-agents/pull/21850):
712 characters, or 32.5%, fewer. That PR targets different proposed definitions
and is not a currently accepted proof of the merged statement. Recheck main and
measure against any actually merged proof before claiming replacement eligibility.
