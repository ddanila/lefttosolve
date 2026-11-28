# A273385 local preparation

Publication authorized on 2026-11-28. Statement PR #22075 by @yooeonwoo merged at 10:48:29 UTC. The watcher stopped on changed checker/client hashes at 10:49; those changes were reviewed and the watcher restarted at 12:46. Exact merged statement bytes match. Official rechecking passed and proof PR [#29877](https://github.com/lefttosolve2/open-math-agents/pull/29877) was submitted at 12:49 UTC.

- [x] Archive the platform brief and full authoritative OEIS entries, with hashes and attribution.
- [x] Model the actual Rule 659 dynamics, changing background, and finite square crop.
- [x] Include all eleven alternative rules, both closed forms, recurrence, generating function, and the newer A270007 comparison.
- [x] Prove finite propagation, early uniformization, persistent uniformity, and Rule 5 alternation in Lean.
- [x] Finish the standalone exact-target proof with only permitted axioms.
- [x] Run isolated checks, direct simulations, cyclic-grid comparisons, and all published term/formula checks.
- [x] Complete official checker rehearsal and save context/hashes.
- [x] Confirm checker reproducibility and integrate the root checker/docs (all six problems passed).
- [x] Record an explicit source-to-statement self-audit; no independent review claimed.

Publication and submission:

- [x] Get publication authorization.
- [x] Refresh upstream status, existing PRs, catalog target, checker and dependency pins.
- [x] Publish the complete proof with its statement for provenance (c7bf665, pushed 2026-11-28).
- [x] Adapt to existing statement PR #22075; official exact-target check accepted.
- [x] Compare exact merged bytes, recheck, and submit proof PR #29877.
- [x] Record statement #22075 and proof #29877.
- [x] First-proof attempt declined after #29790 merged; superseded #29877 is closed.
- [x] Rebase unchanged proof onto main as a replacement: 7,271 vs 8,620 characters.
- [x] Official exact-target checker accepts; submit shorter-proof PR #35981.
- [ ] Monitor replacement #35981; monitoring is active and detects bot rejection.

Automatic submission and CI monitoring are enabled with `scripts/watch_a273385_submission.py`; status lives in `.oma/a273385-watch/status.json`.

Current proof PR: https://github.com/lefttosolve2/open-math-agents/pull/35981
The prior-work disclosure remains in the replacement body.
