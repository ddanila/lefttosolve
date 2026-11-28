Proves the exact rational generating-function identity in the merged statement from #33330.

This revision removes the binary-weight/Lucas calculation. Pascal's recurrence
identifies the OFF cells directly with odd binomial entries, which is precisely
how the merged statement defines A006046. The proof uses the statement's cell
function and works over ℚ throughout, removing the duplicate automaton and the
integer-series mapping. The A267700 relation is outside this target.

The file has 5,553 counted characters, down from our previous 8,267 (32.8%).
Compared with the 6,137 characters in competing PR #38793 at commit
8bf35bd8fdd5c8b1e7831215ff2be36680e21bbe, it is 9.5% shorter and meets the
platform's replacement threshold. This is our independently developed proof;
no proof text from #38793 was used.

Validation: exact-target audit and current official checker; only propext,
Classical.choice and Quot.sound. No dependence on the unproved statement theorem.

Prior mathematics: Hwang, Janson and Tsai, arXiv:2210.10968, section 4.3,
Example 4.9, gives the cumulative identity. This formalizes known mathematics;
no first mathematical proof is claimed.
https://arxiv.org/html/2210.10968#S4.SS3
