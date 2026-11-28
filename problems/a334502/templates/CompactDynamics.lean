import CompactAll
namespace Compact
lemma inner_step (n t x : ℤ) (hn : 14≤n) (ht : 0≤t) (hx : 0<x) (hxn : x<n-1) :
    cell n (t+1) x ↔ (¬cell n t (x-1) ∧ (cell n t x ∨ cell n t (x+1))) ∨
      (cell n t (x-1) ∧ ¬cell n t x) := by
  have nr := reconstruct n 24 (by decide)
  have tr := reconstruct t 12 (by decide)
  have xr := reconstruct x 12 (by decide)
  have h := inner_all (n/24) (t/12) (x/12) (n%24).toNat (t%12).toNat (x%12).toNat
    (residue_nat n 24 (by decide)) (by omega) (by omega)
    (residue_nat t 12 (by decide)) (residue_nat x 12 (by decide)) (by omega) (by omega)
  simpa [cell, plus_mod, minus_mod, plus_div, minus_div] using h

lemma left_step (n t : ℤ) (hn : 14≤n) (ht : 0≤t) :
    cell n (t+1) 0 ↔ (¬cell n t (n-1) ∧ (cell n t 0 ∨ cell n t 1)) ∨
      (cell n t (n-1) ∧ ¬cell n t 0) := by
  have nr := reconstruct n 24 (by decide)
  have tr := reconstruct t 12 (by decide)
  have h := left_all (n/24) (t/12) (n%24).toNat (t%12).toNat
    (residue_nat n 24 (by decide)) (by omega) (by omega) (residue_nat t 12 (by decide))
  have ld := last_div n 1
  simpa [cell, plus_mod, plus_div, last_mod, ld] using h

lemma right_step (n t : ℤ) (hn : 14≤n) (ht : 0≤t) :
    cell n (t+1) (n-1) ↔ (¬cell n t (n-2) ∧ (cell n t (n-1) ∨ cell n t 0)) ∨
      (cell n t (n-2) ∧ ¬cell n t (n-1)) := by
  have nr := reconstruct n 24 (by decide)
  have tr := reconstruct t 12 (by decide)
  have h := right_all (n/24) (t/12) (n%24).toNat (t%12).toNat
    (residue_nat n 24 (by decide)) (by omega) (by omega) (residue_nat t 12 (by decide))
  have ld := last_div n 1
  have ld2 := last_div n 2
  simpa [cell, plus_mod, plus_div, last_mod, ld, ld2, penultimate_mod] using h

lemma initial (n x : ℤ) (hn : 14≤n) (hx : 0≤x) (hxn : x<n) :
    cell n 0 x ↔ x=0 := by
  have nr := reconstruct n 24 (by decide)
  have xr := reconstruct x 12 (by decide)
  have h := base_all (n/24) (x/12) (n%24).toNat (x%12).toNat
    (residue_nat n 24 (by decide)) (by omega) (residue_nat x 12 (by decide))
    (by omega) (by omega)
  norm_num only [Nat.cast_ofNat] at xr
  rw [←xr] at h
  simpa [cell] using h

lemma period (n x : ℤ) (hn : 14≤n) (hx : 0≤x) (hxn : x<n) :
    cell n (12*n+3) x ↔ cell n (12*n) x := by
  have nr := reconstruct n 24 (by decide)
  have xr := reconstruct x 12 (by decide)
  have h := periodic_all (n/24) (x/12) (n%24).toNat (x%12).toNat
    (residue_nat n 24 (by decide)) (by omega) (residue_nat x 12 (by decide))
    (by omega) (by omega)
  norm_num only [Nat.cast_ofNat] at nr
  rw [←nr] at h
  have h1 : (12*n+3)%12=3 := by omega
  have h2 : (12*n)%12=0 := by omega
  have h3 : (12*n+3)/12=n := by omega
  have h4 : (12*n)/12=n := by omega
  simpa [cell, h1, h2, h3, h4] using h

lemma nonfixed (n : ℤ) (hn : 14≤n) :
    ¬(cell n (12*n+1) 2 ↔ cell n (12*n) 2) := by
  have nr := reconstruct n 24 (by decide)
  have h := different_all (n/24) (n%24).toNat (residue_nat n 24 (by decide)) (by omega)
  norm_num only [Nat.cast_ofNat] at nr
  rw [←nr] at h
  have h1 : (12*n+1)%12=1 := by omega
  have h2 : (12*n)%12=0 := by omega
  have h3 : (12*n+1)/12=n := by omega
  have h4 : (12*n)/12=n := by omega
  simpa [cell, h1, h2, h3, h4] using h
end Compact
