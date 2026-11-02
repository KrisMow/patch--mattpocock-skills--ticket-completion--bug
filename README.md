# Patch: mattpocock-skills ticket completion (upstream #508)

## The bug

`/implement` implements, reviews and commits, but never marks the ticket done. Nothing closes, so the frontier that `/to-tickets` and `/wayfinder` rely on never advances. `/implement-spec` says "resolve each ticket the way the issue tracker closes work", but the local-markdown tracker template defines no close operation. Details: `.scratch/the bug.md`.

The plugin auto-updates, so editing the installed files by hand gets overwritten. These scripts re-apply the edit on demand and can remove it again.

## What the patch changes

It appends a clearly marked block (`<!-- mp-patch:<name> begin/end -->`) to five files in the installed plugin. Nothing existing is modified.

| File | Added |
| --- | --- |
| `implement/SKILL.md` | A "Completing the ticket" section: verify acceptance criteria, close per the tracker doc (GitHub/GitLab: resolution comment naming the commit, then close; local: tick criteria, `Status: resolved`, closing note), defer to the PR when `Closes #N` will do it, never close a parent ticket (flag it for review), report the outcome. |
| `implement-spec/SKILL.md` | A "Resolving tickets" detail for step 8 with the same rules. |
| `issue-tracker-local.md` | A "Close a ticket" convention: `Status: resolved` / `wontfix` plus a closing note. |
| `issue-tracker-github.md`, `issue-tracker-gitlab.md` | A "Complete a ticket" line (`gh issue close --comment`, `glab issue note` + `close`). |

Design choices:

- **`resolved`, not `done`.** The local template unblocks dependents only when a blocker is `resolved`, so `done` would keep them blocked.
- **Self-sufficient.** `implement` carries fallback close rules, so it works even when your repo's existing `docs/agents/issue-tracker.md` (generated earlier from the old templates) has no close operation. The template edits only affect repos you set up *after* patching; re-run `/setup-matt-pocock-skills` to refresh one.
- **No new triage label.** Adding a `done` label (a suggestion in the thread) conflicts with the `resolved` convention, so it is left out.
- **Not a workflow mandate.** Where a PR closes the ticket, the patch defers to it.

## Usage

Linux and macOS share the bash scripts; Windows uses PowerShell.

```bash
scripts/patch.sh            # apply (idempotent, safe to re-run after every plugin update)
scripts/patch.sh --check    # report only; exit 1 if anything is unpatched
scripts/unpatch.sh          # remove the added blocks, restoring the original text exactly
```

```powershell
.\scripts\patch.ps1 [-Check]
.\scripts\unpatch.ps1
```

Both target the newest version under `~/.claude/plugins/cache/*/mattpocock-skills/` (`%USERPROFILE%\.claude` on Windows; honors `CLAUDE_CONFIG_DIR`). Override with `--dir <path>` / `-Dir <path>` or the `MATTPOCOCK_SKILLS_DIR` environment variable (see `common/config.env`). Restart Claude Code (or start a new session) after patching so skills reload.

## After a plugin update

1. Run `scripts/patch.sh --check`. If it says `NEEDS`, run `scripts/patch.sh`.
2. If upstream may have fixed or reworded things, paste `prompts/check-patch-needed.md` into an agent. It does a fuzzy, read-only comparison and tells you whether to re-patch, unpatch, or adjust.

## Layout

```
common/config.env        shared settings (plugin location, marker name)
common/manifest.txt      which file gets which fragment
common/fragments/*.md    the text that gets appended (edit these to change the patch)
scripts/                 patch/unpatch for bash (lib.sh) and PowerShell (lib.ps1)
prompts/                 manual agent prompt for post-update checks
```

To add or change a patch, edit a fragment or add a manifest line; the scripts need no changes. After changing a fragment, run `unpatch` before `patch` (existing blocks are detected by marker, not content).

## Status

The bash scripts were tested on a copy of the 1.3.1 skills: check, patch, re-patch, and unpatch restores every file byte-for-byte. The PowerShell scripts were written but **not run** (no PowerShell on the dev machine); try `-Check` first on Windows. macOS was not tested; the script sticks to POSIX tools and avoids GNU-only flags.
