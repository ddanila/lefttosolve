# Local-model review disposition

One sequential request each was made to installed `qwen3.5:9b` and `gemma3:12b`, with 4096-token context, an 1800-token output cap, and a 300-second timeout per request. Both completed. The raw requests and responses are retained; they are advisory evidence, not trusted mathematics or proof code.

Qwen's response is not usable as a proof outline. It incorrectly claimed a cell with no ON neighbours cannot turn ON under `k=0 OR (c=1 AND k>=3)`, invented a first-step exception, gave the wrong binary expansion for 641, and confused the cell state with the decimal sequence value. Its proposed boundary size was also insufficient as a general locality argument. These claims and its proposed Lean snippets were rejected.

Gemma usefully emphasized truth-table and indexing checks, but incorrectly restricted the neighbour count to 0–3 and called bit lookup “bit flipping.” The actual range is 0–4, and the output is the selected bit. Its review is not treated as independent certification.

The implemented proof follows the fixed configuration found by the exact simulator, checked by Lean over all coordinates. The models did not supply any accepted proof lemma. This run demonstrates the practicality of local review loops, but not a model-driven discovery advantage for this particular problem.
