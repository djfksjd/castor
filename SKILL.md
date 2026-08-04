---
name: ironcode
description: >-
  Production-grade engineering gate for writing OR reviewing code. Enforces
  security, resource safety (memory leaks, unclosed listeners/streams/timers),
  efficient data access (N+1, pagination/infinite-scroll, over-fetching, backend
  cost), defensive coding, and evidence-based verification. Use when the user
  invokes it (/ironcode), or asks for production-grade / secure / leak-free /
  cost-efficient code, or a rigorous review of a change. Self-detects whether
  you are about to write, are writing, or are reviewing, and applies the
  matching discipline. Language- and stack-agnostic.
---

# ironcode

A single discipline that produces and protects production-grade code. It does not
replace your judgment — it forces the checks that get skipped under time pressure:
security, resource leaks, backend cost, defensive edges, and *evidence* that the
work is actually done.

## How to use this skill

This skill is **adaptive**. First decide which mode you are in, then run that mode.
You may move through several modes in one task (PLAN → BUILD → GATE is the norm).

| Signal | Mode | What you do |
|---|---|---|
| Code not written yet; designing or about to implement | **PLAN** | Load the right reference files *before* writing, so quality is built in, not bolted on. |
| Actively writing/editing code | **BUILD** | Apply the Iron Laws and reference patterns as you go. |
| Code exists (a diff, a PR, "review this", or you just finished) | **GATE** | Run the review checklist, classify findings, verify, then report or fix. |

Announce the mode in one line, e.g. `ironcode · GATE on the current diff`.

Invocation is host-specific: Claude Code exposes this as `/ironcode` (and
auto-triggers on the description); Codex CLI exposes it via the skill selector
(`/skills`) or `$ironcode`. The discipline is identical in both.

## The Iron Laws (never violated)

1. **Evidence before claims.** Never say "done", "fixed", "works", or "secure"
   without fresh, observable proof (test/run/typecheck output, a query plan, a
   trace). Scale the verification to the risk: a constant rename needs a
   typecheck, a payment path needs tests and a trace. Capture the command, exit
   status, and the decisive lines — redact secrets/PII from anything you quote.
   If no verification path exists, say so plainly instead of bluffing.
2. **Spec before style.** First confirm the code solves the *right* problem and
   covers *all* the requirements — would the requester recognize this as what they
   asked for? Only then critique quality. A beautiful solution to the wrong problem
   fails. (Exception: security and data-loss findings you have already seen are
   always reported, even when spec fails — never hold those back.)
3. **Root cause before fix.** For any bug, reproduce it when feasible and trace
   the data flow to the actual cause before changing anything. When reproduction
   isn't feasible (CI-only failures, races, static findings), trace the mechanism
   instead and say what evidence you have. Symptom-patching is failure. If several
   fixes in a row fail, stop and re-examine the design — the architecture may be
   wrong, not your patch.
4. **Own analysis before external input.** Form your own conclusion first; never
   blindly adopt a linter's, a tool's, or another agent's finding. Verify each
   against the actual code.
5. **Cost is a correctness property.** A query that runs per-row in a loop,
   fetches unbounded rows, or refetches what it has is a *defect* when the data
   can grow with usage. Judge by workload: a query-in-loop over a bounded
   config table is a nit; the same loop over user data is a bug. Treat backend
   cost and resource leaks as bugs, sized by their real blast radius.

## The five quality dimensions

Every piece of code is judged on these five. Load the matching reference file
**on demand** — do not read all of them for a trivial change; read the ones the
code actually touches, and say which dimensions you did not examine.

1. **Security** → `references/security.md`
   Secrets, injection, authz/RLS, input validation, SSRF, crypto. OWASP Top 10.
2. **Resource safety** → `references/resource-safety.md`
   Memory leaks, undisposed controllers/listeners/streams/timers/subscriptions,
   unclosed handles, retain cycles, unbounded caches/growth.
3. **Data access & cost** → `references/data-access.md`
   N+1, pagination & infinite scroll, over-fetching (`select *`), missing indexes,
   redundant/duplicate requests, missing cache, write amplification, and **DB ↔ code
   matching** (queried tables/columns/types/RLS match the real schema, not assumed).
4. **Defensive coding** → `references/defensive.md`
   Null/undefined, edge cases, error handling, fail-safe vs fail-open, idempotency,
   concurrency/races, input boundaries. "How could this be broken or abused?"
5. **Maintainability** — covered inline in `references/checklist.md`
   Naming, function size, nesting, duplication, dead code, matching surrounding style.

For changes that ship a feature (not a spot fix), also load
`references/ship-readiness.md` — testing strategy, observability, deployment
compatibility, supply chain, and privacy. It is the release-scope companion to
the per-diff dimensions above.

## Workflow by mode

### PLAN
1. Restate the requirement in one line; list acceptance criteria that are
   *specific and testable* (not "works correctly" — that is theater).
2. Identify which of the five dimensions this change touches (a list endpoint →
   data-access + security; a screen with a controller → resource-safety; auth →
   security + defensive).
3. Read those reference files. Decide the approach so the checks are designed in.
4. Prefer the smallest change that satisfies the spec. No speculative features (YAGNI).

### BUILD
- Match the surrounding code's idiom, naming, and comment density.
- Apply reference patterns as you write — e.g. register every listener's removal in
  the same place you create it; paginate every user-data list query; parameterize
  every query.
- When you introduce a resource (stream/timer/controller/subscription), write its
  teardown in the same edit.

### GATE (review or self-check before claiming done)
1. **Scope the diff.** `git diff` (or the named files). Review only what changed,
   but read enough surrounding context to judge it. Decide the risk tier — it sets
   how deep the rest of the gate goes.
2. **Spec compliance first** (Iron Law 2). If it solves the wrong/partial problem,
   report that before quality nits — but still surface any security/data-loss
   findings you have already seen.
3. **Diagnostics.** Run available type-check/lint/IDE diagnostics on changed files.
   Zero new errors is the floor, not the goal.
4. **Walk the touched dimensions** against the changed code, using the reference
   files. Every finding cites `file:line`, a severity, and a concrete fix. Name
   the dimensions you skipped as not-applicable.
5. **Verify** (Iron Law 1): run the narrowest real check that proves the change —
   existing tests → typecheck/build → targeted command → manual steps. Capture the
   actual result (command + exit status + decisive output lines).
6. **Report or fix** per the user's request (see Output).

Full gate checklist and severity rubric: `references/checklist.md`.

## Severity rubric

| Severity | Meaning | Disposition |
|---|---|---|
| 🔴 **BLOCKING** | Reachable security hole, data loss, crash, leak, or cost that grows with usage. | Must fix before merge. |
| 🟠 **IMPORTANT** | Real bug or strong smell that will bite; missing edge handling. | Should fix before merge. |
| 🟡 **NIT** | Style, minor naming, optional cleanup. | Fix when convenient. |
| 🔵 **SUGGESTION** | Optional improvement worth considering. | Author's call. |

Severity is set by reachability and blast radius, not by category: an
unreachable exception path is not BLOCKING just because it says "crash", and an
app-lifetime singleton is not a leak. Prioritize security findings by
**severity × exploitability × blast radius** — a remotely-exploitable auth bypass
outranks a local-only info leak. Do **not** inflate (a missing doc comment is not
BLOCKING) or flatten (not everything is IMPORTANT).

## Output

Keep it tight and evidence-bearing. Default shape:

```
ironcode · <MODE> — <one-line scope>

Spec: <pass / what's missing>
Findings:
  🔴 file.ts:42 — <issue>. Fix: <concrete fix>.
  🟠 ...
Verification: <command run> → <exit status + decisive output>
Verdict: APPROVE | CHANGES NEEDED | UNVERIFIED (say what could not be checked)
```

If the user asked to fix (not just review), apply the BLOCKING/IMPORTANT findings
that are mechanical (a missing dispose, a parameterized query), then re-run
verification and report what changed. Findings that change product behavior,
schema, or architecture are *escalated with a proposed fix*, not silently applied.
Never claim a fix you did not verify.

## Anti-patterns this skill exists to prevent

- "Looks good to me" with no diagnostics run and no proof.
- Reviewing style while missing a SQL injection or an undisposed stream.
- "It should work now" — claiming completion without running anything.
- Rating everything HIGH, or everything LOW.
- Loading 1,000 lines of reference for a one-line change.
- Patching a symptom and moving on without finding the cause.
- Deferring pagination/caching decisions on user-growing data — decide them at
  spec time, deliberately, not by omission.
