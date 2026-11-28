import Mathlib.RingTheory.PowerSeries.Basic

/-!
# A273539: Number of active (ON, black) cells at stage 2^n-1 of the two-dimensional cellular automaton defined by "Rule 779", based on the 5-celled von Neumann neighborhood.

Source: https://oeis.org/A273539
Credit: @ddanila

OEIS Foundation and contributors, CC BY-SA 4.0; retrieved 2026-11-28.
The program selects bit centre + 2 * orthogonal-neighbour count, starts from
one ON origin at time zero, and updates every cell synchronously. The count
uses the square crop [-t,t]^2; the infinite background also evolves. The large
cyclic grid in the source has the same observations throughout its horizon.
Offset 0. All three alternative rules are included. The closed formula uses
integer arithmetic: its initial subtraction is negative even at n=0, so a
literal natural-number subtraction would be incorrect. The generating function
is a formal power-series product with its unit denominator.
-/
namespace OMA.S_oeis_a273539

abbrev Grid := ℤ → ℤ → Bool

def bit (b : Bool) : ℕ := if b then 1 else 0

def rule (r : ℕ) (c : Bool) (k : ℕ) : Bool :=
  decide ((r / 2 ^ (bit c + 2 * k)) % 2 = 1)

def neighbors (g : Grid) (x y : ℤ) : ℕ :=
  bit (g (x+1) y) + bit (g (x-1) y) + bit (g x (y+1)) + bit (g x (y-1))

def step (r : ℕ) (g : Grid) : Grid := fun x y => rule r (g x y) (neighbors g x y)

def initial : Grid := fun x y => decide (x = 0 ∧ y = 0)

def state (r : ℕ) : ℕ → Grid
  | 0 => initial
  | t+1 => step r (state r t)

/-- ON cells in the square crop specified by the source program. -/
def count (r t : ℕ) : ℕ :=
  ∑ x ∈ Finset.range (2*t+1), ∑ y ∈ Finset.range (2*t+1),
    bit (state r t ((x : ℤ)-t) ((y : ℤ)-t))

def a (n : ℕ) : ℕ := count 779 (2^n-1)

def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))

theorem main :
    (∀ r ∈ ([795,843,859] : List ℕ), ∀ n : ℕ, count r (2^n-1) = a n) ∧
    (∀ n : ℕ, (a n : ℤ) = 5 - 2^(3+n) + 4^(1+n)) ∧
    (∀ n : ℕ, 2 < n → (a n : ℤ) =
      7*(a (n-1) : ℤ) - 14*(a (n-2) : ℤ) + 8*(a (n-3) : ℤ)) ∧
    (series * ((1-PowerSeries.X)*(1-2*PowerSeries.X)*(1-4*PowerSeries.X)) =
      1-2*PowerSeries.X+16*PowerSeries.X^2) := by
  sorry

end OMA.S_oeis_a273539
