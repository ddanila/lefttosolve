import OMAStatements.S_oeis_a334502
import Mathlib.Dynamics.PeriodicPts.Defs
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# A334502: Eventual period of the Rule 62 cellular automaton on a ring
Credit: @ddanila

Split the unbounded-width dynamics into four width classes. Each hypothesis asks
for an eventual three-cycle and one differing successor, directly in the platform's
row definition. The exceptional widths and generating function are handled here.
-/
namespace OMA.R_oeis_a334502_R1
open OMA.S_oeis_a334502 Function

def H1 : Prop := ∀ n : ℕ, 14 ≤ n → n % 4 = 0 →
  ∃ T, row n (T+3) = row n T ∧ row n (T+1) ≠ row n T

def H2 : Prop := ∀ n : ℕ, 14 ≤ n → n % 4 = 1 →
  ∃ T, row n (T+3) = row n T ∧ row n (T+1) ≠ row n T

def H3 : Prop := ∀ n : ℕ, 14 ≤ n → n % 4 = 2 →
  ∃ T, row n (T+3) = row n T ∧ row n (T+1) ≠ row n T

def H4 : Prop := ∀ n : ℕ, 14 ≤ n → n % 4 = 3 →
  ∃ T, row n (T+3) = row n T ∧ row n (T+1) ≠ row n T

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

/-- A return in two steps on a three-cycle would make its successor equal. -/
lemma period_three (n T : ℕ) (hn : n≠0) (cycle : row n (T+3)=row n T)
    (different : row n (T+1)≠row n T) : a n=3 := by
  apply period_eq n T 3 hn (by decide) cycle
  intro p hp hlt
  have hh : p=1 ∨ p=2 := by omega
  rcases hh with rfl | rfl
  · exact different
  · intro he
    have hs (t : ℕ) : row n (t+1)=step (row n t) := Function.iterate_succ_apply' _ _ _
    have h := congrArg (@step n) he
    rw [←hs, ←hs, show T+2+1=T+3 by omega, cycle] at h
    exact different h.symm

set_option maxRecDepth 10000 in
set_option maxHeartbeats 4000000 in
theorem main : H1 → H2 → H3 → H4 → type_of% @OMA.S_oeis_a334502.main := by
  intro h1 h2 h3 h4
  let expected (n : ℕ) : ℕ := if n = 0 then 0 else if n ≤ 3 then 1 else if n = 4 then 8 else
    if n = 5 then 5 else if n = 7 then 14 else if n = 13 then 26 else 3
  let entryTime (n : ℕ) : ℕ := [0, 1, 2, 2, 1, 1, 3, 6, 3, 12, 3, 3, 21, 24, 7][n]?.getD 0
  have small : ∀ n ∈ Finset.Icc 1 14,
      row n (entryTime n+expected n)=row n (entryTime n) ∧
      ∀ p ∈ Finset.Ioo 0 (expected n), row n (entryTime n+p)≠row n (entryTime n) := by
    decide +kernel
  have values (n : ℕ) : a n=expected n := by
    by_cases hz : n=0
    · subst n; simp [a, expected]
    by_cases hn : n≤14
    · apply period_eq n (entryTime n) (expected n) hz
      · dsimp only [expected]; split_ifs <;> omega
      · exact (small n (Finset.mem_Icc.mpr ⟨by omega, hn⟩)).1
      · intro p hp hlt
        exact (small n (Finset.mem_Icc.mpr ⟨by omega, hn⟩)).2 p (Finset.mem_Ioo.mpr ⟨hp,hlt⟩)
    · have hc : ∃ T, row n (T+3)=row n T ∧ row n (T+1)≠row n T := by
        have hm : n%4=0 ∨ n%4=1 ∨ n%4=2 ∨ n%4=3 := by omega
        rcases hm with hm | hm | hm | hm
        · exact h1 n (by omega) hm
        · exact h2 n (by omega) hm
        · exact h3 n (by omega) hm
        · exact h4 n (by omega) hm
      obtain ⟨T, hc, hd⟩ := hc
      rw [period_three n T hz hc hd]
      simp [expected, hz, show ¬n≤3 by omega, show n≠4 by omega,
        show n≠5 by omega, show n≠7 by omega, show n≠13 by omega]
  constructor
  · intro n hn
    rw [values n, values (n-1)]
    simp [expected, show n ≠ 0 by omega, show ¬n ≤ 3 by omega,
      show n ≠ 4 by omega, show n ≠ 5 by omega, show n ≠ 7 by omega,
      show n ≠ 13 by omega, show n-1 ≠ 0 by omega, show ¬n-1 ≤ 3 by omega,
      show n-1 ≠ 4 by omega, show n-1 ≠ 5 by omega,
      show n-1 ≠ 7 by omega, show n-1 ≠ 13 by omega]
  · simp only [values]
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

end OMA.R_oeis_a334502_R1
