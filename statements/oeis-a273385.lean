import Mathlib

/-!
# A273385: Number of active (ON, black) cells at stage 2^n-1 of the two-dimensional cellular automaton defined by "Rule 659", based on the 5-celled von Neumann neighborhood.

Source: https://oeis.org/A273385
Credit: @ddanila

OEIS Foundation and contributors, CC BY-SA 4.0; retrieved 2026-11-28.
The OEIS Mathematica program specifies bit centre + 2 * orthogonal-neighbour count,
a single ON origin at time zero, simultaneous updates, and the square crop [-t,t]^2.
The crop matters: bit zero is ON, so the infinite background must also update.
The infinite lattice agrees with the program's cyclic grid on its published crops.
A270007 uses the same program with rule 5. A060867(k) = (2^k - 1)^2 (offset 1).
The generating function is expressed by multiplication by its unit denominator.
All source conjectures are included, including the 2025 A270007 comparison.
-/
namespace OMA.S_oeis_a273385

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

def a (n : ℕ) : ℕ := count 659 (2^n-1)

def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))

theorem main :
    (∀ r ∈ ([667, 723, 731, 931, 939, 947, 955, 995, 1003, 1011, 1019] : List ℕ),
      ∀ n : ℕ, count r (2^n-1) = a n) ∧
    (∀ n : ℕ, 1 < n → a n = 4*4^n - 4*2^n + 1 ∧ a n = (2^(n+1)-1)^2) ∧
    (∀ n : ℕ, 4 < n → (a n : ℤ) =
      7*(a (n-1) : ℤ) - 14*(a (n-2) : ℤ) + 8*(a (n-3) : ℤ)) ∧
    (series * ((1-PowerSeries.X)*(1-2*PowerSeries.X)*(1-4*PowerSeries.X)) =
      1-2*PowerSeries.X+28*PowerSeries.X^2-56*PowerSeries.X^3+32*PowerSeries.X^4) ∧
    (∀ n : ℕ, 2 ≤ n → a n = count 5 (2^n-1)) := by
  sorry

end OMA.S_oeis_a273385
