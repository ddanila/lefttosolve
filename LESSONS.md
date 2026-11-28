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

Recorded 2026-11-27 from the upstream merger's source (`tools/merger_loop.sh`, `tools/verdict_one.sh`, `tools/prooflen.py` at `f9464184`) and the public log of merger run 45998943330. The merger was rewritten twice that afternoon (v3 at 15:33 UTC, a merge fix at 16:23), so re-read its scripts before relying on the details below.

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
3. **Read the merger's comment before re-triggering.** Pushing any new commit re-runs the check, but it also discards the current accepted check and any re-run the merger queued itself. Decide from what the pull request shows:
   - **No merger comment, and the check is nearing two hours old:** push a commit. The merger rescans only the last two hours, so an older check is never looked at again.
   - **No merger comment, but the merger just restarted:** wait. A fresh merger scans the last three hours and finishes that scan before it looks at new checks, so a commit would not jump the queue.
   - **Comment says the merge was refused and it is "retrying automatically":** do nothing. The merger has re-run the check itself and tracks it outside the two-hour window. On 2026-11-27 our A267623 proof #7656 got this at 16:03 UTC, from an upstream bug that refused about two in three merges (fixed upstream at 16:23).
   - **Comment says the file is "already on main":** a re-trigger is pointless; only the shortest-proof route in rule 6 remains.
   - **The automatic re-run finished green 20 minutes ago with no new comment, or was cancelled:** push a commit.
4. **Keep the proof pull request ready before the statement merges.** We did this; keep doing it. With a healthy merger it is what decides the race.
5. **Measure proof length before submitting.** A later proof replaces the one on `main` if it is at least 5% and 20 characters shorter, counted by `tools/prooflen.py` (comments and whitespace excluded). The first solve stays with the first prover, but the shortest-proof credit moves. Remove slack such as a redundant `import Mathlib` and duplicated helper lemmas before submission.
6. **A lost first solve can still earn the shortest-proof credit.** The pull request must modify the existing proof file. For A267622 the target is 2,451 counted characters or fewer. The old #7242 cannot merge as it stands, because it adds a file that now exists.
7. **Do not infer copying from timing.** Read the rival file first. Here it was plainly independent.

## References

- Our proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7242
- Merged rival proof: https://github.com/GuillaumeBAUD-coder/open-math-agents/pull/7360
- Merger run with the log: https://github.com/GuillaumeBAUD-coder/open-math-agents/actions/runs/45998943330

# What the top contributors publish

Checked on 2026-11-28, about 09:00 UTC. The leaderboard's top five by points are @Genbox, @ivillar, @marcusbuffett, @TheWaler and @jleguina; @Dugongue is in the top five by commits.

## Where to look

- **Their forks hold no documentation.** Every fork's `main` is plain upstream, far behind, with nothing added. Each has one branch per problem (`oma/<id>`, `claim/<id>`, `formalize/<id>`), 150 to 3,000 of them, holding one Lean file each.
- **@ivillar's `note/` branches are the only published notes.** There are three, and the text is in the commit message, not in a file.
- **Pull request bodies carry the rest.** They show what each fleet checks and how it handles the desk.
- **`https://lefttosolve.com/join.txt` is the rulebook they all follow.** It has grown a lot since we last read it; reread it before each new problem.

## Platform changes found on the way

- **Upstream moved to `lefttosolve2/open-math-agents`** on 2026-11-28 at about 08:17 UTC. Git and plain REST calls to the old name redirect. Searches do not: `gh pr list --repo GuillaumeBAUD-coder/open-math-agents --author … --search …` returns an empty list with exit code 0. Any script that uses such a search as a duplicate guard is blind until it uses the new name.
- **`tools/oma.sh` is now the reference client** (`next`, `check`, `submit`, `note`, `reduce`). Where it and `join.txt` disagree, the script wins.

## Rules worth adopting

1. **Open the proof pull request whatever the desk says.** `join.txt` says so for a 503, a lapsed lease and degraded mode, and @jleguina does it on `proof_pending` for problems whose statement is theirs. Put the reason on the `Lease:` line, for example `Lease: none (the desk answered proof_pending, pointing at #N at HH:MM UTC)`.
2. **Say in the statement pull request that a proof already compiles against it.** @jleguina ends each statement body with that sentence and sends the proof once the statement merges. It is our rule 4 above, made visible to the reviewer.
3. **Audit a statement against a fixed list before sending it.** @Dugongue's bodies name the list: quantifiers, index offsets, edge cases, and no `sInf` or natural-number-subtraction loopholes. Our A273385 closed form uses truncated subtraction in ℕ; it is safe there, but ℤ avoids the question.
4. **Check where a submission stands at `https://lefttosolve.com/api/pending?handle=<handle>`.** It gives the expected wait, which we had been estimating from the merger log.
5. **Test a claim numerically before investing in it.** @ivillar found a reduction step that is false by exhaustive search. A false step cannot be closed, because step files accept only `OMA.solution`.
6. **Expect volume, not speed, from the leaders.** Each of the five had 100 pull requests opened within the last one to nine hours, nearly all still open. They run fleets (`tools/fleet.sh`) and mix models. Reductions (`reductions/<id>.R<n>.lean`) and their steps are a large share of the work of @marcusbuffett and @Genbox, and a kind of contribution we have not used.

## Lean techniques from @ivillar's notes

These are for finite checks, which is what our cellular-automaton base cases are. We have not tried them yet.

- **`decide +kernel` instead of `decide`.** It evaluates in the kernel where the elaborator runs out of recursion depth or heartbeats. The checker forbids `native_decide` and `decide := true`, not this. It is the first thing to try on the A273385 lemma `third`, which needs 4,000,000 heartbeats.
- **Count down on the structural argument.** A loop that passes a growing index costs about 0.7 ms per kernel step; `| 0 => true | k + 1 => P k && allBelow P k` costs about 85 µs.
- **Split a large range into separate theorems** and recombine with `interval_cases` on the quotient. The note used 32 blocks of 4,096.
- **Primality below 2^17 in one step:** for f > 362, f is prime iff `Nat.gcd f (Nat.factorial 362) = 1`.
- **`Nat.nth Nat.Prime k` for small k:** prove a table with `Nat.count Nat.Prime` under `decide +kernel`, then finish with `Nat.nth_count`.

## References

- Notes: https://github.com/ivillar/open-math-agents/branches/all?query=note
- Statement body with a ready proof: https://github.com/lefttosolve2/open-math-agents/pull/23799
- Proof sent on `proof_pending`: https://github.com/lefttosolve2/open-math-agents/pull/23910
- Statement audit list: https://github.com/lefttosolve2/open-math-agents/pull/15960

# A273385 watcher stop and A265284 shorter-proof follow-up

Recorded 2026-11-28. These are separate outcomes: a stopped submission watcher,
and a checked proof that remained open after a competing proof merged.

## What happened

- A273385 statement [#22075](https://github.com/lefttosolve2/open-math-agents/pull/22075)
  merged at **10:48:29 UTC**. Our watcher noticed it, but stopped at **10:49:31**
  with `needs_review: Checker/client changed`. No proof PR was created then.
- The stop was discovered during the user's status request around **12:45 UTC**.
  Merely having launched a watcher was not enough to ensure submission happened.
- The checker had added a root-qualified exact-target guard and a proof-size
  allowlist. The client also changed its canonical repository, event display,
  and later added a separate `solved-elsewhere` command. After inspecting the
  diffs and confirming the merged statement's exact hash, we refreshed the
  approved tool hashes and restarted A273385's watcher at **12:46 UTC**.
  We also refreshed and restarted the still-waiting A273539 watcher, which
  otherwise would encounter the same client-hash stop when its statement merges.
- A265284 proof [#26856](https://github.com/lefttosolve2/open-math-agents/pull/26856)
  passed CI at **10:50:08 UTC**, but @treybeathard-jpg's
  [#10573](https://github.com/lefttosolve2/open-math-agents/pull/10573) merged first
  at **11:28:38 UTC**. Our PR remained open without a verdict comment.
- The official length tool counted **4,199** characters in our proof versus
  **6,412** in the merged proof: **2,213 characters / 34.5% shorter**. We merged
  current upstream main into our existing submission branch, resolved the
  add/add conflict with our unchanged checked proof, and reran the official
  checker successfully. The same PR now modifies the existing proof file;
  its title and description explain the shorter-proof replacement. This update
  triggers fresh CI. First-solve credit belongs to the original solver.

## Changes to our workflow

1. **Treat watcher health as part of monitoring.** Check the process, status
   timestamp, phase, and terminal reason—not just the PR or the fact that a
   watcher was started. `needs_review`, `statement_changed`, network stalls,
   and expiry require attention. The present local watchers write status files;
   they do not proactively notify the owner. A future monitoring setup should
   surface terminal stops through an explicitly authorized notification path.
2. **Keep the checker-change guard, but service it promptly.** Inspect exact
   diffs, verify the statement/dependency pins, and rerun the official checker.
   Do not remove the guard or blindly bless new hashes. Once a harmless shared
   client/checker update has been reviewed, check every active watcher for the
   same stale pin. This prevents repeating the same stop on the next problem.
3. **CI green is only compilation evidence.** Also check whether the statement
   merged, whether our proof PR actually exists, whether another proof is now
   on main, and whether our own submission received a verdict. An open green
   PR can already have lost the first-solve race.
4. **Measure before declaring a lost proof obsolete.** Run the current
   `tools/prooflen.py` on both files. The replacement requires at least 5% and
   20 characters saved; compare counted characters, not bytes or line counts.
   Preserve the base commit, file hashes, both lengths, and checker result.
5. **Update the existing PR to the new reality.** Integrate current upstream,
   resolve only the intended proof conflict, verify the exact target, rerun the
   official checker, and confirm the PR has exactly one `MODIFIED` proof file.
   Rewrite its title/body around the replacement; do not open a duplicate PR
   or imply that shorter-proof credit transfers first-solve credit.
6. **A repaired watcher is not yet a submitted proof.** Report rechecking,
   submitting, proof URL, CI result, and merge as distinct observed states.
   Keep status documentation current after the repair completes.

Evidence: `problems/a265284/reviews/shorter-proof.json`,
`problems/a265284/reviews/shorter-proof-check.json`, the recorded watcher contexts,
and the linked PRs. The original watcher stop remains in the ignored local
`.oma/a273385-watch/checker-change-stop.json` for operational diagnosis.
