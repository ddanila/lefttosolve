import OMAStatements.S_oeis_a267610
import Mathlib.Tactic.Ring
import Mathlib.Tactic.IntervalCases
/-!
# A267610: Rule 182 generating function over the rationals

Source: https://oeis.org/A267610
Credit: @ddanila

This proof targets @ppleskov’s merged GF-only statement. It works directly with
the statement's Rule 182 cells. Even cropped positions are ON; the OFF indicator
at odd position 2k+1 is the parity of choose(n+1,k+1), by Pascal's recurrence.
Summing those residues directly matches the statement's count of odd Pascal
entries. The two omitted endpoints supply the linear correction. The generating
function is then proved over ℚ, without a binary-weight formula or a ring map.

Prior mathematics: Hwang, Janson and Tsai, arXiv:2210.10968, section 4.3,
Example 4.9, explicitly gives the cumulative identity. This formalizes known
mathematics; no first-discovery claim is made.
-/

namespace A267610
open OMA.S_oeis_a267610
/-- OFF cells in the finite crop of row t. -/
def offCount (t : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (2*t+1), if (cell 182) t ((i : ℤ)-t) then 0 else 1

/-- Total OFF cells through row n, including the initial row. -/
def a (n : ℕ) : ℕ := ∑ t ∈ Finset.range (n+1), offCount t

/-- Total odd Pascal entries, counted by residues modulo two. -/
def pascalTotal (n : ℕ) : ℕ := ∑ k ∈ Finset.range n,
  ∑ j ∈ Finset.range (k+1), Nat.choose k j % 2

def series : PowerSeries ℚ := PowerSeries.mk (fun n => (a n : ℚ))
def pascalSeries : PowerSeries ℚ := PowerSeries.mk (fun n => (pascalTotal n : ℚ))

/-- Cells outside the light cone remain OFF. -/
lemma outside (n : ℕ) (x : ℤ) (h : x < -(n:ℤ) ∨ (n:ℤ) < x) : (cell 182) n x = false := by
  induction n generalizing x with
  | zero => simp [cell, show x ≠ 0 by omega]
  | succ n ih =>
    simp only [cell, ih (x-1) (by omega), ih x (by omega), ih (x+1) (by omega)]
    decide

lemma even_rule : ∀ c : Bool, (ruleOut 182) true c true = true := by decide
lemma odd_rule : ∀ l r : Bool, (ruleOut 182) l true r = !(xor l r) := by decide

/-- Even cells are ON; odd cells are complements of Pascal-row parity. -/
lemma rows (n : ℕ) :
    (∀ k : ℕ, k ≤ n → (cell 182) n (2*(k:ℤ)-n) = true) ∧
    (∀ k : ℕ, k < n → (cell 182) n (2*(k:ℤ)+1-n) = decide (Nat.choose (n+1) (k+1) % 2 = 0)) := by
  induction n with
  | zero => constructor <;> intro k hk
            · have : k=0 := by omega
              subst k; rfl
            · omega
  | succ n ih =>
    constructor
    · intro k hk
      simp only [cell]
      by_cases h0 : k=0
      · subst k
        rw [show 2*((0:ℕ):ℤ)-((n+1:ℕ):ℤ)-1 = -(n:ℤ)-2 by omega,
          outside n _ (by omega), show 2*((0:ℕ):ℤ)-((n+1:ℕ):ℤ) = -(n:ℤ)-1 by omega,
          outside n _ (by omega), show -(n:ℤ)-1+1 = 2*((0:ℕ):ℤ)-n by omega,
          ih.1 0 (by omega)]
        decide
      · by_cases hn : k=n+1
        · subst k
          rw [show 2*((n+1:ℕ):ℤ)-((n+1:ℕ):ℤ)-1 = 2*(n:ℤ)-n by omega,
            ih.1 n (by omega), outside n _ (by omega), outside n _ (by omega)]
          decide
        · rw [show 2*(k:ℤ)-((n+1:ℕ):ℤ)-1 = 2*((k-1:ℕ):ℤ)-n by omega,
            ih.1 (k-1) (by omega), show 2*(k:ℤ)-((n+1:ℕ):ℤ)+1 = 2*(k:ℤ)-n by omega,
            ih.1 k (by omega), even_rule]
    · intro k hk
      simp only [cell]
      rw [show 2*(k:ℤ)+1-((n+1:ℕ):ℤ) = 2*(k:ℤ)-n by omega, ih.1 k (by omega)]
      have left : (cell 182) n (2*(k:ℤ)-n-1) = decide (Nat.choose (n+1) k % 2 = 0) := by
        cases k with
        | zero => rw [outside n _ (by omega)]; simp
        | succ k => simpa only [show 2*((k+1:ℕ):ℤ)-n-1 = 2*(k:ℤ)+1-n by omega] using ih.2 k (by omega)
      have right : (cell 182) n (2*(k:ℤ)-n+1) = decide (Nat.choose (n+1) (k+1) % 2 = 0) := by
        by_cases h : k<n
        · simpa only [show 2*(k:ℤ)-n+1 = 2*(k:ℤ)+1-n by omega] using ih.2 k h
        · have : k=n := by omega
          subst k
          rw [outside n _ (by omega)]
          simp
      rw [left, right, odd_rule]
      conv_rhs => rw [Nat.choose_succ_succ, Nat.add_mod]
      have h₁ := Nat.mod_lt (Nat.choose (n+1) k) (by decide : 0<2)
      have h₂ := Nat.mod_lt (Nat.choose (n+1) (k+1)) (by decide : 0<2)
      interval_cases Nat.choose (n+1) k % 2 <;> interval_cases Nat.choose (n+1) (k+1) % 2 <;> decide

/-- Splitting a prefix into consecutive pairs. -/
lemma sum_pairs (f : ℕ → ℕ) (m : ℕ) :
    (∑ k ∈ Finset.range (2*m), f k) = ∑ k ∈ Finset.range m, (f (2*k)+f (2*k+1)) := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [show 2*(m+1) = (2*m+1)+1 by omega, Finset.sum_range_succ,
      Finset.sum_range_succ, ih, Finset.sum_range_succ]
    omega

/-- Pair cropped positions, using the all-ON even cells. -/
lemma off_sum (n : ℕ) : offCount n =
    ∑ k ∈ Finset.range n, Nat.choose (n+1) (k+1) % 2 := by
  unfold offCount
  rw [Finset.sum_range_succ, sum_pairs]
  have he := (rows n).1 n (by omega)
  simp only [Nat.cast_mul, Nat.cast_ofNat] at *
  rw [he]
  simp only [↓reduceIte, Nat.add_zero]
  apply Finset.sum_congr rfl
  intro k hk
  have hk' : k<n := Finset.mem_range.mp hk
  have he := (rows n).1 k (by omega)
  have ho := (rows n).2 k hk'
  simp only [Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one]
  rw [he,ho]
  have h := Nat.mod_lt (Nat.choose (n+1) (k+1)) (by decide : 0<2)
  interval_cases Nat.choose (n+1) (k+1) % 2 <;> decide

/-- Row t has two fewer OFF cells than the number of odd entries in Pascal row t+1. -/
lemma row_count (n : ℕ) : offCount n + 2 = ∑ k ∈ Finset.range (n+2), Nat.choose (n+1) k % 2 := by
  rw [off_sum]
  rw [show n+2 = (n+1)+1 by omega, Finset.sum_range_succ' _ (n+1), Finset.sum_range_succ]
  simp [Nat.add_assoc]

lemma pascal_succ (n : ℕ) : pascalTotal (n+1) = pascalTotal n + ∑ k ∈ Finset.range (n+1), Nat.choose n k % 2 := by
  simp only [pascalTotal, Finset.sum_range_succ]

/-- Accumulating row counts gives the Pascal total with its linear correction. -/
lemma total_count (n : ℕ) : a n + 2*(n+1)+1 = pascalTotal (n+2) := by
  induction n with
  | zero => decide
  | succ n ih =>
    have ha : a (n+1) = a n + offCount (n+1) := by
      simp only [a, Finset.sum_range_succ]
    have hr := row_count (n+1)
    simp only [Nat.add_assoc] at hr
    rw [ha, pascal_succ (n+2)]
    simp only [Nat.add_assoc, Nat.reduceAdd] at *
    omega

/-- The linear coefficient sequence removed by the two divisions by X. -/
def linearSeries : PowerSeries ℚ := PowerSeries.mk (fun n => 2*(n:ℚ)+1)

lemma series_decomposition : pascalSeries = PowerSeries.X^2 * series + PowerSeries.X * linearSeries := by
  ext n
  simp only [map_add, pascalSeries, PowerSeries.coeff_mk, PowerSeries.coeff_X_pow_mul']
  rcases n with _ | _ | n
  · simp [linearSeries, pascalTotal]
  · simp [linearSeries, pascalTotal]
  · rw [PowerSeries.coeff_succ_X_mul]
    simp only [series, linearSeries, PowerSeries.coeff_mk]
    simp only [show 2 ≤ n+1+1 by omega, ↓reduceIte, show n+1+1-2=n by omega]
    have h := total_count n
    simp only [show n+1+1=n+2 by omega]
    push_cast
    exact_mod_cast h.symm

lemma linear_gf : linearSeries * (1-PowerSeries.X)^2 = 1+PowerSeries.X := by
  have expansion : linearSeries * (1-PowerSeries.X)^2 =
      linearSeries - PowerSeries.C 2 * (linearSeries * PowerSeries.X^1) + linearSeries * PowerSeries.X^2 := by
    simp only [map_ofNat]
    ring
  rw [expansion]
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul, PowerSeries.coeff_mul_X_pow',
    linearSeries, PowerSeries.coeff_mk]
  rcases n with _ | _ | n
  · simp
  · simp
  · (simp [PowerSeries.coeff_one, PowerSeries.coeff_X, Nat.cast_add]; ring)

lemma generating_function :
    PowerSeries.X^2 * series * (1-PowerSeries.X)^2 =
      pascalSeries * (1-PowerSeries.X)^2 - PowerSeries.X * (PowerSeries.X+1) := by
  rw [series_decomposition, add_mul, mul_assoc PowerSeries.X, linear_gf]
  ring

lemma count_eq (n : ℕ) : (2*n+1 : ℤ) - onCount 182 n = (offCount n : ℤ) := by
  have h : onCount 182 n + offCount n = 2*n+1 := by
    unfold onCount offCount
    rw [← Finset.sum_add_distrib]
    have hb : ∀ b : Bool, (if b then 1 else 0) + (if b then 0 else 1) = (1:ℕ) := by decide
    simp only [hb, Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one]
  omega

lemma a_eq (n : ℕ) : OMA.S_oeis_a267610.a n = (a n : ℤ) := by
  simp only [OMA.S_oeis_a267610.a, a, Nat.cast_sum, count_eq]

lemma pascal_eq (n : ℕ) : A006046 n = pascalTotal n := by
  unfold A006046 pascalTotal
  apply Finset.sum_congr rfl
  intro k hk
  rw [Finset.card_eq_sum_ones, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro j hj
  have h := Nat.mod_lt (k.choose j) (by decide : 0<2)
  simp only [Nat.odd_iff]
  split_ifs <;> omega

end A267610

open A267610 in
theorem OMA.solution : type_of% @OMA.S_oeis_a267610.main := by
  simpa [series, pascalSeries, a_eq, pascal_eq,
    mul_comm, mul_left_comm, mul_assoc, add_comm] using generating_function
