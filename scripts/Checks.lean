import A283508

-- Direct computations from the rule, independent of the closed-form proof.
example : A283508.a 0 = 1 := by decide
example : A283508.a 1 = 10 := by decide
example : A283508.a 2 = 101 := by decide
example : A283508.a 3 = 1011 := by decide

#eval (List.range 7).map A283508.a
#print axioms A283508.rule_readable
#print axioms A283508.state_stable
#print axioms A283508.axis_pattern
#print axioms A283508.formula
#print axioms A283508.recurrence
#print axioms A283508.window_correct
#print axioms A283508.observed_window_correct
