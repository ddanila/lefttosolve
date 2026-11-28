import Mathlib.RingTheory.PowerSeries.Basic
import Mathlib.Order.Lattice.Nat
import Mathlib.Logic.Function.Iterate

/-!
# Eventual period of elementary cellular automaton rule 131

Starting with one occupied site on a labeled ring of positive width, A334503
counts the steps in the eventual cycle of whole configurations. Colin Barker
conjectured the recurrence and ordinary generating function in May 2020.
Source: https://oeis.org/A334503
-/

namespace OMA.S_oeis_a334503

/-- Each bit is updated simultaneously from its left neighbor, itself and its
right neighbor. The rotations implement the periodic boundary condition. -/
def step {n : ℕ} (w : BitVec n) : BitVec n :=
  let left := w.rotateLeft 1
  let right := w.rotateRight 1
  (~~~left &&& ~~~w) ||| (left &&& w &&& right)

/-- Bit zero is the single occupied site in the initial configuration. -/
def row (n t : ℕ) : BitVec n := step^[t] (1 : BitVec n)

/-- Least positive return time of a recurrent configuration on the orbit.
At width zero use a zero coefficient for the series with offset one. -/
noncomputable def a (n : ℕ) : ℕ :=
  if n = 0 then 0 else sInf {p : ℕ | 0 < p ∧ ∃ t : ℕ, row n (t + p) = row n t}

/-- Barker's recurrence and generating function, with the denominator cleared. -/
theorem main :
    (∀ n : ℕ, 17 < n → a n = a (n - 1)) ∧
    (let X : PowerSeries ℤ := PowerSeries.X
     PowerSeries.mk (fun n => (a n : ℤ)) * (1 - X) =
       X * (1 + 2*X^2 + 5*X^3 - 5*X^4 + 11*X^6 + 2*X^7 - 13*X^8 + 17*X^9 - 17*X^10 + 29*X^15 - 29*X^16)) := by
  sorry

end OMA.S_oeis_a334503
