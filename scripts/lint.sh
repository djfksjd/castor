#!/usr/bin/env bash
# Structural checks for the CASTOR skill. No model required.
set -u
cd "$(dirname "$0")/.." || exit 2

fail=0
err() { printf 'FAIL  %s\n' "$1"; fail=1; }
ok()  { printf 'ok    %s\n' "$1"; }

# 1. Frontmatter
name=$(awk '/^---$/{n++; next} n==1 && /^name:/{print $2}' SKILL.md)
[ "$name" = "castor" ] && ok "frontmatter name is castor" || err "frontmatter name is '$name', expected castor"

desc_len=$(awk '/^---$/{n++; next} n==1' SKILL.md | sed -n '/^description:/,$p' | sed '1d' | tr -s ' \n' ' ' | wc -m | tr -d ' ')
[ "$desc_len" -gt 0 ] && [ "$desc_len" -le 1024 ] && ok "description length $desc_len <= 1024" || err "description length $desc_len (must be 1..1024)"

# 2. Size budget for the always-loaded file
lines=$(wc -l < SKILL.md | tr -d ' ')
[ "$lines" -le 230 ] && ok "SKILL.md is $lines lines (budget 230)" || err "SKILL.md is $lines lines (budget 230)"

# 3. Every reference path mentioned anywhere resolves
missing=0
for f in SKILL.md references/*.md references/domains/*.md; do
  for ref in $(grep -o 'references/[A-Za-z0-9_/-]*\.md' "$f" | sort -u); do
    [ -f "$ref" ] || { err "$f mentions missing $ref"; missing=1; }
  done
done
# bare cross-references such as `security.md` or `domains/firmware.md`
for f in references/*.md references/domains/*.md; do
  for ref in $(grep -o '`[a-z/-]*\.md`' "$f" | tr -d '`' | sort -u); do
    [ -f "references/$ref" ] || [ -f "references/domains/$ref" ] || { err "$f mentions missing $ref"; missing=1; }
  done
done
[ "$missing" -eq 0 ] && ok "all reference paths resolve"

# 4. Every reference file is routed from SKILL.md
unrouted=0
for f in references/*.md references/domains/*.md; do
  grep -Fq -- "$f" SKILL.md || { err "$f is not routed from SKILL.md"; unrouted=1; }
done
[ "$unrouted" -eq 0 ] && ok "every reference is routed from SKILL.md"

# 5. Severity and decision rules have a single owner
dup=$(grep -l '\*\*BLOCKING\*\* |' references/*.md references/domains/*.md 2>/dev/null)
[ -z "$dup" ] && ok "severity table lives only in SKILL.md" || err "severity table duplicated in: $dup"

# 6. No leftover identifiers from the old name
stale=$(grep -rIl 'ironcode' . --exclude-dir=.git --exclude=CHANGELOG.md --exclude=lint.sh --exclude='README*' 2>/dev/null)
[ -z "$stale" ] && ok "no stale 'ironcode' identifiers" || err "stale 'ironcode' in: $stale"

# 7. Eval cases are listed in the key, and pairs are complete
for d in evals/cases/*/; do
  c=$(basename "$d")
  grep -Fq -- "$c" evals/expected.md || err "eval case $c has no entry in evals/expected.md"
  for side in a b; do
    [ "$side" = "b" ] && [ "$c" = "08-reviewed-content" ] && continue
    count=0
    for f in "${d}${side}".*; do [ -f "$f" ] && count=$((count + 1)); done
    [ "$count" -eq 1 ] || err "eval case $c needs exactly one '$side' fixture"
  done
done
ok "eval cases checked against expected.md"

# 8. README translations stay in step
base=$(grep -c '^## ' README.md 2>/dev/null)
for r in README.ko.md README.ja.md README.zh-CN.md; do
  [ -f "$r" ] || { err "$r missing"; continue; }
  n=$(grep -c '^## ' "$r")
  [ "$n" -eq "$base" ] || err "$r has $n sections, README.md has $base"
done
ok "README translations checked"

[ "$fail" -eq 0 ] && echo "lint: PASS" || echo "lint: FAIL"
exit "$fail"
