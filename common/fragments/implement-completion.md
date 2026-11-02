## Completing the ticket

Skip this section if the user did not pass a ticket reference.

After committing, mark the ticket completed on the issue tracker, so the frontier advances.

1. Check every acceptance criterion against the work. Only count a criterion as met if you verified it. If any are unmet, do not close the ticket: leave it open, say which criteria are unmet, and stop.
2. Close the ticket the way `docs/agents/issue-tracker.md` describes ("Close a ticket"). If it describes no close operation:
   - **GitHub / GitLab**: post a short resolution comment that names the commit, then close the issue.
   - **Local markdown**: tick the verified `- [ ]` criteria to `- [x]`, set `Status: resolved` (not `done`: `Blocked by:` only unblocks on `resolved`), and append a closing note naming the commit under `## Comments`.
3. If closing belongs to a pull request (`Closes #N` in a PR the user asked for or the tracker doc configures), do not close the ticket here. Say that the merge will close it.
4. If this was the last open child of a parent ticket or spec, do not close the parent. Tell the user all children are done and the parent needs their review.
5. Finish by reporting the outcome: ticket reference, and whether it was closed, deferred to a PR, or left open and why.
