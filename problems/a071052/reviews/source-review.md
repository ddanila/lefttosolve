# A071052 statement and proof review

Reviewed on 2026-11-28 against both archived OEIS entries, A071052 and A071036.
The exact statement on upstream commit `d5e8ec6f724ec5ac321a0309eb33acc3694f9073`
was formalized by @seanm27lol in statement PR #3436 and is copied unchanged.

| Source convention | Statement | Check |
| --- | --- | --- |
| Rule 150, single initial ON cell | `cell 0 i = decide (i = 0)`; three-parent XOR at each step | All eight truth-table inputs agree with binary rule 10010110. |
| Row n starts at its left edge | Parents i−2, i−1, i in the previous row | Physical position x corresponds to index i=x+n. The three physical neighbors have exactly these previous-row indices. |
| Finite triangle row, length 2n+1 | Sum over indices 0..2n | Counts every displayed cell, including OFF cells between ON cells. It does not count the infinite OFF exterior. |
| Number of zeros, not ones | Boolean conditional contributes 1 exactly when the cell is false | At n=0 the only cell is ON, so a(0)=0. |
| a(2n)=a(n)+2n, offset zero | `∀ n : ℕ, zeroCount (2*n) = zeroCount n + 2*n` | No omitted initial case or added hypothesis; all arithmetic is natural addition/multiplication. |

The proof establishes a stronger pointwise result for every integer position:
`cell (2*n) (2*i) = cell n i` and `cell (2*n) (2*i+1) = false`.
Two Rule 150 steps leave just the parent cells at offsets 4, 2 and 0 because
all repeated XOR terms cancel. Induction on n proves the pointwise result.
A second induction counts pairs of positions and retains the final even cell.
For the actual row there are 2n+1 even positions and 2n odd positions.

Independent validation compares a padded numbered-rule simulation with polynomial
multiplication over F₂ (bitset convolution), checking all rows through time 256.
All 67 archived sequence terms agree. The full doubled-row pattern and recurrence
are checked in 129 cases. Seven small cell/count values are also evaluated in Lean.
The isolated Lean check includes the root-qualified target guard and axiom audit.

This is an author source audit, not an independent reviewer-agent assessment.

## Prior work and comparison

The live brief already linked @seanm27lol's prepared proof. PR #21850 by @agchua
was also open; we inspected its source at commit
`03eeb986cda165c8b082b54383f3b306eef30efb` after developing our two-step XOR argument.
It uses polynomial coefficients and Frobenius expansion against a different
proposed statement (#21567), with definitions `T` and `a` over ZMod 2.
The merged statement instead uses Boolean `cell` and `zeroCount`.

The recorded CI failure in run 46117852839 at 09:28 UTC was a lint rejection:
the checked tree lacked the statement. PR #3436 was created November 27 at
05:39:58 UTC and merged November 28 at 10:00:57 UTC, after this run.
CI checked GitHub’s synthetic merge into b82df58d7394a6209a7b770e08599c6aa30ca299.
The creation date must not be mistaken for the merge date. This was not a
mathematical rejection. The source
file as archived still refers to definitions absent from the current target.
Our length comparison is therefore between two source files, not two accepted
proofs of the exact same Lean declaration. We do not claim a current shortest
record, first discovery, or that the other proof could not be adapted compactly.

The final direct proof counts 1,481 characters versus 2,193 in the pending file,
a saving of 712 (32.5%), using the current official length tool. Its conceptual
simplification is to avoid polynomial infrastructure entirely: local XOR
cancellation gives the required doubling identity directly.
