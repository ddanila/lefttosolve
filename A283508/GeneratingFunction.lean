import A283508.Proof
import Mathlib

namespace A283508

theorem a_zero : a 0 = 1 := by decide
theorem a_one : a 1 = 10 := by decide
theorem a_two : a 2 = 101 := by decide

theorem recurrence_int (n : ℕ) (hn : 2 < n) :
    (a n : ℤ) = 11 * (a (n-1) : ℤ) - 10 * (a (n-2) : ℤ) := by
  have h1 := a_succ (n-1) (by omega)
  have h2 := a_succ (n-2) (by omega)
  have e1 : n-1+1 = n := by omega
  have e2 : n-2+1 = n-1 := by omega
  rw [e1] at h1
  rw [e2] at h2
  have c1 := congrArg (fun k : ℕ => (k : ℤ)) h1
  have c2 := congrArg (fun k : ℕ => (k : ℤ)) h2
  push_cast at c1 c2
  omega

def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))

theorem generating_function :
    series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
      1 - PowerSeries.X + PowerSeries.X^2 := by
  have expand : series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
      series - PowerSeries.C 11 * (series * PowerSeries.X^1) +
        PowerSeries.C 10 * (series * PowerSeries.X^2) := by
    simp only [map_ofNat, pow_one]
    ring
  rw [expand]
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul,
    PowerSeries.coeff_mul_X_pow', series, PowerSeries.coeff_mk]
  rcases n with _ | _ | _ | n
  · simp [a_zero]
  · simp [a_one, a_zero]
  · simp [a_two, a_one, a_zero, PowerSeries.coeff_X]
  · have h := recurrence_int (n+3) (by omega)
    simp only [show 1 ≤ n+3 by omega, show 2 ≤ n+3 by omega, if_true,
      PowerSeries.coeff_one, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
    simp
    simpa using (show (a (n+3) : ℤ) - 11*(a (n+2) : ℤ) + 10*(a (n+1) : ℤ) = 0 by
      simp only [show n+3-1=n+2 by omega, show n+3-2=n+1 by omega] at h
      omega)

end A283508
