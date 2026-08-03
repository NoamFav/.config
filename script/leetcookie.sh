#!/usr/bin/env bash
# leetcookie — pull LEETCODE_SESSION + csrftoken out of Zen/Firefox and put the
# assembled Cookie header on the clipboard, ready for :Leet cookie update
#
# usage: leetcookie [profile-dir]

set -euo pipefail

PROFILES="${1:-$HOME/Library/Application Support/zen/Profiles}"

command -v sqlite3 >/dev/null || { echo "sqlite3 not found" >&2; exit 1; }

# newest cookies.sqlite wins — Zen ships more than one profile dir
JAR=$(find "$PROFILES" -maxdepth 2 -name cookies.sqlite -print0 2>/dev/null \
      | xargs -0 ls -t 2>/dev/null | head -1)

[ -n "$JAR" ] || { echo "no cookies.sqlite under $PROFILES" >&2; exit 1; }

TMP=$(mktemp -t leetcookie)
trap 'rm -f "$TMP"' EXIT
cp "$JAR" "$TMP"          # browser holds a lock on the live file

get() {
  sqlite3 "$TMP" "SELECT value FROM moz_cookies
                  WHERE host LIKE '%leetcode.com' AND name='$1'
                  ORDER BY lastAccessed DESC LIMIT 1;"
}

S=$(get LEETCODE_SESSION)
C=$(get csrftoken)

[ -n "$S" ] || { echo "no LEETCODE_SESSION — are you logged in?" >&2; exit 1; }
[ -n "$C" ] || { echo "no csrftoken" >&2; exit 1; }

printf 'csrftoken=%s; LEETCODE_SESSION=%s' "$C" "$S" | pbcopy

# session is a JWT: base64url payload holds the expiry
EXP=$(printf '%s' "$S" | cut -d. -f2 \
      | tr '_-' '/+' | sed -e 's/$/===/' \
      | base64 -d 2>/dev/null | sed -n 's/.*"_session_expiry":\([0-9]*\).*/\1/p' || true)

echo "copied — csrf ${#C} chars, session ${#S} chars"
[ -n "$EXP" ] && echo "expires $(date -r "$EXP" '+%a %d %b %H:%M')"

exit 0
