import LT2D.VN.M2
import LT2D.Groups.W2B_G7.C
/-
  Group W2B_G7, Mathlib file: one theorem per OEIS statement (A273676, A273767, A273828, A273832, A273848). The formula
  theorems call LT2D.vn_count (VN_M2) and the twin-count theorems call LT2D.vn_twin_count (VN_M1); emit_instance.py
  generates them, except the proof of a273767_formula, a hand patch (rewrite 2^(n+1) = 2 * 2^n and 4^n = (2^n)^2, then
  linarith). Written by W2B/gen/g7.py from the instance numbers: Rule 929 = Rule 913 at every n (kernel evaluation of
  onCount for n < 3, both closed forms for n >= 3), Rules 937, 945, 953 (twins of Rule 929) = Rule 913, and
  Rule 961 = Rule 3 for n >= 2 (both closed forms).
-/
namespace LT2D

/-- A273676 (Rule 833): %F Conjecture: a(n) = 3*4^n - 4*2^n + 1, n>1. - Lars Blomberg, Jul 23 2016 -/
theorem a273676_formula (n : Nat) (hn : 2 ≤ n) :
    (onCount 833 (2 ^ n - 1) : Int) = 3 * 4 ^ n - 4 * 2 ^ n + 1 := by
  have h := vn_count VN.G7_833.tab 833 1007 1 3 (-4) (1) 2 2 VN.G7_833.ok2 VN.G7_833.ok1 VN.G7_833.okr n (by omega)
  first | linarith | (ring_nf at h ⊢; linarith)

/-- A273676: %C Conjecture: Rule 849 also generates this sequence. - Lars Blomberg, Jul 23 2016 -/
theorem a273676_r849_count_eq_833 (n : Nat) : onCount 849 (2 ^ n - 1) = onCount 833 (2 ^ n - 1) :=
  vn_twin_count VN.G7_833.tab 833 849 1007 VN.G7_833.ok2 VN.G7_833.ok1 (List.all_eq_true.mp VN.G7_833.twins 849 (by decide)) _

/-- A273767 (Rule 913): %F Conjecture: a(n) = (2^(n+1) - 1)^2, n>2. - Lars Blomberg, Jul 24 2016 -/
theorem a273767_formula (n : Nat) (hn : 3 ≤ n) :
    (onCount 913 (2 ^ n - 1) : Int) = (2 ^ (n + 1) - 1) ^ 2 := by
  have h := vn_count VN.G7_913.tab 913 1015 1 4 (-4) (1) 3 3 VN.G7_913.ok2 VN.G7_913.ok1 VN.G7_913.okr n (by omega)
  have h2 : (2 : Int) ^ (n + 1) = 2 * 2 ^ n := by ring
  have h4 : (4 : Int) ^ n = (2 ^ n) ^ 2 := by
    rw [← pow_mul, mul_comm, pow_mul]; norm_num
  rw [h2]
  rw [h4] at h
  linarith

/-- A273767: %C Conjecture: Rules 921, 929, 937, 945 and 953 also generate this sequence. - Lars Blomberg, Jul 24 2016 -/
theorem a273767_r921_count_eq_913 (n : Nat) : onCount 921 (2 ^ n - 1) = onCount 913 (2 ^ n - 1) :=
  vn_twin_count VN.G7_913.tab 913 921 1015 VN.G7_913.ok2 VN.G7_913.ok1 (List.all_eq_true.mp VN.G7_913.twins 921 (by decide)) _

/-- A273828 (Rule 950): %F Conjecture: a(n) = 2*4^n - 2*2^n - 3, n>2. - Lars Blomberg, Jul 25 2016 -/
theorem a273828_formula (n : Nat) (hn : 3 ≤ n) :
    (onCount 950 (2 ^ n - 1) : Int) = 2 * 4 ^ n - 2 * 2 ^ n - 3 := by
  have h := vn_count VN.G7_950.tab 950 959 1 2 (-2) (-3) 3 3 VN.G7_950.ok2 VN.G7_950.ok1 VN.G7_950.okr n (by omega)
  first | linarith | (ring_nf at h ⊢; linarith)

/-- A273828: %C Conjecture: Rule 1014 also generates this sequence. - Lars Blomberg, Jul 25 2016 -/
theorem a273828_r1014_count_eq_950 (n : Nat) : onCount 1014 (2 ^ n - 1) = onCount 950 (2 ^ n - 1) :=
  vn_twin_count VN.G7_950.tab 950 1014 959 VN.G7_950.ok2 VN.G7_950.ok1 (List.all_eq_true.mp VN.G7_950.twins 1014 (by decide)) _

/-- A273832 (Rule 961): %F Conjecture: a(n) = 4*4^n - 4*2^n - 3, n>1. - Lars Blomberg, Jul 25 2016 -/
theorem a273832_formula (n : Nat) (hn : 2 ≤ n) :
    (onCount 961 (2 ^ n - 1) : Int) = 4 * 4 ^ n - 4 * 2 ^ n - 3 := by
  have h := vn_count VN.G7_961.tab 961 1007 1 4 (-4) (-3) 2 2 VN.G7_961.ok2 VN.G7_961.ok1 VN.G7_961.okr n (by omega)
  first | linarith | (ring_nf at h ⊢; linarith)

/-- A273832: %C Conjecture: Rule 977 also generates this sequence. - Lars Blomberg, Jul 25 2016 -/
theorem a273832_r977_count_eq_961 (n : Nat) : onCount 977 (2 ^ n - 1) = onCount 961 (2 ^ n - 1) :=
  vn_twin_count VN.G7_961.tab 961 977 1007 VN.G7_961.ok2 VN.G7_961.ok1 (List.all_eq_true.mp VN.G7_961.twins 977 (by decide)) _

/-- A273848 (Rule 969): %F Conjecture: a(n) = 4*4^n - 4*2^n + 1, n>2. - Lars Blomberg, Jul 25 2016 -/
theorem a273848_formula (n : Nat) (hn : 3 ≤ n) :
    (onCount 969 (2 ^ n - 1) : Int) = 4 * 4 ^ n - 4 * 2 ^ n + 1 := by
  have h := vn_count VN.G7_969.tab 969 1007 1 4 (-4) (1) 3 3 VN.G7_969.ok2 VN.G7_969.ok1 VN.G7_969.okr n (by omega)
  first | linarith | (ring_nf at h ⊢; linarith)

/-- A273848: %C Conjecture: Rule 985 also generates this sequence. - Lars Blomberg, Jul 25 2016 -/
theorem a273848_r985_count_eq_969 (n : Nat) : onCount 985 (2 ^ n - 1) = onCount 969 (2 ^ n - 1) :=
  vn_twin_count VN.G7_969.tab 969 985 1007 VN.G7_969.ok2 VN.G7_969.ok1 (List.all_eq_true.mp VN.G7_969.twins 985 (by decide)) _

/-- A273767: %C Conjecture: Rules 921, 929, 937, 945 and 953 also generate this sequence. - Lars Blomberg, Jul 24 2016
Rule 929 has the same count as Rule 913 at every stage 2^n - 1 (separate table: Rule 929 is not a twin of Rule 913 on the
used mask U = 999). n < 3: kernel evaluation (g = 0, 1, 3); n >= 3: vn_count for both tables, the same closed form
a(n) = 4*4^n - 4*2^n + 1. -/
theorem a273767_r929_count_eq_913 (n : Nat) : onCount 929 (2 ^ n - 1) = onCount 913 (2 ^ n - 1) := by
  rcases Nat.lt_or_ge n 3 with hn | hn
  · rcases n with _ | _ | _ | n
    · decide +kernel
    · decide +kernel
    · decide +kernel
    · omega
  · have ha := vn_count VN.G7_929.tab 929 999 1 4 (-4) (1) 3 3 VN.G7_929.ok2 VN.G7_929.ok1 VN.G7_929.okr n hn
    have hb := vn_count VN.G7_913.tab 913 1015 1 4 (-4) (1) 3 3 VN.G7_913.ok2 VN.G7_913.ok1 VN.G7_913.okr n hn
    have key : (onCount 929 (2 ^ n - 1) : Int) = onCount 913 (2 ^ n - 1) := by linarith
    exact_mod_cast key

/-- A273767: %C Conjecture: Rules 921, 929, 937, 945 and 953 also generate this sequence. - Lars Blomberg, Jul 24 2016
Rule 937 is a twin of Rule 929 (same diagram, kernel check `twins` of the Rule 929 table), and Rule 929 has the same count as Rule 913. -/
theorem a273767_r937_count_eq_913 (n : Nat) : onCount 937 (2 ^ n - 1) = onCount 913 (2 ^ n - 1) :=
  (vn_twin_count VN.G7_929.tab 929 937 999 VN.G7_929.ok2 VN.G7_929.ok1 (List.all_eq_true.mp VN.G7_929.twins 937 (by decide)) _).trans
    (a273767_r929_count_eq_913 n)

/-- A273767: %C Conjecture: Rules 921, 929, 937, 945 and 953 also generate this sequence. - Lars Blomberg, Jul 24 2016
Rule 945 is a twin of Rule 929 (same diagram, kernel check `twins` of the Rule 929 table), and Rule 929 has the same count as Rule 913. -/
theorem a273767_r945_count_eq_913 (n : Nat) : onCount 945 (2 ^ n - 1) = onCount 913 (2 ^ n - 1) :=
  (vn_twin_count VN.G7_929.tab 929 945 999 VN.G7_929.ok2 VN.G7_929.ok1 (List.all_eq_true.mp VN.G7_929.twins 945 (by decide)) _).trans
    (a273767_r929_count_eq_913 n)

/-- A273767: %C Conjecture: Rules 921, 929, 937, 945 and 953 also generate this sequence. - Lars Blomberg, Jul 24 2016
Rule 953 is a twin of Rule 929 (same diagram, kernel check `twins` of the Rule 929 table), and Rule 929 has the same count as Rule 913. -/
theorem a273767_r953_count_eq_913 (n : Nat) : onCount 953 (2 ^ n - 1) = onCount 913 (2 ^ n - 1) :=
  (vn_twin_count VN.G7_929.tab 929 953 999 VN.G7_929.ok2 VN.G7_929.ok1 (List.all_eq_true.mp VN.G7_929.twins 953 (by decide)) _).trans
    (a273767_r929_count_eq_913 n)

/-- A273832 (Rule 961): %F Conjecture: a(n) = A269911(n) for n>1. - R. J. Mathar, Jun 02 2016
A269911 is the OEIS entry whose rule is Rule 3 (Chair C's map: A269911 is the entry whose main rule is Rule 3, read id r-mwmmcjss-dm2ppj). From the two closed forms
(Rule 961: n >= 2; Rule 3: n >= 1), Rules 961 and 3 have the same count at stage 2^n - 1 for every n >= 2. -/
theorem a273832_eq_a269911 (n : Nat) (hn : 2 ≤ n) : onCount 961 (2 ^ n - 1) = onCount 3 (2 ^ n - 1) := by
  have ha := vn_count VN.G7_961.tab 961 1007 1 4 (-4) (-3) 2 2 VN.G7_961.ok2 VN.G7_961.ok1 VN.G7_961.okr n hn
  have hb := vn_count VN.G7_3.tab 3 935 1 4 (-4) (-3) 1 1 VN.G7_3.ok2 VN.G7_3.ok1 VN.G7_3.okr n (by omega)
  have key : (onCount 961 (2 ^ n - 1) : Int) = onCount 3 (2 ^ n - 1) := by linarith
  exact_mod_cast key

end LT2D