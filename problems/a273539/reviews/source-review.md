# A273539 source-to-statement audit

Author review, 2026-11-28. This is not a fresh independent-agent review or the
platform's human semantic review. The archived full OEIS entry is authoritative;
`agent-brief.txt` lists the same four conjectures.

| Source requirement | Statement representation | Check |
| --- | --- | --- |
| Single ON origin at stage zero | `initial x y = decide (x=0 ∧ y=0)` | Direct definition, no formula substituted for evolution |
| Five-cell von Neumann rule, centre weight 1 and neighbour weight 2 | `rule r c k` selects zero-based bit `bit c + 2*k` | Matches `IntegerDigits[code,2,10]` and source index `10-#` |
| All cells update synchronously | `state r (t+1) = step r (state r t)` on ℤ² | Background is allowed to change; it is not forced OFF |
| Count the source crop at time t | `count r t`, coordinates `x-t,y-t`, each from `range (2*t+1)` | Includes both endpoints of `[-t,t]²` |
| Sample at stage 2^n−1, offset 0 | `a n = count 779 (2^n-1)` | n=0 means time zero, with a(0)=1 |
| Rules 795, 843 and 859 also generate the sequence | First conjunct, all three rules and all n | No alternative omitted |
| a(n)=5−2^(3+n)+4^(1+n) | Second conjunct, all n, equality in ℤ | Prevents incorrect truncated natural subtraction |
| Recurrence for n>2 | Third conjunct, `2 < n`, equality in ℤ | Exactly the stated range; predecessor indices are nonnegative |
| Rational generating function | Fourth conjunct, formal power series over ℤ with denominator multiplied across | Denominator constant coefficient is 1, so it is a unit; no analytic convergence claim |

## Finite source grid versus infinite grid

The source uses a cyclic grid of side 2S+1, initially a single ON cell, then
observes `[-t,t]²` for t≤S. Its periodic infinite lift has initial ON seeds at
multiples of 2S+1 in each coordinate. A radius-one synchronous rule at time t
depends only on the initial Manhattan ball of radius t. For a cell in the
observed crop, every noncentral periodic seed is at Manhattan distance at least
2S+1−t > t. Thus the observed values agree with a single seed on ℤ² throughout
the source horizon. This justifies the unbounded definition for arbitrary n;
it does not assume the closed formula.

The checker independently compares cyclic and padded-grid crops at every time
0…15, and compares the direct sampled evolution with seven source terms through
n=6. All 16 archived terms are checked against the formula, recurrence, and
formal generating-function coefficients. These computations support the
translation; the Lean proof establishes the infinite claims.

## Withdrawn statement #13806

The earlier PR was closed without merging. Its author explicitly withdrew it
because it conjoined only part of the page's conjectures. The saved discussion
is `sources/pr-13806.json`; in particular our first conjunct includes the three
alternative rules. Closure was not evidence that the problem had been solved.

## Proof bridge audit

The finite machine is NOT the definition of the source sequence. Its recurrence
is checked against a four-parent update, then `bridge` proves its relationship
to the original `state`. The proof starts this relationship at time 1: reading
the auxiliary time-zero seed as an OFF indicator would be wrong. The separate
parity theorem covers the other checkerboard class. Integer extension and
`rotated_support` cover negative and out-of-square indices. Finally `diamond`
quantifies over every integer cell; the finite crop is used only for counting.
