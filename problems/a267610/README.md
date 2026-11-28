# A267610 — corrected relation and generating function proved locally

The [proposed statement](../../statements/oeis-a267610.lean) explicitly corrects
the printed A267700 index to
`a(n) = A267700(n+1) - (n+1)` and retains the generating function unchanged.
The [positive proof](../../proofs/oeis-a267610.lean) proves both for every n.
This is a proposed correction requiring human translation review, not a claim
that the printed formula already says this.

## Argument

At time t every even position in the cropped row is ON. At odd position 2k+1,
the OFF indicator is the parity of binomial(t+1,k+1). Induction using Pascal's
recurrence establishes this directly from Rule 182. Lucas's theorem modulo 2
counts the odd binomial coefficients as 2^weight(t+1). Removing the two endpoints
gives **offCount(t)+2 = 2^weight(t+1)**.

Summing rows gives a(n)+2(n+1)+1=A006046(n+2). The referenced tree sequence
satisfies A267700(m)+(m+1)=A006046(m+1). Their combination proves the corrected
relation. A coefficient calculation proves the original generating function
from the same cumulative identity. Both claims are proved, not just simulated.

## Why the correction is explicit

The printed unshifted relation fails at n=2: 2 ≠ 2−2. It also conflicts with
the GF and with the entry's containment comment using n+1. The original
[statement](archive/printed-statement.lean), [disproof](archive/printed-disproof.lean),
and checker evidence remain in the archive. The submission proposal now concerns
the positive result, not refuting a conjunction through this typo.

The informal containment interpretation is not a separate conjunct; the header
states this scope. Hwang, Janson and Tsai, arXiv:2210.10968, section 4.3,
Example 4.9, explicitly give the cumulative identity in terms of A006046
and the corresponding A267700 identity, allowing index shifts. This is a
formalization of known mathematics; the GF follows algebraically from their
identity. See the source review for the exact index translation.

## Validation

- Official, unmodified checker accepts statement and positive proof against the
  local proposed statement. This is not upstream acceptance.
- Isolated compilation verifies the exact root-qualified target and permits
  only propext, Classical.choice and Quot.sound.
- Narrow imports; final proof check **4.02 s**, **1,992,949,760 bytes peak macOS RSS**,
  versus 5,855,084,544 bytes for the earlier broad-import disproof check.
  These are complete local checker invocations, not capped Linux benchmarks.
- 6,102 counted proof characters; no large tables, extra axioms or native evaluator.
- Simulation matches 1,001 A267610 terms and checks the row formula through 1000.
  Binary-subset enumeration checks 70 A267700 terms; digit sums check 16,384
  A006046 terms. GF checks match 1,001 coefficients.

Run `python3 problems/a267610/check.py` or `python3 scripts/check.py`.
Reports normalize temporary paths. See [source review](reviews/source-review.md),
[official result](reviews/official-proof.json), and [plan](PLAN.md).

@ppleskov’s GF-only statement [#33330](https://github.com/lefttosolve2/open-math-agents/pull/33330)
merged. Our checked [adapted proof](alternatives/ppleskov/proof.lean) is submitted as
[#39513](https://github.com/lefttosolve2/open-math-agents/pull/39513). The watcher
stopped on an unrelated checker/client update; that delta was reviewed and the
current official checker accepted the exact merged target before submission.
The uploaded bytes were verified, and CI/verdict monitoring is active.

The proof in #39513 is now shortened to 5,553 counted characters: 32.8% below
our original 8,267 and 9.52% below the 6,137 in competing #38793. It qualifies
as a shorter replacement against that version. Current official and isolated
checks pass. Our superseded statement #35416 was rejected because #33330 merged;
that rejection is separate from the proof PR.

Runtime status: `.oma/a267610-watch/status.json`; latest log:
`resumed-current-checker.log` beside it. Watcher: `scripts/watch_a267610_submission.py`.
It polls every minute for up to 48 hours and detects failed CI and merger rejection.
