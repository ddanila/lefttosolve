import A283508.Basic

namespace A283508

/-- Arbitrary behavior outside the square; the interior uses the original rule. -/
def windowStep (R : ℕ) (boundary : Grid) (g : Grid) : Grid := fun x y =>
  if -(R : ℤ) ≤ x ∧ x ≤ R ∧ -(R : ℤ) ≤ y ∧ y ≤ R
  then step g x y else boundary x y

def windowEvolve (R : ℕ) (boundary : ℕ → Grid) (g : Grid) : ℕ → Grid
  | 0 => g
  | n+1 => windowStep R (boundary n) (windowEvolve R boundary g n)

/-- After n updates, arbitrary boundary choices cannot affect cells n inside the square. -/
theorem window_correct (R : ℕ) (boundary : ℕ → Grid) (g : Grid) (n : ℕ)
    (x y : ℤ)
    (hx0 : -(R : ℤ) + n ≤ x) (hx1 : x ≤ (R : ℤ) - n)
    (hy0 : -(R : ℤ) + n ≤ y) (hy1 : y ≤ (R : ℤ) - n) :
    windowEvolve R boundary g n x y = evolve g n x y := by
  induction n generalizing x y with
  | zero => rfl
  | succ n ih =>
    have inside : -(R : ℤ) ≤ x ∧ x ≤ R ∧ -(R : ℤ) ≤ y ∧ y ≤ R := by omega
    simp only [windowEvolve, windowStep, inside, and_self, if_true, evolve, step, neighbors]
    rw [ih x y (by omega) (by omega) (by omega) (by omega),
        ih (x+1) y (by omega) (by omega) (by omega) (by omega),
        ih (x-1) y (by omega) (by omega) (by omega) (by omega),
        ih x (y+1) (by omega) (by omega) (by omega) (by omega),
        ih x (y-1) (by omega) (by omega) (by omega) (by omega)]

/-- The simulator updates [-2N,2N] and stores a frozen OFF border one cell beyond it. -/
theorem observed_window_correct (N n m : ℕ) (hn : n ≤ N) (hm : m ≤ n)
    (boundary : ℕ → Grid) :
    windowEvolve (2*N) boundary initial n m 0 = state n m 0 := by
  apply window_correct <;> omega

end A283508
