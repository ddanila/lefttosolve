# A273676 — local preparation and prior-work audit

Status: prior Lean proofs found; no new proof or submission prepared. Local only:
no lease, public note, push, or submission was made for this problem.

The merged platform statement bundles five claims about Rule 833: equality with
Rule 849, equality with Rule 131 from n=2, a closed formula from n=2, a recurrence
from n=5, and a formal generating-function identity.

## Existing work

Alexander R. Cohen's *Certified Digit Automata for Nonlinear Two-Dimensional
Cellular Automata* identifies existing Lean proofs of the three main ingredients.
The source artifact is pinned at
[ca6b7eef](https://github.com/OtherMindset/congress-lean/tree/ca6b7eef533a5a8a0f1bb02780c1793b0f3568a4/lake),
whose GitHub commit timestamp is **2026-11-20 20:36:55 UTC**.

| Platform claim | Existing declaration |
| --- | --- |
| Rule 849 equals Rule 833, every n | `LT2D.a273676_r849_count_eq_833` |
| Rule 833 equals Rule 131, n ≥ 2 | `LT2D.a273676_eq_a270222` |
| Formula, n ≥ 2 | `LT2D.a273676_formula` |
| Recurrence, n ≥ 5 | Algebraic consequence of the formula |
| Generating function | Formula plus initial values 1 and 4 |

The first and third declarations are in `lake/LT2D/Groups/W2B_G7/M.lean`;
the second is in `lake/LT2D/Relations/A273676_eq_A270222.lean`.
Selected sources and hashes are archived locally. The artifact's stated license
is CC BY 4.0; preserve attribution if adapting it.

This is source inspection, **not a successful local rebuild of that artifact**.
The exact platform conjunction has not been proved locally. Neither a new
discovery nor a platform-ready Lean proof should be claimed from this audit.

## Local checks

Run `python3 problems/a273676/check.py`. The dependency-cone simulation checks
Rules 833, 849 and 131 through stage 63, seven sampled terms, the formula,
applicable recurrence instances, and seven generating-function coefficients.
It accounts for the evolving infinite background.

See [source review](reviews/source-review.md), [results](reviews/local-check.json),
and [remaining work](PLAN.md). The root nine-problem checker does not include
this research-only task.
