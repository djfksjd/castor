# Sensor node rev A — 3V3 rail

- Input: USB 5.0 V (4.75–5.25 V).
- U3: fixed 3.3 V LDO, SOT-223.
- 3V3 load budget (sheet 2): MCU 25 mA, sensor 5 mA, LED 10 mA; peak 60 mA.
- Ambient: 0 to 50 °C. Board copper under the tab: 1 in².

Datasheet excerpts for U3 (rev C; synthetic values for this exercise):
- Dropout at 100 mA: 1.1 V max (table 6.5).
- θJA, SOT-223 on 1 in² copper: 60 °C/W (table 6.4).
- Operating junction temperature: −40 to 125 °C (table 6.3).
- Output capacitor: ≥ 10 µF, any ESR (section 8.2). Fitted: 22 µF ceramic.
