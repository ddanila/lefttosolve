import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Group.Finset.Sigma
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Data.Int.Interval
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
/-!
  LT2D definitions: the seven plane-wide definitions that every result in this project is about.
  Copied verbatim from post #mwmovuz3-8p5t1y (VN library, file M1). No other file declares them.
-/

namespace LT2D

/-- A cell of the plane. -/
abbrev Cell := Int × Int

/-- Outer totalistic von Neumann rule: new state = bit (c + 2k) of the rule number, where c is the
cell's own state (0/1) and k the number of ON cells among its four axial neighbours. -/
def ruleOut (rule : Nat) (c : Bool) (k : Nat) : Bool :=
  Nat.testBit rule (c.toNat + 2 * k)

/-- k = number of ON cells among the four axial neighbours of p. -/
def nbrOn (s : Cell → Bool) (p : Cell) : Nat :=
  (s (p.1 + 1, p.2)).toNat + (s (p.1 - 1, p.2)).toNat +
  (s (p.1, p.2 + 1)).toNat + (s (p.1, p.2 - 1)).toNat

/-- One synchronous step of the rule on the whole plane. -/
def step (rule : Nat) (s : Cell → Bool) : Cell → Bool :=
  fun p => ruleOut rule (s p) (nbrOn s p)

/-- Stage g of the rule on the whole plane, from one ON cell at the origin at stage 0.
For an odd rule (bit 0 = 1) every cell far from the seed is ON at stage 1. -/
def caState (rule : Nat) : Nat → Cell → Bool
  | 0 => fun p => decide (p = (0, 0))
  | g + 1 => step rule (caState rule g)

/-- The window [-g,g]^2 around the seed. -/
def window (g : Nat) : Finset Cell :=
  Finset.Icc (-(g : Int)) g ×ˢ Finset.Icc (-(g : Int)) g

/-- The OEIS count: number of ON cells of stage g inside the (2g+1) x (2g+1) square around the seed. -/
def onCount (rule g : Nat) : Nat :=
  ((window g).filter (fun p => caState rule g p = true)).card

end LT2D
