Formalize all four A273539 conjectures: equality with Rules 795, 843 and 859,
the closed formula, the recurrence for n>2, and the formal generating function.

The sequence is defined by synchronous Rule 779 evolution from one ON origin,
counting the source program's square crop at time 2^n−1. The background evolves;
formula and recurrence subtraction use integers. The finite cyclic reference
program agrees with this infinite-grid crop throughout its horizon.

The local official checker accepts the statement. Independent padded and cyclic
simulations, Lean samples, and all 16 archived terms support the source mapping.
The full matching proof is prepared locally. This includes the alternative-rule
claim omitted from the withdrawn #13806.

The statement imports `Mathlib.RingTheory.PowerSeries.Basic` to keep transitive
proof memory bounded. A controlled local comparison with the identical proof
measured 3.78 GB RSS with this import versus 7.77 GB with plain `Mathlib`.
