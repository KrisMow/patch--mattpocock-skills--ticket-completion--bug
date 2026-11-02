# Prompt: does the mattpocock-skills update still need the ticket-completion patch?

Paste everything below the line into a Claude Code session after the plugin has updated.

---

The `mattpocock-skills` Claude Code plugin may have just updated. Its installed copy lives under `~/.claude/plugins/cache/*/mattpocock-skills/<version>/` (on Windows `%USERPROFILE%\.claude\plugins\cache\...`). Use the highest version directory.

**Background.** Upstream issue #508: the `implement` skill (and `implement-spec`) never marks a finished ticket as done on the tracker, so the "work the frontier" loop of `to-tickets` and `wayfinder` stalls. My local patch in `<this repo>/common/fragments/` appends completion instructions to these files, each wrapped in `<!-- mp-patch:<name> begin -->` ... `<!-- mp-patch:<name> end -->` markers (the file list is `common/manifest.txt`):

- `skills/engineering/implement/SKILL.md`
- `skills/engineering/implement-spec/SKILL.md`
- `skills/engineering/setup-matt-pocock-skills/issue-tracker-{local,github,gitlab}.md`

**Do this, read-only, then report. Do not edit anything until I say so.**

1. Check for the markers. Which of the files above still contain them? A file with no marker has been overwritten by the update.
2. For each unpatched file, do a fuzzy read, not a string match. Skills get reworded, split, renamed or moved. Search the whole skills tree (`grep -ril "implement"`, then read the candidates) for where ticket completion is now handled. Judge whether the new version:
   - tells the agent to close or resolve the ticket after committing (any wording, any file, including a new skill such as a `close`/`complete` skill that `implement` calls);
   - defines a "close" operation for each tracker template, and for local markdown uses `Status: resolved` (the value `Blocked by:` unblocks on), not an invented value like `done`;
   - ticks verified acceptance criteria;
   - defers to the merge when a PR closes the ticket, and leaves parent tickets for human review.
3. Classify each file as one of:
   - **PATCH NEEDED**: the upstream fix is absent. Re-run `scripts/patch.sh` (or `scripts/patch.ps1`).
   - **FIXED UPSTREAM**: the behavior now exists. Quote the relevant lines. If my marker is still present too, recommend `scripts/unpatch.sh` so the instructions aren't duplicated.
   - **PARTIAL / CONFLICT**: upstream covers some of it, or contradicts my patch (for example a different done-state). Describe the difference and propose a revised fragment, but don't write it.
   - **MOVED**: the target file no longer exists. Say where the equivalent content is now, and what to change in `common/manifest.txt`.
4. Also tell me if `triage-labels.md` gained a done/resolved label, or if the plugin changelog (`CHANGELOG.md`) mentions #508, ticket completion, or closing tickets.

End with a one-line verdict: re-run the patch, unpatch, or adjust the patch, and the exact command.
