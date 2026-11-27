import Mathlib

/-!
OEIS A283508, https://oeis.org/A283508/internal, retrieved 2026-11-27.
OEIS Foundation and contributors; CC BY-SA 4.0.
Rule 643 evolves the entire infinite grid simultaneously from a single ON origin.
Read positions (0,0) through (n,0) at time n, with the origin digit most significant.
Rule 187 is independently translated from https://oeis.org/A267623/internal:
its sequence reads the centre cell at times 0 through n.
Both encodings use decimal digits, not the numerical value in base two.
The generating-function denominator has constant coefficient 1, so it is a unit;
the product identity expresses the source's formal quotient without division.
-/
namespace OMA.S_oeis_a283508

abbrev Grid := ℤ → ℤ → Bool

def bit (b : Bool) : ℕ := if b then 1 else 0

def rule (c : Bool) (k : ℕ) : Bool :=
  decide ((643 / 2 ^ (bit c + 2 * k)) % 2 = 1)

def neighbors (g : Grid) (x y : ℤ) : ℕ :=
  bit (g (x+1) y) + bit (g (x-1) y) + bit (g x (y+1)) + bit (g x (y-1))

def step (g : Grid) : Grid := fun x y => rule (g x y) (neighbors g x y)

def initial : Grid := fun x y => decide (x = 0 ∧ y = 0)

def evolve (g : Grid) : ℕ → Grid
  | 0 => g
  | n+1 => step (evolve g n)

def state (n : ℕ) : Grid := evolve initial n

/-- Decimal encoding of positions 0 through m, most significant digit first. -/
def encode (g : Grid) : ℕ → ℕ
  | 0 => bit (g 0 0)
  | m+1 => 10 * encode g m + bit (g (↑(m+1 : ℕ)) 0)

def a (n : ℕ) : ℕ := encode (state n) n


namespace A267623
abbrev Row := ℤ → Bool
def bit (b : Bool) : ℕ := if b then 1 else 0
def rule (l c r : Bool) : Bool :=
  decide ((187 / 2 ^ (bit l + 2 * bit c + 4 * bit r)) % 2 = 1)
def step (g : Row) : Row := fun x => rule (g (x-1)) (g x) (g (x+1))
def initial : Row := fun x => decide (x = 0)
def state : ℕ → Row
  | 0 => initial
  | n+1 => step (state n)
def a : ℕ → ℕ
  | 0 => bit (state 0 0)
  | n+1 => 10 * a n + bit (state (n+1) 0)

end A267623

def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))

def Target : Prop :=
  (series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
    1 - PowerSeries.X + PowerSeries.X^2) ∧
  (∀ n : ℕ, 0 < n → a n = (91 * 10^n - 10) / 90) ∧
  (∀ n : ℕ, 2 < n → (a n : ℤ) = 11 * (a (n-1) : ℤ) - 10 * (a (n-2) : ℤ)) ∧
  (∀ n : ℕ, a n = A267623.a n)

theorem main : Target := by sorry

end OMA.S_oeis_a283508
