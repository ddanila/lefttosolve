import CompactBlocks
import CompactEdges
import CompactArithmetic
namespace Compact
set_option maxHeartbeats 2000000
lemma inner_all (N T X : ℤ) (r s v : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r)
    (ht : 0 ≤ 12*T+s) (hs : s < 12) (hv : v < 12)
    (hx : 0 < 12*X+v) (hxn : 12*X+v < 24*N+r-1) :
    reduced r ((s+1)%12) v N (T+if s=11 then 1 else 0) X ↔
    (¬reduced r s ((v+11)%12) N T (X-if v=0 then 1 else 0) ∧
      (reduced r s v N T X ∨ reduced r s ((v+1)%12) N T (X+if v=11 then 1 else 0))) ∨
    (reduced r s ((v+11)%12) N T (X-if v=0 then 1 else 0) ∧ ¬reduced r s v N T X) := by
  interval_cases r
  · exact inner_0 N T X s v hn ht hs hv hx hxn
  · exact inner_1 N T X s v hn ht hs hv hx hxn
  · exact inner_2 N T X s v hn ht hs hv hx hxn
  · exact inner_3 N T X s v hn ht hs hv hx hxn
  · exact inner_4 N T X s v hn ht hs hv hx hxn
  · exact inner_5 N T X s v hn ht hs hv hx hxn
  · exact inner_6 N T X s v hn ht hs hv hx hxn
  · exact inner_7 N T X s v hn ht hs hv hx hxn
  · exact inner_8 N T X s v hn ht hs hv hx hxn
  · exact inner_9 N T X s v hn ht hs hv hx hxn
  · exact inner_10 N T X s v hn ht hs hv hx hxn
  · exact inner_11 N T X s v hn ht hs hv hx hxn
  · exact inner_12 N T X s v hn ht hs hv hx hxn
  · exact inner_13 N T X s v hn ht hs hv hx hxn
  · exact inner_14 N T X s v hn ht hs hv hx hxn
  · exact inner_15 N T X s v hn ht hs hv hx hxn
  · exact inner_16 N T X s v hn ht hs hv hx hxn
  · exact inner_17 N T X s v hn ht hs hv hx hxn
  · exact inner_18 N T X s v hn ht hs hv hx hxn
  · exact inner_19 N T X s v hn ht hs hv hx hxn
  · exact inner_20 N T X s v hn ht hs hv hx hxn
  · exact inner_21 N T X s v hn ht hs hv hx hxn
  · exact inner_22 N T X s v hn ht hs hv hx hxn
  · exact inner_23 N T X s v hn ht hs hv hx hxn
lemma left_all (N T : ℤ) (r s : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r)
    (ht : 0 ≤ 12*T+s) (hs : s < 12) :
    reduced r ((s+1)%12) 0 N (T+if s=11 then 1 else 0) 0 ↔
    (¬reduced r s ((r+11)%12) N T (2*N+((r:ℤ)-1)/12) ∧
      (reduced r s 0 N T 0 ∨ reduced r s 1 N T 0)) ∨
    (reduced r s ((r+11)%12) N T (2*N+((r:ℤ)-1)/12) ∧ ¬reduced r s 0 N T 0) := by
  interval_cases r
  · exact left_0 N T s hn ht hs
  · exact left_1 N T s hn ht hs
  · exact left_2 N T s hn ht hs
  · exact left_3 N T s hn ht hs
  · exact left_4 N T s hn ht hs
  · exact left_5 N T s hn ht hs
  · exact left_6 N T s hn ht hs
  · exact left_7 N T s hn ht hs
  · exact left_8 N T s hn ht hs
  · exact left_9 N T s hn ht hs
  · exact left_10 N T s hn ht hs
  · exact left_11 N T s hn ht hs
  · exact left_12 N T s hn ht hs
  · exact left_13 N T s hn ht hs
  · exact left_14 N T s hn ht hs
  · exact left_15 N T s hn ht hs
  · exact left_16 N T s hn ht hs
  · exact left_17 N T s hn ht hs
  · exact left_18 N T s hn ht hs
  · exact left_19 N T s hn ht hs
  · exact left_20 N T s hn ht hs
  · exact left_21 N T s hn ht hs
  · exact left_22 N T s hn ht hs
  · exact left_23 N T s hn ht hs
lemma right_all (N T : ℤ) (r s : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r)
    (ht : 0 ≤ 12*T+s) (hs : s < 12) :
    reduced r ((s+1)%12) ((r+11)%12) N (T+if s=11 then 1 else 0) (2*N+((r:ℤ)-1)/12) ↔
    (¬reduced r s ((r+10)%12) N T (2*N+((r:ℤ)-2)/12) ∧
      (reduced r s ((r+11)%12) N T (2*N+((r:ℤ)-1)/12) ∨ reduced r s 0 N T 0)) ∨
    (reduced r s ((r+10)%12) N T (2*N+((r:ℤ)-2)/12) ∧
      ¬reduced r s ((r+11)%12) N T (2*N+((r:ℤ)-1)/12)) := by
  interval_cases r
  · exact right_0 N T s hn ht hs
  · exact right_1 N T s hn ht hs
  · exact right_2 N T s hn ht hs
  · exact right_3 N T s hn ht hs
  · exact right_4 N T s hn ht hs
  · exact right_5 N T s hn ht hs
  · exact right_6 N T s hn ht hs
  · exact right_7 N T s hn ht hs
  · exact right_8 N T s hn ht hs
  · exact right_9 N T s hn ht hs
  · exact right_10 N T s hn ht hs
  · exact right_11 N T s hn ht hs
  · exact right_12 N T s hn ht hs
  · exact right_13 N T s hn ht hs
  · exact right_14 N T s hn ht hs
  · exact right_15 N T s hn ht hs
  · exact right_16 N T s hn ht hs
  · exact right_17 N T s hn ht hs
  · exact right_18 N T s hn ht hs
  · exact right_19 N T s hn ht hs
  · exact right_20 N T s hn ht hs
  · exact right_21 N T s hn ht hs
  · exact right_22 N T s hn ht hs
  · exact right_23 N T s hn ht hs
lemma base_all (N X : ℤ) (r v : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r) (hv : v<12)
    (hx : 0 ≤ 12*X+v) (hxn : 12*X+v < 24*N+r) :
    reduced r 0 v N 0 X ↔ 12*X+v=0 := by
  interval_cases r
  · exact base_0 N X v hn hv hx hxn
  · exact base_1 N X v hn hv hx hxn
  · exact base_2 N X v hn hv hx hxn
  · exact base_3 N X v hn hv hx hxn
  · exact base_4 N X v hn hv hx hxn
  · exact base_5 N X v hn hv hx hxn
  · exact base_6 N X v hn hv hx hxn
  · exact base_7 N X v hn hv hx hxn
  · exact base_8 N X v hn hv hx hxn
  · exact base_9 N X v hn hv hx hxn
  · exact base_10 N X v hn hv hx hxn
  · exact base_11 N X v hn hv hx hxn
  · exact base_12 N X v hn hv hx hxn
  · exact base_13 N X v hn hv hx hxn
  · exact base_14 N X v hn hv hx hxn
  · exact base_15 N X v hn hv hx hxn
  · exact base_16 N X v hn hv hx hxn
  · exact base_17 N X v hn hv hx hxn
  · exact base_18 N X v hn hv hx hxn
  · exact base_19 N X v hn hv hx hxn
  · exact base_20 N X v hn hv hx hxn
  · exact base_21 N X v hn hv hx hxn
  · exact base_22 N X v hn hv hx hxn
  · exact base_23 N X v hn hv hx hxn
lemma periodic_all (N X : ℤ) (r v : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r) (hv : v<12)
    (hx : 0 ≤ 12*X+v) (hxn : 12*X+v < 24*N+r) :
    reduced r 3 v N (24*N+r) X ↔ reduced r 0 v N (24*N+r) X := by
  interval_cases r
  · exact periodic_0 N X v hn hv hx hxn
  · exact periodic_1 N X v hn hv hx hxn
  · exact periodic_2 N X v hn hv hx hxn
  · exact periodic_3 N X v hn hv hx hxn
  · exact periodic_4 N X v hn hv hx hxn
  · exact periodic_5 N X v hn hv hx hxn
  · exact periodic_6 N X v hn hv hx hxn
  · exact periodic_7 N X v hn hv hx hxn
  · exact periodic_8 N X v hn hv hx hxn
  · exact periodic_9 N X v hn hv hx hxn
  · exact periodic_10 N X v hn hv hx hxn
  · exact periodic_11 N X v hn hv hx hxn
  · exact periodic_12 N X v hn hv hx hxn
  · exact periodic_13 N X v hn hv hx hxn
  · exact periodic_14 N X v hn hv hx hxn
  · exact periodic_15 N X v hn hv hx hxn
  · exact periodic_16 N X v hn hv hx hxn
  · exact periodic_17 N X v hn hv hx hxn
  · exact periodic_18 N X v hn hv hx hxn
  · exact periodic_19 N X v hn hv hx hxn
  · exact periodic_20 N X v hn hv hx hxn
  · exact periodic_21 N X v hn hv hx hxn
  · exact periodic_22 N X v hn hv hx hxn
  · exact periodic_23 N X v hn hv hx hxn
lemma different_all (N : ℤ) (r : ℕ) (hr : r<24) (hn : 14 ≤ 24*N+r) :
    ¬(reduced r 1 2 N (24*N+r) 0 ↔ reduced r 0 2 N (24*N+r) 0) := by
  interval_cases r
  · exact different_0 N hn
  · exact different_1 N hn
  · exact different_2 N hn
  · exact different_3 N hn
  · exact different_4 N hn
  · exact different_5 N hn
  · exact different_6 N hn
  · exact different_7 N hn
  · exact different_8 N hn
  · exact different_9 N hn
  · exact different_10 N hn
  · exact different_11 N hn
  · exact different_12 N hn
  · exact different_13 N hn
  · exact different_14 N hn
  · exact different_15 N hn
  · exact different_16 N hn
  · exact different_17 N hn
  · exact different_18 N hn
  · exact different_19 N hn
  · exact different_20 N hn
  · exact different_21 N hn
  · exact different_22 N hn
  · exact different_23 N hn
end Compact
