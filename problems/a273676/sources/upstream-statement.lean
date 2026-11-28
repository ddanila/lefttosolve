import Mathlib

/-!
# OEIS A273676: Blomberg's, Mathar's, and Barker's conjectures for the two-dimensional Rule 833 at stages 2^n - 1

Source: https://oeis.org/A273676
Credit: @yooeonwoo

Entry A273676 (offset 0): Number of active (ON, black) cells at stage 2^n - 1 of the
two-dimensional cellular automaton defined by Rule 833, based on the 5-celled von Neumann
neighborhood, initialized with a single black (ON) cell at stage zero.

Conjectures listed in the entry (all stated below as one conjunction):
* Rule 849 also generates this sequence (Lars Blomberg, Jul 23 2016).
* a(n) = A270222(n) for n > 1, where A270222 is the analogous count for Rule 131
  (R. J. Mathar, May 30 2016).
* a(n) = 3 * 4^n - 4 * 2^n + 1 for n > 1 (Lars Blomberg, Jul 23 2016).
* a(n) = 7 * a(n - 1) - 14 * a(n - 2) + 8 * a(n - 3) for n > 4 (Colin Barker, Dec 01 2016).
* G.f.: (1 - 3*x + 19*x^2 - 22*x^3 + 8*x^4) / ((1 - x)*(1 - 2*x)*(1 - 4*x))
  (Colin Barker, Dec 01 2016).

Formalization notes:
* Rule numbering follows Wolfram's outer-totalistic code for the 5-cell von Neumann neighborhood,
  matching the entry's Mathematica program (CAStep with kernel {{0,2,0},{2,1,2},{0,2,0}}): the new
  state of a cell is bit c + 2*s of the rule number, where c is its own state (1 for ON) and s is
  the number of ON cells among its four orthogonal neighbors.
* At stage 0 the origin (0, 0) is ON and every other cell of Z^2 is OFF; each step updates every
  cell of Z^2 synchronously.
* Matching the entry's Mathematica program (which trims stage t to its central (2t+1) x (2t+1)
  square and counts ON cells there), count rule t is the number of ON cells of stage t in
  [-t, t]^2, and a(n) = count 833 (2^n - 1), giving 1, 4, 33, 161, 705, 2945, ...
* The generating function identity A(x) = N(x) / D(x) is stated as A(x) * D(x) = N(x) in the formal
  power series ring over Z.
-/

namespace OMA.S_oeis_a273676

open PowerSeries

/-- Stage `t` of the two-dimensional outer-totalistic 5-cell von Neumann cellular automaton with
Wolfram code `rule`, initialized with a single ON cell at `(0, 0)`. -/
def state (rule : ℕ) : ℕ → ℤ → ℤ → Bool
  | 0, x, y => decide (x = 0 ∧ y = 0)
  | t + 1, x, y =>
    Nat.testBit rule
      ((state rule t x y).toNat +
        2 * ((state rule t (x - 1) y).toNat + (state rule t (x + 1) y).toNat +
             (state rule t x (y - 1)).toNat + (state rule t x (y + 1)).toNat))

/-- Number of ON cells at stage `t` of `rule` inside the trimmed square `[-t, t] x [-t, t]`. -/
noncomputable def count (rule t : ℕ) : ℕ :=
  ((Finset.Icc (-(t : ℤ)) t ×ˢ Finset.Icc (-(t : ℤ)) t).filter
    (fun p => state rule t p.1 p.2 = true)).card

/-- A273676(n): active ON cells at stage `2^n - 1` of Rule 833. -/
noncomputable def a (n : ℕ) : ℕ := count 833 (2 ^ n - 1)

/-- All five conjectures of OEIS A273676. -/
theorem main :
    (∀ n : ℕ, count 849 (2 ^ n - 1) = a n) ∧
    (∀ n : ℕ, 1 < n → a n = count 131 (2 ^ n - 1)) ∧
    (∀ n : ℕ, 1 < n → (a n : ℤ) = 3 * 4 ^ n - 4 * 2 ^ n + 1) ∧
    (∀ n : ℕ, 4 < n → (a n : ℤ) = 7 * a (n - 1) - 14 * a (n - 2) + 8 * a (n - 3)) ∧
    mk (fun n => (a n : ℤ)) * ((1 - X) * (1 - 2 * X) * (1 - 4 * X)) =
      1 - 3 * X + 19 * X ^ 2 - 22 * X ^ 3 + 8 * X ^ 4 := by
  sorry

end OMA.S_oeis_a273676
