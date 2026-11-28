Prove all four A273539 conjectures against the statement's direct cellular-automaton
definition. At every positive sampled time t=2^n−1, the OFF cells are exactly the
diamond |x|+|y|=t. Counting its 4t points gives the formula; the recurrence and
formal generating function follow. A parity invariant proves equality with the
three alternative rules at every generation.

The geometric step uses a finite binary machine. Lean checks 451 recurrence
certificates and their 3,608 transitions, then a ten-state boundary induction.
A separate coordinate bridge relates this machine to the original evolution
from time 1. All finite checks use kernel reduction, with closure checks split
into blocks; no native decision procedure or added axiom is used.

Local validation: official checker accepted; exact target type; only propext,
Classical.choice and Quot.sound; independent direct and cyclic simulations;
all 16 source terms checked. Re-run and update this paragraph against the exact
merged statement before opening the proof PR.
