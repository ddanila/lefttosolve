# A273539 — Rule 779

Complete local Lean proof of all four source conjectures. Nothing for A273539
has been pushed, leased, posted, or submitted. The statement and proof are ready
for a submission preflight when publication is authorized.

- [Statement](../../statements/oeis-a273539.lean): direct synchronous cellular
  evolution, all three alternative rules, closed form, recurrence, and generating function.
- [Standalone proof](../../proofs/oeis-a273539.lean): proves the exact statement
  type; imports only that statement and Mathlib modules.
- [Source audit](reviews/source-review.md), [local checks](reviews/local-check.json),
  [official statement verdict](reviews/official-statement.json),
  [official proof verdict](reviews/official-proof.json).
- [Remaining submission steps](PLAN.md).

## Mathematical argument

At every positive time one checkerboard class is entirely ON. This also proves
that Rules 779, 795, 843, and 859 have identical states at every generation.
For the remaining class, use coordinates
`u=(t+x+y)/2`, `v=(t+x-y)/2`. OFF cells follow a four-parent rule: the new value
is true exactly when one or two parents are true. At time 1 this auxiliary
system agrees with the source grid's four OFF neighbours of the origin.

An automatically discovered binary machine has 87 states, plus three helper
states. Lean verifies 451 recurrence certificates and all 3,608 transitions,
using kernel reduction in blocks of 32 rows. Induction on input size proves the
machine's recurrence for all inputs, not just the discovery samples. A separate
10-state induction proves that at t=2^n−1 its pattern is the square boundary.
The bridge transforms this into exactly `|x|+|y|=t` on the original grid.

For t>0 this diamond has 4t cells: two in each interior row and one at each end.
Subtracting from the `(2t+1)²` crop gives
`a(n)=5−2^(3+n)+4^(1+n)`. Time zero is checked separately. The recurrence and
formal generating function follow algebraically.

## Reproduce

From the repository root, using the pinned Lean 4.33.1 and Mathlib dependencies:

```sh
python3 problems/a273539/check.py
```

This compiles the statement and standalone proof in an empty temporary directory,
audits the final theorem's axioms, checks exact certificate tables, compares all
four rules by independent evolution through time 63, checks the diamond at six
positive sampled times, and checks all 16 source terms. Temporary paths are
normalized in saved reports. The root `scripts/check.py` includes this checker.
Only the statement's required final placeholder is unproved; the solution's
axioms are limited to `propext`, `Classical.choice`, and `Quot.sound`.

The archived finite witnesses are in `data/`. `certificate.py` checks their
closure and exact rendering into the four main Lean tables. `discover.py` can
rediscover a candidate machine from simulated residuals; it is heuristic and is
not part of the trusted proof. To run it, supply an output path:

```sh
python3 problems/a273539/discover.py /tmp/a273539-machine.json
```

The statement received an author source audit, not a fresh independent-agent
review. Platform human review of its meaning is still required after submission.
The previous statement PR #13806 was withdrawn for incomplete conjecture coverage;
its discussion is archived. Recheck upstream before submitting, since local
readiness does not reserve this problem.

## Resource measurements

After replacing broad Mathlib imports with the specific modules used, isolated
proof compilation on this macOS arm64 host took **31.20 seconds**, peaking at
**3.82 GB RSS**. The same measurement for A273385 was **6.60 GB RSS**. The earlier
A273539 run with broad imports was about 7.68 GB. The final proof is about
239 KiB, below the platform's 512 KiB limit. See [recorded measurements](reviews/resources.json).

Reproduce the direct comparison with `python3 problems/a273539/benchmark.py`.
These are host measurements, not a memory-capped Linux runner test. Import
narrowing changes no mathematical definition or theorem. The closure remains
split into 32-row blocks, and all finite proofs still use kernel reduction.
