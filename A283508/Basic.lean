import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
Rule 643 from https://oeis.org/A283508/internal (retrieved 2026-11-27).
The integer code is indexed from its least significant bit by center + 2*neighbors.
The infinite background is updated too; it is not held OFF.
-/
namespace A283508

abbrev Grid := ℤ → ℤ → Bool

def bit (b : Bool) : ℕ := if b then 1 else 0

def rule (c : Bool) (k : ℕ) : Bool :=
  decide ((643 / 2 ^ (bit c + 2 * k)) % 2 = 1)

theorem rule_readable (c : Bool) (k : ℕ) (hk : k ≤ 4) :
    rule c k = decide (k = 0 ∨ (c = true ∧ 3 ≤ k)) := by
  cases c <;> interval_cases k <;> decide

def neighbors (g : Grid) (x y : ℤ) : ℕ :=
  bit (g (x+1) y) + bit (g (x-1) y) + bit (g x (y+1)) + bit (g x (y-1))

def step (g : Grid) : Grid := fun x y => rule (g x y) (neighbors g x y)

def initial : Grid := fun x y => decide (x = 0 ∧ y = 0)

def evolve (g : Grid) : ℕ → Grid
  | 0 => g
  | n+1 => step (evolve g n)

def state (n : ℕ) : Grid := evolve initial n

def first : Grid := fun x y => decide
  (¬ ((x = 0 ∧ (y = -1 ∨ y = 1)) ∨ (y = 0 ∧ (x = -1 ∨ x = 1))))

def stable : Grid := fun x y => decide
  (x < -1 ∨ 1 < x ∨ y < -1 ∨ 1 < y ∨ (x = 0 ∧ y = 0))

/-- Decimal encoding of positions 0 through m, most significant digit first. -/
def encode (g : Grid) : ℕ → ℕ
  | 0 => bit (g 0 0)
  | m+1 => 10 * encode g m + bit (g (↑(m+1 : ℕ)) 0)

def a (n : ℕ) : ℕ := encode (state n) n

end A283508
