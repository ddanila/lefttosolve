import Mathlib

/-!
# A267610: Total number of OFF (white) cells after n iterations of the "Rule 182" elementary cellular automaton starting with a single ON (black) cell.

Source: https://oeis.org/A267610
Credit: @ddanila

OEIS Foundation and contributors, CC BY-SA 4.0; retrieved 2026-11-28.
Offset 0. The published program sums OFF counts through stages 0,...,n,
using the crop [-t,t] at each stage t. This is a cumulative count, not one row.
Rule numbering uses left, centre, right weights 4,2,1 on an infinite OFF
background initialized with a single ON origin.

A267700 is defined by its published digit-sum program, using the partial sums
of A038573, which its entry records as confirmed by N. J. A. Sloane (2016).
A006046 is defined by the binary-weight sum in its title. Their offsets are 0.
Subtraction in the first conjecture is in integers; no index is silently shifted.
The generating-function claim is cleared of x and (1-x)^2 denominators:
x^2*F(x)*(1-x)^2 = A(x)*(1-x)^2 - x*(x+1).
This preserves the printed claim without dividing by the nonunit x.
-/
namespace OMA.S_oeis_a267610

/-- Rule 182, evaluated on the standard Wolfram neighbourhood index. -/
def rule (l c r : Bool) : Bool := Nat.testBit 182 (4*l.toNat+2*c.toNat+r.toNat)

/-- Infinite-line evolution from one ON cell at the origin. -/
def state : ℕ → ℤ → Bool
  | 0, x => decide (x = 0)
  | t+1, x => rule (state t (x-1)) (state t x) (state t (x+1))

/-- OFF cells in the finite crop of row t. -/
def offCount (t : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (2*t+1), if state t ((i : ℤ)-t) then 0 else 1

/-- Total OFF cells through row n, including the initial row. -/
def a (n : ℕ) : ℕ := ∑ t ∈ Finset.range (n+1), offCount t

/-- Number of ones in the binary expansion, including weight zero for 0. -/
def weight (n : ℕ) : ℕ := (Nat.digits 2 n).sum

/-- A267700, as computed by its published Mathematica program. -/
def tree (n : ℕ) : ℕ := ∑ k ∈ Finset.range (n+1), (2^weight k-1)

/-- A006046: odd entries in the first n rows of Pascal's triangle. -/
def pascalTotal (n : ℕ) : ℕ := ∑ k ∈ Finset.range n, 2^weight k

def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))
def pascalSeries : PowerSeries ℤ := PowerSeries.mk (fun n => (pascalTotal n : ℤ))

/-- The two formula claims printed in A267610, with their original indices. -/
theorem main :
    (∀ n : ℕ, (a n : ℤ) = (tree n : ℤ) - n) ∧
    (PowerSeries.X^2 * series * (1-PowerSeries.X)^2 =
      pascalSeries * (1-PowerSeries.X)^2 - PowerSeries.X * (PowerSeries.X+1)) := by
  sorry

end OMA.S_oeis_a267610
