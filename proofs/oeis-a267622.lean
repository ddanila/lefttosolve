import OMAStatements.S_oeis_a267622
import Mathlib

/-!
# A267622: proof of the Rule 187 row conjectures

Source: https://oeis.org/A267622
Credit: @ddanila

Rule 187 turns a cell ON iff it is OFF or its right neighbour is ON. After
one step, the only OFF cell is at 0; thereafter it moves left by one per step.
The crop [-n,n] therefore has digits 1,0,1,...,1 for n >= 1. Each new row
appends two ones, giving a(n+1) = 100*a(n)+11 for n >= 1.
The moving-hole proof is adapted from our earlier A283508 implementation:
https://github.com/ddanila/lefttosolve/commit/9b86320 .
-/
namespace A267622Solution
open OMA.S_oeis_a267622

/-! ## Rule 187 evolution -/

private lemma rule187 (l c r : Bool) : rule l c r = (!c || r) := by
  cases l <;> cases c <;> cases r <;> decide

/-- A row that is ON everywhere except at position `k`. -/
private def hole (k : ℤ) : Row := fun x => decide (x ≠ k)

private lemma step187_initial : step initial = hole 0 := by
  funext x
  simp only [step, initial, rule187, hole, ne_eq, decide_not,
    Bool.or_eq_left_iff_imp, decide_eq_true_eq, Bool.not_eq_eq_eq_not, Bool.not_true,
    decide_eq_false_iff_not]
  omega

/-- The OFF cell moves one position to the left at each step. -/
private lemma step187_hole (k : ℤ) : step (hole k) = hole (k-1) := by
  funext x
  by_cases h : x = k-1
  · simp [step, rule187, hole, h]
  · have h1 : x+1 ≠ k := by omega
    simp [step, rule187, hole, h1, h]

private lemma state187_succ (n : ℕ) : state (n+1) = hole (-(n : ℤ)) := by
  induction n with
  | zero => exact step187_initial
  | succ n ih =>
    change step (state (n+1)) = hole (-↑(n+1 : ℕ))
    rw [ih, step187_hole]
    congr 1
    push_cast
    ring

/-! ## Decimal encoding and recurrence -/

/-- Decimal encoding of the first m bits of 1,0,1,1,...; zero bits encode as 0. -/
private def digits : ℕ → ℕ
  | 0 => 0
  | m+1 => 10 * digits m + bit (decide (m ≠ 1))

private lemma encode_hole (n m : ℕ) :
    encode (hole (-(n : ℤ))) (-((n+1 : ℕ) : ℤ)) m = digits m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    simp only [encode, digits, ih, hole]
    congr 2
    have h : (-((n+1 : ℕ) : ℤ) + (m : ℤ) ≠ -(n : ℤ)) ↔ m ≠ 1 := by
      push_cast
      omega
    simp only [h]

private lemma a_digits (n : ℕ) : a (n+1) = digits (2*n+3) := by
  unfold a
  rw [state187_succ, encode_hole]
  congr 1

private lemma a_zero : a 0 = 1 := by decide
private lemma a_one : a 1 = 101 := by decide
private lemma a_two : a 2 = 10111 := by decide

private lemma a_succ (n : ℕ) (hn : 0 < n) : a (n+1) = 100 * a n + 11 := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+1 := ⟨n-1, by omega⟩
  rw [a_digits (k+1), a_digits k]
  have e : 2*(k+1)+3 = (2*k+3)+1+1 := by omega
  rw [e, digits, digits]
  have digit_one (m : ℕ) (hm : m ≠ 1) : bit (decide (m ≠ 1)) = 1 := by
    simp [bit, hm]
  rw [digit_one (2*k+3) (by omega), digit_one (2*k+3+1) (by omega)]
  ring

private lemma recurrence (n : ℕ) (hn : 2 < n) :
    (a n : ℤ) = 101 * (a (n-1) : ℤ) - 100 * (a (n-2) : ℤ) := by
  have h1 := a_succ (n-1) (by omega)
  have h2 := a_succ (n-2) (by omega)
  rw [show n-1+1=n by omega] at h1
  rw [show n-2+1=n-1 by omega] at h2
  omega

/-! ## Generating function -/

private lemma coeff_series_mul_X (k n : ℕ) :
    PowerSeries.coeff n (series * PowerSeries.X^k) =
      if k ≤ n then (a (n-k) : ℤ) else 0 := by
  simp only [PowerSeries.coeff_mul_X_pow', series, PowerSeries.coeff_mk]

private lemma recurrence_coefficient (n : ℕ) :
    (a (n+3) : ℤ) - 101 * (a (n+2) : ℤ) + 100 * (a (n+1) : ℤ) = 0 := by
  have h := recurrence (n+3) (by omega)
  simp only [show n+3-1=n+2 by omega, show n+3-2=n+1 by omega] at h
  omega

private lemma generating_function :
    series * ((1 - PowerSeries.X) * (1 - 100 * PowerSeries.X)) =
      1 + 10 * PowerSeries.X^2 := by
  have expand : series * ((1 - PowerSeries.X) * (1 - 100 * PowerSeries.X)) =
      series - PowerSeries.C 101 * (series * PowerSeries.X^1) +
        PowerSeries.C 100 * (series * PowerSeries.X^2) := by
    simp only [map_ofNat, pow_one]
    ring
  rw [expand]
  change _ = 1 + PowerSeries.C 10 * PowerSeries.X^2
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul, coeff_series_mul_X]
  simp only [series, PowerSeries.coeff_mk]
  rcases n with _ | _ | _ | n
  · simp [a_zero]
  · simp [a_one, a_zero]
  · simp [a_two, a_one, a_zero]
  · simpa [PowerSeries.coeff_one, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      using recurrence_coefficient n

end A267622Solution

theorem OMA.solution : type_of% @OMA.S_oeis_a267622.main :=
  ⟨A267622Solution.recurrence, A267622Solution.generating_function⟩
