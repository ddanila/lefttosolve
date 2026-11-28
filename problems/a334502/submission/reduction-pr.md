Title: Reduce oeis-a334502 to four width classes

This reduction establishes the original eventual-period and generating-function
claims from four hypotheses on the Rule 62 orbit. For each width ≥14, partitioned
by its residue modulo four, the hypothesis asks for a three-step return and a
one-step inequality. The reduction handles the finite exceptional widths and
shows why these certificates determine the minimal eventual period.

Splitting by width modulo four balances the residue cases across four independently
checked files: a single-file attempt peaked at 9.26 GB locally, above the
platform’s advertised roughly 7 GB budget. Here “period” means the period of
the whole labelled ring, as defined in the merged statement.

The statement is unchanged. Local platform lint and checker accept the reduction,
with only propext, Classical.choice and Quot.sound.
