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
- [x] #33330 merged; reviewed the checker/client delta and resumed the stopped watcher.
- [x] Verify exact merged statement bytes and rerun the current official checker.
- [x] Submit adapted proof #39513 and verify its bytes.
- [ ] Monitor #39513 CI/verdict; watcher active. Competitor #38793 is green and older.

The original typo-disproof is an audit artifact, not the proposed submission.
Watcher: scripts/watch_a267610_submission.py, with runtime status under
.oma/a267610-watch/status.json. It polls every 60 seconds for up to 48 hours,
accepts either checked target, stops on unknown target/checker changes or competing proofs, and recognizes merger
bot rejections even when CI is green.

## Alternative statement coverage

- [x] Archive @ppleskov's exact GF-only statement from #33330.
- [x] Bridge cell states, counts and A006046; cast the GF to ℚ.
- [x] Exact-target and official checker acceptance; standard axioms only.
- [x] Test and restart the watcher with both target hashes and proof files.
- [x] Use a dedicated proof branch; an open statement PR cannot block it.

The adapter in alternatives/ppleskov/ is submitted as #39513 against merged #33330.
It has 8,267 counted characters versus 6,137 for #38793, so it would not qualify
as a shorter replacement if that competing proof merges first. Changed checker
or target hashes still stop safely; unused client changes no longer block this path.
