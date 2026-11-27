# Platform pre-submission audit

Read on 2026-11-27: `sources/join.txt`, refreshed problem brief and API response,
both OEIS internal entries, and the reference checker at
`GuillaumeBAUD-coder/open-math-agents`, commit
`6ee271b036afac3309989bc1a33e3207717cfd17`.

## Actual rules

- A statement is `statements/oeis-a283508.lean`, importing Mathlib, in namespace
  `OMA.S_oeis_a283508`. Only `theorem main` is permitted, with one proof placeholder.
  Its proposition may be a conjunction: the official linter imposes no single-conjecture
  restriction. Faithfulness still requires human review.
- Credit belongs to the GitHub author of the eventual pull request; the file uses
  `Credit: @ddanila`, matching the confirmed handle.
- One new Lean file per submission pull request. This research workspace is a separate
  repository; official submissions belong in a fork of `open-math-agents`.
- A merged statement becomes module `OMAStatements.S_oeis_a283508`.
  The follow-up proof must begin with that import and prove exactly
  `theorem OMA.solution : type_of% @OMA.S_oeis_a283508.main := ...`.
  Mathlib imports and helper declarations are allowed. The conjecture itself may not
  be used as proof evidence. Thus C1's tentative Mathlib-only proof format was incorrect.
- `oma.sh check` does not require a lease or GitHub credentials. It runs the official
  linter, compiles against the pinned checkout, and produces a local verdict.
  `next` and `submit` are separate operations and have not been run.
- `oma.sh` treats an untracked statement file as a new statement. Running it inside
  this research repository (where the statement is tracked) would select the proof
  instead. `scripts/platform_check.py` copies it to an untracked path in a separate
  upstream checkout and invokes the unmodified command there.

## Toolchain

The catalog and checker require formal-conjectures commit
`9097e2f90e66d2f6244209cb1c07f7120d17ec53`. Its `lean-toolchain` is
`leanprover/lean4:v4.33.1`; its resolved Mathlib revision is
`0df444a360eaa60ab8c11dca51a86af692955474`. Every dependency name/revision
matches the local manifest. The official run uses a real checkout at that exact
commit and reuses the existing dependency cache. No checker code is patched.

Reproduce after obtaining both checkouts and their dependencies:

```sh
python3 scripts/platform_check.py /path/to/open-math-agents /path/to/formal-conjectures
python3 scripts/check.py
```

The saved verdict is tied to the statement's SHA-256 hash. Local validation reports
it as unverified if the statement changes, so a stale acceptance cannot cover edits.

## Live data

The refreshed problem response reports `kind: unformalized`, empty Lean/module fields,
`liveAgents: 0`, and `solution: null`. The refreshed brief says it is open.
Both entries' name, comments, formulas, programs, and offsets match the earlier archives.
These are observations at the provenance timestamps, not a reservation or guarantee
that nobody can begin later. Refresh immediately before the eventual lease/submission.

The source conventions are now recorded directly in the statement. In particular,
Rule 187 follows Wolfram's left/centre/right weights 4/2/1. The Maple program uses
the mirrored weights 1/2/4; its centre-column sequence is unchanged by reflection.

## Statement simplification

Every definition in the final file is used transitively by `main`. A267623 now shares
one bit-to-natural conversion with the 2D automaton. The explicit bit division/remainder
and decimal append definitions were retained: they expose the source's rule indexing
and most-significant-first convention directly. Replacing them with `Nat.testBit` or
`Nat.ofDigits` would introduce bit-order/list-order conventions for the reviewer to unpack.
The simple shared Boolean conversion remains explicit rather than adding an alias.

## Follow-up rehearsal

The final proof was also copied to the separate platform checkout and checked by the
unmodified `tools/check.sh proofs/oeis-a283508.lean` against the proposed statement.
It passed both lint and kernel/axiom checks. `reviews/proof-preflight.json` records
the statement and proof hashes. This simulates the post-merge import locally; it is
not a claim that the upstream statement has merged or that the proof was submitted.
