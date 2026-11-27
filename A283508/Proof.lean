import A283508.Basic

namespace A283508

def Far (r x y : ℤ) : Prop := x < -r ∨ r < x ∨ y < -r ∨ r < y

theorem initial_far {x y : ℤ} (h : Far 1 x y) : initial x y = false := by
  have h' : ¬ (x = 0 ∧ y = 0) := by unfold Far at h; omega
  simp [initial, h']

theorem first_far {x y : ℤ} (h : Far 1 x y) : first x y = true := by
  have h' : ¬ ((x = 0 ∧ (y = -1 ∨ y = 1)) ∨
      (y = 0 ∧ (x = -1 ∨ x = 1))) := by unfold Far at h; omega
  simp [first, h']

theorem stable_far {x y : ℤ} (h : Far 1 x y) : stable x y = true := by
  have h' : x < -1 ∨ 1 < x ∨ y < -1 ∨ 1 < y ∨ (x = 0 ∧ y = 0) := by
    unfold Far at h; omega
  simp [stable, h']

theorem step_far (g : Grid) (b : Bool)
    (hg : ∀ x y, Far 1 x y → g x y = b)
    {x y : ℤ} (h : Far 2 x y) : step g x y = rule b (4 * bit b) := by
  have h0 := hg x y (by unfold Far at *; omega)
  have h1 := hg (x+1) y (by unfold Far at *; omega)
  have h2 := hg (x-1) y (by unfold Far at *; omega)
  have h3 := hg x (y+1) (by unfold Far at *; omega)
  have h4 := hg x (y-1) (by unfold Far at *; omega)
  simp only [step, neighbors, h0, h1, h2, h3, h4]
  congr 1
  omega

theorem step_initial : step initial = first := by
  funext x y
  by_cases h : Far 2 x y
  · rw [step_far initial false (fun _ _ h => initial_far h) h,
        first_far (by unfold Far at *; omega)]
    decide
  · have hx : -2 ≤ x ∧ x ≤ 2 := by unfold Far at h; omega
    have hy : -2 ≤ y ∧ y ≤ 2 := by unfold Far at h; omega
    rcases hx with ⟨hx0, hx1⟩
    rcases hy with ⟨hy0, hy1⟩
    interval_cases x <;> interval_cases y <;> decide

theorem step_first : step first = stable := by
  funext x y
  by_cases h : Far 2 x y
  · rw [step_far first true (fun _ _ h => first_far h) h,
        stable_far (by unfold Far at *; omega)]
    decide
  · have hx : -2 ≤ x ∧ x ≤ 2 := by unfold Far at h; omega
    have hy : -2 ≤ y ∧ y ≤ 2 := by unfold Far at h; omega
    rcases hx with ⟨hx0, hx1⟩
    rcases hy with ⟨hy0, hy1⟩
    interval_cases x <;> interval_cases y <;> decide

theorem step_stable : step stable = stable := by
  funext x y
  by_cases h : Far 2 x y
  · rw [step_far stable true (fun _ _ h => stable_far h) h,
        stable_far (by unfold Far at *; omega)]
    decide
  · have hx : -2 ≤ x ∧ x ≤ 2 := by unfold Far at h; omega
    have hy : -2 ≤ y ∧ y ≤ 2 := by unfold Far at h; omega
    rcases hx with ⟨hx0, hx1⟩
    rcases hy with ⟨hy0, hy1⟩
    interval_cases x <;> interval_cases y <;> decide

theorem state_one : state 1 = first := step_initial

theorem state_add_two (n : ℕ) : state (n+2) = stable := by
  induction n with
  | zero => exact congrArg step step_initial |>.trans step_first
  | succ n ih =>
    change step (state (n+2)) = stable
    rw [ih, step_stable]

theorem state_stable (n : ℕ) (hn : 2 ≤ n) : state n = stable := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+2 := ⟨n-2, by omega⟩
  exact state_add_two k

theorem stable_axis (m : ℕ) : stable m 0 = decide (m ≠ 1) := by
  by_cases h : m = 1
  · subst m; decide
  · simp [stable, h]
    omega

theorem axis_pattern (n m : ℕ) (hn : 0 < n) (hm : m ≤ n) :
    state n m 0 = decide (m ≠ 1) := by
  by_cases h : n = 1
  · subst n
    rw [state_one]
    interval_cases m <;> decide
  · rw [state_stable n (by omega), stable_axis]

theorem encode_stable_one : encode stable 1 = 10 := by decide

theorem encode_stable_succ (n : ℕ) (hn : 1 ≤ n) :
    encode stable (n+1) = 10 * encode stable n + 1 := by
  rw [encode, stable_axis]
  simp [bit, show n ≠ 0 by omega]

theorem encode_stable_identity (n : ℕ) (hn : 0 < n) :
    90 * encode stable n + 10 = 91 * 10^n := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+1 := ⟨n-1, by omega⟩
  induction k with
  | zero => decide
  | succ k ih =>
    rw [encode_stable_succ (k+1) (by omega), pow_succ]
    calc
      90 * (10 * encode stable (k+1) + 1) + 10 =
          10 * (90 * encode stable (k+1) + 10) := by ring
      _ = _ := by rw [ih (by omega)]; ring

theorem a_eq_encode_stable (n : ℕ) (hn : 0 < n) : a n = encode stable n := by
  by_cases h : n = 1
  · subst n; decide
  · unfold a; rw [state_stable n (by omega)]

/-- The closed-form conjecture in OEIS A283508, with the source's n > 0 range. -/
theorem formula (n : ℕ) (hn : 0 < n) : a n = (91 * 10^n - 10) / 90 := by
  rw [a_eq_encode_stable n hn]
  have h := encode_stable_identity n hn
  have heq : 91 * 10^n - 10 = 90 * encode stable n := by omega
  rw [heq, Nat.mul_div_right]; decide

/-- Exact identity: the division in formula loses no fractional remainder. -/
theorem exact_identity (n : ℕ) (hn : 0 < n) : 90 * a n + 10 = 91 * 10^n := by
  rw [a_eq_encode_stable n hn]
  exact encode_stable_identity n hn

theorem a_succ (n : ℕ) (hn : 0 < n) : a (n+1) = 10 * a n + 1 := by
  rw [a_eq_encode_stable (n+1) (by omega), a_eq_encode_stable n hn,
      encode_stable_succ n (by omega)]

/-- The recurrence stated in OEIS, with natural subtraction justified by the proof. -/
theorem recurrence (n : ℕ) (hn : 2 < n) :
    a n = 11 * a (n-1) - 10 * a (n-2) := by
  have h1 := a_succ (n-1) (by omega)
  have h2 := a_succ (n-2) (by omega)
  have e1 : n-1+1 = n := by omega
  have e2 : n-2+1 = n-1 := by omega
  rw [e1] at h1
  rw [e2] at h2
  omega

end A283508
