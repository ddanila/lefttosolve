# Independent statement review: A267623

Reviewed 2026-11-27 by a separate reviewer agent. **Verdict: faithful to both conjectures requested in the platform brief; no mathematical correction required.**

Reviewed statement SHA256: `8f7def736759b55839dbb3a684d4eb7056c76fef4ed867b8215bfe64ea0b7dc3`.

## Independence and sources

I read only `statements/oeis-a267623.lean` and these archived inputs: `sources/oeis-internal.html`, `sources/b267623.txt`, and `sources/platform-agent-brief.txt`. I did not consult the author's README, proof, checker, or review. The authoritative mathematical sources are the [OEIS entry](https://oeis.org/A267623/internal) and its [b-file](https://oeis.org/A267623/b267623.txt); the archived platform brief specifies the two conjectures to submit.

## Findings

- **Initial condition and infinite space:** integer-indexed rows, a single ON cell at coordinate zero, and simultaneous updates of every cell correctly model `CellularAutomaton[187,{{1},0},...]`. There is no artificial fixed-OFF boundary. The uniform OFF exterior becomes ON at time one, as required by the rule.
- **Orientation:** `4*left + 2*centre + right` and bit extraction from 187 implement the standard table. Its only OFF outputs are neighborhoods `010` and `110`. Left and right positions in `step` are correctly assigned. The Maple program weights the spatial right neighbor by four instead, which reflects the evolution. Since the initial condition is reflection-invariant and reflection fixes coordinate zero, its middle-column sequence agrees with the standard orientation. The header accurately explains this difference.
- **Temporal encoding:** `column (n+1)` appends the centre cells from times zero through `n`, oldest first, as decimal digits. It does not encode a spatial row or reverse the time order. In the Mathematica program, the `k`th entry of the cropped `k`th row is exactly coordinate zero; `Take[mc,k]` then takes that temporal prefix. This matches the Lean definition.
- **Base and offset:** the published terms `1,10,101,1011,...` disambiguate the title's binary wording: these are decimal integers whose digits are bits, not numeric base-two evaluations (`1,2,5,11,...`). Multiplication by ten in `column` is correct. `a 0 = column 1 = 1` agrees with offset zero. The second component of OEIS offset `0,2` does not shift the index.
- **Recurrence:** the first conjunct exactly states `a(n) = 11*a(n-1) - 10*a(n-2)` for natural `n > 2`, preserving the strict source bound. Casts occur before integer subtraction. Natural subtraction in indices is unambiguous under that bound. At `n=2`, the homogeneous recurrence would give 100 rather than 101, so excluding that case matters.
- **Generating function:** `series` assigns `a n` to coefficient `n` with no index shift. Multiplication by `(1-X)*(1-10*X)` yields `1-X+X^2`, exactly the source numerator and denominator. The denominator's constant coefficient is one, hence it is a unit over integer formal power series. This product identity is equivalent to the formal quotient without adding analytic assumptions.
- **Scope:** both conjectures in the platform brief are present, without extra assumptions or an eventual-range weakening. The OEIS entry additionally lists empirical closed forms and a Rule 643 relationship; those are not requested by this platform brief. Omitting those additional observations does not omit either selected conjecture.
- **Non-circularity and presentation:** `a` is defined from the automaton, not from the conjectured recurrence, closed form, or generating function. The header reproduces the source/platform title apart from line wrapping and includes source and credit. The single intended theorem-body `sorry` is appropriate for a statement submission.

## Independent numerical evidence

I wrote `reviews/independent_simulation.py` directly from the truth table. It independently evolves a finite window with an exact uniform exterior in both spatial orientations, reads successive centre cells, and checks the decimal prefixes against all 1,001 archived terms. It also verifies all tested coefficients of `(1-11*X+10*X^2)*series`: 1 at degree zero, -1 at degree one, 1 at degree two, and zero thereafter. The run passed.

Reproduce from the repository root:

```sh
python3 problems/a267623/reviews/independent_simulation.py
```

This script imports no project modules and writes no files.

## Limitations

This is a source-to-statement review, not a proof audit or platform verdict. Finite simulation does not prove the infinite claims. The semantic conclusion rests on direct comparison of the definitions and source programs, with numerical agreement as supporting evidence. I did not execute Mathematica or Maple, inspect the proof, or independently validate Lean compilation in this review.
