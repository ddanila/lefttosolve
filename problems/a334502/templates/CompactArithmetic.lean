import Compact
namespace Compact
lemma residue_nat (x : ℤ) (k : ℕ) (hk : 0<k) : (x%(k:ℤ)).toNat < k := by
  have h1 := Int.emod_nonneg x (show (k:ℤ)≠0 by omega)
  have h2 := Int.emod_lt_of_pos x (show (0:ℤ)<k by omega)
  omega
lemma reconstruct (x : ℤ) (k : ℕ) (hk : 0<k) :
    x=(k:ℤ)*(x/k)+(x%k).toNat := by
  have := Int.emod_nonneg x (show (k:ℤ)≠0 by omega)
  have := Int.emod_add_mul_ediv x k
  omega
lemma plus_div (x : ℤ) :
    (x+1)/12=x/12+(if (x%12).toNat=11 then 1 else 0) := by
  split_ifs <;> omega
lemma plus_mod (x : ℤ) :
    ((x+1)%12).toNat=((x%12).toNat+1)%12 := by omega
lemma minus_div (x : ℤ) :
    (x-1)/12=x/12-(if (x%12).toNat=0 then 1 else 0) := by
  split_ifs <;> omega
lemma minus_mod (x : ℤ) :
    ((x-1)%12).toNat=((x%12).toNat+11)%12 := by omega
lemma last_div (n : ℤ) (j : ℤ) :
    (n-j)/12=2*(n/24)+(((n%24).toNat:ℤ)-j)/12 := by omega
lemma last_mod (n : ℤ) :
    ((n-1)%12).toNat=((n%24).toNat+11)%12 := by omega
lemma penultimate_mod (n : ℤ) :
    ((n-2)%12).toNat=((n%24).toNat+10)%12 := by omega

lemma cell_reduce (N T X : ℤ) (r s v : ℕ) (hr : r<24) (hs : s<12) (hv : v<12) :
    cell (24*N+r) (12*T+s) (12*X+v) ↔ reduced r s v N T X := by
  have h1 : (24*N+r)%24=(r:ℤ) := by omega
  have h2 : (12*T+s)%12=(s:ℤ) := by omega
  have h3 : (12*X+v)%12=(v:ℤ) := by omega
  have h4 : (24*N+r)/24=N := by omega
  have h5 : (12*T+s)/12=T := by omega
  have h6 : (12*X+v)/12=X := by omega
  simp only [cell, h1, h2, h3, h4, h5, h6, Int.toNat_natCast]
end Compact
