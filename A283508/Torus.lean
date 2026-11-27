import A283508.Locality
import Mathlib

namespace A283508

def distance (u v x y : ℤ) : ℤ := |u-x| + |v-y|

theorem distance_triangle (u v x y p q : ℤ) :
    distance u v x y ≤ distance u v p q + distance p q x y := by
  have h := abs_add_le (u-p) (p-x)
  have k := abs_add_le (v-q) (q-y)
  simp only [sub_add_sub_cancel] at h k
  unfold distance
  linarith

theorem evolve_local (n : ℕ) (g h : Grid) (x y : ℤ)
    (agree : ∀ u v, distance u v x y ≤ n → g u v = h u v) :
    evolve g n x y = evolve h n x y := by
  induction n generalizing x y with
  | zero => exact agree x y (by simp [distance])
  | succ n ih =>
    have near : ∀ p q, distance p q x y ≤ 1 →
        evolve g n p q = evolve h n p q := by
      intro p q hp
      apply ih
      intro u v huv
      apply agree
      have ht := distance_triangle u v x y p q
      omega
    simp only [evolve, step, neighbors]
    rw [near x y (by simp [distance]),
      near (x+1) y (by simp [distance]),
      near (x-1) y (by simp [distance]),
      near x (y+1) (by simp [distance]),
      near x (y-1) (by simp [distance])]

abbrev Torus := ZMod 257 → ZMod 257 → Bool

def torusStep (g : Torus) : Torus := fun x y =>
  rule (g x y) (bit (g (x+1) y) + bit (g (x-1) y) +
    bit (g x (y+1)) + bit (g x (y-1)))

def torusInitial : Torus := fun x y => decide (x = 0 ∧ y = 0)
def torusState : ℕ → Torus
  | 0 => torusInitial
  | n+1 => torusStep (torusState n)
def lift (g : Torus) : Grid := fun x y => g (x : ZMod 257) (y : ZMod 257)
def periodicSeed : Grid := fun x y => decide ((257 : ℤ) ∣ x ∧ (257 : ℤ) ∣ y)

theorem lift_initial : lift torusInitial = periodicSeed := by
  funext x y
  simp [lift, torusInitial, periodicSeed, ZMod.intCast_zmod_eq_zero_iff_dvd]

theorem lift_step (g : Torus) : lift (torusStep g) = step (lift g) := by
  funext x y
  simp [lift, torusStep, step, neighbors]

theorem lift_evolve (n : ℕ) : lift (torusState n) = evolve periodicSeed n := by
  induction n with
  | zero => exact lift_initial
  | succ n ih => simp only [torusState, lift_step, ih, evolve]

theorem periodic_agrees (n m : ℕ) (hn : n ≤ 126) (hm : m ≤ n)
    (u v : ℤ) (huv : distance u v m 0 ≤ n) :
    periodicSeed u v = initial u v := by
  have hu := le_abs_self (u-(m : ℤ))
  have hu' := neg_le_abs (u-(m : ℤ))
  have hv := le_abs_self v
  have hv' := neg_le_abs v
  have au := abs_nonneg (u-(m : ℤ))
  have av := abs_nonneg v
  simp only [distance, sub_zero] at huv
  have eu : (257 : ℤ) ∣ u ↔ u = 0 := by
    constructor
    · intro h
      have := Int.emod_eq_zero_of_dvd h
      omega
    · intro h; simp [h]
  have ev : (257 : ℤ) ∣ v ↔ v = 0 := by
    constructor
    · intro h
      have := Int.emod_eq_zero_of_dvd h
      omega
    · intro h; simp [h]
  simp [periodicSeed, initial, eu, ev]

theorem observed_torus_correct (n m : ℕ) (hn : n ≤ 126) (hm : m ≤ n) :
    torusState n (m : ZMod 257) 0 = state n m 0 := by
  change lift (torusState n) m 0 = evolve initial n m 0
  rw [lift_evolve]
  exact evolve_local n periodicSeed initial m 0 (periodic_agrees n m hn hm)

end A283508
