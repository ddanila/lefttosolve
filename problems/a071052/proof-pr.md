Prove A071052's zero-count recurrence for every natural n, including zero,
against the unchanged merged statement by @seanm27lol.

Two Rule 150 updates cancel repeated XOR terms, leaving parent offsets 4, 2 and
0. Induction gives `cell (2*n) (2*i) = cell n i` and
`cell (2*n) (2*i+1) = false` for every integer i. Counting the row's 2n+1 even
positions and 2n odd positions proves `zeroCount (2*n) = zeroCount n + 2*n`.

The unmodified official checker accepts the exact root-qualified target with
only propext, Classical.choice and Quot.sound. Independent truth-table and
F₂-polynomial simulations agree through time 256, including all 67 archived
terms. Local checking took 3.20 seconds at about 1.38 GB macOS peak RSS.

Related work: @agchua's pending #21850 uses polynomial coefficients against a
different proposed statement. The direct XOR proof here counts 1,481 characters
versus 2,193 in that file, 32.5% fewer, under tools/prooflen.py. This comparison
is not a claim to replace a currently accepted proof or to first discovery.
No proof is present on upstream main at submission preflight.
