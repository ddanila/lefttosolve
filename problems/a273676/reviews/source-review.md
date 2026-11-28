# A273676 source and prior-proof review

Reviewed 2026-11-28. Statement PR #21220 is merged. No matching proof PR was
listed at inspection. These platform facts do not imply mathematical novelty.

## Statement audit

The archived OEIS text and merged Lean statement agree on all five claims:

- Offset zero; one initially ON origin; synchronous evolution on the integer plane.
- Rule index is centre bit plus twice the four-neighbour ON count.
- Count only the square [-t,t]^2 at t = 2^n - 1.
- Rule 849 equality includes n=0 and n=1.
- Rule 131 equality and formula require n>1; recurrence requires n>4.
- Formula and recurrence use integer arithmetic.
- Generating function uses formal power series over integers, multiplied by
  its denominator, whose constant coefficient is 1.

The noncomputable count is mathematically finite. Odd rule numbers have an
evolving background; a global count or permanently OFF exterior would be wrong.

## Existing artifact

Pinned source: OtherMindset/congress-lean at
ca6b7eef533a5a8a0f1bb02780c1793b0f3568a4 (commit metadata archived).

LT2D.Defs uses coordinate pairs rather than curried coordinates. Its ruleOut
uses the same Nat.testBit index. Its neighbour sum lists east before west,
an immaterial commutative reordering. Its initial pair equality is equivalent
to the platform's conjunction. Its window and onCount use the same square
product and filtered cardinality.

The expected adapter is induction proving
`state r t x y = LT2D.caState r t (x,y)`, then filter congruence.
This bridge has been inspected mathematically, not compiled in Lean.

The archived M.lean contains the formula and Rule 849 equality; the relation
file contains Rule 131 equality. Dependencies include certified digit-automaton
machinery and a 13-state Rule 833 table. Selected files alone are not a buildable
copy of the artifact.

The sequence starts 1,4 and equals 3*4^n-4*2^n+1 for n≥2. Each exponential
satisfies the recurrence with characteristic polynomial (z-1)(z-2)(z-4).
The generating-function product has coefficients 1,-3,19,-22,8 through degree
4 and zero thereafter. These algebraic observations are not a kernel-checked
proof of the platform conjunction.

## Limits and recommendation

The original artifact has not been rebuilt or axiom-audited locally. The exact
target adapter and algebraic packaging remain unproved here. Further work
would be attributed adaptation of known results, not a fresh solution of an
untouched conjecture. Recommend reviewing that change in purpose before a
full adaptation. All work remains local.

References:
- https://oeis.org/A273676
- https://github.com/lefttosolve2/open-math-agents/pull/21220
- https://aixiv.online/pdf/2611.02474
- https://github.com/OtherMindset/congress-lean/tree/ca6b7eef533a5a8a0f1bb02780c1793b0f3568a4/lake
