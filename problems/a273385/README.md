# A273385 — Rule 659 ON-cell counts

**Proved and authorized for publication; proof PR pending.** The standalone statement covers every conjecture in the current [OEIS entry](https://oeis.org/A273385), including the 2025 comparison with A270007. Credit: @ddanila.

- [Statement](../../statements/oeis-a273385.lean)
- [Proof](../../proofs/oeis-a273385.lean)
- [Source-to-statement review](reviews/source-review.md)
- [Local checks](reviews/local-check.json)
- [Plan and submission checklist](PLAN.md)

## Why it works

The initial grid has one ON cell at the origin. Rule 659 has bit zero set, so the background becomes ON too. At time 1 there are four OFF cells around the origin; at time 2 there are eight; by time 3 every cell is ON. All eleven alternative rules named in OEIS also reach the uniform ON fixed point by time 3. Their counts agree at the two earlier sampled times, 0 and 1.

The source program counts only the square `[-t,t] × [-t,t]`, despite the infinite ON background. At the sampled time `t = 2^n − 1`, for `n ≥ 2`, this gives

```text
a(n) = (2t + 1)² = (2^(n+1) − 1)² = 4·4^n − 4·2^n + 1.
```

Together with `a(0)=1` and `a(1)=5`, this proves the source's recurrence and generating function. Rule 5, defining A270007, becomes uniformly OFF at time 2 and then alternates. Its odd sampled times from time 3 onward have the same full-square counts.

## Exact statement coverage

| Source conjecture | Lean target |
| --- | --- |
| Eleven other rules generate the sequence | Each named rule agrees at every `n : ℕ` |
| Formula for `n > 1`, including A060867(n+1) | Both the exponential formula and `(2^(n+1)-1)^2` |
| Recurrence for `n > 4` | Same range and coefficients, interpreted over integers |
| Rational generating function | Formal power-series product with the stated denominator and numerator |
| A270007 comparison for `n ≥ 2` | Equality with counts from independently defined Rule 5 dynamics |

The sequence is defined by cellular-automaton evolution, never by the conjectured formula or recurrence. The finite cyclic-grid convention and subtraction bounds are explained in the source review. The archived brief predates formalization; the statement's title uses the full OEIS title rather than the platform's truncated display.

## Reproduce locally

From the repository root, with the existing pinned Lean/Mathlib installation:

```sh
python3 problems/a273385/check.py
```

This compiles the statement and proof in a fresh temporary module directory, audits proof axioms, kernel-checks 39 small observations, simulates all 13 rules through time 31, and compares cyclic and infinite-grid crops through time 15. It compares six published terms directly with simulation and all 16 published terms with the proved formula; it does not pretend to simulate the largest time (32767). Report paths are normalized for reproducibility.

The kernel proof establishes the claims for all indices. Only `propext`, `Classical.choice`, and `Quot.sound` occur in its axiom audit. The statement contains its one intentional platform placeholder; the proof does not depend on it.

Official checker evidence is recorded in `reviews/official-statement.json`, `reviews/official-proof.json`, and `reviews/official-context.json`. These are local rehearsals, not upstream acceptance or semantic review. Recheck upstream and the exact merged statement before submitting a proof.

## Sources and licensing

`sources/` contains the platform agent brief, the full A273385/A270007/A060867 internal pages and readable extracts, and the published A273385 b-file. `provenance.json` records retrieval URLs, timestamps, and SHA-256 hashes. OEIS text is © OEIS Foundation and contributors, CC BY-SA 4.0. The b-file identifies itself as synthesized from the entry; it is not an independent experimental source.

Publication authorized on 2026-11-28. Existing statement [PR #22075](https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/22075) uses equivalent but different definitions; the adapted proof has passed the official checker against its exact pending target. See [submission proof](submission/oeis-a273385.lean) and [checker evidence](reviews/pr-22075-proof-check.json).

## Automatic submission

Publication and submission are authorized without further approval. `scripts/watch_a273385_submission.py --run` watches upstream main for up to 48 hours in an isolated clone. It checks that the merged statement is byte-identical to PR #22075's reviewed target, that no proof exists on main, and that the proof, dependencies, and checker/client still match their recorded hashes. It reruns the official checker, submits a one-file proof PR with the normal client, verifies remote contents, and monitors CI and merge status. Desk outages do not block the client's documented missing-lease submission path.

Current state: `.oma/a273385-watch/status.json`; process ID: `.oma/a273385-watch/pid`. Private operational logs stay ignored. The machine must remain awake and online. A changed target/toolchain, existing merged proof, uncertain submission, or failed CI stops automation for inspection; it never blindly retries an uncertain submission. The watcher does not update committed documentation automatically.

The original proof remains in `proofs/` with its independently developed statement. The submission proof instead imports the other contributor's statement and proves its exact target directly: `Nat.testBit` dynamics, cardinality of a filtered integer-square crop, and integer closed forms. The source and mathematical argument agree; no statement placeholder is used.
