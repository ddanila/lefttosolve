# A283508: actionable gap checklist

This backlog stages the work identified by the statement audit. Stage 1 prepares a complete standalone statement; Stage 2 extends local proof coverage; Stage 3 connects the infinite-grid model to the cyclic reference program. All tasks below are pending. Creating this checklist does not implement the gaps.

Priority order: **P0** = statement readiness, **P1** = additional proof coverage, **P2** = reference-program equivalence. Complete dependencies before starting dependent tasks. Publishing, claiming the problem, and upstream submission are outside this backlog's execution scope; work remains local.

## Stage 1 — Complete and validate the statement

- [ ] **S1 — Archive and audit A267623** · P0 · Dependencies: none.
  - Deliverable: authoritative entry, reference code, and term table saved under `sources/`, with retrieval dates, source URLs, attribution, and SHA-256 provenance. Use https://oeis.org/A267623/internal and its linked term table.
  - Audit Rule 187's bit ordering and initial state. Its sequence reads the centre cell across times `0…n` and encodes those bits as decimal digits; it is not a spatial row.
  - Acceptance: the reference rule, time indexing, and encoding are documented independently of A283508's formula or conjectured equality. Any conflict between source descriptions and programs is recorded and resolved before S2.

- [ ] **S2 — Define both missing propositions** · P0 · Dependencies: S1.
  - Deliverable: an independently defined Rule 187 automaton and its sequence, plus `∀ n : ℕ, A283508.a n = A267623.a n`. Do not define A267623 using the desired closed form or A283508 itself.
  - Define `A : PowerSeries ℤ` with coefficient `n` equal to `(A283508.a n : ℤ)`. State `A * ((1 - X) * (1 - 10*X)) = 1 - X + X^2`.
  - Acceptance: definitions and propositions compile with no placeholders. Document why the denominator's constant coefficient of 1 makes the product identity equivalent to the source's formal generating-function quotient. Proving these propositions belongs to Stage 2.

- [ ] **S3 — Package the standalone statement** · P0 · Dependencies: S2.
  - Deliverable: `statements/oeis-a283508.lean`, beginning with `import Mathlib`, using namespace `OMA.S_oeis_a283508`, and containing complete definitions and exactly one `theorem main`.
  - Copy the minimal necessary definitions into this file; do not import local project modules. Include source attribution and explain the observation and encoding conventions.
  - State `main` as the conjunction, in source order, of the generating-function identity, the natural-number closed formula for `n > 0`, the recurrence with values cast to `ℤ` for `n > 2`, and sequence equality for all `n : ℕ`.
  - Acceptance: `main` has an explicit complete proposition and `by sorry` as its body. This is the file's only proof placeholder; no definition contains `sorry` or an added axiom.

- [ ] **S4 — Validate packaging and definition consistency** · P0 · Dependencies: S3.
  - Deliverable: a reproducible standalone compilation check and Lean equivalence lemmas connecting the packaged definitions to their local counterparts.
  - Compile the statement in an environment exposing Mathlib and its dependencies but no local project modules. Extend validation so the statement's single intentional placeholder is allowed only there; proof modules must remain free of placeholders and forbidden axioms.
  - Acceptance: standalone compilation and definition-equivalence proofs pass. The packaged target's type depends only on complete definitions. Label official checker compatibility **unverified** until the official checker is actually run; compilation alone is not an upstream acceptance claim.

## Stage 2 — Extend proof coverage

- [ ] **P1 — Prove named initial values and integer recurrence** · P1 · Dependencies: none.
  - Deliverable: named theorems for `a 0 = 1`, `a 1 = 10`, and `a 2 = 101`, plus the recurrence in `ℤ` derived from existing results.
  - Acceptance: preserve `n > 2`; no reliance on truncating subtraction in the final integer statement. The build and allowed-axiom audit pass.

- [ ] **P2 — Prove the generating-function identity** · P1 · Dependencies: S2, P1.
  - Deliverable: a proof of the exact power-series proposition selected in S2.
  - Use coefficient extensionality, handle coefficients 0, 1, and 2 explicitly, and use the recurrence for higher coefficients.
  - Acceptance: the theorem compiles with no placeholders and only the allowed axioms; it covers the complete formal power series, not finitely many coefficients.

- [ ] **P3 — Prove equality with A267623** · P1 · Dependencies: S1, S2.
  - Deliverable: a proof of Rule 187's centre-cell behaviour from its independently defined update rule, followed by equality of the decimal encodings for all natural indices.
  - Acceptance: cover index 0 and the early transient explicitly. Numerical agreement is supporting validation, not the proof. Neither sequence is defined or assumed equal to the other.

- [ ] **P4 — Certify the complete statement locally** · P1 · Dependencies: S4, P1, P2, P3.
  - Deliverable: a separate verification module proving the exact conjunction and definitions used in the standalone statement, with explicit checks that the target matches `main`'s type.
  - Acceptance: do not use `main` or any theorem depending on its placeholder as evidence. Audit the complete proof for only `propext`, `Classical.choice`, and `Quot.sound`. Keep the statement file's required single placeholder while retaining the full proof separately.

## Stage 3 — Bridge to the reference program

- [ ] **R1 — Prove initial-state locality** · P2 · Dependencies: none.
  - Deliverable: a general Lean theorem that two initial grids agreeing on the Manhattan-distance ball of radius `n` around a cell produce the same value at that cell after `n` updates.
  - Acceptance: the result applies to arbitrary initial grids and coordinates, covers `n = 0`, and follows from the existing simultaneous update definition without assumptions about the conjectured pattern.

- [ ] **R2 — Connect torus and infinite evolution** · P2 · Dependencies: R1.
  - Deliverable: cyclic evolution on a 257×257 grid and its periodic lift, with a proved correspondence between cyclic updates and infinite-grid updates of the lift.
  - Represent the lifted seed configuration by ON cells at `(257ℤ)²`. Prove that other seeds lie outside every observed cell's initial dependency ball when `0 ≤ m ≤ n ≤ 126`; use `257 - n > n`.
  - Acceptance: for every such `n` and `m`, the cyclic reference model's cell equals `state n m 0`, including `n = 126, m = 126`. Do not substitute the existing frozen-border theorem for this argument.

- [ ] **R3 — Validate and document the reference bridge** · P2 · Dependencies: R2.
  - Deliverable: a cyclic simulator matching the reference rule and 257×257 dimensions, comparisons with all 127 supplied terms, and updated source-audit documentation.
  - Acceptance: cyclic simulation agrees with the table and infinite model through step 126. Audit the new Lean bridge theorems. Distinguish the old padded-border result, the proved cyclic model, and the remaining human translation of the Mathematica program; do not claim formal verification of Mathematica itself.

## Completion rules

- Mark a task complete only after its deliverable and acceptance checks pass; record the relevant theorem names, check commands, and result beside the task.
- Update README and validation claims when implementation changes their scope. Do not mark a proof complete based on samples, model opinions, or standalone compilation.
- Preserve the existing checked formula and recurrence throughout. Local validation and upstream human review remain separate statuses.
- Treat natural-number arithmetic as a presentation issue, not an established defect. The new packaged recurrence uses `ℤ`; the existing natural-number theorems remain valid.

## Audit findings and task mapping

Found by auditing the Lean statement against the saved OEIS entry (`sources/A283508.html`) and the Left to Solve brief (`sources/agent.txt`) on 2026-11-27. The definitions in `A283508/Basic.lean` and the ranges of `formula` (`n > 0`) and `recurrence` (`n > 2`) match the source; the gaps below are about what is missing around them.

### 1. Deliverable is not in the format the brief asks for

Tracked by **S3–S4**; full local certification follows in **P4**.

The brief asks for a statement file, not a proof:

- path `statements/oeis-a283508.lean`
- `import Mathlib`
- namespace `OMA.S_oeis_a283508`
- definitions with no `sorry` and no `axiom`
- a single `theorem main` whose body is the only `sorry`

The repo instead has a fully proved `A283508.formula` and `A283508.recurrence` under a different namespace and layout, with narrow Mathlib imports. It would not pass `tools/oma.sh check oeis-a283508` as is.

To close: add the standalone file with copied minimal definitions, rather than imports of local modules, and prove consistency with the existing definitions. State `main` as the conjunction of all four source conjectures.

### 2. Two of the four source conjectures are not stated

Tracked by **S1–S2** for formulation and **P1–P4** for proof coverage.

The OEIS entry lists:

| Source conjecture | Status |
| --- | --- |
| `a(n) = (91*10^n - 10) / 90` for `n > 0` | stated and proved (`formula`, `exact_identity`) |
| `a(n) = 11*a(n-1) - 10*a(n-2)` for `n > 2` | stated and proved (`recurrence`) |
| G.f. `(1 - x + x^2) / ((1 - x)*(1 - 10*x))` | not stated |
| `a(n) = A267623(n)` | not stated |

- **Generating function.** It is equivalent to the closed form together with `a 0 = 1`, and `a 0 = 1` is currently only an `example` in `scripts/Checks.lean`. The selected formulation is the explicit `PowerSeries ℤ` product identity in S2, with coefficients cast from `ℕ` to `ℤ`. Initial values and the recurrence support its proof rather than replace its statement.
- **A267623.** This needs a second automaton defined from the A267623 entry, whose source is not yet saved under `sources/`. To close: archive that entry, define its sequence, and state `∀ n, a n = A267623.a n`.

### 3. `Locality.lean` does not cover the Mathematica reference program

Tracked by **R1–R3**, a separate follow-up stage after statement readiness.

`window_correct` justifies the repo's own dense validator, which freezes an OFF border. The OEIS Mathematica program is different: `ListConvolve[..., a, 2]` is cyclic, so it runs on a 257×257 torus.

Applied to that torus, the generic light-cone bound in `window_correct` only guarantees the read cells up to about `n = 63`, not the published `n = 126`. The full range holds for a different reason: the torus is the infinite grid with seeds on the lattice `(257ℤ)²`, and the cell `(m, 0)` with `m ≤ n` at step `n` depends only on initial cells within L1 distance `n`, while the nearest other seed is at distance `257 - n > n`.

This does not affect the correctness of the statement, and the 127 b-file terms agree with the infinite-grid model. To close (optional): prove that two initial grids agreeing on the L1 ball of radius `n` around a cell give the same value there after `n` steps, and apply it to the periodic seed configuration; also correct README item 6 if it is read as covering the Mathematica program.

### 4. Natural-number arithmetic in the statements (no action needed)

Presentation choice settled in **S3** and supported by **P1**; no correction to the existing natural-number results is required.

`formula` and `recurrence` use truncating `-` and `/` in `ℕ`. This does not weaken either claim: `exact_identity` shows the division is exact, and the `ℕ` recurrence implies the `ℤ` one because `a n > 0`. The standalone statement will use `ℤ` for the recurrence; the closed formula retains the existing natural-number formulation and exact-identity justification.
