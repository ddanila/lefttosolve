# A071052 local preparation

Scope: user authorized publication and proof submission without further approval.

## Local work

- [x] Archive authoritative A071052/A071036 entries, b-file, brief and exact statement.
- [x] Inspect existing PRs and the other proof, including the reason for its CI failure.
- [x] Audit source ranges, left-edge indexing, initial row, and zero counting.
- [x] Prove two-step XOR cancellation and the all-integer doubling identities.
- [x] Count the even/odd positions and prove the exact upstream target.
- [x] Isolate compilation and audit axioms; check independent simulations.
- [x] Run the unmodified official checker and measure time, memory and proof length.
- [x] Prepare PR text with candid attribution and comparison limitations.
- [x] Integrate the root checker, verify reproducible reports, and commit locally.

## Authorized submission

- Recheck canonical upstream `lefttosolve2/open-math-agents`, its exact statement,
  any proof on main, and PR #21850 (including potential competing submissions).
- Verify dependency/checker pins and rerun the official checker if anything changed.
- If a proof has merged, compare against that file using current `tools/prooflen.py`;
  the 5% plus 20-character replacement threshold applies to main, not a pending PR.
- Publish local provenance promptly, then use the normal client to submit exactly
  one proof file. Use the documented no-lease path if a pending-proof desk refusal
  occurs, explaining it honestly in the PR.
- Verify exact submitted bytes and one-file diff, then monitor CI, verdict and merge.

No A071052 watcher is running. The pre-existing watchers are unaffected.
