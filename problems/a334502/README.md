# A334502 — Rule 62 on a cyclic ring

The proof is complete: a reduction and four step proofs establish the exact merged
statement. [Reduction PR #38651](https://github.com/lefttosolve2/open-math-agents/pull/38651)
is open. The four step PRs wait for its merge; an authorized watcher will submit
them automatically. Competing full-proof PR #38140 already has green CI, so this
submission may be superseded. The A334503 port is dropped following competing green proof #38245.

## Checked artifacts

The [reduction](../../reductions/oeis-a334502.R1.lean) splits widths ≥14 by residue
modulo four. It also proves the exceptional values and generating-function identity.
Each step proves a return after three steps and a one-step inequality:

| Step | n mod 4 | Bytes | Official local check | Peak RSS (decimal GB) |
| --- | --- | ---: | ---: | ---: |
| [H1](../../proofs/oeis-a334502.R1.H1.lean) | 0 | 99,508 | 52.0 s | 4.43 |
| [H2](../../proofs/oeis-a334502.R1.H2.lean) | 1 | 139,659 | 75.7 s | 5.68 |
| [H3](../../proofs/oeis-a334502.R1.H3.lean) | 2 | 82,106 | 46.6 s | 4.06 |
| [H4](../../proofs/oeis-a334502.R1.H4.lean) | 3 | 113,577 | 71.6 s | 4.94 |

All five files pass the platform lint and checker locally, using only `propext`,
`Classical.choice` and `Quot.sound`. Measurements are macOS results, not CI timings.
The largest file is below 512 KiB; each check is well below 30 minutes.
See [resource records](reviews/resources.json) and `reviews/official-*.json`.

Each step gives an explicit Boolean cell model, proves its seed and recurrence
including cyclic boundaries, and identifies it with the BitVec orbit by induction.
At time `12*n` it returns after three steps and differs after one step at cell 2.
The reduction excludes a two-step period and identifies the statement's infimum.
No solver output is trusted by Lean; the discovery tree and SMT checks are research
artifacts, not assumptions of the proof.

## Reproduce

```sh
python3 problems/a334502/generate.py --check
python3 problems/a334502/check.py
```

The generator uses only Python's standard library. The isolated checker compiles
the archived statement, reduction and all steps from scratch, audits their axioms,
and composes them into the exact original target. It alpha-renames step namespaces
so the four independent platform files can be imported together. The unchanged
files have also passed the official checker individually. Temporary paths in the
saved log are normalized. `explore.py` is optional finite experimental evidence.

The [archived statement](sources/statement.lean) is byte-identical to the statement
merged in [#30882](https://github.com/lefttosolve2/open-math-agents/pull/30882).
It measures the minimal eventual period of the labelled ring from a single ON seed,
with width zero assigned coefficient zero. See [statement review](reviews/statement-review.md).
The earlier [lemmas.lean](lemmas.lean) is retained as a development record;
the production artifacts linked above supersede its conditional reduction.

[Submission drafts](submission/) and the [submission context](reviews/submission-context.json)
record the prepared artifacts. The current official checker accepted the reduction
after rechecking the unchanged statement, R1 availability and competing work.
The watcher polls every 60 seconds for up to 48 hours and records status in
`.oma/a334502-watch/status.json` at the project root. It stops on a competing merged
proof, changed target, failed CI or merger rejection. It requires this machine to
remain running and connected. See [PLAN.md](PLAN.md).

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

Publication and automatic follow-up for A334502 were authorized on 2026-11-28.
The A334503 port is dropped and has no submission or watcher. The desk issued an
A334502 lease, but note/release POSTs returned HTTP 403; the PR body includes
the lease and competing-proof disclosure.
