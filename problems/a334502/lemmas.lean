import OMAStatements.S_oeis_a334502
import Mathlib.Dynamics.PeriodicPts.Defs
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Local reductions for A334502
Credit: @ddanila

These lemmas do not yet prove the unbounded-width cellular automaton claim.
-/

namespace A334502Local
open OMA.S_oeis_a334502 Function

/-- A return anywhere on an orbit is a return at any periodic point of that orbit. -/
lemma return_at_cycle {α : Type*} (f : α → α) (x : α) (T P t p : ℕ)
    (hP : 0 < P) (cycle : IsPeriodicPt f P (f^[T] x))
    (ret : f^[t+p] x = f^[t] x) : f^[p] (f^[T] x) = f^[T] x := by
  apply ((cycle.apply_iterate p).iterate t).eq_of_apply_eq_same (cycle.iterate t) hP
  simp only [← Function.iterate_add_apply]
  calc
    f^[t + (p + T)] x = f^[T] (f^[t+p] x) := by
      rw [← Function.iterate_add_apply]
      congr 1
      omega
    _ = f^[T] (f^[t] x) := congrArg (f^[T]) ret
    _ = f^[t+T] x := by rw [← Function.iterate_add_apply, Nat.add_comm T t]

/-- A finite cycle certificate determines the infimum in the platform definition. -/
lemma period_eq (n T P : ℕ) (hn : n ≠ 0) (hP : 0 < P)
    (cycle : row n (T+P) = row n T)
    (minimal : ∀ p, 0 < p → p < P → row n (T+p) ≠ row n T) : a n = P := by
  rw [a, if_neg hn]
  have mem : P ∈ {p : ℕ | 0 < p ∧ ∃ t, row n (t+p) = row n t} :=
    ⟨hP, T, cycle⟩
  apply Nat.le_antisymm (Nat.sInf_le mem)
  apply le_csInf ⟨P, mem⟩
  rintro p ⟨hp, t, ht⟩
  by_contra h
  apply minimal p hp (by omega)
  have cyc : IsPeriodicPt (@step n) P (row n T) := by
    simpa only [IsPeriodicPt, IsFixedPt, row, ← Function.iterate_add_apply,
      Nat.add_comm P T] using cycle
  have ret := return_at_cycle (@step n) (1 : BitVec n) T P t p hP cyc ht
  simpa only [row, ← Function.iterate_add_apply, Nat.add_comm p T] using ret

/-- A compact decidable certificate, independent of the noncomputable infimum. -/
def Certificate (n T P : ℕ) : Prop :=
  row n (T+P) = row n T ∧ ∀ p ∈ Finset.Ioo 0 P, row n (T+p) ≠ row n T

instance (n T P : ℕ) : Decidable (Certificate n T P) := inferInstanceAs
  (Decidable (_ ∧ ∀ p ∈ Finset.Ioo 0 P, row n (T+p) ≠ row n T))

lemma period_of_certificate (n T P : ℕ) (hn : n ≠ 0) (hP : 0 < P)
    (h : Certificate n T P) : a n = P :=
  period_eq n T P hn hP h.1 (fun p hp hpP => h.2 p (Finset.mem_Ioo.mpr ⟨hp, hpP⟩))

/-- Expected coefficients, including the convention at width zero. -/
def expected (n : ℕ) : ℕ :=
  if n = 0 then 0 else if n ≤ 3 then 1 else if n = 4 then 8 else
  if n = 5 then 5 else if n = 7 then 14 else if n = 13 then 26 else 3

/-- First cycle-entry times for the fourteen small positive widths. -/
def entryTime (n : ℕ) : ℕ :=
  [0, 1, 2, 2, 1, 1, 3, 6, 3, 12, 3, 3, 21, 24, 7][n]?.getD 0

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
lemma small_certificates : ∀ n ∈ Finset.Icc 1 14,
    Certificate n (entryTime n) (expected n) := by decide +kernel

/-- The finite exceptional widths are fully kernel checked. -/
lemma small_values (n : ℕ) (hn : n ≤ 14) : a n = expected n := by
  by_cases hz : n = 0
  · subst n; simp [a, expected]
  apply period_of_certificate n (entryTime n) (expected n) hz
  · unfold expected
    split_ifs <;> omega
  · exact small_certificates n (Finset.mem_Icc.mpr ⟨by omega, hn⟩)

/-- The remaining dynamical claim. This is a definition, not a proved theorem. -/
def LargeCycles : Prop :=
  ∀ n, 14 ≤ n → ∃ T, Certificate n T 3

/-- All sequence coefficients follow from the missing large-ring cycle lemma. -/
lemma values_of_largeCycles (h : LargeCycles) (n : ℕ) : a n = expected n := by
  by_cases hn : n ≤ 14
  · exact small_values n hn
  obtain ⟨T, hT⟩ := h n (by omega)
  rw [period_of_certificate n T 3 (by omega) (by decide) hT]
  simp [expected, show n ≠ 0 by omega, show ¬n ≤ 3 by omega,
    show n ≠ 4 by omega, show n ≠ 5 by omega, show n ≠ 7 by omega,
    show n ≠ 13 by omega]

/-- The generating-function algebra depends only on the explicit coefficient list. -/
lemma expected_gf :
    (let X : PowerSeries ℤ := PowerSeries.X
     PowerSeries.mk (fun n => (expected n : ℤ)) * (1 - X) =
       X * (1 + 7*X^3 - 3*X^4 - 2*X^5 + 11*X^6 - 11*X^7 + 23*X^12 - 23*X^13)) := by
  dsimp
  rw [mul_sub, mul_one]
  have expand (X : PowerSeries ℤ) :
      X * (1 + 7*X^3 - 3*X^4 - 2*X^5 + 11*X^6 - 11*X^7 + 23*X^12 - 23*X^13) =
      X^1 + PowerSeries.C 7*X^4 - PowerSeries.C 3*X^5 - PowerSeries.C 2*X^6 +
      PowerSeries.C 11*X^7 - PowerSeries.C 11*X^8 + PowerSeries.C 23*X^13 -
      PowerSeries.C 23*X^14 := by simp only [map_ofNat]; ring
  rw [expand, ← pow_one (PowerSeries.X : PowerSeries ℤ)]
  ext n
  simp only [map_sub, map_add, PowerSeries.coeff_C_mul,
    PowerSeries.coeff_mul_X_pow', PowerSeries.coeff_mk]
  by_cases hn : n ≤ 14
  · interval_cases n <;> norm_num [expected, PowerSeries.coeff_X]
  · simp [expected, PowerSeries.coeff_X, show n ≠ 0 by omega, show ¬n ≤ 3 by omega,
      show n ≠ 4 by omega, show n ≠ 5 by omega, show n ≠ 7 by omega,
      show n ≠ 13 by omega, show n ≠ 14 by omega, show n ≠ 8 by omega,
      show n ≠ 6 by omega, show n ≠ 1 by omega, show 1 ≤ n by omega,
      show n-1 ≠ 0 by omega, show ¬n-1 ≤ 3 by omega,
      show n-1 ≠ 4 by omega, show n-1 ≠ 5 by omega,
      show n-1 ≠ 7 by omega, show n-1 ≠ 13 by omega]

/-- Exact platform target, conditional on the explicitly named unresolved claim. -/
lemma target_of_largeCycles (h : LargeCycles) : type_of% @OMA.S_oeis_a334502.main := by
  have values := values_of_largeCycles h
  constructor
  · intro n hn
    rw [values n, values (n-1)]
    simp [expected, show n ≠ 0 by omega, show ¬n ≤ 3 by omega,
      show n ≠ 4 by omega, show n ≠ 5 by omega, show n ≠ 7 by omega,
      show n ≠ 13 by omega, show n-1 ≠ 0 by omega, show ¬n-1 ≤ 3 by omega,
      show n-1 ≠ 4 by omega, show n-1 ≠ 5 by omega,
      show n-1 ≠ 7 by omega, show n-1 ≠ 13 by omega]
  · simpa only [values] using expected_gf

end A334502Local
