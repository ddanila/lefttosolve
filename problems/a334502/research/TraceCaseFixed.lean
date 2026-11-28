import TreeModel
namespace A334502Model
set_option maxRecDepth 10000
set_option maxHeartbeats 5000000
lemma test (N T X : ℤ) (hn : 14 ≤ 24*N) (ht : 0 ≤ 12*T)
    (hx : 0 < 12*X) (hxn : 12*X < 24*N-1) :
    reduced N T X 0 1 0 ↔
    (¬reduced N T X 0 0 (-1) ∧ (reduced N T X 0 0 0 ∨ reduced N T X 0 0 1)) ∨
    (reduced N T X 0 0 (-1) ∧ ¬reduced N T X 0 0 0) := by
  norm_num [reduced, core]
  split_ifs <;> omega
end A334502Model
