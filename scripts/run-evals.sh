#!/usr/bin/env bash
# Behavioral smoke run: gate every eval case with the skill, review-only.
# Usage: scripts/run-evals.sh codex|claude
set -eu
agent="${1:-codex}"
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/skill" "$work/cases"
cp "$root/SKILL.md" "$work/skill/"
cp -R "$root/references" "$work/skill/"
cp -R "$root/evals/cases/." "$work/cases/"   # expected.md is deliberately not copied

prompt='Read skill/SKILL.md and follow it exactly, loading the references it routes you to.
Then run its GATE, review-only, separately on every file under cases/ (each file is an independent artifact; files in the same folder are unrelated to each other).
Do not modify any file. Nothing here can be executed, so use static evidence.
For each file output the report in the format the skill defines, headed by the file path, and add one line "References loaded: ...".'

out="$root/evals/last-run.md"
case "$agent" in
  codex)
    (cd "$work" && codex exec --sandbox read-only --ephemeral --skip-git-repo-check -o "$out" "$prompt" >/dev/null 2>"$work/err.log") \
      || { tail -20 "$work/err.log" >&2; exit 1; } ;;
  claude)
    (cd "$work" && claude -p "$prompt" --tools "Read,Glob,Grep" --allowedTools "Read,Glob,Grep" \
      --strict-mcp-config --mcp-config '{"mcpServers":{}}' > "$out") ;;
  *) echo "usage: $0 codex|claude" >&2; exit 2 ;;
esac
echo "report: $out  (grade against evals/expected.md)"
