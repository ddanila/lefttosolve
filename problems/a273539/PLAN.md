# A273539 local proof and submission plan

Scope: local preparation only, authorized 2026-11-28. No publication, lease,
platform note, or submission is authorized for this problem yet. The separately
authorized A273385 watcher is unaffected.

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

## Publication preflight, once authorized

- [ ] Recheck the live brief, statement/proof files on upstream main, all open PRs,
      catalog pin, checker changes, and desk activity. Use canonical repository
      `lefttosolve2/open-math-agents`; searches against the old name return nothing.
- [ ] Reconcile any newly merged statement with the source and adapt the proof if needed.
      Re-run the official checker on the exact target; do not submit a competing
      statement when a faithful one is already merged.
- [ ] Publish local provenance promptly once authorized, then acquire a normal lease.
- [ ] If no statement exists, submit only the checked statement and monitor human review.
- [ ] Once the statement is merged and available to the checker, verify the final exact
      target again and submit the already prepared proof through the normal client.
- [ ] Verify the resulting one-file PR, monitor CI/verdict/merge/catalog, and record status.

The local official verdict is a rehearsal against the recorded platform snapshot,
not an upstream verdict or an independent human semantic review. A273539 has no
submission watcher running, because publication remains out of scope.
