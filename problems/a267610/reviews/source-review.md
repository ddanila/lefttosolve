# A267610 translation, correction and proof audit

Sources retrieved 2026-11-28: A267610, A267700 and A006046 full internal entries
and b-files. Source hashes are in sources/provenance.json.

| Issue | Source and proposed Lean interpretation |
| --- | --- |
| Initial state | One ON origin; every other integer position OFF |
| Rule orientation | Wolfram index 4*left+2*centre+right; bit from rule 182 |
| Row window | Positions -t through t, inclusive |
| Meaning of total | Sum row OFF counts for stages 0 through n, as in the program |
| A267700 | Its explicit digit-sum program, partial sums through index n |
| A006046 | Sum of 2^binary-weight(k) over 0≤k<n, as in its title |
| Offsets | All three sequences have offset zero |
| First claim | Explicit correction: a(n)=tree(n+1)-(n+1), in integers |
| Second claim | Unchanged GF: X²*F*(1-X)²=A*(1-X)²-X*(X+1) |
| Containment comment | Not a separate formal conjunct; omission documented in header |

## The printed claim and its correction

At n=2, the first three crops 1,111,10101 give cumulative OFF count 2.
The tree program, its independent binary-subset interpretation, DATA and b-file
all give tree(2)=2. Thus a(2)=tree(2)-2 is false in both integer and natural
arithmetic. The original statement/disproof pair and official checks are archived.

However, tree(n+1)+(n+2)=A006046(n+2) follows from the reference definitions.
The GF implies a(n)=A006046(n+2)-(2n+3), hence exactly the corrected relation.
The old conjunction therefore joined incompatible assertions. Refuting it did
not establish the meaningful GF result. The active proposal instead proves the
corrected relation and unchanged GF, with the change prominently disclosed.
The platform must approve this corrected target; it is not a literal translation
of the erroneous first formula line.

The tree entry's 2016 Sloane confirmation concerns its partial-sum/tree
interpretations, not the later 2019 cross-sequence conjecture. The explicit
program is the basis for tree, with no hardcoded sequence values. Binary weight
is the sum of base-2 digits. The subtraction 2^weight(k)-1 is nonnegative.

For the GF, multiplying F=(1/X)*(A/X-(X+1)/(1-X)^2) by X²(1-X)² gives the
formal-power-series identity. Formal Laurent series justify the divisions;
no analytical convergence or division by the nonunit X inside PowerSeries is used.

## Positive proof chain

1. Outside the radius-t interval, cells remain OFF.
2. Even cropped positions are ON. Odd positions are complements of the parity
   of choose(t+1,k+1), by the actual Rule 182 transition and Pascal recurrence.
3. Lucas modulo 2 reduces pairs of binomial entries to a smaller row. Strong
   induction and the base-2 digit recursion give 2^weight(n) odd entries.
4. Removing the two boundary entries proves offCount(t)+2=2^weight(t+1).
5. Summing rows proves the cumulative identity and corrected tree relation.
6. Decomposing the Pascal series into X²*series plus the linear-coefficient
   series proves the original generating function.

All six steps compile in the standalone proof. The official exact-target guard
and axiom audit pass. Numerics supplement, rather than replace, the all-n proof.
Narrow statement and proof imports reduce measured peak RSS from 5.86 GB to
1.99 GB despite replacing the tiny counterexample with the full positive proof.

## Prior work and verification limits

Hwang, Janson and Tsai, arXiv:2210.10968, section 4.3, Example 4.9,
explicitly identify S_{2,1}(m) with A006046(m). They then give the shifted
A267610 sequence as S_{2,1}(m)-2m+1 and A267700 as S_{2,1}(m)-m.
The surrounding text explicitly allows shifts. In our zero-based definitions,
the first uses m=n+2 and the second m=n+1. Thus their A267610 formula is
exactly a(n)=A006046(n+2)-2n-3. Combining these formulas gives the corrected
relation; the GF follows algebraically. This is known mathematics, not merely
a related discussion. The passage states these identities but does not supply
our detailed Rule 182-to-binomial-parity proof or explicitly diagnose the OEIS
typo. Our contribution is a checked formalization from the cellular-automaton
definition, not mathematical discovery. Platform eligibility remains for review.

Read on 2026-11-28 at https://arxiv.org/html/2210.10968#S4.SS3.
The retrieved HTML is archived and hashed in sources/provenance.json; this
pins the inspected content rather than inferring its date from the arXiv ID.

The openwitness.net link was reopened and verified on 2026-11-28. Its November 1
post explicitly lists A267610 as not handled (GF defined through A006046).
It also says its certificates are Python-checked, not proof-assistant proofs.
We use it only as evidence of that survey's scope, not as mathematical evidence.

The source audit and proof implementation were performed in the same session,
not by an independent reviewer. Human translation review remains required.
Official acceptance establishes compilation and allowed axioms, not that the
platform accepts an explicitly corrected statement in place of its brief.

References:
- https://oeis.org/A267610
- https://oeis.org/A267700
- https://oeis.org/A006046
- https://arxiv.org/html/2210.10968
- https://www.openwitness.net/p/10906
