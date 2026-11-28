# Statement audit: A265284

Reviewed locally on 2026-11-28 against the archived full OEIS entry and b-file.
The statement is the exact upstream file at commit
`924349e4d149f5d5db97a5484ee5da48920e4fdf`, formalized by @ecirak42.
No statement changes are proposed.

| Source requirement | Lean representation | Audit |
| --- | --- | --- |
| Rule 94, binary 01011110 | `rule94 left center right` | True precisely for 001, 010, 011, 100, 110; all eight cases independently checked. |
| One initial ON cell, OFF exterior | `row 0 = [true]`; `next` scans from two OFF cells and appends two OFF cells | Each step adds one position at each end. Rule 000 stays OFF, so the represented interval contains all ON cells. |
| Total through generation n | `a 0 = ones (row 0)`; `a (n+1) = a n + ones (row (n+1))` | Includes generation zero. This is not the single-row count A118102. The source Mathematica program takes partial sums of row counts. |
| Signed closed formula for n > 0 | `4*a n = 2*n² + 12*n - (-1)^n + 1` | Multiplication by 4 is equivalent to the rational formula; all arithmetic is in Int. The exceptional n=0 is excluded. |
| Even formula for n > 1 | `Even n` and `1 < n`, multiplied by 2 | Original range preserved; n=0 excluded. |
| Odd formula | `Odd n`, multiplied by 2 | Original range preserved, automatically n≥1. |
| Recurrence for n > 4 | Same integer equality with natural predecessor indices | Every predecessor is positive, so natural subtraction causes no truncation issue. |
| Rational generating function | `productCoeff n = numeratorCoeff n` for every n | The denominator expands to 1−2x+2x³−x⁴. Its constant coefficient is 1, making the all-coefficient product identity equivalent to the formal rational generating function. Initial coefficients 0..4 are explicit. |

The independent padded truth-table evolution agrees with the list scanner and
all 1,000 b-file terms, indices 0..999. It also checks every whole row against
the proved pattern from generation 2 onward. Lean separately checks 16 small
sequence/coefficient values and the exact root-qualified target type.

This is our source audit, not a new independent review by another agent.
The imported statement already has platform review and retains its author's credit.

## Existing work

The live brief and public PR descriptions were read before implementation. They
already describe alternating row patterns and a scanner argument. PRs #10573 and
#22508 were both open at preflight; neither was merged. The present Lean proof
was written locally against the statement without importing either submitted
proof. We make no claim to the first discovery of these elementary patterns.
The initial work was local only. Publication and submission were subsequently
authorized on 2026-11-28; see the plan for current status.
