Prove the generating-function identity against @ppleskov’s statement from #33330.

The Rule 182 cell states agree by induction. ON and OFF counts sum to the crop
length, so the two cumulative definitions agree after casting to integers.
Counting odd binomial coefficients identifies the statement’s A006046 with the
binary-weight sum. Mapping the established integer series identity to ℚ gives
the exact rational target, with multiplication reordered as in the statement.

The official checker accepts the exact target with only propext,
Classical.choice and Quot.sound. No dependency on our alternative statement
PR #35416 or its unproved theorem is used. The file is standalone apart from
the merged statement and Mathlib. The proof has 8,267 counted characters.

Prior mathematics: Hwang, Janson and Tsai, arXiv:2210.10968, section 4.3,
Example 4.9, explicitly gives the cumulative identity. This formalizes known
mathematics; no first mathematical proof is claimed.
https://arxiv.org/html/2210.10968#S4.SS3

Before submission, recheck the exact merged statement and current checker pins.
