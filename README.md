<div align="center">

<img src="assets/castor-logo.png" alt="CASTOR logo" width="160">

<h1>CASTOR</h1>

**An engineering gate for AI agents.**
*For work that has to hold up in the real world: application code, firmware, HDL, and hardware design.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-e2783a.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#install)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#install)

**English** · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md)

</div>

> *Castor* is the beaver genus: the animal that builds structures which have to
> hold back real water. CASTOR was previously published as **ironcode**.

---

## Why

AI agents produce plausible work quickly, and they skip the same checks people
skip under time pressure: the listener nobody removes, the query inside a
loop, the regulator nobody ran the thermal numbers on, the "should work now"
with nothing actually run.

A longer checklist does not fix that. An agent with a checklist reports every
pattern it recognizes and calls a passing typecheck proof. CASTOR is a small
set of **decision rules** instead:

- what counts as a defect (a reachable trigger, a mechanism, and a consequence),
- what counts as proof (evidence that could have shown the claim false),
- and what an agent may not do without a human (anything it cannot undo).

## What it gates

| Domain | Examples of what it catches |
|---|---|
| **Application code** | Missing authorization on an object, lost updates under concurrency, N+1 queries, leaked subscriptions, unsafe retries, tests weakened to pass |
| **Firmware / embedded** | Non-atomic data shared with an ISR, waits with no timeout, tick wraparound, stack and flash budgets, updates that can brick a device |
| **HDL / FPGA** | Unsynchronized clock-domain crossings, inferred latches, unconstrained paths reported as "timing met" |
| **Hardware design** | Parts beyond rating at worst case, LDO thermal overruns, symbol/footprint/BOM mismatches, back-powering, floating strap pins |
| **Anything else** | A five-question first-principles gate: requirement source, budgets, failure modes, irreversible steps, falsifying evidence |

## The six laws

| | Law | Meaning |
|---|---|---|
| **C** | **Claims need evidence** | No "done", "fixed", "safe" or "fab-ready" without evidence that could have proven it wrong. A typecheck is not a behavior test; a simulation is not a bench measurement. |
| **A** | **Analyze the cause before the fix** | Reproduce or trace the mechanism, name the cause, then edit. Two failed fixes in a row means question the design. |
| **S** | **Spec before style** | First establish that the work solves the right problem, all of it. Then judge quality. |
| **T** | **Trust nothing unverified** | Tool output, other agents, and your own memory are leads. Never invent an API, package, register, pinout or rating: write `TBC (source needed)`. |
| **O** | **Overruns are defects** | Queries, memory, stack, latency, power, heat, tolerance, BOM cost: exceeding a budget under a realistic workload is a bug, not an optimization for later. |
| **R** | **Reversible by default** | Production data changes, fleet OTA, eFuses, fab orders: prepared and explained, then left for a human to approve. |

## How it works

```
PLAN   →  requirements, budgets and the evidence plan, before building
BUILD  →  the release written next to the acquisition, the bound next to the fetch
GATE   →  target → spec → routed references → findings → verify → decide
DEBUG  →  reproduce → hypothesis → refute or confirm → fix → fails-before / passes-after
```

**Risk tier sets the depth.** T1 mechanical, T2 behavioral, T3 consequential
(auth, money, migrations, bootloaders, power stages). Tier follows
consequence, not size: a one-line migration is T3.

**A pattern is only a candidate.** It becomes a finding when the agent can
state *trigger → mechanism → consequence*. What it cannot complete is reported
as a question, not a defect. That one rule removes most review noise.

**The decision has a fixed precedence.**
`CHANGES NEEDED` if a blocking finding, or an important one nobody has
explicitly accepted, is open, whether or not anything could be run.
`INCOMPLETE` if the tier's evidence or a material answer is missing. `PASS`
otherwise, qualified by what was and was not examined.

## What a report looks like

```
castor · GATE — working tree vs HEAD · T3

Requirements: issue #214 — met

F1 🔴 inventory/reserve.ts:48 — two concurrent checkouts for the last unit
   both read stock=1 and both write stock=0 → oversold order.
   Evidence: static trace; read (:41) and write (:48) are separate statements
   with no lock, constraint or version check.
   Fix: single conditional update; treat zero rows affected as sold out.

Verification: npm test -- reserve → failed (1 of 14); proves the race test
              added for F1 reproduces it
Coverage: examined correctness, data-access · not applicable resources ·
          not examined deployment
Decision: CHANGES NEEDED
```

The same contract on a board:

```
castor · GATE — power.kicad_sch rev A · T3

F1 🔴 U3 (LDO, SOT-223) — 12 V in, 3V3 rail at its sustained 400 mA load
   → P ≈ (12 − 3.3) × 0.4 ≈ 3.5 W → ≈ 209 °C steady-state rise at 60 °C/W
   (datasheet rev C, table 6.4) → far above the 125 °C operating limit.
   Evidence: calculation from cited values.
   Fix: buck converter for the 12 V → 3.3 V step.
Q1 ❓ The 60 °C/W figure assumes 1 in² of copper under the tab; the layout
   was not supplied.

Verification: ERC → blocked (no tool access); calculation → static-only
Decision: CHANGES NEEDED
```

## References

Loaded on demand. A one-line change never pulls in a thousand lines of
checklist, and the report says what was not examined.

| Reference | Covers |
|---|---|
| [`verification.md`](references/verification.md) | Matching evidence to claims, the review target, traps that produce false green |
| [`correctness.md`](references/correctness.md) | Invariants, concurrency, partial failure, retries, money/time/units |
| [`security.md`](references/security.md) | Access control across layers, injection, sessions, SSRF, secrets, LLM-calling apps |
| [`resource-safety.md`](references/resource-safety.md) | Ownership, cancellation, reachability, unbounded growth |
| [`data-access.md`](references/data-access.md) | N+1, pagination, counts, indexes, code ↔ schema agreement |
| [`ship-readiness.md`](references/ship-readiness.md) | Rollout compatibility, rollback, observability, supply chain, privacy |
| [`domains/firmware.md`](references/domains/firmware.md) | Interrupts, timing, memory, watchdog, non-volatile data, updates |
| [`domains/hardware.md`](references/domains/hardware.md) | Ratings, power tree, protection, interfaces, footprints, layout, fab release |
| [`domains/hdl.md`](references/domains/hdl.md) | Clock-domain crossings, reset, sim/synth mismatch, timing constraints |

## Install

**Claude Code**

```bash
git clone https://github.com/djfksjd/castor.git ~/.claude/skills/castor
```

Invoke with `/castor`, or ask for a production-grade, rigorous or fab-ready
implementation or review; the skill triggers on its description.

**Codex CLI**

Codex reads the same `SKILL.md` format. Depending on your version the user
skill directory is `~/.codex/skills` or `~/.agents/skills`:

```bash
git clone https://github.com/djfksjd/castor.git ~/.codex/skills/castor
```

Invoke from the skill selector (`/skills`) or with `$castor`.

## Upgrading from ironcode

The old repository URL redirects, but the skill name and folder changed:

```bash
mv ~/.claude/skills/ironcode ~/.claude/skills/castor
git -C ~/.claude/skills/castor remote set-url origin https://github.com/djfksjd/castor.git
git -C ~/.claude/skills/castor pull
```

What changed: `/ironcode` is now `/castor`; the five Iron Laws became the six
CASTOR laws; verdicts are `PASS` / `CHANGES NEEDED` / `INCOMPLETE`;
`checklist.md` and `defensive.md` were replaced by `verification.md` and
`correctness.md`. Details in the [changelog](CHANGELOG.md).

## Testing the skill

A skill is a prompt, and prompts regress silently. Two checks ship with it:

```bash
scripts/lint.sh              # structure: paths, routing, budgets, single-owner rules
scripts/run-evals.sh codex   # behavior: gate the fixtures, grade against evals/expected.md
```

The fixtures in [`evals/cases`](evals/cases) come in pairs: one with a seeded
defect and one near-miss that looks similar but is correct, because a reviewer
that only ever sees defects learns to report everything. See
[`evals/README.md`](evals/README.md).

## Limits

CASTOR is a review discipline, not a certification. `PASS` means no supported
defect was found within the stated target and coverage. It is not a security
guarantee, and it never clears mains-voltage, lithium-battery or
safety-critical designs, EMC compliance, or anything that requires a
measurement nobody took. Those are listed in the report as verification still
owed.

## License

[MIT](LICENSE)
