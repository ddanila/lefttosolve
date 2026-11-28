import OMAStatements.S_oeis_a267610
import Mathlib.Data.Nat.Choose.Lucas
import Mathlib.Tactic.Ring
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.Positivity
/-!
# A267610: Rule 182, Pascal parity, and the corrected sequence relation

Source: https://oeis.org/A267610
Credit: @ddanila

The printed unshifted A267700 relation fails at n=2. This proof addresses the
explicitly corrected statement, retaining the generating function unchanged.

Even positions in each cropped row are ON. The OFF indicator at odd position
2k+1 is the parity of choose(n+1,k+1). Pascal's recurrence proves this directly
from Rule 182. Lucas's theorem then counts the odd binomial coefficients as
2 raised to the binary weight. Removing the two endpoints yields the row count.
Summing rows proves the corrected relation and the same power-series identity.
No automaton table or native evaluation is needed.

Prior mathematics: Hwang, Janson and Tsai, arXiv:2210.10968, section 4,
discuss this sequence. No first-discovery claim is made.
-/

namespace A267610Positive
open OMA.S_oeis_a267610

/-- Cells outside the light cone remain OFF. -/
lemma outside (n : ℕ) (x : ℤ) (h : x < -(n:ℤ) ∨ (n:ℤ) < x) : state n x = false := by
  induction n generalizing x with
  | zero => simp [state, show x ≠ 0 by omega]
  | succ n ih =>
    simp only [state, ih (x-1) (by omega), ih x (by omega), ih (x+1) (by omega)]
    decide

lemma even_rule : ∀ c : Bool, rule true c true = true := by decide
lemma odd_rule : ∀ l r : Bool, rule l true r = !(xor l r) := by decide

/-- Even cells are ON; odd cells are complements of Pascal-row parity. -/
lemma rows (n : ℕ) :
    (∀ k : ℕ, k ≤ n → state n (2*(k:ℤ)-n) = true) ∧
    (∀ k : ℕ, k < n → state n (2*(k:ℤ)+1-n) = decide (Nat.choose (n+1) (k+1) % 2 = 0)) := by
  induction n with
  | zero => constructor <;> intro k hk
            · have : k=0 := by omega
              subst k; rfl
            · omega
  | succ n ih =>
    constructor
    · intro k hk
      rw [state]
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
      rw [state, show 2*(k:ℤ)+1-((n+1:ℕ):ℤ) = 2*(k:ℤ)-n by omega, ih.1 k (by omega)]
      have left : state n (2*(k:ℤ)-n-1) = decide (Nat.choose (n+1) k % 2 = 0) := by
        cases k with
        | zero => rw [outside n _ (by omega)]; simp
        | succ k => simpa only [show 2*((k+1:ℕ):ℤ)-n-1 = 2*(k:ℤ)+1-n by omega] using ih.2 k (by omega)
      have right : state n (2*(k:ℤ)-n+1) = decide (Nat.choose (n+1) (k+1) % 2 = 0) := by
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

/-- Lucas modulo 2 reduces each adjacent pair to one entry of a smaller row. -/
lemma choose_pair (n k : ℕ) :
    Nat.choose n (2*k) % 2 + Nat.choose n (2*k+1) % 2 =
      (n%2+1) * (Nat.choose (n/2) k % 2) := by
  have h₀ := Choose.choose_modEq_choose_mod_mul_choose_div_nat (n:=n) (k:=2*k) (p:=2)
  have h₁ := Choose.choose_modEq_choose_mod_mul_choose_div_nat (n:=n) (k:=2*k+1) (p:=2)
  change _ % 2 = _ % 2 at h₀ h₁
  have hn := Nat.mod_lt n (by decide : 0<2)
  interval_cases n%2 <;> simp_all [Nat.add_div, Nat.add_mod]
  omega

/-- The number of odd binomial coefficients is 2 to the binary weight. -/
lemma odd_count (n : ℕ) :
    (∑ k ∈ Finset.range (n+1), Nat.choose n k % 2) = 2^weight n := by
  induction n using Nat.strong_induction_on with
  | h n ih =>
    by_cases hn : n=0
    · subst n; simp [weight, Nat.digits_zero]
    have hp : 0<n := by omega
    have hd := ih (n/2) (Nat.div_lt_self hp (by decide))
    have pair := sum_pairs (fun k => Nat.choose n k % 2) (n/2+1)
    have hsum : (∑ k ∈ Finset.range (2*(n/2+1)), Nat.choose n k % 2) =
        (n%2+1)*2^weight (n/2) := by
      rw [pair]
      simp only [choose_pair, ← Finset.mul_sum, hd]
    have hw : weight n = n%2 + weight (n/2) := by
      simp only [weight, Nat.digits_def' (by decide : 1<2) hp, List.sum_cons]
    have hm := Nat.mod_lt n (by decide : 0<2)
    rcases (by omega : n%2=0 ∨ n%2=1) with he | ho
    · rw [show 2*(n/2+1)=(n+1)+1 by omega, Finset.sum_range_succ,
        Nat.choose_eq_zero_of_lt (by omega), Nat.zero_mod, Nat.add_zero, he] at hsum
      simpa only [hw, he, zero_add, zero_add, one_mul] using hsum
    · rw [show 2*(n/2+1)=n+1 by omega, ho] at hsum
      rw [hw, ho, pow_add]
      simpa using hsum


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
lemma row_count (n : ℕ) : offCount n + 2 = 2^weight (n+1) := by
  rw [off_sum]
  have h := odd_count (n+1)
  rw [Finset.sum_range_succ' _ (n+1), Finset.sum_range_succ] at h
  simpa only [Nat.choose_self, Nat.choose_zero_right, Nat.one_mod, Nat.add_assoc] using h



lemma pascal_succ (n : ℕ) : pascalTotal (n+1) = pascalTotal n + 2^weight n := by
  simp only [pascalTotal, Finset.sum_range_succ]

/-- Accumulating row counts gives the Pascal total with its linear correction. -/
lemma total_count (n : ℕ) : a n + 2*(n+1)+1 = pascalTotal (n+2) := by
  induction n with
  | zero => decide
  | succ n ih =>
    have ha : a (n+1) = a n + offCount (n+1) := by
      simp only [a, Finset.sum_range_succ]
    have hr := row_count (n+1)
    simp only [show n+1+1=n+2 by omega] at hr
    rw [ha, pascal_succ (n+2)]
    omega

/-- The reference tree sequence uses the same powers with one removed per term. -/
lemma tree_count (n : ℕ) : tree n + (n+1) = pascalTotal (n+1) := by
  induction n with
  | zero => decide
  | succ n ih =>
    have ht : tree (n+1) = tree n + (2^weight (n+1)-1) := by
      simp only [tree, Finset.sum_range_succ]
    have hp : 0 < 2^weight (n+1) := by positivity
    rw [ht, pascal_succ (n+1)]
    omega

lemma corrected (n : ℕ) : (a n : ℤ) = (tree (n+1) : ℤ) - (n+1) := by
  have ht := tree_count (n+1)
  simp only [show n+1+1=n+2 by omega] at ht
  have ha := total_count n
  omega

/-- The linear coefficient sequence removed by the two divisions by X. -/
def linearSeries : PowerSeries ℤ := PowerSeries.mk (fun n => 2*(n:ℤ)+1)

lemma series_decomposition : pascalSeries = PowerSeries.X^2 * series + PowerSeries.X * linearSeries := by
  ext n
  simp only [map_add, pascalSeries, PowerSeries.coeff_mk, PowerSeries.coeff_X_pow_mul']
  rcases n with _ | _ | n
  · simp [linearSeries, pascalTotal]
  · simp [linearSeries, pascalTotal, weight]
  · rw [PowerSeries.coeff_succ_X_mul]
    simp only [series, linearSeries, PowerSeries.coeff_mk]
    simp only [show 2 ≤ n+1+1 by omega, ↓reduceIte, show n+1+1-2=n by omega]
    have h := total_count n
    simp only [show n+1+1=n+2 by omega]
    push_cast
    omega

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
  · simp [PowerSeries.coeff_one, PowerSeries.coeff_X, Nat.cast_add]
    ring

lemma generating_function :
    PowerSeries.X^2 * series * (1-PowerSeries.X)^2 =
      pascalSeries * (1-PowerSeries.X)^2 - PowerSeries.X * (PowerSeries.X+1) := by
  rw [series_decomposition, add_mul, mul_assoc PowerSeries.X, linear_gf]
  ring

end A267610Positive

/-- The corrected sequence relation and unchanged generating function. -/
theorem OMA.solution : type_of% @OMA.S_oeis_a267610.main :=
  ⟨A267610Positive.corrected, A267610Positive.generating_function⟩
