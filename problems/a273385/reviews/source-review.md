# A273385 source-to-statement review

Reviewed locally on 2026-11-28 against the archived full OEIS internal pages, including the Mathematica code. This is the implementing agent's semantic audit, not a fresh independent reviewer or upstream human approval.

## Definition audit

- **Initial state and offset:** A273385 says one black cell at stage zero, offset 0. `initial` is true exactly at `(0,0)` and `a n` observes time `2^n-1`; at n=0 this is time 0.
- **Rule numbering:** `IntegerDigits[code,2,10]` is most significant first. The program accesses `rule[[10-#]]`; therefore sum `#` selects zero-based bit `#`. The convolution weights are centre 1 and each of the four orthogonal neighbors 2. `rule`, `neighbors`, and `step` implement exactly this outer-totalistic convention, not a five-bit directional encoding.
- **Synchronous infinite background:** Every site updates from the previous entire grid. Bit zero is ON for all the rules in question, so treating absent sites as permanently OFF would be incorrect.
- **Counted set:** The program trims generation t to the centered square of side `2t+1`. The two `Finset.range (2*t+1)` sums translate each index i to integer coordinate `i-t`, a bijection onto `[-t,t]`. This counts the entire square, not only a Manhattan diamond and not the infinite lattice.
- **Cyclic reference grid:** For a program horizon S, the cyclic grid has side `2S+1`. On its infinite periodic lift the extra initial seeds have coordinates `((2S+1)i,(2S+1)j)`. Any noncentral seed is at Manhattan distance at least `2S+1-t > t` from the time-t crop when t≤S. A radius-one rule after t steps depends only on the radius-t neighborhood, so none of those seeds can affect the crop. The infinite single-seed model therefore agrees with the program throughout its published horizon. This general bridge is a mathematical review argument, not a separate Lean theorem; the checker also compares both implementations through time 15.

## Conjecture audit

1. The alternative-rule list is exactly 667, 723, 731, 931, 939, 947, 955, 995, 1003, 1011, 1019. Equality holds for all n, including 0 and 1. Intermediate generations need not agree: e.g. at time 2 some rules count 17 and others 25. The statement correctly compares only sampled times.
2. The exponential formula has the exact range n>1. Natural subtraction is safe here: 4·2^n≤4·4^n. The proof first establishes the integer polynomial identity and explicitly supplies this inequality when casting back.
3. A060867 is defined in its own entry by `(2^k-1)^2`, offset 1. Substituting k=n+1 (n>1) gives the second conjunct. This is an exact expansion of its primary definition.
4. The recurrence retains n>4, even though a different initial range might be tempting from the eventual formula. All subtraction in the recurrence is over ℤ. In particular, its n=4 extension would be false: 7·225−14·49+8·5=929, not 961.
5. The generating function uses ordinary formal power series over ℤ. The denominator `(1-X)(1-2X)(1-4X)` has constant coefficient 1, hence is a unit. Multiplying by it is equivalent to the source quotient. The numerator coefficients are exactly 1, −2, 28, −56, 32; boundary coefficients 0 through 4 are checked individually.
6. The current OEIS entry has an additional June 2025 conjecture absent from the platform excerpt: A270007 equality for n≥2. The statement includes it. A270007's full program is identical except for `code=5`, so `count 5 (2^n-1)` is its independent dynamical definition. At n=1 it is 8 rather than 5; that exception is retained.

## Proof audit

The proof does not use the conjectured formula to define any source sequence. Finite propagation handles every cell outside the time-three square. Kernel `decide` checks all 49 interior cells for each of the 12 rules; fixed-point induction covers every later generation. Rule 5 has a separate time-two check and two-step induction. The final theorem uses the type of `main` but not its proof. The isolated axiom audit excludes `sorryAx`; no native evaluation, extra axiom, unsafe code, or external oracle is used.

Result: no blocking source/translation mismatch found. An independent semantic review remains desirable before publication; none is claimed here.
