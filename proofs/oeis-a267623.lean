import OMAStatements.S_oeis_a267623

/-!
# A267623: proof of the Rule 187 middle-column conjectures

Source: https://oeis.org/A267623
Credit: @ddanila

## Outline

Rule 187 turns a cell ON iff it is OFF or its right neighbour is ON.
Starting from the single ON origin, the first row is ON everywhere except at 0.
Each subsequent step moves that one OFF cell left by one position, so at time
n+1 the hole is at -n (`state187_succ`).

The centre column is therefore 1,0,1,1,... . Appending one centre digit gives
a(n+1)=10*a(n)+1 for n>=1. Subtract adjacent identities for the recurrence.
Multiplying the series by (1-X)*(1-10*X) shifts its coefficients: degrees
0,1,2 give 1,-1,1; higher coefficients vanish by the recurrence.

The moving-hole lemmas and coefficient argument adapt our A267622 proof,
which in turn adapts our A283508 work (public commit 9b86320).
-/
namespace A267623Solution
open OMA.S_oeis_a267623

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

/-! ## Centre column and recurrence -/

/-- From time 2 onward the moving hole is strictly left of the centre. -/
private lemma centre_on (n : ℕ) (hn : 1 < n) : state n 0 = true := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+1 := ⟨n-1, by omega⟩
  rw [state187_succ]
  simp [hole, show k ≠ 0 by omega]

private lemma a_zero : a 0 = 1 := by decide
private lemma a_one : a 1 = 10 := by decide
private lemma a_two : a 2 = 101 := by decide

private lemma a_succ (n : ℕ) (hn : 0 < n) : a (n+1) = 10 * a n + 1 := by
  change 10 * column (n+1) + bit (state (n+1) 0) = _
  rw [centre_on (n+1) (by omega)]
  rfl

private lemma recurrence (n : ℕ) (hn : 2 < n) :
    (a n : ℤ) = 11 * (a (n-1) : ℤ) - 10 * (a (n-2) : ℤ) := by
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
    (a (n+3) : ℤ) - 11 * (a (n+2) : ℤ) + 10 * (a (n+1) : ℤ) = 0 := by
  have h := recurrence (n+3) (by omega)
  simp only [show n+3-1=n+2 by omega, show n+3-2=n+1 by omega] at h
  omega

private lemma generating_function :
    series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
      1 - PowerSeries.X + PowerSeries.X^2 := by
  have expand : series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
      series - PowerSeries.C 11 * (series * PowerSeries.X^1) +
        PowerSeries.C 10 * (series * PowerSeries.X^2) := by
    simp only [map_ofNat, pow_one]
    ring
  rw [expand]
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul, coeff_series_mul_X]
  simp only [series, PowerSeries.coeff_mk]
  rcases n with _ | _ | _ | n
  · simp [a_zero]
  · simp [a_one, a_zero]
  · simp [a_two, a_one, a_zero, PowerSeries.coeff_X]
  · simpa [PowerSeries.coeff_one, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      using recurrence_coefficient n

end A267623Solution

theorem OMA.solution : type_of% @OMA.S_oeis_a267623.main :=
  ⟨A267623Solution.recurrence, A267623Solution.generating_function⟩
