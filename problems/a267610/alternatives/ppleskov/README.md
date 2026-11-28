# Alternative target: statement PR #33330 by @ppleskov

This is a checked, standalone adaptation for the rival GF-only statement over ℚ.
The archived statement is byte-identical to commit
`e3866c4c5065a31da8119cf1759d1e1f36f046b3`. Neither file has been published by us.

The proof retains our verified model in a separate namespace. Four bridges
identify the cell states, cumulative counts, Pascal counts, and mapped power
series. The exact platform target is audited; the proof does not import or use
our proposed statement's main theorem. The A267700 relation is not part of this
alternative target. No first-discovery claim is made.

Run `python3 problems/a267610/check_alternative.py`. The official checker accepts
with only propext, Classical.choice and Quot.sound. Latest check: 9.29 s,
5,775,458,304 bytes peak macOS RSS (the statement imports all of Mathlib).
The proof has 8,267 counted characters. Reports and source hashes are in
`../../reviews/ppleskov-*.json` and `../../reviews/ppleskov-lean-check.txt`.

The watcher selects by exact merged-statement hash: our #35416 target uses the
original proof, and #33330 uses this adapter. Unknown targets stop for review.
A dedicated proof branch avoids overwriting or being blocked by our statement PR.
