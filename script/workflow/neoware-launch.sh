#!/usr/bin/env zsh

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export TERM="xterm-256color"

NEOWARE_ROOT="${NEOWARE_ROOT:-$HOME/Neoware}"
RUNNER="${HOME}/.config/aerospace/run.sh"

# --- guards ---------------------------------------------------------------
if [[ ! -d "$NEOWARE_ROOT" ]]; then
  print -r -- "Neoware root not found: $NEOWARE_ROOT"
  exit 1
fi
if [[ ! -x "$RUNNER" ]]; then
  print -r -- "Runner not executable or missing: $RUNNER"
  exit 1
fi

# --- helpers --------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1 }

# list all projects exactly one level beneath the top-level buckets
# e.g., Neoware/00-apps/Iris (but not deeper)
collect_projects() {
  # mindepth=2,maxdepth=2 => only bucket's direct children
  # exclude hidden dirs
  find "$NEOWARE_ROOT" -mindepth 2 -maxdepth 2 -type d \
    ! -name '.*' -print 2>/dev/null | sort -f
}

# prompt to choose one item from stdin; prefer fzf
pick_one() {
  if have fzf; then
    fzf --prompt="Select project > " --height=40% --reverse --border
  else
    # dumb menu fallback
    typeset -a items
    items=("${(@f)$(cat)}")
    if (( ${#items[@]} == 0 )); then
      return 1
    fi
    local i=1
    for it in "${items[@]}"; do
      printf "%2d) %s\n" "$i" "$it"
      ((i++))
    done
    printf "Choice (1-%d): " "${#items[@]}" >&2
    local sel
    read -r sel
    if [[ "$sel" == <-> ]] && (( sel >= 1 && sel <= ${#items[@]} )); then
      print -r -- "${items[$sel]}"
    else
      return 1
    fi
  fi
}

# resolve a project directory from an input token (exact or fuzzy)
# echo the chosen path on success
resolve_project() {
  local token="$1"
  local -a all
  all=("${(@f)$(collect_projects)}")
  (( ${#all[@]} )) || return 1

  # First: exact (case-insensitive) match on basename
  local token_l="${token:l}"
  local -a exact
  for p in "${all[@]}"; do
    if [[ "${p:t:l}" == "$token_l" ]]; then
      exact+=("$p")
    fi
  done
  if (( ${#exact[@]} == 1 )); then
    print -r -- "${exact[1]}"
    return 0
  fi

  # Next: substring (case-insensitive) on basename
  local -a fuzzy
  for p in "${all[@]}"; do
    if [[ "${p:t:l}" == *"${token_l}"* ]]; then
      fuzzy+=("$p")
    fi
  done

  if (( ${#fuzzy[@]} == 1 )); then
    print -r -- "${fuzzy[1]}"
    return 0
  elif (( ${#fuzzy[@]} > 1 )); then
    # Let user choose among candidates
    print -r -- "${(F)fuzzy}" | pick_one
    return $?
  fi

  # Finally: allow matching on full relative path fragment
  local -a pathmatch
  for p in "${all[@]}"; do
    local rel="${p#$NEOWARE_ROOT/}"
    if [[ "${rel:l}" == *"$token_l"* ]]; then
      pathmatch+=("$p")
    fi
  done
  if (( ${#pathmatch[@]} == 1 )); then
    print -r -- "${pathmatch[1]}"
    return 0
  elif (( ${#pathmatch[@]} > 1 )); then
    print -r -- "${(F)pathmatch}" | pick_one
    return $?
  fi

  return 1
}

# --- main -----------------------------------------------------------------
proj_arg="${1:-}"

# Collect once (used for no-arg flow too)
projects=("${(@f)$(collect_projects)}")

if [[ -z "$proj_arg" ]]; then
  # No arg: interactive selection
  if (( ${#projects[@]} == 0 )); then
    print -r -- "No projects found under $NEOWARE_ROOT"
    exit 1
  fi
  chosen="$(print -r -- "${(F)projects}" | pick_one)" || {
    print -r -- "Selection cancelled."
    exit 1
  }
else
  # Try to resolve from argument
  chosen="$(resolve_project "$proj_arg")" || {
    print -r -- "Project '$proj_arg' not found under $NEOWARE_ROOT"
    exit 1
  }
fi

# cd into the project
cd -- "$chosen" || {
  print -r -- "Failed to cd into: $chosen"
  exit 1
}

# Derive the canonical project name (basename)
proj_name="${PWD:t}"

# Run your launcher with the resolved project name
exec "$RUNNER" "$proj_name"
