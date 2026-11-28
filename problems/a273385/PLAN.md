# A273385 local preparation

Publication authorized on 2026-11-28. Existing statement PR #22075 by @yooeonwoo is open; adapt the proof to its exact target and submit after merge.

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
- [ ] After merge, compare exact merged bytes, recheck the proof against that statement, and submit it promptly.
- [ ] Record PRs and monitor verdicts; distinguish CI success, merger acceptance, and catalog deployment.

Automatic submission and CI monitoring are enabled with `scripts/watch_a273385_submission.py`; status lives in `.oma/a273385-watch/status.json`.
