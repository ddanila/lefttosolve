# A334502 — Rule 62 on a cyclic ring

Local proof work is **incomplete**. The exceptional widths and the generating-function
algebra are proved in Lean; the all-width dynamical argument is still missing.
No unconditional `OMA.solution` is present and nothing has been submitted.

This is the first problem in the A334502/A334503 pair. Finish it before porting
its argument to A334503. They will remain separate platform problems.

## Exact target and checked progress

The archived [statement](sources/statement.lean) is byte-identical to the merged
statement from [#30882](https://github.com/lefttosolve2/open-math-agents/pull/30882).
It measures the minimal eventual period of whole labelled configurations, with
width zero assigned coefficient zero. The rule truth table and finite sequence
values agree with the OEIS entry.

[lemmas.lean](lemmas.lean) contains:

- A generic proof that a return anywhere on an orbit also returns its periodic points.
- `period_eq`: finite cycle certificates imply the exact `sInf` value used by the statement.
- Kernel-checked exceptional values for widths 0–14.
- The generating function for the proposed coefficient sequence.
- `target_of_largeCycles`: the **exact target, conditional** on `LargeCycles`.

The sole remaining hypothesis in that reduction is
`∀ n ≥ 14, ∃ T, Certificate n T 3`: a return after three steps at time T,
with neither one nor two steps returning the same configuration. Naming this
hypothesis does not prove it.

Run:

```sh
python3 problems/a334502/check.py
python3 problems/a334502/explore.py
```

The isolated Lean checker audits the conditional target and standard axioms; its
success message explicitly reports an incomplete proof. The simulation independently
checks the truth table for widths 1–64, all archived b-file values, and the conjectured
periods through width 1,500. Those experiments are not a substitute for an induction.

## Next mathematical step

The first cycle-entry time appears to depend only on the width modulo eight:

| n mod 8 | T(n), for n ≥ 14 |
| --- | --- |
| 0 | n/2 − 1 |
| 1 | 3(n−1)/2 |
| 2 | n/2 − 2 |
| 3 | (n−5)/2 |
| 4 | 3n/2 + 3 |
| 5 | (3n+29)/2 |
| 6 | n/2 |
| 7 | (3n+15)/2 |

This formula matches every tested width 14–1,500. It suggests an induction on
width in residue classes, tracking the two expanding fronts and their collision.
Before collision, the interior contains a period-three background with spatial
blocks `100011010111` and `110`; both blocks are individually period-three when
repeated cyclically. A proof still has to handle their boundaries and collision.
A proof of the exact entry time is optional: any certified entry into a minimal
three-cycle is enough for `LargeCycles`.

## Prior-work audit

No exact previous proof was identified in the OEIS entry, web searches for the
sequence identifier, or GitHub code search on 2026-11-28. This is not an exhaustive
novelty guarantee. Relevant results inspected:

- [jOEIS A334502](https://github.com/archmageirvine/joeis/blob/68812375e90e8fbb3ba94ccfeb0ebe9cf6ad416a/src/irvine/oeis/a334/A334502.java)
  implements the generating function and explicitly implements `Conjectural`.
- [LODA A334502](https://github.com/loda-lang/loda-programs/blob/f1b383b2344ab03ae8f79f41289360a6bd4394bd/oeis/334/A334502.asm)
  evaluates the proposed sequence formula; it does not connect it to cellular automata.
- [Project-Discovery DISC-0005](https://github.com/Bonnie9981/Project-Discovery/blob/a463f9720d1e8edead50fcc0abd8997964d8dba8/records/DISC-0005/result.json)
  records finite orbit experiments, not an all-width proof of this claim.
- Chua, Sbitnev and Yoon, [Part IV, §4.3](https://nonlinear.eecs.berkeley.edu/CellularAutomata/PartIV.pdf),
  discusses period-three attractors and competing patterns for Rule 62, but that
  section does not establish this single-seed, all-ring-width conjecture.

Publication remains unauthorized for this pair. No lease, note, push, PR or watcher
has been created for either problem.
