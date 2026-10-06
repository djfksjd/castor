# Correctness and robustness (CASTOR reference)

Load when the change alters behavior or state, handles external input or
failure, runs concurrently, retries, or converts between representations. The
question is not "does it work?" but "under what reachable condition is it
wrong?"

## Invariants and where they are enforced

For every state-changing operation, state the invariant ("stock never goes
negative", "one active subscription per user", "an order is charged once") and
the boundary that enforces it. An invariant enforced only in a UI or in one
process is not enforced.

- **Lost update.** Read, compute, write back, with another writer in between.
  Enforce with an atomic read-modify-write statement, a checked version
  column, or a lock or transaction that covers every writer. A constraint
  helps only if it expresses the whole invariant: `stock >= 0` does not stop
  two decrements from overwriting each other.
- **Check-then-act.** "If not exists then insert" as two steps: use a unique
  constraint and handle the conflict. "If balance ≥ x then debit" as two
  steps: use one atomic conditional update, or lock the row.
- **Idempotency.** Anything retried (payments, sends, creates, webhook
  handlers, queue consumers) needs a durable dedupe key claimed atomically. Two
  concurrent requests with the same key must not both proceed.
- **Client-side guards are UX.** A disabled button or an in-flight flag reduces
  duplicates; it does not establish a server-side invariant.

## Partial failure and external side effects

List the systems one operation touches. A database transaction makes steps
atomic only inside that database.

- For a write plus an external effect (charge, email, message publish), decide
  what happens if the process dies between them. Use an outbox, a compensating
  action or reconciliation; choose deliberately.
- Distinguish **failed** from **unknown outcome**. A timeout on a write does
  not mean it did not happen; retrying it without idempotency duplicates it.
- Batch semantics are a decision: independent items are isolated and reported
  per item; operations that must be all-or-nothing share one transactional
  boundary. Drifting into one by accident is the defect.

## Failure amplification

When the change adds or alters outbound calls, workers or queues:

- Every wait has a timeout, and the whole operation has a deadline.
- Retries are bounded, backed off, and only for errors that can succeed on
  retry. Retries at several layers multiply; count the worst case.
- Concurrency and queue depth are bounded. Cancellation propagates to work the
  caller abandoned.

## Representation

At every conversion and comparison, name the unit, precision and meaning.

- **Money:** integer minor units or a decimal type, never binary floating
  point; rounding mode and where it is applied.
- **Numbers:** integer width and sign, overflow, precision loss across JSON
  (integers above 2^53), division by zero.
- **Time:** time zone, DST, instant versus local date, clock skew, wraparound
  of tick counters.
- **Units and scaling:** milli versus micro, bytes versus bits, fixed-point
  scale, degrees versus radians.
- **Absence:** null, empty, zero and missing often need different handling;
  null ordering in sort keys.
- **Text:** encoding, normalization, case folding, very long or whitespace-only
  input.

Check one boundary example that separates the intended representation from the
implemented one.

## Absence and edges

Enumerate what applies before judging: empty, single and very large
collections; minimum, maximum, zero and negative values; off-by-one at
boundaries; duplicate, out-of-order and stale data; first run, empty state and
unauthenticated state; slow network, offline, partial response.

A force-unwrap or unchecked cast is a finding only when the null or mismatched
case is reachable; an invariant that rules it out is a fine justification.

## Errors

- An error path must leave the system in a known state and tell someone who
  can act: a user-meaningful message, or a log with context.
- Swallowing an error is a defect when it hides a failure the caller needs to
  know about. Deliberate suppression (cancellation, best-effort cleanup) is
  fine; a one-line reason is enough.
- Catch what you can handle; a catch-all that hides programming errors is a
  finding when it changes behavior.
- Release resources on the error path too (see `resource-safety.md`).
- Do not leak internals or stack traces to end users.
- Fail closed for anything that decides access or safety.

## Input boundaries

Validate at the trust boundary and enforce on the server; client validation is
for the user's convenience. Enforce length, range and format, and reject rather
than silently truncate when the difference matters. Data from parameters,
responses, deep links, files, buses and radios is hostile until validated.

## Async in user interfaces

Results can arrive after the screen is gone or after a newer request: guard
state updates with a liveness check, cancel or ignore obsolete responses
(search-as-you-type), and do not assume completion order.

## Finding shape

```
F1 🔴 inventory/reserve.ts:48 — two concurrent checkouts for the last unit
   both read stock=1 and both write stock=0 → oversold order.
   Evidence: static trace; read at :41 and write at :48 are separate
   statements with no lock, constraint or version check.
   Fix: single `update … set stock = stock - 1 where id = $1 and stock > 0`
   and treat zero rows affected as sold out.
```
