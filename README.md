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

This is local work. No problem lease, submission, remote repository, or claim of a newly discovered mathematical result has been made. The standalone statement is in `statements/oeis-a283508.lean`; its exact target is proved separately by `scripts/Certificate.lean`. Official checker compatibility remains **unverified**.

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

The pinned toolchain and dependencies download when needed. A fresh setup needs several GB; this checkout already has the toolchain and cache. `scripts/check.py` runs the build, sparse/padded/cyclic Rule 643 simulations, an independent Rule 187 simulation, Lean computation samples, source hash checks, and axiom audits. It also compiles the standalone statement in an empty directory with only Mathlib dependencies available, then assembles and checks the separate certificate. It writes the latest validation results into `reviews/`.

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

The remaining trust boundary is the human translation of the OEIS definitions and Mathematica program. Lean proves the defined cyclic model's correspondence; it does not formally verify Mathematica syntax or its evaluator. Upstream human review and the official checker have not occurred.

## Independent A267623 audit

The [A267623 entry](https://oeis.org/A267623/internal), reference-code extract, and [term table](https://oeis.org/A267623/b267623.txt) are archived with retrieval times and SHA-256 hashes in `sources/provenance.json`. Attribution and licensing are the same OEIS terms stated above; the entry retains individual contributor credits. The extract is derived from the archived entry.

The primary definition observes the **centre cell across times 0 through n**, starting from a single ON cell at time zero. R. J. Mathar's Maple program assigns weight 1 to the left cell, 2 to the centre, and 4 to the right, and returns OFF only for neighbourhood codes 2 and 6. This is bit rule 187, equivalent to “centre OFF or left ON.” The independently defined Lean rule proves that truth table. At time 1 the only OFF cell is the origin; afterwards that hole moves one cell right per step. Thus the centre is OFF exactly at time 1.

Maple first constructs the binary value from these time-ordered digits, then applies A007088 to display those digits as a decimal integer. Mathematica directly uses `FromDigits` with its default base 10. The initial centre is the most significant digit in either program. The Lean definition appends each new centre value in base 10; it neither uses the closed formula nor refers to A283508. The independent simulator checks every archived A267623 term.

The entry's secondary Rule 643 comment says “from the left edge to the origin.” Read literally, that reverses the digits and conflicts with the listed terms (already at n=1). We use the primary Rule 187 definition and both programs to define A267623, rather than this secondary comment or the conjectured equality.

## Generating function and certification

`series : PowerSeries ℤ` has coefficient `n` equal to `(a n : ℤ)`. The theorem proves
`series * ((1-X)*(1-10*X)) = 1-X+X²` by coefficient extensionality: the first three coefficients use the initial values, and every higher coefficient uses the integer recurrence. The denominator has constant coefficient 1, so it is a unit in the formal power-series ring; multiplication by it is equivalent to the source's formal quotient.

The standalone target lists the four conjectures in source order. The certificate proves equivalence of the copied definitions with the local ones, including induction for the recursive definitions, and proves exactly the same `Target` type as `main`. Its axiom audit permits only `propext`, `Classical.choice`, and `Quot.sound`; `sorryAx` would fail validation. The target itself is audited too. See `reviews/statement-checks.txt` for the isolated compilation and certificate result.
