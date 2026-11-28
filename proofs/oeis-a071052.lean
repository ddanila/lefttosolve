import OMAStatements.S_oeis_a071052

/-!
# A071052: Number of 0's in n-th row of triangle in A071036 (Rule 150)

Source: https://oeis.org/A071052
Credit: @ddanila
Statement formalization: @seanm27lol.

Two Rule 150 steps cancel the repeated XOR terms. Induction then shows that
row 2n is row n with an OFF cell between each pair of adjacent cells.
Splitting the finite row into even and odd positions proves the recurrence.
-/

namespace A071052
open OMA.S_oeis_a071052

/-- In two steps, every repeated XOR term cancels. -/
lemma xor_cancel : ∀ a b c d e : Bool,
    xor (xor (xor (xor a b) c) (xor (xor b c) d)) (xor (xor c d) e) =
      xor (xor a c) e := by
  decide

/-- Two time steps have spatial offsets 4, 2 and 0. -/
lemma two_steps (n : Nat) (i : Int) :
    cell (n+2) i = xor (xor (cell n (i-4)) (cell n (i-2))) (cell n i) := by
  simp only [cell, show i-2-2 = i-4 by omega, show i-2-1 = i-3 by omega,
    show i-1-2 = i-3 by omega, show i-1-1 = i-2 by omega]
  exact xor_cancel _ _ _ _ _

/-- Time doubling preserves even-position cells and turns all odd positions OFF. -/
lemma doubled (n : Nat) :
    (∀ i : Int, cell (2*n) (2*i) = cell n i) ∧
    (∀ i : Int, cell (2*n) (2*i+1) = false) := by
  induction n with
  | zero =>
    constructor
    · intro i
      simp only [cell]
      congr 1
      exact propext (by omega)
    · intro i
      simp [cell, show 2*i+1 ≠ 0 by omega]
  | succ n ih =>
    constructor <;> intro i <;>
      rw [show 2*(n+1) = 2*n+2 by omega, two_steps]
    · rw [show 2*i-4 = 2*(i-2) by omega, show 2*i-2 = 2*(i-1) by omega,
        ih.1, ih.1, ih.1]
      rfl
    · rw [show 2*i+1-4 = 2*(i-2)+1 by omega, show 2*i+1-2 = 2*(i-1)+1 by omega,
        ih.2, ih.2, ih.2]
      rfl

/-- Pair even positions with the intervening OFF cells, retaining the last even cell. -/
lemma count_doubled (n m : Nat) :
    (∑ i ∈ Finset.range (2*m+1), if cell (2*n) (i:Int) then 0 else 1) =
      (∑ i ∈ Finset.range (m+1), if cell n (i:Int) then 0 else 1) + m := by
  induction m with
  | zero =>
    have h : cell (2*n) 0 = cell n 0 := by simpa using (doubled n).1 0
    simp [h]
  | succ m ih =>
    rw [show 2*(m+1)+1 = (2*m+1)+1+1 by omega,
      Finset.sum_range_succ, Finset.sum_range_succ, ih,
      Finset.sum_range_succ (fun i => if cell n (i:Int) then 0 else 1) (m+1)]
    have he := (doubled n).1 (m+1)
    have ho := (doubled n).2 m
    simp only [Int.natCast_add, Int.natCast_mul, show ((2:Nat):Int) = 2 from rfl]
    simp only [Int.natCast_one, show 2*(m:Int)+2 = 2*((m:Int)+1) by omega,
      he, ho, Bool.false_eq_true, ↓reduceIte]
    omega

end A071052

/-- The exact zero-count recurrence from the merged upstream statement. -/
theorem OMA.solution : type_of% @OMA.S_oeis_a071052.main := by
  intro n
  exact A071052.count_doubled n (2*n)

