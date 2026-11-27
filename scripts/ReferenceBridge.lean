import A283508
import OMAStatements.S_oeis_a283508

/-! Connect the reference-program model to the proposed published definitions.
The conjecture proof is maintained only in proofs/oeis-a283508.lean. -/
namespace A283508

/-- The reference model and the statement use the same initial grid and update rule. -/
theorem state_matches_statement (n : ℕ) : state n = OMA.S_oeis_a283508.state n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    change step (state n) = OMA.S_oeis_a283508.step (OMA.S_oeis_a283508.state n)
    rw [ih]
    rfl

/-- Every observed torus cell agrees with the state used by the published conjectures. -/
theorem observed_statement_torus_correct (n m : ℕ) (hn : n ≤ 126) (hm : m ≤ n) :
    torusState n (m : ZMod 257) 0 = OMA.S_oeis_a283508.state n m 0 := by
  rw [observed_torus_correct n m hn hm, state_matches_statement]

end A283508
