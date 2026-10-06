# Firmware and embedded (CASTOR domain pack)

Load for MCU, RTOS, bare-metal, driver, bootloader or device-side code. It adds
to the shared references; `correctness.md` and `security.md` still apply.

Firmware fails differently from application code: the hardware is part of the
program, time is a requirement, memory is fixed, and a bad release can make a
device unrecoverable. "It compiles" and "it passes on the host" say nothing
about timing or hardware behavior. State which evidence came from the target.

## Hardware truth (law T)

- Register addresses, bit positions, reset values, pin multiplexing, clock
  tree and peripheral instances match the reference manual and datasheet for
  the **exact part number and revision**, and the board's schematic. Cite the
  document and section. If you have not read it, write `TBC (source needed)`.
- Errata for the exact silicon revision are checked for the peripherals used.
- Register access semantics are respected: permitted access width, reserved
  bits, write-one-to-clear and read-to-clear flags. An ordinary read-modify-
  write on a write-one-to-clear status register clears events it did not mean
  to.
- Vendor HAL or SDK calls exist in the version the project pins.
- Configuration order matters: clock enabled before the peripheral is touched,
  pin mode set before the peripheral drives it.

## Interrupts and concurrency

- Data shared between an ISR and other code needs a synchronization protocol
  valid for this target and compiler. `volatile` forces the access to happen;
  it does not make a read-modify-write or a multi-word access atomic. Use a
  short critical section covering every writer, an atomic operation the target
  performs without a lock (unsupported widths fall back to library helpers
  that may lock, which deadlocks in an ISR), or a single-writer lock-free
  structure with a correct publication order. Masking interrupts does not
  exclude another core.
- ISRs are short and bounded: no blocking, no dynamic allocation, no formatted
  printing; only the RTOS's interrupt-safe API variants. Defer work to a task.
- The interrupt source is acknowledged as the peripheral requires, or the ISR
  re-enters forever.
- Interrupt priorities are consistent with the RTOS's rules for which
  priorities may call kernel functions.
- Shared resources between tasks: mutex with priority inheritance where a
  high-priority task can wait on it; consistent lock order; bounded hold time
  that is counted in the deadline analysis. A mutex may cover a bounded
  blocking bus transaction when ownership requires it; never block with
  interrupts disabled or while holding a spinlock.
- Functions called from more than one context are reentrant.

## Time

- Deadlines are stated and measured on target for T2/T3 paths.
- Every wait on a hardware flag or bus has a timeout; a `while (!flag)` with
  no exit hangs the device when the hardware misbehaves.
- Tick comparisons survive wraparound: compare elapsed time with unsigned
  subtraction cast back to the tick type, `(tick_t)(now - start) >= timeout`,
  never `now >= deadline`. The cast matters: operands narrower than `int` are
  promoted to signed `int` and the difference goes negative. The measured
  interval must stay shorter than the counter's wrap period.
- Blocking delays in a shared context stall everything behind them.

## Memory

- Stack: worst-case depth per task and for interrupts, with margin; no
  recursion, variable-length arrays or large locals. Check the high-water mark
  on target when feasible.
- Heap: avoid allocation after initialization, or bound it; long-running
  devices fragment.
- Every receive path (UART, USB, BLE, CAN, network) bounds its length against
  the buffer; length fields from the wire are hostile.
- Protocol structures: endianness, packing, alignment and unaligned access.
- DMA buffers outlive the transfer (not on a returning function's stack), meet
  alignment requirements, respect cache maintenance on cores with a data
  cache, and sit in a memory region the DMA engine can actually reach (check
  the bus matrix and the linker map).
- Flash and RAM usage from the map file against capacity, with margin for the
  next update.

## Arithmetic

Integer width, sign and promotion; overflow in intermediate products; fixed-
point scale; division by zero; units. Floating point only where the cost is
understood (no FPU, or FPU context in interrupts).

## Failure and recovery

- The watchdog is serviced from a place that proves the main work is alive,
  not from a timer interrupt that keeps running while the application hangs.
- Hazardous outputs (actuators, heaters, drivers) are safe throughout reset,
  boot and brown-out. Firmware is not running then, so this is the job of
  hardware biasing and pin reset defaults; check it against the schematic.
  Firmware sets the output latch before enabling the pin driver, and returns
  outputs to the safe state on a fault.
- Fault handlers record enough to diagnose (reset cause, fault registers) and
  reach the safe state.
- Initialization failures and stuck buses (I2C held low) have a recovery path.

## Non-volatile data and updates

- Power loss at any instant leaves the last committed state recoverable: a
  valid record is kept while its replacement is written, and incomplete
  records are detected and discarded on boot. A checksum detects corruption;
  it does not provide atomicity. Check the erase/program order against what
  the storage actually guarantees. Erase/write cycles respect endurance.
- Stored-format changes migrate from every version in the field.
- Updates: image is authenticated before use, verified before the old one is
  given up, with a fallback (A/B slots or a recovery loader) and rollback
  protection. A failed or interrupted update must not brick the device.

## Power

Sleep modes actually entered and woken by the intended sources; unused
peripheral clocks off; pin states defined in sleep (floating inputs draw
current); average current against the battery budget.

## Device security

Debug port and read-out protection configured for production; secure boot
where the threat model needs it; no shared secrets in the image (it can be
extracted); per-device keys; data from radio, bus and removable media is
untrusted. Security-sensitive random numbers come from a cryptographic
generator seeded by a documented entropy source, with startup and failure
handling; never raw hardware samples, and never a predictable fallback.

## Irreversible operations (law R)

Prepare the command, state the consequence, and wait for the human:
programming eFuse/OTP, enabling a permanent read-out protection level,
overwriting a bootloader, mass erase of a device holding calibration or keys,
flashing units other than the developer's bench unit, starting a fleet OTA
rollout.

## Finding shape

```
F1 🔴 drivers/tick.c:31 — on this 32-bit MCU the tick ISR fires between the
   two halves of main's read of the 64-bit `g_uptime_ms` → main gets a torn
   value off by 2^32 ms → timeouts expire instantly or never.
   Evidence: static trace; `g_uptime_ms` is `volatile uint64_t`, incremented
   in SysTick_Handler (:12), read without exclusion in uptime_ms() (:31).
   Fix: read inside a critical section (save and disable interrupts, copy,
   restore), or read twice until both reads match.
```
