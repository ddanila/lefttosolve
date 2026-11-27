# Author source review — A267623

Reviewed the archived full OEIS entry and platform brief against the statement.
This is not a fresh independent reviewer report.

The Mathematica program constructs `mc` from the middle cell of each row, then
applies `FromDigits[Take[mc,k]]`. Therefore index n means n+1 time samples,
not n spatial cells, and the base is decimal. The infinite background is OFF
initially, but becomes ON at time 1: a permanently OFF finite boundary would
be incorrect. Integer-indexed rows avoid this boundary error.

The Maple code assigns weight 4 to c+1 and weight 1 to c-1, reflecting the
Mathematica/Wolfram spatial coordinates. For the symmetric one-cell seed,
reflection sends each row to the other convention's row and fixes position 0.
The centre time sequence agrees. The checker uses the Wolfram truth table
without the moving-hole simplification or recurrence.

The source's requested recurrence has n>2, preserved literally. All subtraction
in the recurrence is in ℤ. The generating function is a formal identity;
the denominator constant term is 1, so it is invertible. Both conjectures are
conjoined, and the definitions assume neither. The empirical closed forms
elsewhere in the OEIS entry are not part of the platform brief.

Before publication, request a fresh independent statement review as done for
A267622; machine compilation alone does not establish source faithfulness.
