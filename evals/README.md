# Evaluating CASTOR

Two layers, cheapest first.

## 1. Structural lint (every change, no model needed)

```bash
scripts/lint.sh
```

Checks the frontmatter, that every reference path resolves and is routed from
`SKILL.md`, that the severity table has a single owner, the `SKILL.md` size
budget, leftover identifiers from the old name, and that every eval case has
an entry in `expected.md`.

## 2. Behavioral run (when a rule changes, and before a release)

`cases/` holds small artifacts in pairs: one with a seeded defect and one
near-miss that looks similar but is correct. Pairs matter because a skill that
only ever sees defects is rewarded for reporting everything. File names are
neutral; the key is in `expected.md`.

```bash
scripts/run-evals.sh codex     # or: claude
```

The runner copies the skill and `cases/` (never `expected.md`) into a temporary
directory, asks the agent to gate each file review-only, and writes the report
to `evals/last-run.md` (git-ignored). Grade it against `expected.md`.

For a baseline, give the same model only `cases/` and a neutral prompt, for
example: "Review each file under cases/ independently for real defects. Do
not modify files. Use static evidence. Report location, severity, mechanism,
consequence and coverage, and end each report with PASS, CHANGES NEEDED or
INCOMPLETE."

Model output varies between runs. Treat a single run as a smoke test and
repeat it before drawing conclusions about a wording change.
