#!/usr/bin/env bash
# save as: brew-prune-candidates.sh
# usage:   ./brew-prune-candidates.sh 90   # days to look back (default 180)

set -euo pipefail
DAYS="${1:-180}"

echo "→ Scanning top-level formulas unused in last $DAYS days…"

HIST="${HISTFILE:-$HOME/.zsh_history}"
CUTOFF_EPOCH="$(date -v-"$DAYS"d +%s 2>/dev/null || date -d "-$DAYS days" +%s)"

# zsh history often has timestamps like: : 1724880000:0;command args
# we'll keep only lines with a timestamp newer than cutoff
if grep -qE '^: [0-9]+:' "$HIST" 2>/dev/null; then
  recent_hist="$(awk -v cut="$CUTOFF_EPOCH" -F: 'BEGIN{OFS=":"} $2 >= cut {print $0}' "$HIST" || true)"
else
  # fallback: no timestamps in history → just use whole file
  recent_hist="$(cat "$HIST" 2>/dev/null || true)"
fi

mapfile -t leaves < <(brew leaves | sort)
declare -a suspects=()

for pkg in "${leaves[@]}"; do
  cmd="$pkg"
  # guess a runnable name if the package name isn't the binary
  # (add your own mappings here if needed)
  case "$pkg" in
    gnuplot) cmd="gnuplot" ;;
    ripgrep) cmd="rg" ;;
    findutils) cmd="gfind" ;;
    coreutils) cmd="gdate" ;;    # representative
    git-delta) cmd="delta" ;;
    neovim) cmd="nvim" ;;
    oh-my-posh) cmd="oh-my-posh" ;;
    switchaudio-osx) cmd="SwitchAudioSource" ;;
    yazi) cmd="ya" ;;
    fd) cmd="fd" ;;
    eza) cmd="eza" ;;
    *) : ;;
  esac

  # seen in recent history?
  if ! printf '%s\n' "$recent_hist" | grep -Eq "(^|[ ;|&])$cmd([ ;|&]|$)"; then
    suspects+=("$pkg")
  fi
done

echo
echo "=== Candidates (top-level formulas NOT seen in your last $DAYS days of zsh history) ==="
printf '%s\n' "${suspects[@]}" | sort

echo
echo "=== Orphaned deps (safe to remove) — brew autoremove dry-run ==="
brew autoremove --dry-run || true

echo
echo "Tip: review before removing. To uninstall a batch:"
echo '  brew uninstall <name1> <name2> …'