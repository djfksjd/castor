# GATE checklist & rubric (ironcode reference)

The full pass for reviewing a diff or self-checking before claiming done. Walk it in
order. If spec fails at step 1, report that first — but any security/data-loss
finding already seen is still reported alongside it.

## 0. Scope
- [ ] Identify changed files (`git diff` / named files). Read enough context to judge.
- [ ] Decide the risk tier (docs/rename vs logic vs auth/payments/migration) — it
      sets how deep the rest of the gate goes.
- [ ] Note which of the five dimensions the change touches; load those reference
      files. Name the ones you skip as not-applicable.

## 1. Spec compliance (BLOCKING gate — Iron Law 2)
- [ ] Covers ALL stated requirements; solves the RIGHT problem.
- [ ] Nothing missing; nothing extra/speculative (YAGNI).
- [ ] Acceptance criteria are specific & testable, and met.
- If this fails → report it before quality nits (security/data-loss findings are
  still included).

## 2. Diagnostics (cheap, do early)
- [ ] Type-check / IDE diagnostics / lint on changed files — zero NEW errors.
- [ ] No leftover debug prints, `console.log`, `print()`, commented-out code, or
      dead code. TODOs are fine when they carry an issue/ticket reference; bare
      TODOs that hide unfinished spec work are findings.

## 3. Security (`references/security.md`)
- [ ] No secrets in code/history; deps audited if changed.
- [ ] Input parameterized/validated/escaped (injection, XSS, path traversal).
- [ ] Authorization checked server-side / RLS on every client-reachable table;
      not client-only.
- [ ] No sensitive data in logs; safe error messages.

## 4. Resource safety (`references/resource-safety.md`)
- [ ] Every controller/listener/subscription/stream/timer has a dispose/cancel path
      (app-lifetime singletons excepted — deliberately, not by accident).
- [ ] `dispose()`/`close()` present on stateful objects that create resources.
- [ ] State updates after await are liveness-guarded; no unbounded caches/growth.

## 5. Data access & cost (`references/data-access.md`)
- [ ] No N+1 / query-in-loop on data that grows with usage.
- [ ] User-data list reads are paginated (keyset for scroll) with in-flight guards;
      small bounded reference data may be fetched whole — as a stated decision.
- [ ] No over-fetch (`select *` for 3 cols; fetch-to-count); no refetch of held data.
- [ ] Indexes exist for the filters/orders run; realtime filtered & torn down.
- [ ] DB ↔ code matches: queried tables/columns exist; result types & nullability map to
      the model; migration committed & types regenerated; RLS grants what the query assumes.

## 6. Defensive (`references/defensive.md`)
- [ ] Null/empty/edge cases handled; no force-unwrap or unchecked cast without justification.
- [ ] No swallowed errors (`catch {}`); resources freed in `finally`.
- [ ] Races/double-submit/stale-async guarded.

## 7. Maintainability
- [ ] Matches surrounding idiom, naming, comment density.
- [ ] Functions reasonably small; nesting shallow; no copy-paste duplication.
- [ ] Names say what/why; no magic numbers without a named constant.

## 8. Verification (BLOCKING gate — Iron Law 1)
- [ ] Ran the narrowest real proof: existing tests → typecheck/build → targeted
      command → manual steps. Captured command + exit status + decisive output.
- [ ] If it failed, the failure is reported plainly. If unverifiable, that is stated
      and the verdict is UNVERIFIED, not APPROVE.

## Severity rubric
| Severity | Meaning | Disposition |
|---|---|---|
| 🔴 BLOCKING | Reachable security hole, data loss, crash, leak, usage-growing cost. | Fix before merge. |
| 🟠 IMPORTANT | Real bug / strong smell / missing edge. | Fix before merge. |
| 🟡 NIT | Style/minor naming/optional cleanup. | When convenient. |
| 🔵 SUGGESTION | Optional improvement. | Author's call. |

Severity follows reachability and blast radius, not category. Security ordering:
**severity × exploitability × blast radius**. Don't inflate; don't flatten.

## Verdict
- **APPROVE** — no BLOCKING/IMPORTANT; only NIT/SUGGESTION remain; verification ran.
- **CHANGES NEEDED** — any BLOCKING/IMPORTANT open. List them with `file:line` + fix.
- **UNVERIFIED** — review done but proof could not run (no test path, sandbox,
  missing env). Say exactly what was not checked.
- Every finding: `🔴 file:line — issue. Fix: concrete change.`
