Title: Prove oeis-a334502.R1.H2

Proves the width class n % 4 = 1 for n ≥14. An explicit cell model is verified
against the single seed and the Rule 62 recurrence, including cyclic boundaries.
Induction identifies it with the statement's orbit. At time 12*n, it returns after
three steps and differs after one step at cell 2.

The model was discovered computationally; Lean checks its properties independently.
No external solver result is assumed. The unchanged step file passes local platform
lint and checker with only propext, Classical.choice and Quot.sound. Resource
measurements and reproducible generation are retained in the local project.
