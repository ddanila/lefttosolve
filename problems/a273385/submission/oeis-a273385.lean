import OMAStatements.S_oeis_a273385

/-!
# A273385: ON-cell counts for the Rule 659 von Neumann automaton

Credit: @ddanila

First prove finite propagation and check the first three generations. The listed
rules then stay uniformly ON; Rule 5 alternates uniformly OFF and ON. Counting
the source's square crop gives the formula, recurrence, and generating function.
-/
namespace A273385Solution
open OMA.S_oeis_a273385

private abbrev Grid := ℤ → ℤ → Bool
private def bit (b : Bool) : ℕ := b.toNat
private def rule (r : ℕ) (c : Bool) (k : ℕ) : Bool := Nat.testBit r (bit c + 2*k)
private def neighbors (g : Grid) (x y : ℤ) : ℕ :=
  bit (g (x-1) y) + bit (g (x+1) y) + bit (g x (y-1)) + bit (g x (y+1))
private def step (r : ℕ) (g : Grid) : Grid := fun x y => rule r (g x y) (neighbors g x y)
private noncomputable def series : PowerSeries ℤ := PowerSeries.mk (fun n => (a n : ℤ))

/-! ## Finite propagation and the first generations -/

/-- Evolution of the spatially uniform background. -/
private def background (r : ℕ) : ℕ → Bool
  | 0 => false
  | t+1 => rule r (background r t) (4 * bit (background r t))

/-- A cell outside the time-t square cannot yet see the initial ON origin. -/
private lemma outside (r t : ℕ) (x y : ℤ)
    (h : x < -(t : ℤ) ∨ (t : ℤ) < x ∨ y < -(t : ℤ) ∨ (t : ℤ) < y) :
    state r t x y = background r t := by
  induction t generalizing x y with
  | zero =>
    have h0 : ¬(x = 0 ∧ y = 0) := by omega
    simp [state, background, h0]
  | succ t ih =>
    have hc := ih x y (by omega)
    have he := ih (x+1) y (by omega)
    have hw := ih (x-1) y (by omega)
    have hn := ih x (y+1) (by omega)
    have hs := ih x (y-1) (by omega)
    simp only [state, hc, he, hw, hn, hs, background, rule, bit]
    congr 1
    omega

set_option maxHeartbeats 4000000 in
/-- After three generations all listed rules have reached the all-ON fixed point. -/
private lemma third (r : ℕ)
    (hr : r ∈ ([659,667,723,731,931,939,947,955,995,1003,1011,1019] : List ℕ)) :
    state r 3 = fun _ _ => true := by
  funext x y
  by_cases h : x < -3 ∨ 3 < x ∨ y < -3 ∨ 3 < y
  · rw [outside r 3 x y (by simpa using h)]
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
    rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      decide
  · have hx : -3 ≤ x ∧ x ≤ 3 := by omega
    have hy : -3 ≤ y ∧ y ≤ 3 := by omega
    rcases hx with ⟨hxl, hxu⟩
    rcases hy with ⟨hyl, hyu⟩
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
    rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      interval_cases x <;> interval_cases y <;> decide

/-- Every listed rule keeps a uniform ON grid ON. -/
private lemma fixed (r : ℕ)
    (hr : r ∈ ([659,667,723,731,931,939,947,955,995,1003,1011,1019] : List ℕ)) :
    step r (fun _ _ => true) = fun _ _ => true := by
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> funext x y <;> norm_num [step, neighbors, rule, bit] <;> decide

private lemma uniform (r t : ℕ)
    (hr : r ∈ ([659,667,723,731,931,939,947,955,995,1003,1011,1019] : List ℕ))
    (ht : 3 ≤ t) : state r t = fun _ _ => true := by
  obtain ⟨k, rfl⟩ : ∃ k, t = 3+k := ⟨t-3, by omega⟩
  induction k with
  | zero => exact third r hr
  | succ k ih =>
    change step r (state r (3+k)) = _
    rw [ih (by omega), fixed r hr]

/-- Rule 5 has erased the initial perturbation by generation two. -/
private lemma five_second : state 5 2 = fun _ _ => false := by
  funext x y
  by_cases h : x < -2 ∨ 2 < x ∨ y < -2 ∨ 2 < y
  · rw [outside 5 2 x y (by simpa using h)]
    rfl
  · have hx : -2 ≤ x ∧ x ≤ 2 := by omega
    have hy : -2 ≤ y ∧ y ≤ 2 := by omega
    rcases hx with ⟨hxl, hxu⟩
    rcases hy with ⟨hyl, hyu⟩
    interval_cases x <;> interval_cases y <;> decide

/-- Thereafter Rule 5 is uniformly ON at odd times and OFF at even times. -/
private lemma five_odd (k : ℕ) : state 5 (2*k+3) = fun _ _ => true := by
  induction k with
  | zero =>
    change step 5 (state 5 2) = _
    rw [five_second]
    funext x y
    norm_num [step, neighbors, rule, bit]
  | succ k ih =>
    have ht : 2*(k+1)+3 = (2*k+3)+1+1 := by omega
    rw [ht]
    change step 5 (step 5 (state 5 (2*k+3))) = _
    rw [ih]
    funext x y
    norm_num only [step, neighbors, rule, bit, Bool.toNat_true]
    decide

/-! ## Counting the square crop -/

/-- A uniform ON crop has one cell for each pair of its 2t+1 coordinates. -/
private lemma count_uniform (r t : ℕ) (h : state r t = fun _ _ => true) :
    count r t = (2*t+1)^2 := by
  simp only [count, h, Finset.filter_true, Finset.card_product, Int.card_Icc, pow_two]
  congr 1 <;> omega

private lemma time_bound (n : ℕ) (hn : 2 ≤ n) : 4 ≤ 2^n := by
  calc 4 = 2^2 := by norm_num
       _ ≤ 2^n := Nat.pow_le_pow_right (by omega) hn

private lemma square (r n : ℕ)
    (hr : r ∈ ([659,667,723,731,931,939,947,955,995,1003,1011,1019] : List ℕ))
    (hn : 2 ≤ n) : count r (2^n-1) = (2^(n+1)-1)^2 := by
  rw [count_uniform r _ (uniform r _ hr (by have := time_bound n hn; omega))]
  congr 1
  rw [pow_succ]
  have := time_bound n hn
  omega

private lemma a_square (n : ℕ) (hn : 2 ≤ n) : a n = (2^(n+1)-1)^2 :=
  square 659 n (by simp) hn

private lemma small_interval : Finset.Icc (-1 : ℤ) 1 = {-1,0,1} := by
  ext x
  simp only [Finset.mem_Icc, Finset.mem_insert, Finset.mem_singleton]
  omega

private lemma same_rules (r : ℕ)
    (hr : r ∈ ([667,723,731,931,939,947,955,995,1003,1011,1019] : List ℕ))
    (n : ℕ) : count r (2^n-1) = a n := by
  by_cases hn : 2 ≤ n
  · rw [square r n (by exact List.mem_cons_of_mem 659 hr) hn, a_square n hn]
  · interval_cases n <;>
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hr <;>
      rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num only [a, count, pow_zero, pow_one, Nat.reducePow, Nat.reduceSub, Nat.cast_zero, Nat.cast_one, neg_zero, Finset.Icc_self, small_interval] <;> decide

private lemma same_five (n : ℕ) (hn : 2 ≤ n) : a n = count 5 (2^n-1) := by
  have hpow : 2^n = 4 * 2^(n-2) := by
    conv_lhs => rw [show n = (n-2)+2 by omega]
    rw [pow_add]
    ring
  have hp : 1 ≤ 2^(n-2) := Nat.one_le_pow _ _ (by omega)
  have ht : 2^n-1 = 2*(2*2^(n-2)-2)+3 := by omega
  rw [count_uniform 5 _ (ht ▸ five_odd (2*2^(n-2)-2)), a_square n hn]
  congr 1
  rw [pow_succ]
  omega

/-- Integer form of the area formula, avoiding truncated subtraction. -/
private lemma a_formula (n : ℕ) (hn : 2 ≤ n) :
    (a n : ℤ) = 4*4^n - 4*2^n + 1 := by
  rw [a_square n hn]
  have hp : 1 ≤ 2^(n+1) := Nat.one_le_pow _ _ (by omega)
  push_cast [Nat.cast_sub hp]
  rw [pow_succ]
  have h4 : (4 : ℤ)^n = (2^n)^2 := by
    rw [← pow_mul, mul_comm n 2, pow_mul]
    norm_num
  rw [h4]
  ring

private lemma closed_form (n : ℕ) (hn : 1 < n) :
    a n = 4*4^n - 4*2^n + 1 ∧ a n = (2^(n+1)-1)^2 := by
  refine ⟨?_, a_square n (by omega)⟩
  have h := a_formula n (by omega)
  have hp : 2^n ≤ (4 : ℕ)^n := Nat.pow_le_pow_left (by omega) n
  have hc : 4*2^n ≤ 4*(4 : ℕ)^n := Nat.mul_le_mul_left 4 hp
  have he : (a n : ℤ) = ((4*4^n - 4*2^n + 1 : ℕ) : ℤ) := by
    push_cast [Nat.cast_sub hc]
    exact h
  exact_mod_cast he

/-! ## Recurrence and generating function -/

/-- The three exponential terms satisfy the characteristic polynomial. -/
private lemma recurrence (n : ℕ) (hn : 4 < n) :
    (a n : ℤ) = 7*(a (n-1) : ℤ) - 14*(a (n-2) : ℤ) + 8*(a (n-3) : ℤ) := by
  rw [a_formula n (by omega), a_formula (n-1) (by omega),
    a_formula (n-2) (by omega), a_formula (n-3) (by omega)]
  obtain ⟨k, rfl⟩ : ∃ k, n = k+5 := ⟨n-5, by omega⟩
  simp only [show k+5-1=k+4 by omega, show k+5-2=k+3 by omega,
    show k+5-3=k+2 by omega, pow_add]
  ring

private lemma a_zero : a 0 = 1 := by norm_num only [a, count, pow_zero, Nat.reduceSub, Nat.cast_zero, neg_zero, Finset.Icc_self]; decide
private lemma a_one : a 1 = 5 := by norm_num only [a, count, pow_zero, pow_one, Nat.reducePow, Nat.reduceSub, Nat.cast_zero, Nat.cast_one, neg_zero, Finset.Icc_self, small_interval]; decide
private lemma a_two : a 2 = 49 := by rw [a_square 2 (by omega)]; norm_num
private lemma a_three : a 3 = 225 := by rw [a_square 3 (by omega)]; norm_num
private lemma a_four : a 4 = 961 := by rw [a_square 4 (by omega)]; norm_num

/-- Multiplication by X^k shifts the sequence by k places. -/
private lemma coeff_series_mul_X (k n : ℕ) :
    PowerSeries.coeff n (series * PowerSeries.X^k) =
      if k ≤ n then (a (n-k) : ℤ) else 0 := by
  simp only [PowerSeries.coeff_mul_X_pow', series, PowerSeries.coeff_mk]

set_option maxHeartbeats 1000000 in
private lemma generating_function :
    series * ((1-PowerSeries.X)*(1-2*PowerSeries.X)*(1-4*PowerSeries.X)) =
      1-2*PowerSeries.X+28*PowerSeries.X^2-56*PowerSeries.X^3+32*PowerSeries.X^4 := by
  have expand : series * ((1-PowerSeries.X)*(1-2*PowerSeries.X)*(1-4*PowerSeries.X)) =
      series - PowerSeries.C 7 * (series * PowerSeries.X^1) +
        PowerSeries.C 14 * (series * PowerSeries.X^2) -
        PowerSeries.C 8 * (series * PowerSeries.X^3) := by
    simp only [map_ofNat, pow_one]
    ring
  rw [expand]
  have numerator : (1 : PowerSeries ℤ)-2*PowerSeries.X+28*PowerSeries.X^2-
      56*PowerSeries.X^3+32*PowerSeries.X^4 =
      1 - PowerSeries.C 2 * PowerSeries.X^1 + PowerSeries.C 28 * PowerSeries.X^2 -
      PowerSeries.C 56 * PowerSeries.X^3 + PowerSeries.C 32 * PowerSeries.X^4 := by
    simp only [map_ofNat, pow_one]
  rw [numerator]
  ext n
  simp only [map_add, map_sub, PowerSeries.coeff_C_mul, coeff_series_mul_X]
  simp only [series, PowerSeries.coeff_mk]
  rcases n with _ | _ | _ | _ | _ | n
  · simp [PowerSeries.coeff_X, a_zero]
  · simp [PowerSeries.coeff_X, a_zero, a_one]
  · simp [PowerSeries.coeff_X, a_zero, a_one, a_two]
  · simp [PowerSeries.coeff_X, a_zero, a_one, a_two, a_three]
  · simp [PowerSeries.coeff_X, a_one, a_two, a_three, a_four]
  · have h := recurrence (n+5) (by omega)
    simp only [show n+5-1=n+4 by omega, show n+5-2=n+3 by omega,
      show n+5-3=n+2 by omega] at h
    have hz : (a (n+5) : ℤ) - 7*(a (n+4) : ℤ) +
        14*(a (n+3) : ℤ) - 8*(a (n+2) : ℤ) = 0 := by omega
    simpa [PowerSeries.coeff_one, PowerSeries.coeff_X, PowerSeries.coeff_X_pow, Nat.add_assoc] using hz


end A273385Solution

theorem OMA.solution : type_of% @OMA.S_oeis_a273385.main := by
  refine ⟨?_, ?_, A273385Solution.recurrence, A273385Solution.generating_function,
    A273385Solution.same_five⟩
  · intro r hr n
    apply A273385Solution.same_rules r _ n
    simpa using hr
  · intro n hn
    refine ⟨A273385Solution.a_formula n (by omega), ?_⟩
    rw [A273385Solution.a_square n (by omega)]
    have hp : 1 ≤ 2^(n+1) := Nat.one_le_pow _ _ (by omega)
    push_cast [Nat.cast_sub hp]
    rfl
