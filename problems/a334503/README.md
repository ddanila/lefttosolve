# A334503 — Rule 131 on a cyclic ring

Local preparation only; proof work is queued behind A334502 at the user's request.
The merged [statement](sources/statement.lean), platform brief, OEIS entry and b-file
are archived with hashes. Statement PR:
[#30892](https://github.com/lefttosolve2/open-math-agents/pull/30892).
No Lean proof of this target has been prepared yet.

Complementing cell states conjugates the Boolean rules 62 and 131. This does not
identify the two single-seed orbits: the complement of a single ON cell is an
almost-full ring. The port therefore needs an additional initial-condition argument;
it cannot be obtained by changing the rule number in the A334502 proof.

Next: finish [A334502](../a334502/README.md), then formalize that conjugacy and the
initial-condition bridge, prove this problem's exceptional values and eventual
three-cycle claim, and validate its exact target separately. No publication,
platform lease or automatic submission is authorized for this pair.
