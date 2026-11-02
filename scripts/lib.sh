# Shared bash helpers for patch.sh / unpatch.sh (Linux + macOS). Sourced, not run.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cfg() { sed -n "s/^$1=//p" "$ROOT/common/config.env" | head -n1; }
MARKER="$(cfg MARKER_PREFIX)"

# Echo the plugin version dir to patch: --dir arg > env override > newest installed version.
find_plugin_dir() {
  local override_env dir; override_env="$(cfg OVERRIDE_ENV)"
  if [ -n "${1:-}" ]; then dir="$1"
  elif [ -n "${!override_env:-}" ]; then dir="${!override_env}"
  else
    local base="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    # shellcheck disable=SC2086
    dir="$(ls -d $base/$(cfg PLUGIN_CACHE_GLOB) 2>/dev/null | awk -F/ '{print $NF"\t"$0}' \
      | sort -t. -k1,1n -k2,2n -k3,3n | tail -n1 | cut -f2-)"
  fi
  [ -n "$dir" ] && [ -d "$dir/skills" ] || { echo "mattpocock-skills not found (pass --dir <version dir>)" >&2; return 1; }
  echo "$dir"
}

# Call "$1 <target> <fragment path> <fragment name>" for each manifest entry.
each_entry() {
  local target frag
  while IFS='|' read -r target frag; do
    case "$target" in ''|'#'*) continue;; esac
    "$1" "$target" "$ROOT/common/fragments/$frag" "${frag%.md}"
  done < "$ROOT/common/manifest.txt"
}

is_patched() { grep -qF "<!-- $MARKER:$2 begin -->" "$1"; }

# Remove a patched block, plus the blank line patch.sh put before it.
strip_block() { # file name
  local tmp; tmp="$(mktemp)"
  awk -v b="<!-- $MARKER:$2 begin -->" -v e="<!-- $MARKER:$2 end -->" '
    { lines[++n]=$0 }
    END { skip=0; out=0
      for (i=1;i<=n;i++) {
        if (lines[i]==b) { skip=1; if (out>0 && buf[out]=="") out--; continue }
        if (skip) { if (lines[i]==e) skip=0; continue }
        buf[++out]=lines[i]
      }
      for (i=1;i<=out;i++) print buf[i] }' "$1" > "$tmp" && cat "$tmp" > "$1"; rm -f "$tmp"
}
