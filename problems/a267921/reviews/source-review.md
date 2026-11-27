# A267921 — author source review

Reviewed the full archived OEIS entry and platform brief against the standalone statement. This is an author review, not a fresh independent reviewer report.

Both sources request exactly two conjectures: the recurrence with strict bound n>2 and the generating function. The statement preserves both, using integer arithmetic and a formal power-series product with a unit denominator. Neither conjecture is assumed in the sequence definition.

The reference program initializes a single ON origin and uses Wolfram Rule 243. The k-th row crop is taken from rows-k+1 through rows+k-1, which corresponds to [-n,n] at n=k-1. FromDigits reads left to right. A267920 uses the default base 10; A267921 explicitly passes base 2. Titles describe display conventions and must not be used to swap these bases.

At time 1, the infinite OFF exterior becomes ON. The integer-indexed Lean state correctly allows this; the simulator shrinks its initially padded window so boundary effects cannot reach the observed crop. Index 0 is the seed row. The only zero at times n>=1 is at n-1, so reversing the row would change the sequence from time 2 onward (11101 versus 10111). The supplied b-files disambiguate this orientation.

Each statement reproduces the full authoritative OEIS title. The A267921 platform title truncates the final word; the source has cell. The additional empirical closed form in A267921 is not requested in the platform brief. A fresh independent semantic review remains planned before publication.
