import OMAStatements.S_oeis_a334502
import Mathlib.Dynamics.PeriodicPts.Defs
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Local reductions for A334502
Credit: @ddanila

Historical development lemmas. The complete proof now lives in the R1 reduction
and its four step files; this earlier conditional reduction is retained for reference.
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

namespace A334502Local
open OMA.S_oeis_a334502

/-- Boolean local rule, independent of the bit-vector representation. -/
def localRule (l c r : Bool) : Bool := (!l && (c || r)) || (l && !c)

def prev (n i : ℕ) : ℕ := if i = 0 then n-1 else i-1
def next (n i : ℕ) : ℕ := if i+1 = n then 0 else i+1

/-- Rotations implement the two neighbours on the labelled ring. -/
lemma step_bit {n : ℕ} (hn : 1 < n) (w : BitVec n) (i : ℕ) (hi : i < n) :
    (step w).getLsbD i =
      localRule (w.getLsbD (prev n i)) (w.getLsbD i) (w.getLsbD (next n i)) := by
  simp only [step, localRule, BitVec.getLsbD_or, BitVec.getLsbD_and,
    BitVec.getLsbD_not, BitVec.getLsbD_rotateLeft_of_le hn,
    BitVec.getLsbD_rotateRight_of_lt hn, hi, decide_true, Bool.true_and]
  by_cases h0 : i = 0
  · subst i
    simp [prev, next, show 1 ≠ n by omega, show 0 < n-1 by omega]
  · by_cases he : i+1 = n
    · have h : i = n-1 := by omega
      simp [prev, next, h, show ¬n-1 < 1 by omega,
        show n-1 ≠ 0 by omega, show n-1+1 = n by omega]
    · simp [prev, next, h0, he, show ¬i < 1 by omega,
        show i < n-1 by omega, Nat.add_comm]

lemma row_succ (n t : ℕ) : row n (t+1) = step (row n t) := by
  exact Function.iterate_succ_apply' _ _ _

lemma prev_lt {n i : ℕ} (hn : 0 < n) (hi : i < n) : prev n i < n := by
  unfold prev; split <;> omega

lemma next_lt {n i : ℕ} (hn : 0 < n) (hi : i < n) : next n i < n := by
  unfold next; split <;> omega

end A334502Local

namespace A334502Local
open OMA.S_oeis_a334502

lemma localRule_true (l c r : Bool) :
    localRule l c r = true ↔ (¬l=true ∧ (c=true ∨ r=true)) ∨ (l=true ∧ ¬c=true) := by
  cases l <;> cases c <;> cases r <;> decide

/-- A cellwise recurrence and the seed characterize every row on the ring. -/
lemma row_model (n : ℕ) (hn : 1 < n) (C : ℕ → ℕ → Prop)
    (initial : ∀ i, i<n → (C 0 i ↔ i=0))
    (update : ∀ t i, i<n → (C (t+1) i ↔
      (¬ C t (prev n i) ∧ (C t i ∨ C t (next n i))) ∨
      (C t (prev n i) ∧ ¬ C t i))) :
    ∀ t i, i<n → ((row n t).getLsbD i=true ↔ C t i) := by
  intro t
  induction t with
  | zero =>
    intro i hi
    change (1#n).getLsbD i=true ↔ C 0 i
    simpa only [BitVec.getLsbD_one,
      show 0<n from by omega, decide_true, Bool.true_and, decide_eq_true_eq] using
      (initial i hi).symm
  | succ t ih =>
    intro i hi
    rw [row_succ, step_bit hn _ i hi, localRule_true,
      ih (prev n i) (prev_lt (by omega) hi), ih i hi,
      ih (next n i) (next_lt (by omega) hi)]
    exact (update t i hi).symm

/-- On a three-cycle, excluding a fixed point also excludes a two-step return. -/
lemma certificate_three (n T : ℕ) (cycle : row n (T+3)=row n T)
    (different : row n (T+1)≠row n T) : Certificate n T 3 := by
  refine ⟨cycle, ?_⟩
  intro p hp
  have h := Finset.mem_Ioo.mp hp
  have : p=1 ∨ p=2 := by omega
  rcases this with rfl | rfl
  · exact different
  · intro he
    have hh := congrArg (@step n) he
    rw [←row_succ, ←row_succ] at hh
    have eq : T+2+1=T+3 := by omega
    rw [eq, cycle] at hh
    exact different hh.symm

lemma certificate_of_model (n T : ℕ) (hn : 2<n) (C : ℕ → ℕ → Prop)
    (bridge : ∀ t i, i<n → ((row n t).getLsbD i=true ↔ C t i))
    (cycle : ∀ i, i<n → (C (T+3) i ↔ C T i))
    (different : ¬ (C (T+1) 2 ↔ C T 2)) : Certificate n T 3 := by
  apply certificate_three
  · apply BitVec.eq_of_getLsbD_eq
    intro i hi
    apply Bool.eq_iff_iff.mpr
    exact (bridge (T+3) i hi).trans ((cycle i hi).trans (bridge T i hi).symm)
  · intro he
    apply different
    rw [← bridge (T+1) 2 hn, ← bridge T 2 hn, he]
end A334502Local
