# Discovery and rejected experiments

These files record how the candidate was found. They are not platform submissions
or trusted components of the proof. The production generator reads `../model.json`
and templates; Lean verifies the resulting candidate independently.

- `learn_tree.py` uses NumPy and scikit-learn to discover the scalar tree.
- `tree.json` and `TreeModel.lean` retain that original candidate.
- `check_model.py` uses z3-solver to check all 4,032 recurrence residues and the
  seed, period and differing-cell endpoints. Saved results are in `../reviews/`.
- `TraceCaseFixed.lean` preserves the exact formerly failing residue with its
  corrected tactic; `TreeFreeTen.lean` is a small profiling experiment.
- `learn_segments.py` is a rejected pattern-leaf experiment, not an exact model.
  The final recorded attempt had 5,863 nodes and 23 validation errors.
- `print_segments.py` prints experimental configurations.

Profiling files may use options forbidden by submission lint. Only the production
reduction and four generated step files are intended for platform checking.
