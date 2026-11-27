# OEIS A283508: Rule 643 in Lean

All four source conjectures (generating function, closed form, integer recurrence, and equality with A267623) are proved for the infinite-grid interpretation of the OEIS reference program. The project builds with **Lean 4.33.1** and the exact Mathlib revision used by formal-conjectures commit `9097e2f90e66d2f6244209cb1c07f7120d17ec53`.

For every `n > 0`, the Lean kernel checks

```text
a(n) = (91 * 10^n - 10) / 90
```

The stronger exact identity `90*a(n)+10 = 91*10^n` also holds, so natural-number division has not weakened the claim. For `n > 2`, the source's recurrence is proved as well:

```text
a(n) = 11*a(n-1) - 10*a(n-2)
```

The workspace is published at [ddanila/lefttosolve](https://github.com/ddanila/lefttosolve). The problem lease was acquired under @ddanila on 2026-11-27; no platform submission has been made. This is not a claim of a newly discovered mathematical result. The standalone statement is in `statements/oeis-a283508.lean`; its exact target is proved separately by `scripts/Certificate.lean`. The unmodified official checker **accepted** the statement on 2026-11-27. A fresh independent source-to-statement review found no blocking mismatch; upstream human review still follows submission.

## Why the proof is short

Initially only the origin is ON. At step 1, every cell is ON except the four orthogonal neighbours of the origin. At step 2, every cell is ON except the eight cells surrounding the origin. The latter configuration is fixed under Rule 643.

The proof checks cells in `[-2,2] × [-2,2]` by kernel reduction and handles all remaining cells using an exterior lemma. Induction then proves stability forever. Reading the horizontal axis gives `1`, `10`, `101`, `1011`, and so on. The final arithmetic proof uses the decimal append operation `v ↦ 10*v+1`.

## Reproduce

Python 3 and elan are required. With elan installed:

```sh
export PATH="$HOME/.elan/bin:$PATH"
lake exe cache get
python3 scripts/check.py
```

The pinned toolchain and dependencies download when needed. A fresh setup needs several GB; this checkout already has the toolchain and cache. `scripts/check.py` runs the build, sparse/padded/cyclic Rule 643 simulations, an independent Rule 187 simulation, Lean computation samples, source hash checks, and axiom audits. It also compiles the standalone statement in an empty directory with only Mathlib dependencies available, then assembles and checks the separate certificate. It also compiles the single-file follow-up proof with only the proposed upstream statement and Mathlib available, and audits `OMA.solution`. It writes the latest validation results into `reviews/`.

The completed run checks all 32 neighbourhoods and all 127 supplied OEIS terms, indexed 0 through 126. Lean additionally checks direct computations at indices 0–3 and evaluates indices 0–6. The proof modules and complete certificate have no `sorry`, added axioms, `native_decide`, or unsafe implementation. The statement has exactly one intentional `sorry` in `main`, as the problem brief requests; the certificate never invokes it. Its only axioms are `propext`, `Classical.choice`, and `Quot.sound`.

## Files

- `A283508/Basic.lean`: rule bits, infinite grid, evolution, observation and decimal encoding.
- `A283508/Proof.lean`: first two steps, fixed configuration, axis pattern, formula, exact identity and recurrence.
- `A283508/Locality.lean`: independence from arbitrary, time-varying boundary values when sufficiently padded.
- `A283508/GeneratingFunction.lean`: initial values, integer recurrence, and all-coefficient power-series proof.
- `A283508/Rule187.lean`: independent elementary automaton, centre-cell pattern, and sequence equality.
- `A283508/Torus.lean`: general Manhattan locality, periodic lift, and cyclic observation equivalence.
- `statements/oeis-a283508.lean`: self-contained statement with the brief's single intentional placeholder.
- `scripts/Certificate.lean`: definition-equivalence proofs and the complete target certificate, appended to the statement by the checker.
- `proofs/oeis-a283508.lean`: generated follow-up proof in the platform format, importing the proposed merged statement.
- `scripts/package_proof.py`: regenerate that file after local proof changes.
- `scripts/platform_check.py`: run the official statement checker in separate upstream checkouts, without a lease.
- `scripts/validate.py`: independent sparse, padded, cyclic, and Rule 187 simulations.
- `scripts/check.py` and `scripts/Checks.lean`: reproducible checks and axiom audit.
- `sources/`: saved source material and SHA-256 provenance manifest.
- `reviews/`: raw local-model requests/responses, review disposition, and verification output.

## Source and semantic audit

Source: [OEIS A283508](https://oeis.org/A283508), its [internal entry and Mathematica program](https://oeis.org/A283508/internal), and [Robert Price's table](https://oeis.org/A283508/b283508.txt), retrieved 2026-11-27. OEIS material is attributed to the OEIS Foundation and the contributors named in the archived entry and is provided under its [CC BY-SA 4.0 terms](https://oeis.org/wiki/The_OEIS_End-User_License_Agreement). Source snapshots retain their original content.

The translation decisions are:

1. **Rule indexing.** `IntegerDigits[643,2,10]` lists bits most significant first. The source indexes that list at `10-(c+2*k)`, which selects zero-based bit `c+2*k`. Lean defines that bit using division and remainder, then proves the readable truth table for both centre states and all neighbour counts 0–4.
2. **Simultaneous updates.** Every next cell reads only the previous grid. The neighbourhood is the centre plus the four orthogonal neighbours. Their order does not matter because only their count is used.
3. **Background.** The infinite initially OFF background becomes ON at step 1 because bit 0 is 1. There is no special first-step rule and no permanently OFF infinite exterior. At later times the uniform ON background stays ON because bit 9 is 1.
4. **Observation window.** “Right edge” means the displayed crop at position `n`, not the boundary of a finite ON population: the grid already has infinitely many ON cells at time 1. Read `x=0..n` on `y=0` after exactly `n` updates.
5. **Decimal encoding.** The source explicitly uses `FromDigits[...,10]`. Thus `1011` denotes decimal 1011, despite its digits being cell bits. Lean's recursive encoding uses base 10.
6. **Padding.** The dense validator stores coordinates through `±(2*N+1)`, freezes that outermost border OFF, and updates the interior through `±2*N`. `observed_window_correct` proves arbitrary border behavior cannot affect any read digit for `n ≤ N`. This justifies the independent finite simulation; we do not claim to have executed or formally verified Mathematica itself.
7. **Cyclic reference grid.** The source's `ListConvolve[...,a,2]` uses a 257×257 cyclic grid. This differs from the padded validator. `lift_step` and `lift_evolve` identify cyclic evolution with the infinite periodic lift, whose initial ON cells lie in `(257ℤ)²`. `evolve_local` proves that only the initial Manhattan ball of radius `n` matters. For an observation `(m,0)`, `m ≤ n ≤ 126`, every other seed is at distance at least `257-m ≥ 257-n > n`. `periodic_agrees` checks this using coordinate bounds and divisibility; `observed_torus_correct` then proves equality of every observed digit, including the endpoint `n=m=126`. The cyclic simulator compares all 127 encodings with the table and sparse infinite model.
8. **Source inconsistency.** The linked diagrams explicitly say Rule 641 and show an OFF origin at odd steps. The entry, program and sequence table specify Rule 643. We follow the latter three and do not use those diagrams as validation evidence.

The remaining trust boundary is the human translation of the OEIS definitions and Mathematica program. Lean proves the defined cyclic model's correspondence; it does not formally verify Mathematica syntax or its evaluator. The official local checker passed; upstream human review has not occurred.

## Independent A267623 audit

The [A267623 entry](https://oeis.org/A267623/internal), reference-code extract, and [term table](https://oeis.org/A267623/b267623.txt) are archived with retrieval times and SHA-256 hashes in `sources/provenance.json`. Attribution and licensing are the same OEIS terms stated above; the entry retains individual contributor credits. The extract is derived from the archived entry.

The primary definition observes the **centre cell across times 0 through n**, starting from a single ON cell at time zero. R. J. Mathar's Maple program assigns weight 1 to the left cell, 2 to the centre, and 4 to the right, and returns OFF only for neighbourhood codes 2 and 6. This is the mirror of Wolfram’s standard orientation. Lean and the Python simulator now use the standard left/centre/right weights 4/2/1, as in the Mathematica program: “centre OFF or right ON.” At time 1 the only OFF cell is the origin; afterwards that hole moves one cell left per step. Reflection preserves the centre observation from the symmetric single-cell seed. Thus the centre is OFF exactly at time 1.

Maple first constructs the binary value from these time-ordered digits, then applies A007088 to display those digits as a decimal integer. Mathematica directly uses `FromDigits` with its default base 10. The initial centre is the most significant digit in either program. The Lean definition appends each new centre value in base 10; it neither uses the closed formula nor refers to A283508. The independent simulator checks every archived A267623 term.

The entry's secondary Rule 643 comment says “from the left edge to the origin.” Read literally, that reverses the digits and conflicts with the listed terms (already at n=1). We use the primary Rule 187 definition and both programs to define A267623, rather than this secondary comment or the conjectured equality.

## Generating function and certification

`series : PowerSeries ℤ` has coefficient `n` equal to `(a n : ℤ)`. The theorem proves
`series * ((1-X)*(1-10*X)) = 1-X+X²` by coefficient extensionality: the first three coefficients use the initial values, and every higher coefficient uses the integer recurrence. The denominator has constant coefficient 1, so it is a unit in the formal power-series ring; multiplication by it is equivalent to the source's formal quotient.

The standalone theorem inlines the four conjectures in source order, without a `Target` alias. Its header gives the source and `Credit: @ddanila`, and comments state every interpretation choice. The two automata share one bit conversion; each definition is used by the claim. The certificate proves equivalence of the copied definitions with the local ones, including induction for the recursive definitions, and proves exactly the inlined type of `main`; `type_of% main` checks that match. Its axiom audit permits only `propext`, `Classical.choice`, and `Quot.sound`; `sorryAx` would fail validation. The separate proof never invokes the statement’s placeholder. See `reviews/statement-checks.txt` for the isolated compilation and certificate result.

## Platform checks and follow-up

The platform pins the same Lean, Mathlib, and dependency revisions as this project;
see `reviews/platform-review.md`. To repeat the official check, obtain a checkout of
`GuillaumeBAUD-coder/open-math-agents` and formal-conjectures at the recorded pin,
with its Mathlib cache, then run:

```sh
python3 scripts/platform_check.py /path/to/open-math-agents /path/to/formal-conjectures
python3 scripts/check.py
```

`reviews/official-check.json` records the checker commit, toolchain, verdict, and
statement hash. The local validator reports acceptance only while that hash matches.
The separate upstream checkout is required because the client distinguishes new,
untracked statements from already tracked ones. No lease is needed for checking.

The follow-up proof begins with `import OMAStatements.S_oeis_a283508` and proves
`OMA.solution : type_of% @OMA.S_oeis_a283508.main`. It contains its helper proofs in
one file and is checked against an isolated copy of the proposed statement. If upstream
review changes the statement, regenerate and revalidate before submitting the proof.
The official proof checker also accepted a local rehearsal against this proposed statement
(`reviews/proof-preflight.json`). This preparation does not imply that the statement has merged.

The refreshed live snapshot still lists the problem as unformalized, with zero active
agents and no solution. That snapshot predates the lease acquired for @ddanila. The submission checkout and lease state are stored locally under `.oma/platform/`, excluded from git. Stage D
in `PLAN.md` requires Danila’s separate confirmation before each visible submission step.
