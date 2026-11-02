## Resolving tickets (step 8 detail)

"Resolve each ticket" means actually writing it back to the tracker, per ticket, once its work is merged to the integration branch:

- Verify each acceptance criterion; tick only those verified. Leave a ticket open, and report it, if any criterion is unmet.
- Close it with the tracker's "Close a ticket" operation in `docs/agents/issue-tracker.md`. For a local markdown tracker that means `Status: resolved` plus a closing note under `## Comments` naming the merge commit. Never write `Status: done`.
- If a draft PR closes the tickets on merge, leave them open and say so.
- Never close the spec or parent ticket: tell the user it is ready for review.
