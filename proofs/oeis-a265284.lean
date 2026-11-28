import OMAStatements.S_oeis_a265284
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.IntervalCases

/-!
# A265284: cumulative Rule 94 cell counts

Source: https://oeis.org/A265284
Credit: @ddanila
Statement formalization: @ecirak42.

The two row shapes alternate between pairs of updates. Counting their cells
and summing consecutive rows yields the closed forms and all remaining claims.
-/

namespace A265284
open OMA.S_oeis_a265284

/-! ## Alternating interiors and row transitions -/

/-- An alternating word consisting of n copies of the pair (b, !b). -/
def pairs (b : Bool) : Nat → List Bool
  | 0 => []
  | n+1 => b :: (!b) :: pairs b n

/-- Scanning an alternating interior preserves the scanner state. -/
lemma scan_pairs (n : Nat) (tail : List Bool) :
    scan true false (pairs true n ++ tail) =
      pairs false n ++ scan true false tail := by
  induction n with
  | zero => rfl
  | succ n ih => simpa [pairs, scan, rule94] using congrArg (fun l => false :: true :: l) ih

/-- Shift the starting bit of an alternating word by one place. -/
lemma pairs_shift (b : Bool) (n : Nat) :
    b :: pairs (!b) n = pairs b n ++ [b] := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [pairs, Bool.not_not, List.cons_append, ← ih]

/-- A full alternating pair can move from the end to the start. -/
lemma pairs_snoc (b : Bool) (n : Nat) :
    pairs b n ++ [b, !b] = b :: (!b) :: pairs b n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simpa only [pairs, List.cons_append] using
      congrArg (fun l => b :: (!b) :: l) ih

/-- Even positive rows have two black boundary cells at each end. -/
def evenRow (k : Nat) := [true,true,false] ++ pairs true (2*k) ++ [true,true]

/-- Odd rows after the first have three black boundary cells at each end. -/
def oddRow (k : Nat) := [true,true,true,false] ++ pairs true (2*k) ++ [true,true,true]

/-- One Rule 94 update takes an even row to the next odd row. -/
lemma next_even (k : Nat) : next (evenRow k) = oddRow k := by
  simp only [next, evenRow, List.append_assoc, List.cons_append, List.nil_append,
    scan]
  rw [scan_pairs]
  simpa [scan, rule94, oddRow, List.append_assoc] using
    congrArg (fun l => [true,true,true] ++ l ++ [true,true,true])
      (pairs_shift false (2*k)).symm

/-- The next update lengthens the alternating interior by two pairs. -/
lemma next_odd (k : Nat) : next (oddRow k) = evenRow (k+1) := by
  simp only [next, oddRow, List.append_assoc, List.cons_append, List.nil_append,
    scan]
  rw [scan_pairs]
  suffices h : pairs false (2*k) ++ [false,true,false,true,true] =
      false :: true :: false :: (pairs true (2*k) ++ [true,true]) by
    simpa [scan, rule94, evenRow, Nat.mul_add, pairs] using h
  have h := congrArg (fun l => l ++ [true,true]) (pairs_shift false (2*k))
  have j := congrArg (fun l => l ++ [false,true,true]) (pairs_snoc false (2*k))
  simp only [Bool.not_false, List.append_assoc, List.cons_append, List.nil_append] at h j
  rw [j, ← h]

/-- The explicit row shapes follow from the two transition lemmas. -/
lemma rows (k : Nat) : row (2*k+2) = evenRow k ∧ row (2*k+3) = oddRow k := by
  induction k with
  | zero => constructor <;> rfl
  | succ k ih =>
    have he : row (2*(k+1)+2) = evenRow (k+1) := by
      rw [show 2*(k+1)+2 = (2*k+3)+1 by omega, row, ih.2, next_odd]
    refine ⟨he, ?_⟩
    rw [show 2*(k+1)+3 = (2*(k+1)+2)+1 by omega, row, he, next_even]

/-! ## Row counts and cumulative totals -/

/-- Counting ON cells respects concatenation. -/
lemma ones_append (xs ys : List Bool) : ones (xs ++ ys) = ones xs + ones ys := by
  induction xs with
  | nil => simp [ones]
  | cons b xs ih => simp [ones, ih, add_assoc]

/-- Every alternating pair contains exactly one ON cell. -/
lemma ones_pairs (b : Bool) (n : Nat) : ones (pairs b n) = (n : Int) := by
  induction n with
  | zero => rfl
  | succ n ih => cases b <;> simp [pairs, ones, ih, add_comm]

/-- Each row has an alternating interior and a fixed number of boundary cells. -/
lemma row_counts (k : Nat) :
    ones (row (2*k+2)) = 2*(k:Int)+4 ∧ ones (row (2*k+3)) = 2*(k:Int)+6 := by
  rw [(rows k).1, (rows k).2]
  simp only [evenRow, oddRow, ones_append, ones_pairs, ones, Bool.false_eq_true,
    ↓reduceIte, Nat.cast_mul, Nat.cast_ofNat]
  constructor <;> ring

/-- Cumulative counts, with generation zero included. -/
lemma totals (k : Nat) :
    a (2*k+1) = 2*(k:Int)^2+8*k+4 ∧ a (2*k+2) = 2*(k:Int)^2+10*k+8 := by
  induction k with
  | zero => constructor <;> decide
  | succ k ih =>
    have ho : a (2*(k+1)+1) = 2*((k+1:Nat):Int)^2+8*(k+1:Nat)+4 := by
      rw [show 2*(k+1)+1 = (2*k+2)+1 by omega, a, ih.2, (row_counts k).2]
      push_cast
      ring
    refine ⟨ho, ?_⟩
    rw [show 2*(k+1)+2 = (2*(k+1)+1)+1 by omega, a, ho]
    rw [show 2*(k+1)+1+1 = 2*(k+1)+2 by omega, (row_counts (k+1)).1]
    push_cast
    ring

/-! ## Closed formulas, recurrence and generating function -/

/-- The even-index formula excludes the exceptional zeroth total. -/
lemma even_formula (n : Nat) (hn : 1 < n) (he : Even n) :
    2*a n = (n:Int)^2 + 6*n := by
  obtain ⟨k, hk⟩ := he
  obtain ⟨j, hj⟩ : ∃ j, k = j+1 := ⟨k-1, by omega⟩
  have h : n = 2*j+2 := by omega
  rw [h, (totals j).2]
  push_cast
  ring

/-- Every odd index has the same quadratic formula. -/
lemma odd_formula (n : Nat) (ho : Odd n) :
    2*a n = (n:Int)^2 + 6*n + 1 := by
  obtain ⟨k, rfl⟩ := ho
  rw [(totals k).1]
  push_cast
  ring

/-- Combine the parity cases into the signed-power formula. -/
lemma formula (n : Nat) (hn : 0 < n) :
    4*a n = 2*(n:Int)^2 + 12*n - (-1)^n + 1 := by
  rcases Nat.even_or_odd n with he | ho
  · have h : 1 < n := by obtain ⟨k, hk⟩ := he; omega
    rw [he.neg_one_pow]
    linarith [even_formula n h he]
  · rw [ho.neg_one_pow]
    linarith [odd_formula n ho]

/-- The fourth-order relation cancels the quadratic and alternating terms. -/
lemma recurrence_shift (k : Nat) :
    a (k+5) = 2*a (k+4) - 2*a (k+2) + a (k+1) := by
  have h5 := formula (k+5) (by omega)
  have h4 := formula (k+4) (by omega)
  have h2 := formula (k+2) (by omega)
  have h1 := formula (k+1) (by omega)
  norm_num [Nat.cast_add, pow_add] at h5 h4 h2 h1
  nlinarith

/-- Reindex the shifted recurrence to the source range n > 4. -/
lemma recurrence (n : Nat) (hn : 4 < n) :
    a n = 2*a (n-1) - 2*a (n-3) + a (n-4) := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k+5 := ⟨n-5, by omega⟩
  simpa only [show k+5-1 = k+4 by omega, show k+5-3 = k+2 by omega,
    show k+5-4 = k+1 by omega] using recurrence_shift k

/-- The generating-function identity is the recurrence plus its five initial coefficients. -/
lemma generating_function (n : Nat) : productCoeff n = numeratorCoeff n := by
  by_cases hn : n ≤ 4
  · interval_cases n <;> decide
  · obtain ⟨k, rfl⟩ : ∃ k, n = k+5 := ⟨n-5, by omega⟩
    have h := recurrence_shift k
    simp only [show k+5 = (k+1)+4 by omega, productCoeff]
    have hz : numeratorCoeff (k+1+4) = 0 := by
      simp [numeratorCoeff]
    rw [hz]
    have h4 : k+1+3 = k+4 := by omega
    have h2 : k+1+1 = k+2 := by omega
    rw [h4, h2]
    linarith

end A265284

/-- All five conjectures, against the exact upstream statement. -/
theorem OMA.solution : type_of% @OMA.S_oeis_a265284.main :=
  ⟨A265284.formula, A265284.even_formula, A265284.odd_formula,
    A265284.recurrence, A265284.generating_function⟩

