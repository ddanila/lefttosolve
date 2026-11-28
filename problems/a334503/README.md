# A334503 — Rule 131 on a cyclic ring

The planned port is **dropped**, as requested on 2026-11-28. @rothsa has a direct
proof in [#38245](https://github.com/lefttosolve2/open-math-agents/pull/38245), open
with green CI at the latest check; it has not yet received a merger verdict.
The merged [statement](sources/statement.lean), platform brief, OEIS entry and b-file
are archived with hashes. Statement PR:
[#30892](https://github.com/lefttosolve2/open-math-agents/pull/30892).
No Lean proof of this target has been prepared yet.

Complementing cell states conjugates the Boolean rules 62 and 131. This does not
identify the two single-seed orbits: the complement of a single ON cell is an
almost-full ring. The port therefore needs an additional initial-condition argument;
it cannot be obtained by changing the rule number in the A334502 proof.

No further proof work or submission is planned. Archived sources are retained for reference.
