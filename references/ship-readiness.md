# Ship-readiness (ironcode reference)

Load when the change ships a *feature or release*, not a spot fix. These are the
release-scope dimensions that a per-diff review misses. Check what applies; name
what you skipped.

## Testing strategy (writing tests, not just running them)
- Match test level to risk: pure logic → unit; boundaries (API/DB/serialization)
  → integration/contract; money/auth/data-loss paths → E2E on the critical flow.
- Every bug fix ships with the regression test that would have caught it.
- Negative tests are not optional: invalid input, unauthorized caller, timeout,
  the empty case. A suite that only tests the happy path verifies hope.
- Treat flaky tests as defects — quarantine and fix, don't retry-until-green.

## Observability (can you tell it works in prod?)
- Structured logs with a correlation/request ID on the paths that matter; log the
  *decision* (denied, rate-limited, fallback taken), not just exceptions.
- A metric or health signal for the new behavior — if it breaks at 3am, what
  alerts? If the answer is "a user email", say so as a finding.
- Never log secrets/tokens/PII (see `security.md`); errors carry enough context
  to debug without them.

## Deployment compatibility
- Old code and new code run *simultaneously* during deploy: schema changes are
  expand → migrate → contract; API/queue payload changes are backward compatible
  one version in each direction.
- A rollback path exists and doesn't lose data. Migrations that can't roll back
  (dropped columns, lossy backfills) are called out before merge, not after.
- Risky behavior ships behind a flag or staged rollout when the blast radius is
  the whole user base.

## Supply chain
- Lockfile committed; new dependencies justified (maintenance, license, size) —
  a left-pad-sized function does not need a package.
- Pin CI actions/images to versions or SHAs; no `curl | bash` installs in CI.
- License of every new dep is compatible with the project's license.

## Privacy / PII
- Collect the minimum; know which fields are PII and where they flow (logs,
  analytics, backups, third parties).
- Deletion/retention: when a user deletes their account, does this feature's
  data actually go away?
- PII stays out of URLs, logs, analytics events, and error reports.

## Finding shape
```
🟠 release scope — new orders export has no metric/alert; silent failure mode.
   Fix: emit orders_export_{success,failure} counters + alert on failure rate.
```
