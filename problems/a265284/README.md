# A265284 — cumulative Rule 94 cell counts

Complete local proof of all five conjectures against @ecirak42's exact merged
statement. Publication and submission were authorized on 2026-11-28 after the
initial local preparation; final preflight is in progress.

- [Upstream statement, unchanged](../../statements/oeis-a265284.lean).
- [Standalone proof](../../proofs/oeis-a265284.lean).
- [Source audit](reviews/source-review.md) and [source snapshots](sources/).
- [Plan and submission gates](PLAN.md).

## Argument

Rule 94 preserves an OFF exterior. Starting at generation 2, its rows alternate
between `110 (10)^(2k) 11` at generation `2k+2` and
`1110 (10)^(2k) 111` at generation `2k+3`. Each pair of scanner transitions
returns to the same state, so induction proves these entire rows.

Their ON counts are `2k+4` and `2k+6`. Summing consecutive rows gives
`a(2k+1) = 2k²+8k+4` and `a(2k+2) = 2k²+10k+8`. These are cumulative totals,
including generation zero. The three source closed forms follow by parity;
the fourth-order recurrence cancels their quadratic and alternating terms.
The generating function follows coefficientwise from the recurrence and five
initial coefficients.

## Validation

Run `python3 problems/a265284/check.py`, or the root `python3 scripts/check.py`.
The checker compiles in an isolated environment, checks the root-qualified exact
target, and audits the axioms. It compares independent padded truth-table
evolution with the statement's scanning model and all 1,000 b-file terms
(indices 0..999), checks 998 complete row patterns and all eight rule inputs,
and evaluates 16 small Lean sequence/coefficient values.

Only `propext`, `Classical.choice`, and `Quot.sound` occur in the proof's axiom
report. No `sorry`, `native_decide`, or added axiom occurs in the proof.
Reports normalize temporary paths so repeated checking does not dirty the tree.

The current unmodified official checker also accepts the proof (including its
root-namespace target guard). The complete check took 4.51 seconds and peaked at
1,498,726,400 bytes RSS on macOS; this is not a capped Linux-runner measurement.
The proof is 7,406 bytes, far below the 512 KiB limit. See
[official verdict](reviews/official-proof.json) and [pinned context](reviews/official-context.json).

## Existing submissions

At preflight, proof PRs [#10573](https://github.com/lefttosolve2/open-math-agents/pull/10573)
and [#22508](https://github.com/lefttosolve2/open-math-agents/pull/22508) were open.
Their descriptions and the brief already give the alternating-row approach.
This local proof does not establish a first-solve priority claim. Before any
future publication, check whether a proof has merged and whether the platform's
shorter-proof route applies.
