#!/usr/bin/env sh
# Runs hooks/zied-mode.sh against a table of prompts. Usage: sh tests/hook.test.sh
set -u
hook="$(cd -- "$(dirname -- "$0")/.." && pwd)/hooks/zied-mode.sh"
CLAUDE_CONFIG_DIR=$(mktemp -d)
export CLAUDE_CONFIG_DIR
fails=0

# expect <session> <prompt-json-string> <ON|OFF|SILENT>
expect() {
  out=$(printf '{"session_id":"%s","cwd":"/tmp/stop zied mode","hook_event_name":"UserPromptSubmit","prompt":"%s"}' "$1" "$2" | sh "$hook")
  case "$out" in
    *"is ON"*) got=ON ;;
    *"is OFF"*) got=OFF ;;
    "") got=SILENT ;;
    *) got="OTHER: $out" ;;
  esac
  if [ "$got" = "$3" ]; then echo "ok    $1 | $2 -> $3"; else echo "FAIL  $1 | $2 -> expected $3, got $got"; fails=$((fails + 1)); fi
}

expect s1 'hello' SILENT
expect s1 'how do I stop zied mode?' SILENT
expect s1 '/zstack:zied-mode fix the bug' ON
expect s1 'continue' ON
expect s2 'continue' SILENT
expect s1 'ok, Stop Zied-Mode now' OFF
expect s1 'continue' SILENT
expect s3 '/zied-mode' ON
expect s4 '/zied-modeling' SILENT
expect s5 '\n /zstack:zied-mode do it' ON
expect s6 '/zstack:zied-mode do not stop zied mode' ON

rm -rf "$CLAUDE_CONFIG_DIR"
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
