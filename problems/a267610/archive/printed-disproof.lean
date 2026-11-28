import OMAStatements.S_oeis_a267610

/-!
# A267610: counterexample to the printed A267700 relation

Source: https://oeis.org/A267610
Credit: @ddanila

At n=2, the first three Rule 182 crops are 1, 111, and 10101.
Their cumulative OFF count is 2. A267700(2)=2, so the printed
right-hand side A267700(2)-2 is 0. Both sequences have offset zero.
This refutes the conjunction via its first claim; it does not refute the
separate generating-function claim or assert an all-n corrected formula.
-/
namespace A267610
open OMA.S_oeis_a267610

/-- The cumulative cellular-automaton count at the first failing index. -/
lemma count_two : a 2 = 2 := by decide

/-- The referenced tree sequence at the same index. -/
lemma tree_two : tree 2 = 2 := by decide

end A267610

/-- The unchanged printed relation fails at n=2. -/
theorem OMA.disproof : ¬ (type_of% @OMA.S_oeis_a267610.main) := by
  intro h
  have bad := h.1 2
  rw [A267610.count_two, A267610.tree_two] at bad
  norm_num at bad
