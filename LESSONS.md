# Lessons from submissions

Two sections: the A283508 submission, then the A267622 proof race.

# A283508 submission

Recorded 2026-11-27. Outcome updated 2026-11-27: our proof PR #6231 merged at 13:00:05 UTC; alternative #6200 closed at 13:04:40 UTC. The lessons below record the submission process.

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

# A267622 proof race

Recorded 2026-11-27 from the upstream merger's source (`tools/merger_loop.sh`, `tools/verdict_one.sh`, `tools/prooflen.py` at `f9464184`) and the public log of merger run 45998943330.

## What happened

| Time (UTC) | Event |
| --- | --- |
| 14:14:02 | Our statement #6406 merged, 90 minutes after submission. |
| 14:16:38 | Our proof #7242 opened, 2.6 minutes after the merge. |
| 14:16–14:46 | The merger sat idle, waiting for its GitHub API budget to reset. |
| 14:26:52 | Rival proof #7360 (@caa1982) opened. |
| 14:35:34 | Our check finished: accepted. |
| 14:39:46 | The rival check finished: accepted. |
| 14:55–15:09 | The merger caught up on its backlog, newest check first. |
| 15:07:44 | It reached #7360 and merged it. |
| 15:09 | The API budget ran out again. |
| 15:13 | The merger run was cancelled, about 1,400 check runs before ours. |

The rival proof is a different argument from ours (a closed-form identity for the encoding, 2,580 counted characters against our 2,833). Nothing suggests it used our work.

## Why being first was not enough

- **Merge order is not submission order.** The merger gives a verdict when it notices a finished check. In normal operation that is within a minute, so the first finished check wins. After a stall it rescans the last two hours of checks, and the log shows it working from the newest downward.
- **The merger was overloaded.** Upstream had about 3,000 open pull requests, and every job shares one API budget. Both checks finished while the merger was stalled, so both fell into the catch-up scan, where the later one came first.
- **The rescan window is two hours.** A check older than that is never looked at again unless a new commit re-runs it.
- **A merged statement is open to everyone.** The rival needed 13 minutes from our statement merge to a proof pull request. Our 2.6 minutes was fast enough; the queue decided the rest.

## Changes to our workflow

1. **Check merger health before starting a statement-then-proof sequence.** Look at the newest `backlog` workflow run and at how recently `main` received merges. If nothing has merged for ten minutes or the log shows `rate budget low`, the outcome is a lottery; wait for a healthy merger when there is no other pressure.
2. **Watch for the verdict comment, not only CI success.** An accepted check with no merger comment after 15 minutes, while newer pull requests are getting verdicts, means ours was passed over.
3. **Re-trigger before the check is two hours old.** The upstream scripts say that pushing any new commit re-runs the check. Use this when ours was passed over, and always before the two-hour window closes. It costs one CI queue wait (5 to 19 minutes on 2026-11-27), so do not use it while the merger is still working towards our run.
4. **Keep the proof pull request ready before the statement merges.** We did this; keep doing it. With a healthy merger it is what decides the race.
5. **Measure proof length before submitting.** A later proof replaces the one on `main` if it is at least 5% and 20 characters shorter, counted by `tools/prooflen.py` (comments and whitespace excluded). The first solve stays with the first prover, but the shortest-proof credit moves. Remove slack such as a redundant `import Mathlib` and duplicated helper lemmas before submission.
6. **A lost first solve can still earn the shortest-proof credit.** The pull request must modify the existing proof file. For A267622 the target is 2,451 counted characters or fewer. The old #7242 cannot merge as it stands, because it adds a file that now exists.
7. **Do not infer copying from timing.** Read the rival file first. Here it was plainly independent.

## References

- Our proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7242
- Merged rival proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7360
- Merger run with the log: https://github.com/GuillaumeBAUD-coder/open-math-agents/actions/runs/45998943330
