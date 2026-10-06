# HDL and FPGA (CASTOR domain pack)

Load for RTL (Verilog, SystemVerilog, VHDL), FPGA or ASIC logic, constraints
and testbenches.

Three different things are routinely confused: a passing simulation, met
timing, and working hardware. Each is evidence only for itself. Say which you
have.

## Evidence

Lint → self-checking simulation (assertions and compared outputs, not waveform
inspection) → synthesis report → static timing with **all** paths constrained
→ clock-domain-crossing report → on-board run. A design with unconstrained
paths has not met timing, whatever the summary says.

## Clock domain crossings

- Classify each crossing first. Related clocks with a correctly constrained
  relationship may use ordinary timed paths. Asynchronous crossings need a
  protocol.
- Asynchronous single-bit level: a synchronizer (two flops is the usual
  starting point; depth is chosen against an MTBF target for fast clocks, and
  the flops carry the tool's synchronizer attributes so they stay adjacent).
- Multi-bit values that must arrive coherent: a handshake, an asynchronous
  FIFO, or another proven scheme. Do not synchronize the bits of a binary
  value independently. Gray-coded counters are the exception, with inter-bit
  skew constrained.
- No combinational logic between the source flop and the synchronizer.
- Events: capture is guaranteed only if pulse width and spacing are bounded
  against the destination clock. Stretching or a toggle works within those
  bounds; otherwise use an acknowledged handshake or a FIFO.
- Asynchronous resets are asserted asynchronously and released synchronously
  in each domain.

## Reset and initialization

- State that must start known has a reset; the reset strategy is consistent.
- Reliance on FPGA power-up initial values is a stated decision (it does not
  carry to ASIC and may not survive partial reconfiguration).

## Simulation versus synthesis mismatch

- Incomplete `if`/`case` in combinational logic infers latches; assign
  defaults or cover every branch.
- Non-blocking assignments in clocked processes, blocking in combinational
  ones; incomplete sensitivity lists (use `always_comb`/`always_ff`,
  `process(all)`).
- Constructs the target flow does not synthesize, or synthesizes with a
  different meaning than simulation (delays, for example). `initial` blocks
  that the FPGA flow documents as supported, such as memory initialization,
  are valid there but do not port to ASIC.
- X-optimism: simulation hides unknowns that hardware resolves arbitrarily.
- `full_case`/`parallel_case` and similar pragmas change synthesis only.

## Timing constraints

- Every clock, generated clock and I/O delay is defined.
- Clocks are not gated or multiplexed with ordinary logic; a glitch clocks
  part of the design. Prefer clock enables, or the device's dedicated clock
  gating and switching primitives.
- Each false-path and multicycle exception has a written justification; a
  wrong exception hides a real violation.
- Check setup and hold slack across the supported corners, reset
  recovery/removal, and the unconstrained-path report; then fan-out and
  pipeline depth on the failing paths. A multicycle exception changes the hold
  check as well as the setup check.

## Arithmetic and state machines

- Width and signedness at every operator; truncation and sign extension are
  intentional; overflow behavior is defined.
- State machines recover from illegal states and have a default branch.

## Interfaces

- Handshake rules of the protocol are honored (for AXI-style ready/valid:
  valid does not wait for ready, and valid and payload both stay stable until
  a clock edge where valid and ready are high).
- Back-pressure reaches the source; FIFOs cannot overflow or underflow, or
  the condition is detected.

## Budgets

Utilization (LUT, FF, block RAM, DSP) and power against the device, with
headroom; memories and multipliers inferred as the intended primitives.

## Pins and board agreement

Pin assignments, I/O standards and bank voltages match the schematic; unused
pins configured as the board requires (see `hardware.md`).

## Irreversible operations (law R)

Writing configuration flash on a fielded device, programming eFuses or
encryption keys, and ASIC tape-out wait for a human.

## Finding shape

```
F1 🔴 rtl/uart_rx.sv:18 — `rx` is an asynchronous input sampled directly by
   the state machine in `clk` → a transition inside the setup/hold window
   makes different flops of the state register see different values → illegal
   state and dropped or corrupted bytes, intermittently.
   Evidence: static trace; `rx` feeds `state_next` logic at :18 with no
   synchronizer; no CDC report was run.
   Fix: pass `rx` through a two-flop synchronizer and use the synchronized
   signal everywhere.
```
