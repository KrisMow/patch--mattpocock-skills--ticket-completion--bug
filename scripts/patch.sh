#!/usr/bin/env bash
# Apply the ticket-completion patch to the installed mattpocock-skills plugin.
# Usage: patch.sh [--check] [--dir <plugin version dir>]   (safe to re-run after plugin updates)
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
check=0; dir=""
while [ $# -gt 0 ]; do
  case "$1" in --check) check=1;; --dir) dir="$2"; shift;; *) echo "unknown arg $1" >&2; exit 2;; esac
  shift
done
PLUGIN="$(find_plugin_dir "$dir")"; echo "Plugin: $PLUGIN"
missing=0
apply() { # target fragment name
  local f="$PLUGIN/$1"
  [ -f "$f" ] || { echo "  SKIP    $1 (file not found; see prompts/check-patch-needed.md)"; return; }
  if is_patched "$f" "$3"; then echo "  ok      $1 (already patched)"; return; fi
  if [ "$check" = 1 ]; then echo "  NEEDS   $1"; missing=1; return; fi
  if [ -s "$f" ] && [ -n "$(tail -c1 "$f")" ]; then echo >> "$f"; fi
  { echo; echo "<!-- $MARKER:$3 begin -->"; cat "$2"; echo "<!-- $MARKER:$3 end -->"; } >> "$f"
  echo "  PATCHED $1"
}
each_entry apply
exit "$missing"
