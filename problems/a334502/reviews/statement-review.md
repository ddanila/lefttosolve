# Archived target review

The production reduction concludes `type_of% @OMA.S_oeis_a334502.main`, so it covers
both conjectures, with exactly the archived definitions. The isolated composition
check guards this same type without using the statement's placeholder theorem.

Statement SHA-256: `ced8e1ba5d46a92c9f7890fc8510cd9287da56c592703a0936d8d2ab4b999979`.
It is the statement merged by PR #30882. The Rule 62 Boolean truth table, seed 1,
cyclic neighbours and computed coefficients were checked by the exploration script.
The recurrence threshold n>14 and the integer power-series numerator match the
archived OEIS formulas. Width zero is assigned zero to obtain the indicated series;
the OEIS data starts at width one.

Interpretation limit: the OEIS title says “eventual period of a single cell”. The
merged statement measures the entire labelled ring started from one ON cell, not
an observed coordinate alone. The archived entry provides no program or detailed
definition resolving that wording. Agreement with the b-file supports this reading,
but does not independently establish the author's intended semantics. Our proof
is of the existing platform target; it does not silently change its meaning.

This is a local source-to-target review, not an independent reviewer sign-off.
Recheck live upstream and prior work before any publication.
