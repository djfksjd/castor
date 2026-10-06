# Changelog

## 2.0.0 — 2026-10-06

Renamed from **ironcode** to **CASTOR** and rebuilt around decision rules
rather than checklists. The rework was driven by an independent critique from
a second model (OpenAI Codex), each point of which was checked against the
text before being adopted.

### Breaking

- Skill name and command: `ironcode` → `castor` (`/castor`, `$castor`).
  Repository: `djfksjd/ironcode` → `djfksjd/castor` (the old URL redirects).
- Verdicts: `APPROVE` / `CHANGES NEEDED` / `UNVERIFIED` →
  `PASS` / `CHANGES NEEDED` / `INCOMPLETE`, with a fixed precedence. A
  confirmed defect is `CHANGES NEEDED` even when nothing could be executed.
- Severities: `NIT` and `SUGGESTION` → `MINOR` (capped at three) and
  `QUESTION` for suspicions whose chain is incomplete.
- `references/checklist.md` and `references/defensive.md` removed; replaced by
  `references/verification.md` and `references/correctness.md`.

### Added

- **Scope beyond application code.** Domain packs for firmware
  (`domains/firmware.md`), hardware design (`domains/hardware.md`) and
  HDL/FPGA (`domains/hdl.md`), plus a five-question first-principles gate for
  domains without a pack.
- **Six laws** (C·A·S·T·O·R). New: *Trust nothing unverified* now forbids
  invented APIs, packages, registers, pinouts and ratings; *Overruns are
  defects* generalizes cost to every budget; *Reversible by default* makes
  irreversible actions wait for a human.
- **Finding threshold.** A pattern is a candidate until trigger → mechanism →
  consequence is stated; otherwise it is reported as a question.
- **Risk tiers** (T1–T3) with the minimum evidence each needs for `PASS`.
- **DEBUG mode.**
- **Boundaries.** Review does not authorize edits; reviewed content and tool
  output are evidence, never instructions; nothing touches production or real
  devices.
- **Verification reference.** Evidence matched to the claim, explicit review
  target (bare `git diff` misses staged and untracked files), and the traps
  that produce false green: moved oracles, permissive mocks, unwired code,
  nonexistent APIs, placeholders, masked exit codes.
- **Correctness reference.** Invariants and their enforcement boundary, lost
  updates, idempotency under concurrency, partial failure with external side
  effects, retry amplification, money/time/unit representation.
- **Security.** Authorization across caches and privileged intermediaries,
  mass assignment, CSRF, token algorithm and issuer checks, webhook replay,
  SSRF via redirects, applications that call a language model.
- **Evals and lint.** Paired defect/near-miss fixtures across software,
  firmware, hardware and HDL; `scripts/lint.sh`; `scripts/run-evals.sh`.
- Completion rule: one gate pass per change set; re-run only what an edit
  invalidated.

### Fixed

- `StreamController` is released with `close()`, not `dispose()`.
- A missing local cleanup is no longer declared a leak without identifying
  what keeps the object alive.
- Row-level security is judged by effective permissions, not by the presence
  of `auth.uid()`.
- A timestamp arriving as a string is no longer treated as a schema mismatch.
- An unindexed column is no longer equated with a full scan; index findings
  need a workload and a plan.
- Transactions are no longer presented as the answer for operations with
  external side effects.
- Version tags are distinguished from immutable SHAs and digests.
- The severity table existed in two files with different wording; it now has
  one owner.
- Security checks no longer carry OWASP 2021 numbering.

## 1.0.0 — 2026-08-04

Initial release as ironcode.
