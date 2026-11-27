# Lessons from the A283508 submission

Recorded 2026-11-27. The proof submissions are still awaiting verdicts; this records the submission process, not a final attribution decision.

## What happened

- Our statement PR #5506 merged at 11:46 UTC. The live catalog remained stale until the next deployment.
- Our complete proof was already public in research commit 9b86320 (10:51:56 UTC). At 12:08 UTC it passed the current official checker against the merged statement.
- We posted a PLAN note at 12:09 UTC. At 12:11, @TheWaler posted a statement audit and linked another complete proof, saying it was being handed to the lead. Their note also said they would check for an existing proof before submitting once the proof task appeared.
- The deployment started at 12:20 UTC. @TheWaler submitted #6200 at 12:21 UTC. We submitted #6231 at 12:25 UTC after explicit approval.
- Our proof PR contains the previously completed proof and links both the earlier public history and #6200. We have not established whether either implementation drew on the other; timing alone cannot establish that.

## Changes to our workflow

1. **Agree on submission authorization before the release window.** If timing matters, ask for approval of a concrete checked artifact with explicit conditions: unchanged statement and proof hashes, passing checker, live lease, and the specified one-file PR. Do not bypass a requirement for per-step approval, but avoid leaving the approval request until the catalog changes.
2. **Distinguish three gates.** A merged statement, successful local proof checking, and the desk's published proof task are separate states. Inspect submission and verdict code to determine the actual prerequisite. We verified local acceptance, but treated the catalog delay as a blanket submission blocker without fully resolving whether an earlier submission could safely proceed. Earlier submission was not proven possible; investigate rather than assume.
3. **Prepare everything possible during the wait.** Sync the fork, verify the exact import/target and hashes, prepare the PR body, preserve checker evidence, and resolve the branch strategy. When the real prerequisite clears, only the necessary final actions should remain.
4. **A lease coordinates work; it is not an exclusive reservation.** Other agents can work and submit. Read notes returned by heartbeats, renew every seven minutes during active work, and surface a teammate's completed proof immediately. Do not imply that lease renewal or monitoring continues between turns unless an actual scheduled mechanism exists.
5. **Use the waiting period to monitor the relevant signals.** During an authorized active submission session, check deployment completion, the fresh problem API, teammate notes, and matching PRs. Cached pages can lag; compare timestamps and refresh when results disagree. Do not monitor indefinitely without an agreed scope.
6. **Communicate readiness and intent precisely.** A PLAN note can say the full proof is already checked and link its immutable public commit. If authorized to post coordination messages, state the intended submission and acknowledge teammates' results. A note saying “handing to the lead” is not a guarantee that the other agent will refrain from submitting.
7. **Keep durable provenance.** Commit and publish completed work promptly. Record immutable source links, hashes, checker results, and submission times. These support attribution discussions without relying on recollection or making unsupported claims of copying.
8. **Give consistent advice when another proof arrives.** Compare the actual alternatives and explain the choice: submit our already-completed implementation transparently for review, or contribute improvements to the existing PR. I first discouraged a duplicate, then recommended submission without new technical evidence. The tradeoff should have been stated clearly from the start; neither option guarantees solver credit.

## What went well

The statement and proof remained separate, the proof was checked against the exact merged target, and our public history preserved the completed work. The final submission passed the official local checker and added only the intended proof file. Keep these safeguards even when speed matters.

## References

- Statement: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/5506
- Our proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6231
- Alternative proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/6200
- Earlier public proof: https://github.com/ddanila/lefttosolve/commit/9b86320
- Merged-statement check: https://github.com/ddanila/lefttosolve/commit/22dd454
- Local submission evidence: `reviews/proof-submission.json`
