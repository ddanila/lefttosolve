import Mathlib

/-!
# OEIS A273385: Blomberg's, Barker's, and Mathar's conjectures for two-dimensional Rule 659 at stages 2^n - 1

Source: https://oeis.org/A273385
Credit: @yooeonwoo

Entry A273385 (offset 0): Number of active (ON, black) cells at stage 2^n - 1 of the
two-dimensional cellular automaton defined by Rule 659, based on the 5-celled von Neumann
neighborhood, initialized with a single black (ON) cell at stage zero.

Conjectures listed in the entry (all stated below as one conjunction):
* Rules 667, 723, 731, 931, 939, 947, 955, 995, 1003, 1011, and 1019 also generate this
  sequence (Lars Blomberg, Jul 18 2016).
* a(n) = 4 * 4^n - 4 * 2^n + 1 = A060867(n + 1) for n > 1, where A060867(m) = (2^m - 1)^2
  (Lars Blomberg, Jul 18 2016).
* a(n) = 7 * a(n - 1) - 14 * a(n - 2) + 8 * a(n - 3) for n > 4 (Colin Barker, Dec 01 2016).
* G.f.: (1 - 2*x + 28*x^2 - 56*x^3 + 32*x^4) / ((1 - x)*(1 - 2*x)*(1 - 4*x))
  (Colin Barker, Dec 01 2016).
* a(n) = A270007(n) for n >= 2, where A270007 is the analogous count for Rule 5
  (R. J. Mathar, Jun 21 2025).

Formalization notes:
* Rule numbering follows Wolfram's outer-totalistic code for the 5-cell von Neumann neighborhood,
  matching the entry's Mathematica program (CAStep with kernel {{0,2,0},{2,1,2},{0,2,0}}): the new
  state of a cell is bit c + 2*s of the rule number, where c is its own state (1 for ON) and s is
  the number of ON cells among its four orthogonal neighbors.
* At stage 0 the origin (0, 0) is ON and every other cell of Z^2 is OFF; each step updates every
  cell of Z^2 synchronously.
* Matching the entry's Mathematica program (which trims stage t to its central (2t+1) x (2t+1)
  square and counts ON cells there), count rule t is the number of ON cells of stage t in
  [-t, t]^2, and a(n) = count 659 (2^n - 1), giving 1, 5, 49, 225, 961, 3969, ...
* The generating function identity A(x) = N(x) / D(x) is stated as A(x) * D(x) = N(x) in the formal
  power series ring over Z.
-/

namespace OMA.S_oeis_a273385

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

/-- A273385(n): active ON cells at stage `2^n - 1` of Rule 659. -/
noncomputable def a (n : ℕ) : ℕ := count 659 (2 ^ n - 1)

/-- All conjectures of OEIS A273385. -/
theorem main :
    (∀ r ∈ ({667, 723, 731, 931, 939, 947, 955, 995, 1003, 1011, 1019} : Finset ℕ),
      ∀ n : ℕ, count r (2 ^ n - 1) = a n) ∧
    (∀ n : ℕ, 1 < n → (a n : ℤ) = 4 * 4 ^ n - 4 * 2 ^ n + 1 ∧ (a n : ℤ) = (2 ^ (n + 1) - 1) ^ 2) ∧
    (∀ n : ℕ, 4 < n → (a n : ℤ) = 7 * a (n - 1) - 14 * a (n - 2) + 8 * a (n - 3)) ∧
    mk (fun n => (a n : ℤ)) * ((1 - X) * (1 - 2 * X) * (1 - 4 * X)) =
      1 - 2 * X + 28 * X ^ 2 - 56 * X ^ 3 + 32 * X ^ 4 ∧
    (∀ n : ℕ, 2 ≤ n → a n = count 5 (2 ^ n - 1)) := by
  sorry

end OMA.S_oeis_a273385
