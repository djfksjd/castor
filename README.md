<div align="center">

# ⚔️ ironcode

**A production-grade engineering gate for AI coding agents.**

*One discipline that produces and protects production-grade code — security,
resource safety, backend cost, defensive edges, and evidence that the work is
actually done.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#install--claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#install--codex-cli)

**English** · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md)

</div>

---

## Why

AI agents write plausible code fast — and skip the same checks humans skip
under time pressure: the undisposed stream, the query in a loop, the `catch {}`,
the "should work now" with nothing actually run.

**ironcode** is not a style guide. It is a *gate*. It forces the checks that
get skipped, and it forbids claiming "done" without observable proof.

## The Iron Laws

| # | Law | Meaning |
|---|-----|---------|
| 1 | **Evidence before claims** | Never say "done / fixed / works" without fresh test, build, or run output. |
| 2 | **Spec before style** | First prove it solves the *right* problem; only then critique quality. |
| 3 | **Root cause before fix** | Reproduce and trace before patching. Symptom-patching is failure. |
| 4 | **Own analysis before external input** | Verify every linter/tool/agent finding against the actual code. |
| 5 | **Cost is a correctness property** | N+1 queries and unbounded fetches are *defects*, not "optimizations for later". |

## The five quality dimensions

Reference files load **on demand** — a one-line change never pulls in a
thousand lines of checklist.

| Dimension | Reference | Catches |
|---|---|---|
| 🔐 Security | [`references/security.md`](references/security.md) | Secrets, injection, authz/RLS, SSRF, OWASP Top 10 |
| 🧹 Resource safety | [`references/resource-safety.md`](references/resource-safety.md) | Leaked listeners, streams, timers, controllers, unbounded caches |
| 💸 Data access & cost | [`references/data-access.md`](references/data-access.md) | N+1, missing pagination, over-fetching, schema drift, missing indexes |
| 🛡️ Defensive coding | [`references/defensive.md`](references/defensive.md) | Null/edge cases, swallowed errors, races, idempotency |
| 🧭 Maintainability | [`references/checklist.md`](references/checklist.md) | Naming, size, duplication, dead code — plus the full gate checklist |
| 🚀 Ship-readiness | [`references/ship-readiness.md`](references/ship-readiness.md) | Release scope: testing strategy, observability, deploy compatibility, supply chain, privacy |

## How it works

The skill is **adaptive** — it detects which mode the agent is in:

```
PLAN   →  design the checks in before writing
BUILD  →  apply the patterns while writing (teardown written with every resource)
GATE   →  spec → diagnostics → five dimensions → verify → report with evidence
```

Every finding is concrete and actionable:

```
🔴 home_controller.dart:120 — fetches all rows (no limit), re-runs every rebuild.
   Fix: keyset pagination + in-flight guard + cache.
Verification: flutter analyze → 0 issues · make test → 250 passed
Verdict: CHANGES NEEDED
```

## Install — Claude Code

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.claude/skills/ironcode
```

Then invoke with `/ironcode`, or just ask for a *production-grade / rigorous /
leak-free* implementation or review — the skill self-triggers on its
description.

## Install — Codex CLI

Codex CLI reads the same open `SKILL.md` skill format (the old
`~/.codex/prompts` custom prompts are deprecated). Depending on your Codex
version, the user skill directory is `~/.codex/skills` or `~/.agents/skills`:

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.codex/skills/ironcode
# or
git clone https://github.com/djfksjd/ironcode.git ~/.agents/skills/ironcode
```

Invoke via the skill selector (`/skills`) or `$ironcode`.

## Scope

Language- and stack-agnostic by design: patterns are given for
Flutter/Dart, JS/TS, C#/Java/Kotlin, Go, Rust, and SQL/Postgres (incl.
Supabase RLS). Examples lean on real production incidents; adapt the
specifics to your stack.

## Severity rubric

| | Severity | Disposition |
|---|---|---|
| 🔴 | Security hole, data loss, crash, leak, unbounded cost | Fix before merge |
| 🟠 | Real bug, strong smell, missing edge handling | Fix before merge |
| 🟡 | Style, minor naming, optional cleanup | When convenient |
| 🔵 | Optional improvement | Author's call |

> Findings are ranked by **severity × exploitability × blast radius** — never
> inflated, never flattened.

## License

[MIT](LICENSE)
