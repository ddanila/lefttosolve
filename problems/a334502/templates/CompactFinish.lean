import CompactDynamics
import Finish
namespace A334502Local
open OMA.S_oeis_a334502

lemma cell_step_nat (n t i : ℕ) (hn : 14≤n) (hi : i<n) :
    Compact.cell n (t+1:ℕ) i ↔
    (¬Compact.cell n t (prev n i) ∧
      (Compact.cell n t i ∨ Compact.cell n t (next n i))) ∨
    (Compact.cell n t (prev n i) ∧ ¬Compact.cell n t i) := by
  by_cases h0 : i=0
  · subst i
    have hp : (prev n 0:ℤ)=(n:ℤ)-1 := by unfold prev; split_ifs <;> omega
    have hq : (next n 0:ℤ)=1 := by unfold next; split_ifs <;> omega
    simpa only [Nat.cast_add, Nat.cast_one, Nat.cast_zero, hp, hq] using
      Compact.left_step n t (by omega) (by omega)
  · by_cases he : i+1=n
    · have hp : (prev n i:ℤ)=(n:ℤ)-2 := by unfold prev; split_ifs <;> omega
      have hq : (next n i:ℤ)=0 := by unfold next; split_ifs <;> omega
      have hx : (i:ℤ)=(n:ℤ)-1 := by omega
      simpa only [Nat.cast_add, Nat.cast_one, hx, hp, hq] using
        Compact.right_step n t (by omega) (by omega)
    · have hp : (prev n i:ℤ)=(i:ℤ)-1 := by unfold prev; split_ifs <;> omega
      have hq : (next n i:ℤ)=(i:ℤ)+1 := by unfold next; split_ifs <;> omega
      simpa only [Nat.cast_add, Nat.cast_one, hp, hq] using
        Compact.inner_step n t i (by omega) (by omega) (by omega) (by omega)

/-- The pruned residue model supplies a uniform certificate at time 12*n. -/
theorem largeCycles : LargeCycles := by
  intro n hn
  let C : ℕ → ℕ → Prop := fun t i => Compact.cell n t i
  have initial : ∀ i, i<n → (C 0 i ↔ i=0) := by
    intro i hi
    simpa only [C, Nat.cast_zero, Nat.cast_eq_zero] using
      Compact.initial n i (by omega) (by omega) (by omega)
  have bridge := row_model n (by omega) C initial (cell_step_nat n · · hn)
  refine ⟨12*n, certificate_of_model n (12*n) (by omega) C bridge ?_ ?_⟩
  · intro i hi
    simpa only [C, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] using
      Compact.period n i (by omega) (by omega) (by omega)
  · simpa only [C, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] using
      Compact.nonfixed n (by omega)
end A334502Local

namespace OMA
theorem solution : type_of% @S_oeis_a334502.main :=
  A334502Local.target_of_largeCycles A334502Local.largeCycles
end OMA
#print axioms OMA.solution
