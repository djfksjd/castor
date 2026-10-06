# Hardware design (CASTOR domain pack)

Load for schematic, PCB layout, power, analog or mixed-signal design,
component selection, and BOM or netlist review.

A board cannot be patched after it ships, and an agent cannot probe it. So
the rules tighten: every electrical claim cites its source, every margin is
calculated at worst case, and release to fabrication is a human decision.

## What counts as evidence here

1. **Cited datasheet value:** part number, document revision, page or table.
2. **Worst-case calculation** shown with numbers, tolerances and temperature.
3. **Tool reports:** ERC, DRC against the chosen fab's rules, netlist compare.
4. **Simulation** with the models and conditions stated.
5. **Bench measurement,** supplied by the human.

Never fill a gap from memory (law T). Unknown pinouts, absolute maximums,
thermal resistances, footprints, prices and availability are written
`TBC (source needed)`, and a T3 conclusion that depends on one is INCOMPLETE.
Absolute-maximum ratings are damage limits, not operating conditions; design
to the recommended operating range.

## Requirements and operating envelope

Before judging parts: input voltage range including transients, peak and
average load per rail, ambient temperature range, environment (humidity,
vibration, ESD exposure), lifetime, target cost and volume, and the regulatory
regime the product must meet.

## Ratings and derating

For each stressed part, worst case against rating, with margin:

- Capacitors: voltage rating versus maximum applied; MLCC capacitance loss
  under DC bias and temperature; ripple current for bulk capacitors.
- Resistors: power at worst-case voltage; pulse rating where relevant.
- MOSFETs: VDS, VGS (including gate drive overshoot), safe operating area,
  RDS(on) at the actual gate voltage and temperature, dissipation.
- Diodes: reverse voltage, average and surge current.
- Inductors: saturation current above worst-case peak current (including at
  current limit), and RMS current within the thermal rating.
- Connectors, traces and vias: current.

## Power tree

For every rail: source, summed worst-case load, regulator headroom, and heat.

- Linear regulators: dropout satisfied at minimum input; dissipation
  P = (VIN − VOUT) × IOUT + VIN × IGND (drop the ground-current term only when
  it is clearly negligible) and steady-state junction temperature
  TJ = TA + P × θJA at maximum ambient, with θJA for the actual copper area.
  That formula is for sustained load; heating during a short burst needs the
  duration, duty cycle and transient thermal data.
- Switching regulators: inductor and capacitor selection per the datasheet
  procedure, compensation, minimum on-time, light-load behavior.
- Stability requirements on output capacitance and ESR are met.
- Sequencing, enable and power-good wiring; inrush and soft-start; UVLO
  thresholds; behavior during brown-out.
- Load steps (radio bursts, motors, relays): the rail's undershoot and
  overshoot stay inside every connected device's limits, or the system resets
  cleanly. This usually needs simulation or a bench capture.
- Decoupling: values and count per the IC's datasheet, plus bulk per rail.

## Protection

Reverse polarity; over-voltage and transient suppression on inputs; ESD
protection on every externally reachable signal; over-current (fuse, limit);
flyback path for inductive loads; hot-plug; **back-powering** through I/O
protection diodes when one rail is off and a neighbor drives its pins.

Battery (especially lithium) charging and protection, and anything connected
to mains, are safety functions: review them, then say plainly that they need a
qualified engineer and the applicable standard. PASS never covers them.

## Digital interfaces

- Logic levels across voltage domains: driver VOH/VOL against receiver
  VIH/VIL; 5 V tolerance is per pin and per datasheet, never assumed.
- No floating inputs. Pull-ups and pull-downs present and sized (I2C pull-up
  against bus capacitance and speed; open-drain lines need one).
- Boot, strap and configuration pins are in the intended state at reset,
  including with attached peripherals driving them.
- Reset circuit, unused pins per the datasheet's instruction.
- Level shifters match direction, speed and drive type.
- Traces that are electrically long for the edge rate are transmission lines:
  controlled impedance *and* suitable source or load termination, with ringing
  and overshoot checked against receiver thresholds and pin ratings.

## Clocks and analog

- Crystal: load capacitors from CL = (C1 × C2)/(C1 + C2) + C_stray, drive
  level, and the MCU's oscillator requirements.
- ADC: source impedance and settling against acquisition time, reference
  accuracy and decoupling, anti-alias filtering, signal within the full-scale
  and common-mode range for the chosen reference and gain, and within input
  voltage and injection-current limits, including while unpowered.
- Op-amps: input common-mode and output swing within what the supply allows,
  stability with capacitive loads, offset and gain error in the error budget.
- Dividers: impedance against the load's bias and leakage current.
- Tolerance stack: the function still meets spec with every part at its
  tolerance limit and temperature extreme.

## Symbol ↔ footprint ↔ BOM agreement

The classic respin causes. Check each against the manufacturer's drawing:

- Symbol pin numbers match the datasheet for the **specific package** ordered
  (the same part number family often has different pinouts per package).
- Footprint dimensions, pin-1 location and pad numbering match the package
  drawing; polarity and orientation of diodes, electrolytics, LEDs, connectors.
- Connector pinout matches the mating part and cable, viewed from the correct
  side.
- BOM manufacturer part number agrees with the schematic value, package,
  rating and tolerance; do-not-populate parts marked.

## PCB layout

- Trace width and via count for current and allowed temperature rise.
- Clearance and creepage for the working voltage.
- Unbroken return paths: no signal crossing a split in its reference plane.
- Decoupling capacitors at the pins with short loops; switching-regulator hot
  loop minimized and laid out per the datasheet's example.
- Kelvin connections for current sense; sensitive analog away from switching
  nodes.
- Differential pairs and controlled-impedance nets: stack-up specified,
  lengths matched as the interface requires.
- Thermal paths: copper area and vias under dissipating parts.
- Antenna keep-outs and RF feed per the module's guide.
- Mechanical: outline, mounting holes, connector positions and heights,
  enclosure fit.
- Manufacturability with the chosen fab's limits (trace/space, drill, annular
  ring, solder mask), fiducials, test points on rails and key signals,
  programming and debug access.

## Sourcing

Availability, lifecycle status and price change daily. Do not assert them
from memory; check a live source or mark `TBC`. Note single-source parts.

## Release to fabrication (law R)

An order costs money and weeks and cannot be recalled. Before a human approves
it: ERC clean or each waiver explained; DRC clean against the fab's rules;
netlist matches schematic; footprints checked against package drawings; BOM
cross-checked; fabrication outputs reviewed in a viewer; open `TBC` items
resolved. The agent prepares and reports this list; it does not place orders.

## What review cannot clear

EMC compliance, safety certification, thermal performance in the enclosure and
RF performance require measurement. List them as verification still owed.

## Finding shape

```
F1 🔴 power.kicad_sch U3 (LDO, SOT-223) — 12 V input with the 3V3 rail at its
   sustained 400 mA load → P ≈ (12 − 3.3) × 0.4 ≈ 3.5 W → at the datasheet's
   θJA of 60 °C/W (rev C, table 6.4) the steady-state rise is ≈ 209 °C →
   junction far above the 125 °C operating limit at any ambient.
   Evidence: calculation from cited values; load from the rail budget on
   sheet 2; ground current neglected (it only adds).
   Fix: replace with a buck converter for the 12 V → 3.3 V step.
```
