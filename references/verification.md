# Verification (CASTOR reference)

Load for every GATE and DEBUG. It answers one question: *what evidence supports
the claim you are about to make?*

## Match the evidence to the claim

Pick the check that could have come out the other way if the claim were false.

| Claim | Evidence that can falsify it | Does not establish it |
|---|---|---|
| "The bug is fixed" | A check that failed before the fix and passes after | Tests that passed before too |
| "This behaves as specified" | A test or run that exercises the specified behavior | Typecheck, lint, successful build |
| "No regression" | The existing suite on the affected area, compared with baseline | A single happy-path run |
| "This is a defect" | A complete static trace (trigger → mechanism → consequence) or a reproduction | A pattern match or a tool warning alone |
| "It is fast / cheap enough" | A measurement or plan on representative data, against a stated budget | Reasoning about big-O alone on a T3 path |
| "The part is within rating" | Worst-case calculation with cited datasheet values | Nominal values, or values from memory |
| "The board is ready for fab" | Clean ERC and DRC with the fab's rules, footprint and BOM cross-check | The schematic looking right |

State for each check what it proves and what it leaves unknown. Record the
status as **passed**, **failed**, **blocked** (could not run; say why) or
**static-only** (reasoned, not executed).

## Evidence by domain

| Domain | Evidence, roughly from cheapest to closest to reality |
|---|---|
| Application code | inspection → typecheck/lint → unit test → integration test → run with observed output or trace |
| Firmware | inspection → build with warnings as errors, map file → host unit test → static analysis → on-target run, logic-analyzer or scope capture |
| HDL | inspection → lint → self-checking simulation → synthesis and timing reports, CDC report → on-board run |
| Hardware | inspection → cited datasheet values → worst-case calculation → ERC/DRC → simulation with stated models → bench measurement |

These are complementary, not a strict ranking. A measurement proves the
conditions it observed; it does not replace analysis of other inputs, corners
or failure mechanisms. An agent usually cannot reach the right-hand end for
firmware and hardware: say where you stopped, and ask the human for the
measurement instead of implying it.

## The review target

Name it before you look, because the usual shortcut is wrong:

- **Working tree:** `git status --short`, then `git diff HEAD` plus untracked
  files. Bare `git diff` omits staged changes and new files.
- **A commit:** `git show <sha>`. **A branch or PR:** `git diff <base>...HEAD`.
- **Named files or a non-git artifact** (schematic, netlist, exported BOM):
  list them and their revision or date.

Then read what the change can break: callers of a changed contract, schema,
config, tests, the sheet or net a changed part connects to.

## Traps that produce false verification

Check for these whenever the evidence looks green, especially on work written
by an AI agent, including you.

- **The oracle moved.** Assertions weakened, tests skipped or deleted,
  snapshots regenerated, expected values edited to match output. Diff the
  tests as carefully as the code.
- **The test shares the misunderstanding.** Test and implementation written
  from the same wrong reading of the spec agree with each other and prove
  nothing. Check the expectation against the requirement's source.
- **The mock is more permissive than the real thing.** A mocked boundary that
  accepts anything hides contract errors. Check the mock against the real API.
- **The new path is not wired in.** A handler never registered, a route never
  mounted, a module never instantiated, a net never connected. Trace from an
  entry point to the new code.
- **The thing does not exist.** An API, option, package, register, or part
  recalled from memory. Confirm against the installed version, lockfile,
  schema or datasheet. A plausible package name that is not in the registry is
  a supply-chain risk, not a typo.
- **The implementation is a placeholder.** Hard-coded returns, stubbed
  branches, `TODO` in the path the spec requires.
- **The result is stale or masked.** A cached run, an old build artifact, an
  exit status hidden by a pipe or `|| true`, zero tests collected reported as
  success. Check the count of what ran.
- **Scope drifted.** Unrequested edits and deletions ride along with the
  change. Account for every changed file.

## Baseline

Separate what the change introduced from what was already failing. Run or
inspect the baseline when a failure's origin is unclear, and report
pre-existing failures as such rather than as findings against the change.

## Running things safely

- Read an unfamiliar script before running it; know what it writes and where.
- Prefer local, isolated and read-only checks. Never run against production
  data, live payment or messaging providers, or a connected device that could
  be damaged, unless the human explicitly asked for exactly that.
- Quote the command, its exit status and the decisive lines. Redact secrets
  and personal data from anything you quote.

## Reusing evidence and stopping

Evidence stays valid until something it depends on changes. After an edit,
re-run the checks that edit could affect, not the whole gate. If the required
evidence cannot be produced, name the missing item and do not substitute a
weaker check for it. With no open defect that makes the decision INCOMPLETE;
an established defect is still CHANGES NEEDED.
