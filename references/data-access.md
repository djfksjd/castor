# Data access & backend cost (ironcode reference)

Load when the change reads/writes a database, calls an API, or renders a list. Goal:
correct data **and** minimal, bounded, cheap requests. Excessive queries = real money.

## The cost defects (treat as bugs when the data grows with usage)
- **N+1 queries.** A query inside a loop / per-list-item / per-render. Fix: batch with
  `in (...)`, a join, or a single embedded select naming the columns you need
  (Supabase `select('id, title, rel(id, name)')`). A loop over a small, bounded
  config table is a nit, not a defect — say which case you're in.
  *Smell: `for (item in list) { await db... }`.*
- **Unbounded fetch.** A list query with no `limit`/`range` on user-growing data.
  Paginate those; small bounded reference data (country codes, roles, settings)
  may be fetched whole as a deliberate, stated decision. Use keyset/cursor
  pagination over `OFFSET` for large/scrolling sets — `OFFSET` scans and skips,
  getting slower as you go. A keyset cursor needs a **unique, stable sort key**:
  order by `(created_at, id)` and cursor on both (tie-breaker), not on a
  non-unique column alone — otherwise rows are skipped or duplicated at ties.
- **Over-fetching.** `select *` when you need 3 columns; fetching rows to count them
  (use a count query / `count: 'exact', head: true`); fetching a whole list to find one.
- **Refetching what you have.** Re-querying on every rebuild/render instead of caching;
  no dedupe of identical in-flight requests; not using already-loaded data.
- **Chatty round-trips.** Many small sequential awaits that could be one query, or —
  when they must stay separate — a *bounded* parallel batch (`Future.wait`/
  `Promise.all` over a capped set). Parallelism is not batching: it still costs one
  connection/request each, so cap it and respect rate limits.
- **Missing indexes.** Filtering/ordering/joining on an unindexed column → full scan.
  Recommend an index for the exact `where`/`order by` the code runs.
- **Write amplification.** Per-keystroke writes (debounce them); per-frame persistence;
  re-subscribing on every build.

## Pagination / infinite scroll — the correct pattern
- Page size 20–50 as a starting point — tune to payload size, latency, and memory;
  never "load all" on user-growing data.
- Keyset cursor (last seen sort key + unique tie-breaker), not OFFSET, for
  infinite scroll.
- Track `hasMore`, `isLoading`, and the cursor; **guard against duplicate page
  requests** (don't fire the next page while one is in flight or already at end).
- Trigger the next page *before* the user hits the absolute bottom (prefetch threshold),
  not on a button only.
- Show distinct empty / loading / end-of-list / error states.
- Append to the existing list; don't refetch page 1..N to add page N+1.

## Realtime / subscriptions
- Subscribe with a filter (only the rows you need), not the whole table.
- One channel, cleaned up on teardown (see `resource-safety.md`).
- Choose realtime vs polling by change frequency: fast-changing shared state →
  realtime; slow-changing data → a sane polling interval is simpler and cheaper
  than held-open connections. Either way, stop it off-screen.

## DB ↔ code consistency (verify against the real schema, don't assume)
Code that queries a column/table that doesn't exist, or maps a result to a model with the
wrong type/nullability, fails at runtime — not compile time. Check the code against the
**actual** schema, not your memory of it.
- **Tables & columns exist** with the names/casing the query uses. Introspect with
  whatever schema source is available: `information_schema.columns`, an ORM/schema
  file, migrations, or generated types. Don't trust the string in the code.
- **Types & nullability match the model.** A nullable DB column mapped to a non-null field
  crashes on the first null row; an int parsed as String, a timestamp as a plain string,
  enum values not in the DB check constraint — all 🔴/🟠.
- **Migrations cover the change.** New column/table used by code must have a committed
  migration; no schema drift between envs. Generated types regenerated after a migration.
- **RLS/permission assumptions hold.** The query assumes the caller can see/write these
  rows — confirm a policy actually grants that (see `security.md`). A select that silently
  returns 0 rows because RLS blocks it is a bug that looks like "no data".
- **Foreign keys / relations** used in embedded selects/joins actually exist in the schema.
- **Indexes back the filters** the code runs (see "Missing indexes" above).
- After a schema change, regenerate types/models and re-run the queries to confirm.

## Verification
- Count the queries a single user action triggers — should be O(1), not O(rows).
- For SQL, get the query plan (`EXPLAIN`) on representative data and check the
  index is *used effectively* (row estimates, selectivity) — an index appearing
  in the plan is not proof by itself, and every index taxes writes.
- Confirm list screens cap rows and that scrolling fetches incrementally, not all-at-once.

## Finding shape
```
🔴 orders_controller.ts:120 — fetches all orders (no limit), grows unbounded and
   re-runs every rebuild. Fix: keyset pagination (`where (created_at, id) <
   (cursor) order by created_at desc, id desc limit 30`) + cache; load next page
   on scroll threshold with an in-flight guard.
```
