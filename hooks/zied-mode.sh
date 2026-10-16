#!/usr/bin/env sh
# UserPromptSubmit hook. Keeps zied-mode on for one session:
# a prompt starting with /zstack:zied-mode (or /zied-mode) turns it on,
# a prompt containing "stop zied mode" turns it off, and every prompt in between gets a short reminder.
# Pure POSIX sh, no jq. Never blocks the prompt: every path exits 0.

input=$(cat) || exit 0

session=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -n 1)
[ -n "$session" ] || exit 0

# Claude Code sends the prompt as the last field, so the rest of the JSON after "prompt":" is the prompt.
prompt=$(printf '%s' "$input" | tr '\n' ' ' | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"//p' |
  sed -E 's/^([[:space:]]|\\[nt])+//' | tr '[:upper:]' '[:lower:]')

state_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/zstack/sessions"
flag="$state_dir/$session"

case "$prompt" in
  '/zied-mode"'* | '/zied-mode '* | '/zied-mode\'* | '/zstack:zied-mode"'* | '/zstack:zied-mode '* | '/zstack:zied-mode\'*)
    mkdir -p "$state_dir" 2>/dev/null && : >"$flag" 2>/dev/null
    if [ ! -f "$flag" ]; then
      echo "zstack could not save the zied-mode flag in $state_dir, so the mode applies to this message only."
      exit 0
    fi
    find "$state_dir" -type f -mtime +14 -exec rm -f {} + 2>/dev/null
    ;;
  *'stop zied mode'* | *'stop zied-mode'*)
    if [ -f "$flag" ] && rm -f "$flag" 2>/dev/null; then
      echo "zied-mode is OFF for this session. Work normally from now on."
    fi
    exit 0
    ;;
esac

[ -f "$flag" ] || exit 0
touch "$flag" 2>/dev/null

root=$(cd -- "$(dirname -- "$0")/.." 2>/dev/null && pwd) || exit 0
skill="$root/skills/zied-mode/SKILL.md"

printf 'zied-mode is ON for this session. Follow the zied-mode skill at %s. If its text is not in your context (for example after compaction), Read that file before you act. "new task" means re-match a playbook. The user turns the mode off with "stop zied mode".\n' "$skill"
