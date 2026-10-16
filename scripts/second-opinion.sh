#!/usr/bin/env bash
# Runs an external CLI reviewer in read-only mode and fails if it touched the working tree.
#
#   second-opinion.sh list
#   second-opinion.sh <codex|devin|copilot|cursor> <prompt-file> <out-file> [model]
#
# Exit codes: 0 ok, 2 usage, 3 reviewer CLI not installed, 4 working tree changed, 5 reviewer failed.
set -u

bin_for() {
  case "$1" in
    codex) echo codex ;;
    cursor) echo agent ;;
    devin) echo devin ;;
    copilot) echo copilot ;;
    *) return 1 ;;
  esac
}

if [ "${1:-}" = list ]; then
  for r in codex devin copilot cursor; do
    if command -v "$(bin_for "$r")" >/dev/null 2>&1; then echo "$r available"; else echo "$r missing"; fi
  done
  exit 0
fi

reviewer=${1:-}
prompt=${2:-}
out=${3:-}
model=${4:-}

bin=$(bin_for "$reviewer") || { echo "unknown reviewer '$reviewer'. Use codex, devin, copilot or cursor." >&2; exit 2; }
if [ ! -f "$prompt" ] || [ -z "$out" ]; then
  echo "usage: $0 <codex|devin|copilot|cursor> <prompt-file> <out-file> [model]" >&2
  exit 2
fi
command -v "$bin" >/dev/null 2>&1 || { echo "$reviewer unavailable: '$bin' is not on PATH" >&2; exit 3; }

in_git=false
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && in_git=true
snapshot() {
  $in_git || return 0
  git status --porcelain=v1 --untracked-files=all
  git diff HEAD 2>/dev/null | shasum
}
before=$(snapshot)

log="$out.log"
model_args=()
case "$reviewer" in
  codex)
    [ -n "$model" ] && model_args=(-m "$model")
    codex exec -s read-only --skip-git-repo-check ${model_args[@]+"${model_args[@]}"} -o "$out" - <"$prompt" >"$log" 2>&1
    ;;
  cursor)
    [ -n "$model" ] && model_args=(--model "$model")
    agent -p --mode ask --trust --output-format text ${model_args[@]+"${model_args[@]}"} "$(cat "$prompt")" >"$out" 2>"$log"
    ;;
  devin)
    [ -n "$model" ] && model_args=(--model "$model")
    devin -p --prompt-file "$prompt" --permission-mode auto --respect-workspace-trust false ${model_args[@]+"${model_args[@]}"} >"$out" 2>"$log"
    ;;
  copilot)
    [ -n "$model" ] && model_args=(--model "$model")
    copilot -p "$(cat "$prompt")" -s --no-ask-user --no-color --deny-tool write --deny-tool shell ${model_args[@]+"${model_args[@]}"} >"$out" 2>"$log"
    ;;
esac
status=$?

after=$(snapshot)
if [ "$before" != "$after" ]; then
  echo "$reviewer changed the working tree. Inspect 'git status' and discard its edits before trusting this review." >&2
  exit 4
fi
if [ "$status" -ne 0 ] || [ ! -s "$out" ]; then
  echo "$reviewer failed (exit $status). Last lines of $log:" >&2
  tail -n 20 "$log" >&2
  exit 5
fi
echo "$reviewer review written to $out"
