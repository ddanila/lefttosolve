# Plan

Status checked against GitHub on 2026-11-28, 06:45 UTC. Process notes are in `LESSONS.md`.

## Finished problems

Nothing is left to do on these five. All five statements are ours and merged; one proof is ours.

| Problem | Statement (ours) | Proof on `main` |
| --- | --- | --- |
| A283508 — Rule 643 | [#5506](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/5506) | Ours, [#6231](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6231) |
| A267622 — Rule 187 row | [#6406](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6406) | @caa1982, #7360 |
| A267623 — Rule 187 centre column | [#7472](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7472) | @carl2sheriff, #8776 |
| A267920 — Rule 243, decimal digits | [#8024](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/8024) | @rpinho, #11172 |
| A267921 — Rule 243, binary value | [#7966](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7966) | @treybeathard-jpg, #11159, then shortened by @DavidHallgren, #12167 |

Our proof pull requests #7242 (A267622) and #7656 (A267623) are still open upstream and can no longer merge. Closing them is optional housekeeping and needs Danila's confirmation.

## Current work and next candidates

The one-dimensional family we worked in is taken: every remaining problem from the 2026-11-27 shortlist has an open statement pull request. Of 451 cellular-automaton problems, 24 have neither a statement nor an open pull request. Two of those use the A283508 automaton (five-cell von Neumann neighbourhood, single ON seed) and count ON cells at stage 2^n − 1.

- [x] **A273385 — Rule 659: proof PR [#29877](https://github.com/lefttosolve2/open-math-agents/pull/29877) submitted.** See [local proof and validation](problems/a273385/README.md) and [future submission checklist](problems/a273385/PLAN.md). The statement includes the newer A270007 comparison as well. Lean proves the whole (2t+1)² window is ON from stage 3, so the count is (2^(n+1) − 1)². Conjectures:
  - a(n) = 4·4^n − 4·2^n + 1 for n > 1;
  - a(n) = 7a(n−1) − 14a(n−2) + 8a(n−3) for n > 4;
  - g.f. (1 − 2x + 28x² − 56x³ + 32x⁴) / ((1−x)(1−2x)(1−4x));
  - eleven other rules (667, 723, 731, 931, 939, 947, 955, 995, 1003, 1011, 1019) generate the same sequence.

  This is the closest to A283508 and simpler: no exceptional cells. The multi-rule conjecture is the extra work.
- [x] **A273539 — Rule 779: proved and published; statement PR #26102 open, automatic proof submission running.** See [proof and checks](problems/a273539/README.md) and [submission preflight](problems/a273539/PLAN.md). A kernel-checked finite machine and a coordinate bridge prove that OFF cells at stages 2^n − 1 are exactly a diamond boundary. All four conjectures are covered:
  - a(n) = 5 − 2^(n+3) + 4^(n+1);
  - a(n) = 7a(n−1) − 14a(n−2) + 8a(n−3) for n > 2;
  - g.f. (1 − 2x + 16x²) / ((1−x)(1−2x)(1−4x));
  - rules 795, 843 and 859 generate the same sequence.

A third free problem of the same kind, A272706 (Rule 515), is a fallback. The sibling A273313 (Rule 643 itself) is already claimed by an open pull request.

A273539 publication is authorized; live preflight found no merged statement or open competing PR. Submit the statement, then automatically submit the checked proof after merge. A273385 publication and automatic submission remain separately authorized.

## A265284 — proof PR #26856 submitted

All five conjectures are proved against the existing statement by @ecirak42.
See [workspace and checks](problems/a265284/README.md) and [local plan](problems/a265284/PLAN.md).
All eight problems pass the root checker. Proof PR [#26856](https://github.com/lefttosolve2/open-math-agents/pull/26856)
is now a 34.5% shorter replacement after #10573 merged. It passed a fresh local
official check; new CI and a verdict are pending. It needs no statement-waiting watcher.

## A071052 — proof ready; submission authorized

The exact merged statement is proved via two-step XOR cancellation. The proof
is 32.5% shorter than pending #21850, but that file targets a different proposed
statement. See [validation and comparison](problems/a071052/README.md).
Recheck any proof on main before recommending a shortest-proof submission.
