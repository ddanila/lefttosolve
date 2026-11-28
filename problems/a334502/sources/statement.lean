import Mathlib.RingTheory.PowerSeries.Basic
import Mathlib.Order.Lattice.Nat
import Mathlib.Logic.Function.Iterate

/-!
# Eventual period of elementary cellular automaton rule 62

Starting with one occupied site on a labeled ring of positive width, A334502
counts the steps in the eventual cycle of whole configurations. Colin Barker
conjectured the recurrence and ordinary generating function in May 2020.
Source: https://oeis.org/A334502
-/

namespace OMA.S_oeis_a334502

/-- Each bit is updated simultaneously from its left neighbor, itself and its
right neighbor. The rotations implement the periodic boundary condition. -/
def step {n : ℕ} (w : BitVec n) : BitVec n :=
  let left := w.rotateLeft 1
  let right := w.rotateRight 1
  (~~~left &&& (w ||| right)) ||| (left &&& ~~~w)

/-- Bit zero is the single occupied site in the initial configuration. -/
def row (n t : ℕ) : BitVec n := step^[t] (1 : BitVec n)

/-- Least positive return time of a recurrent configuration on the orbit.
At width zero use a zero coefficient for the series with offset one. -/
noncomputable def a (n : ℕ) : ℕ :=
  if n = 0 then 0 else sInf {p : ℕ | 0 < p ∧ ∃ t : ℕ, row n (t + p) = row n t}

/-- Barker's recurrence and generating function, with the denominator cleared. -/
theorem main :
    (∀ n : ℕ, 14 < n → a n = a (n - 1)) ∧
    (let X : PowerSeries ℤ := PowerSeries.X
     PowerSeries.mk (fun n => (a n : ℤ)) * (1 - X) =
       X * (1 + 7*X^3 - 3*X^4 - 2*X^5 + 11*X^6 - 11*X^7 + 23*X^12 - 23*X^13)) := by
  sorry

end OMA.S_oeis_a334502
