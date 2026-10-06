# Ship-readiness (CASTOR reference)

Load when the change affects how something is released or what it must stay
compatible with: deployment, schema, persisted or wire formats, dependencies,
CI, feature rollout. Size is irrelevant; a one-line migration qualifies. Check
what applies and name what you skipped.

## Tests that ship with the change

- Match test level to risk: pure logic → unit; boundaries (API, database,
  serialization) → integration or contract; money, auth and data-loss paths →
  an end-to-end check of the critical flow.
- A bug fix ships with the regression test that fails without it.
- Include the negative cases the change makes relevant: invalid input,
  unauthorized caller, timeout, empty.
- A flaky test is a defect to fix or quarantine, not to retry until green.

## Deployment compatibility

- Old and new versions run at the same time during a rollout. Schema changes
  go expand → migrate → contract; API, queue and stored-format changes stay
  readable one version in each direction.
- State the rollback path and whether it loses data. Changes that cannot be
  rolled back (dropped columns, lossy backfills, one-way format upgrades) are
  called out before release and fall under law R.
- Long migrations: lock duration, table size, and whether they can run online.
- Wide-blast-radius behavior ships behind a flag or staged rollout.

## Observability

- For consequential new behavior, identify how a failure would be detected
  and acted on. It is a finding only when a reachable failure could go
  unnoticed long enough to cause material harm; name the signal and the
  response that would close the gap.
- Log decisions (denied, rate-limited, fallback taken) with a correlation id,
  never secrets or personal data.

## Supply chain

- Lockfile committed and consistent with the manifest. New dependencies are
  justified (maintenance, license, size) and exist under the intended name.
- For builds that need reproducibility or run with elevated trust, pin CI
  actions to full commit SHAs and images to digests, with an update process.
  A version tag is mutable; whether that is acceptable is project policy, so
  report it against the project's stated policy rather than as a blanket
  defect.
- No piping remote scripts into a shell in CI.

## Privacy

- Know which fields are personal data and where they flow: logs, analytics,
  backups, third parties.
- Deleting an account removes or anonymizes this feature's data too.
- Personal data stays out of URLs, logs, analytics events and error reports.

## Physical releases

Firmware images and boards have releases too: see the release sections of
`domains/firmware.md` and `domains/hardware.md`.

## Finding shape

```
F1 🟠 migrations/0042_drop_legacy_email.sql:1 — rollout runs old and new app
   versions together → old version still selects `legacy_email` → 500s on
   profile load until the rollout completes; rollback cannot restore the
   column's data.
   Evidence: static trace; column read at user_repo.ts:61 in the currently
   deployed version.
   Fix: ship the code that stops reading the column first; drop it in a later
   release.
```
