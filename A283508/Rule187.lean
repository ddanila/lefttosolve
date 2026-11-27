import A283508.Proof

/-! Independent translation of the Maple program in OEIS A267623.
The low bit is the cell at x-1, the centre has weight 2, and x+1 has weight 4.
The sequence reads the centre cell through TIME, encoding the bits in decimal.
-/
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

theorem rule_readable (l c r : Bool) : rule l c r = (!c || l) := by
  cases l <;> cases c <;> cases r <;> decide

def hole (k : ℤ) : Row := fun x => decide (x ≠ k)

theorem step_initial : step initial = hole 0 := by
  funext x
  simp [step, rule_readable, initial, hole]
  omega

theorem step_hole (k : ℤ) : step (hole k) = hole (k+1) := by
  funext x
  by_cases h : x = k+1 <;> by_cases j : x = k
  all_goals simp_all [step, rule_readable, hole, show x-1 = k ↔ x = k+1 by omega]

theorem state_succ (n : ℕ) : state (n+1) = hole n := by
  induction n with
  | zero => exact step_initial
  | succ n ih =>
    change step (state (n+1)) = hole (↑(n+1 : ℕ))
    rw [ih, step_hole]
    simp

theorem center (n : ℕ) : state n 0 = decide (n ≠ 1) := by
  cases n with
  | zero => decide
  | succ n => rw [state_succ]; simp [hole, eq_comm]

theorem sequence_eq (n : ℕ) : A283508.a n = a n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    cases n with
    | zero => decide
    | succ n =>
      rw [A283508.a_succ (n+1) (by omega), a, center, ← ih]
      simp [bit]

end A267623
