import LT2D.Instances.LB4_R131.M
import LT2D.Groups.W2B_G7.C
/-
  A273676 (Rule 833), R. J. Mathar's line "a(n) = A270222(n) for n>1" (Chair B, 19 Nov 2026). Hand-written. It uses the Rule 833
  table of W2B_G7_C and LT2D.a270222_formula of the posted Rule 131 file (LB4_R131_M), both closed forms 1 - 4*2^n + 3*4^n.
-/
namespace LT2D

/-- A273676 (Rule 833): %F Conjecture: a(n) = A270222(n) for n>1. - R. J. Mathar, May 30 2016
A270222 is the OEIS entry whose main rule is Rule 131 (Chair C's map: read id r-mwmmwzse-d43mbh). Rule 833 has the same count as
Rule 131 at stage 2^n - 1 for every n >= 2 (the Rule 833 formula holds from n = 2). Proof: vn_count for the Rule 833 table
(3*4^n - 4*2^n + 1, n >= 2) and LT2D.a270222_formula (1 - 2^(2+n) + 3*4^n, n >= 1). -/
theorem a273676_eq_a270222 (n : Nat) (hn : 2 ≤ n) : onCount 833 (2 ^ n - 1) = onCount 131 (2 ^ n - 1) := by
  have ha := vn_count VN.G7_833.tab 833 1007 1 3 (-4) (1) 2 2 VN.G7_833.ok2 VN.G7_833.ok1 VN.G7_833.okr n hn
  have hb := a270222_formula n (by omega)
  have key : (onCount 833 (2 ^ n - 1) : Int) = onCount 131 (2 ^ n - 1) := by
    rw [hb]; ring_nf at ha ⊢; linarith
  exact_mod_cast key

end LT2D