# Defensive coding (ironcode reference)

Load when handling external input, async results, optionals, collections, or anything
that can fail. The reviewer's question is not "does this work?" but **"how could this be
broken or abused?"**

## Null / absence
- Check null/undefined/empty before dereferencing. Don't blindly force-unwrap
  (Dart/TS `!`) or downcast unchecked (Dart `as`, TS `as` without a guard) —
  handle the null/mismatch branch or justify why it's impossible.
- Distinguish "absent", "empty", and "zero" — they often need different handling.
- Provide safe defaults; fail closed, not open (deny on uncertainty for anything
  security/permission related).

## Edge cases (enumerate before coding)
- Empty collection, single element, huge collection.
- Min/max/zero/negative; off-by-one at boundaries.
- Duplicate / out-of-order / stale data.
- Unicode, very long strings, whitespace-only, emoji, RTL.
- Slow network, offline, partial response, timeout, retry.
- First run / empty state / not-logged-in.

## Errors
- Handle the error path, don't swallow it — **no empty `catch {}`**. Log with context;
  surface a user-meaningful message; don't leak internals/stack traces to the user.
- Catch specific exceptions, not bare catch-all that hides bugs.
- Release resources in `finally` so the error path doesn't leak (see resource-safety).
- Decide batch semantics deliberately: independent items (imports, notifications)
  → isolate failures and report per-item; atomic operations (payments, inventory,
  migrations) → all-or-nothing in a transaction. Either is fine; drifting into
  one by accident is the bug.

## Async & concurrency
- Guard state updates after `await` with liveness checks (`if (!mounted) return;`).
- Races: double-tap submitting twice, overlapping refreshes, page N+1 firing twice —
  add in-flight guards / debounce / idempotency keys.
- Cancel obsolete work (search-as-you-type: cancel the previous request).
- Don't `await` in a way that serializes independent calls — but don't fire unbounded
  parallelism either.

## Input boundaries / validation
- Validate at the trust boundary (API edge, form submit) AND rely on server-side checks;
  client validation is UX, not security.
- Enforce length/range/format limits; reject rather than truncate silently when it matters.
- Treat all external data (params, responses, deep links, files) as hostile until validated.

## Idempotency & state
- Operations that can be retried (payments, sends, creates) need idempotency or dedupe.
- Don't assume order of async completions; don't assume a widget/screen still exists.

## Finding shape
```
🟠 chat_controller.dart:64 — response.data force-unwrapped; null on timeout crashes the
   screen. Fix: null-check, show retry state, keep the controller mounted-guarded.
```
