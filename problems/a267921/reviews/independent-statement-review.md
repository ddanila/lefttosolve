# Independent statement review: A267921

Reviewed 2026-11-27 by a separate reviewer agent. **Verdict: faithful to both conjectures in the platform brief; no mathematical correction required.**

Reviewed statement SHA256: `60be3d94c9ffc78e86068353b69c50da6af16ed4f279ccaaf2b6d27ca8ec0607`.

## Independence and sources

I read only `statements/oeis-a267921.lean` and the archived `sources/oeis-internal.html`, `sources/b267921.txt`, and `sources/platform-agent-brief.txt`. I did not consult the author's proof, README, checker, or source review. Mathematical references are the [OEIS entry](https://oeis.org/A267921/internal) and [b-file](https://oeis.org/A267921/b267921.txt); the platform brief identifies the requested conjectures.

## Semantic review

- **Rule and orientation:** extracting bit `4*l+2*c+r` from 243 implements Wolfram's Rule 243. Its displayed bit string is `11110011`, so the only OFF outputs are neighborhoods `010` and `011`; equivalently the centre is ON and the left neighbor is OFF. `step` assigns left to `x-1` and right to `x+1`, correctly preserving spatial orientation. Reflecting this rule would change the encoded rows, so this is substantive.
- **Initial state and infinite background:** rows are functions on all integers, initialized ON exactly at zero. Updates cover the whole line, matching the source's single ON cell with uniform OFF exterior. Since `000` and `111` both map to ON, the far exterior turns ON at time one and stays ON. No fixed-OFF boundary or finite-support assumption is introduced.
- **Crop and order:** at generation `n`, `encode` reads exactly `2*n+1` cells from `-n` to `n`, in increasing coordinate order, appending each new cell as the least significant digit. The leftmost cell is therefore most significant. With the source's one-based `k=n+1`, its crop indices `rows-k+1` through `rows+k-1` become the centered interval from `rows-n` to `rows+n`. This agrees with the Lean crop and does not attempt to encode all infinitely many ON cells.
- **Encoding:** The source explicitly uses `FromDigits[...,2]`; the bits are evaluated as a binary integer. Multiplication by two in `encode` is correct, despite the title referring to its decimal representation. The initial values `1,5,29` agree with the published sequence and distinguish the two encoding conventions.
- **Offset:** `state 0 = initial` and the one-cell crop give `a 0 = 1`, agreeing with offset zero. The second component of OEIS's `0,2` is not an index shift.
- **Recurrence:** the first conjunct exactly states `a(n) = 5*a(n-1) - 4*a(n-2)` for natural `n > 2`. Coefficients, strict range, and quantification match both OEIS and the platform brief. Integer casts precede subtraction, avoiding truncation. Natural subtraction in the indices is safe under `2 < n`.
- **Generating function:** `series` has coefficient `a n` at degree `n`. The product identity uses denominator `(1-X)*(1-4*X)` and numerator `1+8*X^2`, exactly as stated in the source. The denominator has constant coefficient one and is a unit over integer formal power series; multiplying through is equivalent to the formal quotient, without an analytic-convergence assumption.
- **Scope and non-circularity:** both selected conjectures occur as conjuncts, with no extra hypotheses. The automaton independently defines the sequence; neither conjecture is embedded in its definition. The source also lists an empirical closed form, but the platform brief selects only the recurrence and generating function. Omitting that additional observation does not omit either selected conjecture.
- **Presentation:** source, credit, and namespace are present, and the only intentional `sorry` is the theorem body. The platform brief truncates the last word of the title to “cel”; the statement correctly restores the authoritative OEIS title ending “cell.”

## Independent numerical evidence

I ran a separate Python simulation directly from the string `11110011`, using a dictionary of cells and an explicitly evolving uniform exterior. I converted each cropped bit string using base 2 and matched all 1,001 archived terms, indices 0 through 1000. This simulation did not import project code or read the author's checker.

For the independently generated values, I also checked every available coefficient of `(1-5*X+4*X^2)*series`: one at degree zero, 8 at degree two, and zero elsewhere. All checks passed. The nonzero degree-two correction also confirms that the strict recurrence bound excludes a genuinely exceptional case.

## Limitations

Finite simulation supports interpretation but does not prove infinite claims. This verdict rests on direct source-to-definition comparison, supplemented by numerical agreement. I did not run Mathematica, inspect the Lean proof, or independently check compilation in this review. This document makes no claim about platform acceptance or submission status.
