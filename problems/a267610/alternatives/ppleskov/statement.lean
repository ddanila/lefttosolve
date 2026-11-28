import Mathlib

/-!
# A267610: Total number of OFF (white) cells after n iterations of the 'Rule 182' elementary cellular automaton starting with a single ON (black) cell.

Source: https://oeis.org/A267610

The conjecture formalized here (John Tyler Rascoe, Jul 08 2024, marked "conjectured" in the entry):
* G.f.: (1/x)*(A(x)/x - (x+1)/(1-x)^2) where A(x) is the g.f. for A006046.

A006046 is the total number of odd entries in the first n rows of Pascal's triangle (offset 0,
a(0) = 0). The entry also records a second conjecture (Gus Wiseman, a(n) = A267700(n) - n),
which is not formalized here.

Conventions (as in Wolfram's numbering and the OEIS program): the automaton runs on the integers,
starting from one ON cell at position 0 on an all-OFF background, and the rule is applied to every
cell, including the background, at each step.
Offset 0: a(n) is the total number of OFF cells among positions -k..k after k steps, summed over
0 <= k <= n. The definition below reproduces every term listed in the OEIS entry.

Since A(x) has zero constant term and A(x)/x - (x+1)/(1-x)^2 has zero constant term, the
generating function identity G(x) = (1/x)*(A(x)/x - (x+1)/(1-x)^2) for G(x) = Sum_{n >= 0} a(n) x^n
is stated with the denominators cleared: x^2 (1-x)^2 G(x) = (1-x)^2 A(x) - x (1+x), as formal
power series over the rationals. The identity was checked against the automaton for every n < 70.
-/

namespace OMA.S_oeis_a267610

/-- The new value of a cell under the elementary cellular automaton with Wolfram rule number
`rule`, given the old values of its left neighbour, itself and its right neighbour. -/
def ruleOut (rule : ℕ) (l c r : Bool) : Bool :=
  rule.testBit (4 * l.toNat + 2 * c.toNat + r.toNat)

/-- `cell rule t i` is the value of the cell at position `i` after `t` steps, starting from a
single ON cell at position 0 on an all-OFF background. -/
def cell (rule : ℕ) : ℕ → ℤ → Bool
  | 0 => fun i => decide (i = 0)
  | t + 1 => fun i => ruleOut rule (cell rule t (i - 1)) (cell rule t i) (cell rule t (i + 1))

/-- The number of ON cells among positions `-t..t` after `t` steps. -/
def onCount (rule t : ℕ) : ℕ :=
  ∑ j ∈ Finset.range (2 * t + 1), if cell rule t ((j : ℤ) - t) then 1 else 0

/-- A267610(n): the total number of OFF cells among positions -k..k after k steps, summed over
0 <= k <= n. -/
def a (n : ℕ) : ℤ :=
  ∑ k ∈ Finset.range (n + 1), ((2 * k + 1 : ℤ) - onCount 182 k)

/-- A006046(n): the total number of odd entries in the first `n` rows (rows `0..n-1`) of Pascal's
triangle. -/
def A006046 (n : ℕ) : ℕ :=
  ∑ k ∈ Finset.range n, ((Finset.range (k + 1)).filter (fun j => Odd (k.choose j))).card

open PowerSeries in
theorem main :
    X ^ 2 * (1 - X) ^ 2 * PowerSeries.mk (fun n => (a n : ℚ)) =
      (1 - X) ^ 2 * PowerSeries.mk (fun n => (A006046 n : ℚ)) - X * (1 + X) := by
  sorry

end OMA.S_oeis_a267610
