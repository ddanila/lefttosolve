import A283508

-- Direct computations from the rule, independent of the closed-form proof.
example : A283508.a 0 = 1 := by decide
example : A283508.a 1 = 10 := by decide
example : A283508.a 2 = 101 := by decide
example : A283508.a 3 = 1011 := by decide

#eval (List.range 7).map A283508.a
#print axioms A283508.rule_readable
#print axioms A283508.window_correct
#print axioms A283508.observed_window_correct
#print axioms A283508.evolve_local
#print axioms A283508.lift_initial
#print axioms A283508.lift_step
#print axioms A283508.lift_evolve
#print axioms A283508.periodic_agrees
#print axioms A283508.observed_torus_correct
