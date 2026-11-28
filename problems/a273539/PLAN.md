# A273539 local proof and submission plan

Scope: full publication and submission authorized 2026-11-28, without further
approvals. The separately authorized A273385 watcher is unaffected.

## Local work

- [x] Archive the full OEIS entry, b-file, platform brief, and earlier PR withdrawal.
- [x] State all four conjectures with the original ranges and integer subtraction.
- [x] Audit source semantics, including background evolution and the finite crop.
- [x] Prove the parity invariant and equality of the four rules at all times.
- [x] Discover a finite machine and verify its recurrence certificates in Lean.
- [x] Prove the sampled boundary by induction over ten reachable boundary states.
- [x] Extend to integer coordinates; prove the support bound and original-grid bridge.
- [x] Prove OFF iff on the diamond and count its 4t points.
- [x] Derive the formula, recurrence, generating function, and exact `OMA.solution`.
- [x] Assemble a standalone proof with no dependency on local research modules.
- [x] Run isolated compilation, axiom audit, certificate and independent simulation checks.
- [x] Run the unmodified official statement and proof checkers locally.
- [x] Check the 512 KiB size and measure compilation resources; narrow Mathlib imports.
- [x] Integrate the per-problem checker into the root checker and document the result.
- [x] Prepare statement/proof PR text and preserve local provenance in Git.

## Publication and submission

- [x] Recheck the live brief, statement/proof files on upstream main, all open PRs,
      catalog pin, checker changes, and desk activity. Use canonical repository
      `lefttosolve2/open-math-agents`; searches against the old name return nothing.
- [ ] Reconcile any newly merged statement with the source and adapt the proof if needed.
      Re-run the official checker on the exact target; do not submit a competing
      statement when a faithful one is already merged.
- [x] Publish local provenance and acquire a normal lease.
- [x] Submit checked statement PR [#26102](https://github.com/lefttosolve2/open-math-agents/pull/26102); awaiting human review.
- [ ] Once the statement is merged and available to the checker, verify the final exact
      target again and submit the already prepared proof through the normal client.
- [ ] Verify the resulting one-file PR, monitor CI/verdict/merge/catalog, and record status.

The complete proof is published in `ddanila/lefttosolve` at commit `21508ae`.
The live official checker accepted both files, including the new exact-statement guard.

Automatic follow-up is running via `scripts/watch_a273539_submission.py --run`.
It polls every 60 seconds for up to 48 hours, then rechecks and submits the proof
after the exact statement merges. It monitors proof CI and merge. The watcher
stops for a changed target or checker, an existing proof, rejected statement,
or uncertain submission; its status is `.oma/a273539-watch/status.json`.
It requires this machine to remain awake and online. No further approval is needed.
