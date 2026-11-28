# A267610 translation and counterexample audit

Sources retrieved 2026-11-28: A267610, A267700 and A006046 full internal entries
and their b-files. SHA-256 hashes are in sources/provenance.json.

| Issue | Source and Lean interpretation |
| --- | --- |
| Initial state | One ON origin; every other integer position OFF |
| Rule orientation | Wolfram index 4*left+2*centre+right; bit from rule 182 |
| Row window | Positions -t through t, inclusive |
| Meaning of total | Sum row OFF counts for stages 0 through n, as in the program |
| A267700 | Its explicit digit-sum program, partial sums through index n |
| A006046 | Sum of 2^binary-weight(k) over 0≤k<n, as in its title |
| Indices | All three sequences have offset zero; no shift inserted |
| First conjecture | Integer equality a(n)=tree(n)-n for every natural n |
| Second conjecture | X²*F*(1-X)²=A*(1-X)²-X*(X+1) over PowerSeries integers |

The first formula's integer subtraction avoids truncation. At the witness,
both natural and integer subtraction give 2−2=0, so this choice cannot create
the counterexample. In the tree definition each term 2^weight(k)−1 is nonnegative.
The binary weight is the sum of base-2 digits, not their list length.

The GF rearrangement comes from F=(1/X)*(A/X-(X+1)/(1-X)^2).
Multiplying by X²(1-X)² gives the stated identity. Interpret division by X
through the formal Laurent series embedding; multiplication by this nonzero
factor is injective, and (1-X)² is a unit. No analytical convergence is assumed.

The tree entry's 2016 Sloane confirmation concerns its partial-sum/tree
interpretations. It does not certify the later 2019 cross-sequence conjecture.
The definition follows the entry's explicit Mathematica program; independent
binary-subset pair counting and all archived terms agree with it.

The informal binary-containment comment on A267610 suggests the corrected
index n+1. We preserve the two formula claims selected by the platform brief,
not an amended claim. A267610(2)=2 and A267700(2)=2 are confirmed by Lean,
direct simulation, both entries' DATA, and their b-files. No sequence values
are hardcoded into the Lean definitions.

## Prior work and limits

Searches for A267610 and A267700 found no matching platform PR. Hwang, Janson
and Tsai, arXiv:2210.10968, section 4, discuss A267610 among divide-and-conquer
applications. That is relevant prior mathematics, not a proof of the false
unshifted relation. The inspected passage did not explicitly refute that
relation. A November 1 certificate survey explicitly leaves A267610 unhandled.
This was a limited search, not an exhaustive novelty audit. Do not claim first
discovery. The original GF may follow from known results; it is not refuted here.

This audit was performed in the same session as the implementation; it is not
an independent-agent review. The statement still requires the platform's human
translation review. Official local acceptance checks compilation, not meaning.

References:
- https://oeis.org/A267610
- https://oeis.org/A267700
- https://oeis.org/A006046
- https://arxiv.org/html/2210.10968
- https://www.openwitness.net/p/10906
