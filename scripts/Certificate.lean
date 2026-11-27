-- Appended to the standalone source by check.py, with the local library imported.
-- Recursive definitions are connected by induction; simple definitions by reduction.
namespace OMA.S_oeis_a283508
theorem bit_consistent : bit = _root_.A283508.bit := rfl
theorem rule_consistent : rule = _root_.A283508.rule := rfl
theorem neighbors_consistent : neighbors = _root_.A283508.neighbors := rfl
theorem step_consistent : step = _root_.A283508.step := rfl
theorem initial_consistent : initial = _root_.A283508.initial := rfl
theorem evolve_consistent : evolve = _root_.A283508.evolve := by
  funext g n
  induction n with
  | zero => rfl
  | succ n ih => simp only [evolve, _root_.A283508.evolve, ih, step_consistent]
theorem state_consistent : state = _root_.A283508.state := by
  funext n
  simp only [state, _root_.A283508.state, evolve_consistent, initial_consistent]
theorem encode_consistent : encode = _root_.A283508.encode := by
  funext g n
  induction n with
  | zero => rfl
  | succ n ih => simp only [encode, _root_.A283508.encode, ih, bit_consistent]
theorem sequence_consistent : a = _root_.A283508.a := by
  funext n
  simp only [a, _root_.A283508.a, encode_consistent, state_consistent]
theorem rule187_consistent : A267623.rule = _root_.A267623.rule := rfl
theorem step187_consistent : A267623.step = _root_.A267623.step := rfl
theorem initial187_consistent : A267623.initial = _root_.A267623.initial := rfl
theorem state187_consistent : A267623.state = _root_.A267623.state := by
  funext n
  induction n with
  | zero => rfl
  | succ n ih => simp only [A267623.state, _root_.A267623.state, ih, step187_consistent]
theorem sequence187_consistent : A267623.a = _root_.A267623.a := by
  funext n
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [A267623.a, _root_.A267623.a, ih, state187_consistent]
    rfl
theorem series_consistent : series = _root_.A283508.series := by
  simp only [series, _root_.A283508.series, sequence_consistent]

theorem certified :
  (series * ((1 - PowerSeries.X) * (1 - 10 * PowerSeries.X)) =
    1 - PowerSeries.X + PowerSeries.X^2) ∧
  (∀ n : ℕ, 0 < n → a n = (91 * 10^n - 10) / 90) ∧
  (∀ n : ℕ, 2 < n → (a n : ℤ) = 11 * (a (n-1) : ℤ) - 10 * (a (n-2) : ℤ)) ∧
  (∀ n : ℕ, a n = A267623.a n) := by
  rw [series_consistent, sequence_consistent, sequence187_consistent]
  exact ⟨_root_.A283508.generating_function, _root_.A283508.formula,
    _root_.A283508.recurrence_int, _root_.A267623.sequence_eq⟩

-- Definitional equality of theorem types is checked without using main as evidence.
example : type_of% main := certified
#print axioms certified
end OMA.S_oeis_a283508
