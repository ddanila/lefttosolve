# Independent statement review: A267622

Reviewed 2026-11-27 by a separate reviewer agent. Verdict: **the mathematical statement faithfully represents both OEIS conjectures**. No mathematical correction is required.

## Scope and independence

I read `statements/oeis-a267622.lean`, the archived OEIS internal entry in `sources/oeis-internal.html`, and `sources/b267622.txt`. I did not read the author's README, proof, or existing verification script. This review concerns the translation from the source to the Lean statement, not the correctness or style of the proof.

Final reviewed statement SHA256: `1efe4669aef297ca4512a4b748f21d8ce3645ee6a39249bf25cb588bd37d4f31`.

Sources: [OEIS entry](https://oeis.org/A267622/internal), [OEIS b-file](https://oeis.org/A267622/b267622.txt). The archived entry contains both conjectures, the Mathematica program, and offset `0,2`.

## Source-to-statement comparison

| Item | Independent assessment |
| --- | --- |
| Initial condition | `initial x := decide (x = 0)` is a single ON cell on an infinite OFF background, matching `{{1},0}`. |
| Rule number and orientation | The neighborhood index is `4*l + 2*c + r`, with left neighbor at `x-1` and right at `x+1`. Reading bit `i` of 187 gives outputs `1,1,0,1,1,1,0,1` for neighborhoods `000` through `111`, exactly the standard Rule 187 table. In particular the output is false precisely when the centre is ON and the right neighbor is OFF. This rules out accidental reflected orientation. |
| Infinite background | The definition updates the entire integer line. Since `000` maps to ON and `111` maps to ON, the exterior becomes ON at time 1 and remains ON. The statement does not introduce a false fixed-OFF boundary. |
| Crop | At time `n`, `a` reads exactly `[-n,n]`, including both endpoints. For the source program's one-based row index `k=n+1`, its bounds `rows-k+1` and `rows+k-1` become `rows-n` and `rows+n`, the same centered crop. This is a crop of the infinite row, not its support. |
| Encoding and base | `encode` appends each successive bit on the right using `10 * prefix + bit`, so the leftmost cell is most significant and the numeric base is ten. Although the title calls this a binary representation, the published terms are decimal integers made of binary digits: `1,101,10111,...`. Base-two numeric evaluation would produce `1,5,23,...` and would not match the source. |
| Offset | `state 0 = initial`, hence `a 0 = 1`, consistent with the first offset component zero. The second component of `0,2` is OEIS metadata, not an instruction to shift the sequence by two. |
| Recurrence | The first conjunct is precisely `a(n) = 101*a(n-1) - 100*a(n-2)` for `n > 2`. Values are cast to integers before subtraction, avoiding truncated natural subtraction. Natural index subtraction is harmless under `2 < n`. |
| Generating function | `series` has coefficient `a n` at degree `n`, with no shift. The second conjunct multiplies it by `(1-X)*(1-100*X)` and sets the result to `1+10*X^2`, matching the stated rational generating function. The denominator has constant coefficient 1, so it is a unit in integer formal power series; the product identity is equivalent to the formal quotient. There is no extra analytic-convergence assumption. |
| Coverage | Both source conjectures occur as conjuncts of `main`, with no extra assumptions. The cellular-automaton definition is independent of those conjectures; the recurrence or generating function is not built into `a`. |

## Independent checks

I separately simulated the truth table using a Python dictionary of finite rows and an explicitly evolving uniform exterior. This did not import the author's Lean proof or checking code. It matched every one of the 1,001 archived terms, for indices 0 through 1000.

The simulation is preserved in `reviews/independent_simulation.py`. Reproduce it from the repository root with `python3 problems/a267622/reviews/independent_simulation.py`; it reads the archived b-file and writes no files.

For those same independently simulated values I checked that the coefficient of degree `n` in `(1-101*X+100*X^2)*series` was 1 at degree 0, 10 at degree 2, and zero at every other checked degree. This also checks the recurrence throughout its finite tested range. The exceptional degree 2 is substantive: the homogeneous recurrence does not hold there, so the strict bound `n > 2` is appropriate.

## Presentation and limitations

The initially paraphrased title has been restored. I checked the final header against the archived OEIS title: it now matches, apart from line wrapping, while retaining the explanation of decimal digit encoding. This presentation issue is resolved; the mathematical definitions and target are unchanged.

Finite agreement does not prove the infinite claims. The main conclusion of this review rests on inspecting the definitions and translating the source, supplemented by the independent numerical check. I did not run Mathematica, audit Lean's kernel, or check the final proof; compilation and proof validation are separate checks. Source interpretation necessarily uses the OEIS program and data to disambiguate its informal title. No assertion is made here about leases, platform acceptance, or submission status.
