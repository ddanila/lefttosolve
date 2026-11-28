import OMAStatements.S_oeis_a334502
import Mathlib.Tactic.NormNum

namespace A334502Local
open OMA.S_oeis_a334502

/-- Boolean local rule, independent of the bit-vector representation. -/
def localRule (l c r : Bool) : Bool := (!l && (c || r)) || (l && !c)

def prev (n i : ℕ) : ℕ := if i = 0 then n-1 else i-1
def next (n i : ℕ) : ℕ := if i+1 = n then 0 else i+1

/-- Rotations implement the two neighbours on the labelled ring. -/
lemma step_bit {n : ℕ} (hn : 1 < n) (w : BitVec n) (i : ℕ) (hi : i < n) :
    (step w).getLsbD i =
      localRule (w.getLsbD (prev n i)) (w.getLsbD i) (w.getLsbD (next n i)) := by
  simp only [step, localRule, BitVec.getLsbD_or, BitVec.getLsbD_and,
    BitVec.getLsbD_not, BitVec.getLsbD_rotateLeft_of_le hn,
    BitVec.getLsbD_rotateRight_of_lt hn, hi, decide_true, Bool.true_and]
  by_cases h0 : i = 0
  · subst i
    simp [prev, next, show 1 ≠ n by omega, show 0 < n-1 by omega]
  · by_cases he : i+1 = n
    · have h : i = n-1 := by omega
      simp [prev, next, h, show ¬n-1 < 1 by omega,
        show n-1 ≠ 0 by omega, show n-1+1 = n by omega]
    · simp [prev, next, h0, he, show ¬i < 1 by omega,
        show i < n-1 by omega, Nat.add_comm]

lemma row_succ (n t : ℕ) : row n (t+1) = step (row n t) := by
  exact Function.iterate_succ_apply' _ _ _

lemma prev_lt {n i : ℕ} (hn : 0 < n) (hi : i < n) : prev n i < n := by
  unfold prev; split <;> omega

lemma next_lt {n i : ℕ} (hn : 0 < n) (hi : i < n) : next n i < n := by
  unfold next; split <;> omega

end A334502Local
