Prove all five A265284 claims against the unchanged statement by @ecirak42:
the three closed forms, the recurrence for n>4, and the generating-function
coefficient identity. The sequence counts all ON cells from generation zero
through n, not just the last row.

The proof gives the entire Rule 94 rows at generations 2k+2 and 2k+3 as
`110 (10)^(2k) 11` and `1110 (10)^(2k) 111`. A two-cell scanning lemma proves
both updates. Counting and summing adjacent rows gives the two quadratic parity
formulas; the recurrence and generating function follow algebraically.

Validation: the unmodified official checker accepts the exact root-qualified
target, using only propext, Classical.choice and Quot.sound. Independent padded
truth-table evolution agrees with the statement scanner and all 1,000 archived
OEIS terms (0..999), including 998 whole-row pattern comparisons. The 7,406-byte
proof checked locally in 4.51 seconds at about 1.50 GB peak macOS RSS.

The first proof, by @treybeathard-jpg in #10573, merged at 11:28:38 UTC.
This PR now replaces that proof under the platform's shorter-proof rule.
The unmodified `tools/prooflen.py` counts 4,199 characters here versus 6,412
on main: 2,213 characters (34.5%) shorter. The unchanged proof was rechecked
against current main and the exact statement; the official checker accepted it.
First-solve credit remains with the original solver.

The live brief and prior PR descriptions described the same alternating-row
approach. This Lean file was implemented locally without importing their proof
files; no first-discovery claim is made.
