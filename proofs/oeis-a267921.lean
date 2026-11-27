import OMAStatements.S_oeis_a267921

/-!
# A267921: proof of the Rule 243 row conjectures

Source: https://oeis.org/A267921
Credit: @ddanila

## Outline

Rule 243 is !centre || left. The first step leaves a single OFF cell at 0;
subsequent steps move that hole right. At time n+1, the hole is at n, so the
crop [-(n+1),n+1] consists of 2n+1 ones followed by 0,1.

Encoding in base 2 gives a(n+1)=4*ones(2n+1)+1. Adding two leading ones
therefore gives a(n+1)=4*a(n)+9 for n>=1. Adjacent instances yield
the requested recurrence. Coefficient shifts and the initial three terms then
prove the generating-function product identity.

The automaton argument mirrors our A267622 proof; A267920 and A267921 use
identical dynamics with different encoding bases. Each proof is self-contained.
-/
namespace A267921Solution
open OMA.S_oeis_a267921

/-! ## Rule 243 evolution -/

private lemma rule243 (l c r : Bool) : rule l c r = (!c || l) := by
  cases l <;> cases c <;> cases r <;> decide

/-- A row that is ON everywhere except at position `k`. -/
private def hole (k : ℤ) : Row := fun x => decide (x ≠ k)

private lemma step243_initial : step initial = hole 0 := by
  funext x
  simp only [step, initial, rule243, hole, ne_eq, decide_not,
    Bool.or_eq_left_iff_imp, decide_eq_true_eq, Bool.not_eq_eq_eq_not, Bool.not_true,
    decide_eq_false_iff_not]
  omega

/-- The OFF cell moves one position to the right at each step. -/
private lemma step243_hole (k : ℤ) : step (hole k) = hole (k+1) := by
  funext x
  by_cases h : x = k+1
  · simp [step, rule243, hole, h]
  · have h1 : x-1 ≠ k := by omega
    simp [step, rule243, hole, h1, h]

private lemma state243_succ (n : ℕ) : state (n+1) = hole (n : ℤ) := by
  induction n with
  | zero => exact step243_initial
  | succ n ih =>
    change step (state (n+1)) = hole (↑(n+1 : ℕ))
    rw [ih, step243_hole]
    congr 1

/-! ## Row encoding and recurrence -/

/-- Encoding of m consecutive ON cells in base 2. -/
private def ones : ℕ → ℕ
  | 0 => 0
  | m+1 => 2 * ones m + 1

/-- The prefix before the hole consists entirely of ON cells. -/
private lemma encode_prefix (n m : ℕ) (hm : m ≤ 2*n+1) :
    encode (hole (n : ℤ)) (-((n+1 : ℕ) : ℤ)) m = ones m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [encode, ih (by omega), ones]
    have h : -((n+1 : ℕ) : ℤ) + (m : ℤ) ≠ (n : ℤ) := by
      push_cast
      omega
    simp only [hole, ne_eq, h, not_false_eq_true, decide_true]
    rfl

/-- The full crop is an all-ON prefix followed by the bits 0,1. -/
private lemma a_ones (n : ℕ) : a (n+1) = 4 * ones (2*n+1) + 1 := by
  unfold a
  rw [state243_succ]
  have length_eq : 2*(n+1)+1 = (2*n+1)+1+1 := by omega
  rw [length_eq, encode, encode, encode_prefix n (2*n+1) (by omega)]
  have hzero : bit (hole (n : ℤ) (-((n+1 : ℕ) : ℤ) + ((2*n+1 : ℕ) : ℤ))) = 0 := by
    have h : -((n+1 : ℕ) : ℤ) + ((2*n+1 : ℕ) : ℤ) = n := by push_cast; ring
    simp only [hole, ne_eq, h, not_true_eq_false, decide_false, eq_self]
    rfl
  have hone : bit (hole (n : ℤ) (-((n+1 : ℕ) : ℤ) + ((2*n+1+1 : ℕ) : ℤ))) = 1 := by
    have h : -((n+1 : ℕ) : ℤ) + ((2*n+1+1 : ℕ) : ℤ) ≠ n := by push_cast; omega
    simp only [hole, ne_eq, h, not_false_eq_true, decide_true]
    rfl
  rw [hzero, hone]
  ring

private lemma a_zero : a 0 = 1 := by decide
private lemma a_one : a 1 = 5 := by decide
private lemma a_two : a 2 = 29 := by decide

private lemma a_succ (n : ℕ) (hn : 0 < n) : a (n+1) = 4 * a n + 9 := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+1 := ⟨n-1, by omega⟩
  rw [a_ones (k+1), a_ones k]
  have h : 2*(k+1)+1 = (2*k+1)+1+1 := by omega
  rw [h, ones, ones]
  ring

private lemma recurrence (n : ℕ) (hn : 2 < n) :
    (a n : ℤ) = 5 * (a (n-1) : ℤ) - 4 * (a (n-2) : ℤ) := by
  have h1 := a_succ (n-1) (by omega)
  have h2 := a_succ (n-2) (by omega)
  rw [show n-1+1=n by omega] at h1
  rw [show n-2+1=n-1 by omega] at h2
  omega

/-! ## Generating function -/

/-- Multiplication by X^k shifts coefficients by k, filling earlier positions with zero. -/
private lemma coeff_series_mul_X (k n : ℕ) :
    PowerSeries.coeff n (series * PowerSeries.X^k) =
      if k ≤ n then (a (n-k) : ℤ) else 0 := by
  simp only [PowerSeries.coeff_mul_X_pow', series, PowerSeries.coeff_mk]

private lemma recurrence_coefficient (n : ℕ) :
    (a (n+3) : ℤ) - 5 * (a (n+2) : ℤ) + 4 * (a (n+1) : ℤ) = 0 := by
  have h := recurrence (n+3) (by omega)
  simp only [show n+3-1=n+2 by omega, show n+3-2=n+1 by omega] at h
  omega

private lemma generating_function :
    series * ((1 - PowerSeries.X) * (1 - 4 * PowerSeries.X)) =
      1 + 8 * PowerSeries.X^2 := by
  have expand : series * ((1 - PowerSeries.X) * (1 - 4 * PowerSeries.X)) =
      series - PowerSeries.C 5 * (series * PowerSeries.X^1) +
        PowerSeries.C 4 * (series * PowerSeries.X^2) := by
    simp only [map_ofNat, pow_one]
    ring
  rw [expand]
  change _ = 1 + PowerSeries.C 8 * PowerSeries.X^2
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul, coeff_series_mul_X]
  simp only [series, PowerSeries.coeff_mk]
  rcases n with _ | _ | _ | n
  · simp [a_zero]
  · simp [a_one, a_zero]
  · simp [a_two, a_one, a_zero]
  · simpa [PowerSeries.coeff_one, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      using recurrence_coefficient n

end A267921Solution

theorem OMA.solution : type_of% @OMA.S_oeis_a267921.main :=
  ⟨A267921Solution.recurrence, A267921Solution.generating_function⟩
