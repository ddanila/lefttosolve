# A267610 local preparation — positive proof of the corrected target

Scope: statement submission and automatic proof submission authorized on
2026-11-28. Publish the proof only after the accepted statement merges and
the exact-target check passes.

## Completed

- [x] Archive entries, b-files and brief; inspect prior literature.
- [x] Audit cumulative counts, offsets and reference definitions.
- [x] Preserve the literal statement/disproof and checks in archive/.
- [x] Explicitly propose the n+1 correction; leave the GF unchanged.
- [x] Explain the omission of the separate containment interpretation.
- [x] Prove Rule 182's Pascal-parity row invariant.
- [x] Use Lucas to prove the binary-weight row count.
- [x] Prove the corrected relation and GF for every n.
- [x] Narrow imports; official peak memory falls from 5.86 GB to 1.99 GB.
- [x] Official statement/proof checkers and exact target/axiom audit pass.
- [x] Verify the openwitness reference and document its limited role.
- [x] Rewrite both PR drafts around the positive result and explicit correction.
- [x] Full ten-problem suite passes; reports reproduce exactly.
- [x] Commit the complete local package without pushing.

## Pre-submission review follow-up

- [x] Remove proof readiness and method from the statement PR draft.
- [x] Read section 4.3, Example 4.9; archive and hash the inspected paper.
- [x] Disclose known mathematics explicitly in both PR drafts and source audit.
- [x] Remove the unnecessary Bitwise import; statement and proof still compile.
- [x] Make the two tactic sequences tolerate simplification closing a goal.
- [x] Rerun official and isolated checks: accepted, standard axioms only, no proof warnings.
- Optional proof shortening deferred; current length is 6,102 counted characters.

## Submission workflow

- [x] Recheck canonical upstream, matching PRs, dependency and checker pins.
- [x] Submit statement [#35416](https://github.com/lefttosolve2/open-math-agents/pull/35416), disclosing the correction,
  prior mathematics and competing GF-only statement #33330.
- Do not silently replace a source formula or claim the brief is unchanged.
- [ ] After review/merge, watcher verifies exact statement bytes and reruns the checker.
- [ ] Watcher submits one positive proof file, verifies its bytes and monitors CI/verdict.

The original typo-disproof is an audit artifact, not the proposed submission.
Watcher: scripts/watch_a267610_submission.py, with runtime status under
.oma/a267610-watch/status.json. It polls every 60 seconds for up to 48 hours,
stops on target/checker changes or competing proofs, and recognizes merger
bot rejections even when CI is green.
