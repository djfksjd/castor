# Data access and backend cost (CASTOR reference)

Load when the change reads or writes a database, calls an API, or renders a
list of data. The goal is correct data with bounded, proportionate work. Cost
defects are judged by workload: the same loop is harmless over a five-row
config table and a bug over user data.

## Cost defects

Each is a finding only with a plausible workload that makes it hurt.

- **N+1.** A query or request per item of a collection that grows with usage.
  Batch it (`in (...)`, a join, an embedded select naming the columns needed).
- **Unbounded read.** A list read with no limit on data that grows. Page it.
  Small bounded reference data may be read whole as a stated decision.
- **Over-fetching.** Whole rows for a few columns on a hot path; loading rows
  to count them; loading a list to find one item.
- **Refetching what is held.** Re-querying on every render or rebuild; no
  dedupe of identical in-flight requests.
- **Chatty round-trips.** Sequential awaits that could be one query. When they
  must stay separate, a *bounded* parallel batch; parallelism still costs one
  request each, so cap it and respect rate limits.
- **Write amplification.** A write per keystroke or frame; re-subscribing on
  every render.

Do not prescribe a cache as a reflex. A cache needs a freshness rule, a key
that partitions by user or tenant (see `security.md`), and eviction.

## Pagination

- Keyset (cursor) pagination for large or scrolling sets; offset pagination
  rescans skipped rows and slows with depth.
- The cursor needs a **unique, stable order**: sort by `(created_at, id)` and
  carry both. Ordering on a non-unique or nullable column alone skips or
  repeats rows at ties.
- Track cursor, has-more and in-flight state; never request the next page
  while one is loading or after the end.
- Append the new page; do not refetch earlier pages.
- Show distinct empty, loading, end and error states.
- Keep the interaction the product asked for. Infinite scroll, a "load more"
  button and numbered pages are all valid; exports stream in bounded chunks.

## Counts

Choose what the requirement needs: an exact count, an estimate, an existence
check, or no count. An exact count over a large filtered set is itself
expensive even when no rows are transferred.

## Indexes

Report a missing index only with the mechanism: the query, the table's
realistic size, the existing indexes (including composite ones that already
cover the filter), and the resulting plan. A sequential scan is correct for
small tables and low-selectivity filters, and every index taxes writes.

## Realtime versus polling

Subscribe with a filter, not to a whole table. Fast-changing shared state
suits realtime; slow-changing data is often cheaper polled at a sane interval.
Tie the lifetime to whoever needs the data: usually the screen, sometimes a
deliberate background sync.

## Code ↔ schema agreement

Check against the real schema source (migrations, schema file, introspection,
generated types), not memory.

- Tables, columns and relations the code names exist, with that spelling.
- Compare the chain: database constraint → transport representation →
  static or generated type → runtime validation → what the consumer assumes.
  Report a demonstrated mismatch (a nullable column read as non-null, an enum
  value the constraint rejects). A different representation alone is not a
  defect: a timestamp arriving as an ISO string is normal for JSON.
- A schema change the code depends on has a committed migration. Regenerate
  types when the project uses generation.
- The caller is actually permitted to read or write the rows. A read that
  returns nothing because a policy blocks it looks like "no data".

## Verification

- Count the queries or requests per bounded unit of work (one page, one
  action) and look for avoidable per-item round-trips. Exports and bulk jobs
  legitimately issue more requests as total data grows, in bounded chunks.
- For SQL on a T3 path, read the plan (`EXPLAIN`, with `ANALYZE` on
  non-production data) and check the estimated and actual rows, not merely
  that an index name appears.
- Confirm a list caps its rows and fetches incrementally.

## Finding shape

```
F1 🔴 orders/list.ts:120 — an account with 40k orders opens the list → query
   has no limit and re-runs on every re-render → multi-MB response and a full
   scan per render.
   Evidence: static trace; query at :120 has no limit, called from a render
   effect with no dependency guard (:98).
   Fix: keyset page of 30 on (created_at desc, id desc), fetch once per
   cursor with an in-flight guard.
```
