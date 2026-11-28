import OMAStatements.S_oeis_a071052

-- Problem: A071052: Number of 0's in n-th row of triangle in A071036 (cellular automaton Rule 150).
-- Upstream: formal-conjectures statements/oeis-a071052.lean:0 (declaration OMA.S_oeis_a071052.main)
-- Credit: @agchua (the owner of the agent is credited as the solver)
-- Prove EXACTLY this target. No sorry, no axiom, no native_decide.
-- Proof idea: T(n,k) is the coefficient of x^k in P^n, P = 1 + x + x^2 over ZMod 2 (induction on n;
-- cells left of the row are 0). By Frobenius, P^(2n) = (P^n)^2 = expand 2 (P^n), so
-- T(2n,2i) = T(n,i) and T(2n,2i+1) = 0. Splitting row 2n (indices 0..4n) into its 2n+1 even and
-- 2n odd places gives a(2n) = a(n) + 2n.

open OMA.S_oeis_a071052 in
theorem OMA.solution : type_of% @OMA.S_oeis_a071052.main := by
  have L1 : ∀ n : ℕ, ∀ k : ℤ, k < 0 → T n k = 0 := by
    intro n
    induction n with
    | zero =>
      intro k hk
      simp only [T]
      rw [if_neg (show ¬ (k = 0) by omega)]
    | succ m ih =>
      intro k hk
      simp only [T]
      simp only [ih (k - 2) (by omega), ih (k - 1) (by omega), ih k hk, add_zero]
  obtain ⟨P, hP⟩ : ∃ P : Polynomial (ZMod 2), P = 1 + Polynomial.X + Polynomial.X ^ 2 :=
    ⟨_, rfl⟩
  have L2 : ∀ n k : ℕ, T n (k : ℤ) = (P ^ n).coeff k := by
    intro n
    induction n with
    | zero =>
      intro k
      rw [pow_zero, Polynomial.coeff_one]
      simp only [T]
      rcases Nat.eq_zero_or_pos k with h0 | h0
      · subst h0
        simp
      · rw [if_neg (show ¬ ((k : ℤ) = 0) by omega), if_neg (show ¬ (k = 0) by omega)]
    | succ m ih =>
      intro k
      have hPm : P ^ (m + 1) = P ^ m + P ^ m * Polynomial.X ^ 1 + P ^ m * Polynomial.X ^ 2 := by
        rw [pow_succ P m]
        generalize P ^ m = Q
        rw [hP]
        ring
      have S : ∀ j : ℕ, ∀ z : ℤ, z = (k : ℤ) - (j : ℤ) →
          T m z = (P ^ m * Polynomial.X ^ j).coeff k := by
        intro j z hz
        rw [Polynomial.coeff_mul_X_pow']
        by_cases hj : j ≤ k
        · have hz' : z = ((k - j : ℕ) : ℤ) := by omega
          rw [if_pos hj, hz']
          exact ih (k - j)
        · rw [if_neg hj]
          exact L1 m z (by omega)
      have S1 := S 1 ((k : ℤ) - 1) (by omega)
      have S2 := S 2 ((k : ℤ) - 2) (by omega)
      simp only [T]
      rw [hPm, Polynomial.coeff_add, Polynomial.coeff_add, ← S1, ← S2, ← ih k]
      ring
  have D_even : ∀ n i : ℕ, T (2 * n) ((2 * i : ℕ) : ℤ) = T n (i : ℤ) := by
    intro n i
    rw [L2, L2, pow_mul' P 2 n, ← ZMod.expand_card (P ^ n),
      Polynomial.coeff_expand (show (0 : ℕ) < 2 by norm_num),
      if_pos (dvd_mul_right 2 i), show 2 * i / 2 = i by omega]
  have D_odd : ∀ n i : ℕ, T (2 * n) ((2 * i + 1 : ℕ) : ℤ) = 0 := by
    intro n i
    rw [L2, pow_mul' P 2 n, ← ZMod.expand_card (P ^ n),
      Polynomial.coeff_expand (show (0 : ℕ) < 2 by norm_num),
      if_neg (show ¬ (2 ∣ 2 * i + 1) by omega)]
  have SPLIT : ∀ (f : ℕ → ℕ) (m : ℕ), ∑ k ∈ Finset.range (2 * m + 1), f k =
      ∑ i ∈ Finset.range (m + 1), f (2 * i) + ∑ i ∈ Finset.range m, f (2 * i + 1) := by
    intro f m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [show 2 * (m + 1) + 1 = 2 * m + 1 + 1 + 1 by ring, Finset.sum_range_succ f (2 * m + 1 + 1),
        Finset.sum_range_succ f (2 * m + 1), ih,
        Finset.sum_range_succ (fun i => f (2 * i)) (m + 1),
        Finset.sum_range_succ (fun i => f (2 * i + 1)) m,
        show 2 * m + 1 + 1 = 2 * (m + 1) by ring]
      ring
  intro n
  have E1 : ∑ i ∈ Finset.range (2 * n + 1), (if T (2 * n) ((2 * i : ℕ) : ℤ) = 0 then 1 else 0)
      = ∑ i ∈ Finset.range (2 * n + 1), (if T n (i : ℤ) = 0 then 1 else 0) := by
    apply Finset.sum_congr rfl
    intro i _
    rw [D_even n i]
  have E2 : ∑ i ∈ Finset.range (2 * n), (if T (2 * n) ((2 * i + 1 : ℕ) : ℤ) = 0 then 1 else 0)
      = 2 * n := by
    have h1 : ∀ i ∈ Finset.range (2 * n),
        (if T (2 * n) ((2 * i + 1 : ℕ) : ℤ) = 0 then 1 else 0) = 1 := by
      intro i _
      exact if_pos (D_odd n i)
    rw [Finset.sum_congr rfl h1]
    simp
  unfold a
  rw [Finset.card_filter, Finset.card_filter, SPLIT _ (2 * n), E1, E2]
