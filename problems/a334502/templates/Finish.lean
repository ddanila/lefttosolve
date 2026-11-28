import Bridge
import Lemmas
namespace A334502Local
open OMA.S_oeis_a334502

lemma localRule_true (l c r : Bool) :
    localRule l c r = true ↔ (¬l=true ∧ (c=true ∨ r=true)) ∨ (l=true ∧ ¬c=true) := by
  cases l <;> cases c <;> cases r <;> decide

/-- A cellwise recurrence and the seed characterize every row on the ring. -/
lemma row_model (n : ℕ) (hn : 1 < n) (C : ℕ → ℕ → Prop)
    (initial : ∀ i, i<n → (C 0 i ↔ i=0))
    (update : ∀ t i, i<n → (C (t+1) i ↔
      (¬ C t (prev n i) ∧ (C t i ∨ C t (next n i))) ∨
      (C t (prev n i) ∧ ¬ C t i))) :
    ∀ t i, i<n → ((row n t).getLsbD i=true ↔ C t i) := by
  intro t
  induction t with
  | zero =>
    intro i hi
    change (1#n).getLsbD i=true ↔ C 0 i
    simpa only [BitVec.getLsbD_one,
      show 0<n from by omega, decide_true, Bool.true_and, decide_eq_true_eq] using
      (initial i hi).symm
  | succ t ih =>
    intro i hi
    rw [row_succ, step_bit hn _ i hi, localRule_true,
      ih (prev n i) (prev_lt (by omega) hi), ih i hi,
      ih (next n i) (next_lt (by omega) hi)]
    exact (update t i hi).symm

/-- On a three-cycle, excluding a fixed point also excludes a two-step return. -/
lemma certificate_three (n T : ℕ) (cycle : row n (T+3)=row n T)
    (different : row n (T+1)≠row n T) : Certificate n T 3 := by
  refine ⟨cycle, ?_⟩
  intro p hp
  have h := Finset.mem_Ioo.mp hp
  have : p=1 ∨ p=2 := by omega
  rcases this with rfl | rfl
  · exact different
  · intro he
    have hh := congrArg (@step n) he
    rw [←row_succ, ←row_succ] at hh
    have eq : T+2+1=T+3 := by omega
    rw [eq, cycle] at hh
    exact different hh.symm

lemma certificate_of_model (n T : ℕ) (hn : 2<n) (C : ℕ → ℕ → Prop)
    (bridge : ∀ t i, i<n → ((row n t).getLsbD i=true ↔ C t i))
    (cycle : ∀ i, i<n → (C (T+3) i ↔ C T i))
    (different : ¬ (C (T+1) 2 ↔ C T 2)) : Certificate n T 3 := by
  apply certificate_three
  · apply BitVec.eq_of_getLsbD_eq
    intro i hi
    apply Bool.eq_iff_iff.mpr
    exact (bridge (T+3) i hi).trans ((cycle i hi).trans (bridge T i hi).symm)
  · intro he
    apply different
    rw [← bridge (T+1) 2 hn, ← bridge T 2 hn, he]
end A334502Local
