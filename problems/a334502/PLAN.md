# A334502 local plan

Scope: A334502 publication and automatic step submission authorized on 2026-11-28.
The A334503 port was subsequently dropped after competing green proof #38245.

- [x] Archive the merged statement, agent brief, OEIS entry and b-file.
- [x] Initial prior-work and statement audit, with limits recorded.
- [x] Reproduce terms and prove the exceptional widths and generating function.
- [x] Prove BitVec neighbour bridge, cellwise induction and minimality.
- [x] Discover and symbolically validate a cell model; rerun the formerly failing residue.
- [x] Measure compact models; reject the oversized single-file route and inexact segment learner.
- [x] Split into four platform hypotheses by width modulo four.
- [x] Prove seed, recurrence, wraparound, return and inequality for every width ≥14.
- [x] Pass platform lint and official checker locally for reduction and all four steps.
- [x] Package reproducible generation, resource records and local submission drafts.
- [x] Complete isolated composition audit against the exact target (standard axioms only).

## Submission and monitoring

- [x] Recheck upstream statement hash, competing proofs and prior work.
  Statement unchanged; competing full proof #38140 has green CI, not yet merged.
- [x] Confirm R1 is available.
- [x] Recheck reduction with current platform checker; unchanged dependencies and target.
- [x] Submit reduction as PR #38651 and verify the uploaded bytes.
- [x] Start `scripts/watch_a334502_submission.py --run` (48-hour window).
- [ ] Submit the four prepared steps after reduction merge, unless superseded.
  The watcher rechecks each step with the official checker before submission.
- [ ] Monitor CI and merger verdicts, especially H2 memory: its 5.68 GB peak
  is measured on macOS only; CI memory use remains unverified.

A334503 is dropped; its proof was not ported.
