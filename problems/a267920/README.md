# A267920 — Rule 243 row encoding in base 10

Local statement and proof of both conjectures in the [platform brief](https://lefttosolve.com/p/oeis-a267920), from [OEIS A267920](https://oeis.org/A267920). This work is not submitted or published.

Rule 243 outputs ON exactly when the centre is OFF or the left neighbour is ON. From a single ON origin, time 1 is ON everywhere except at 0. The hole then moves right each step. At time n+1, the crop [-(n+1),n+1] is 2n+1 ones followed by 0,1.

The full encoding is therefore 100 times an all-ones prefix plus 1. Extending that prefix by two bits gives a(n+1)=100a(n)+1001 for n>=1. Adjacent instances yield the requested homogeneous recurrence; coefficient shifts yield the generating function with numerator 1+1000X².

## Source-to-statement mapping

| Source convention | Lean definition |
| --- | --- |
| Single ON cell on infinite OFF background | `initial : ℤ → Bool` |
| Standard Wolfram Rule 243 | `rule` uses weights 4,2,1 and bit extraction |
| Simultaneous evolution | `step`, `state` |
| Row at time n, crop [-n,n], left to right | `encode (state n) (-n) (2*n+1)` |
| Default FromDigits base 10, bits written as decimal digits | Encoding multiplier 10 |
| Offset 0 | `a 0 = 1` |
| Recurrence only for n>2 | Strict bound `2 < n`; arithmetic in ℤ |
| Formal generating-function quotient | Product identity in `PowerSeries ℤ` |

The denominator has constant coefficient 1 and is therefore a unit, so the product identity specifies the formal quotient. The initial OFF background becomes ON after one step; the crop is not a finite ON population. Neither conjecture defines the sequence.

## Relationship to the companion problem

[A267921](../a267921/README.md) observes exactly the same row and crop. A267920 writes the bits as decimal digits; A267921 evaluates them as a binary integer. For example, the time-2 row is 11101, giving decimal-digit encoding 11101 and binary value 29. Rule 243 reflects our Rule 187 dynamics from A267622: the hole moves right, making the zero second from the right rather than second from the left. The proofs share their argument but each imports only its own statement, preserving standalone submission readiness.

## Reproduction and review boundary

Run `python3 problems/a267920/check.py`, or the root `python3 scripts/check.py`. The isolated checker compiles the statement/proof, audits allowed axioms, checks initial Lean samples, and directly simulates Rule 243 against all 1,001 b-file terms. Reports normalize temporary paths. The joint checker verifies that every decimal-digit row encodes its companion binary value and checks Lean's two state definitions agree.

This mapping is an author source review. A fresh independent statement review remains a pre-publication step. Sources and immutable hashes are under `sources/`; local evidence is under `reviews/`. The original source title is preserved apart from line wrapping.

## Validation result

Both official local checker modes accepted. The isolated proof uses only `propext`, `Classical.choice`, and `Quot.sound`. All 1,001 source terms match direct simulation. The joint state equality is proved using only `propext`; all paired base conversions pass. Root checks pass for all five problems, and standalone reruns produce byte-identical reports. Exact hashes, pins, and verdicts are in `reviews/`.
