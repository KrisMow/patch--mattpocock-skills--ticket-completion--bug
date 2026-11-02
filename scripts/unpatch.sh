#!/usr/bin/env bash
# Remove every block added by patch.sh, restoring the original skill text.
# Usage: unpatch.sh [--dir <plugin version dir>]
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
dir=""; if [ "${1:-}" = "--dir" ]; then dir="$2"; fi
PLUGIN="$(find_plugin_dir "$dir")"; echo "Plugin: $PLUGIN"
revert() {
  local f="$PLUGIN/$1"
  if [ -f "$f" ] && is_patched "$f" "$3"; then strip_block "$f" "$3"; echo "  REVERTED $1"
  else echo "  ok       $1 (not patched)"; fi
}
each_entry revert
