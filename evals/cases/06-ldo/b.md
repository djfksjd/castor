# Motor node rev A — 3V3 rail

- Input: 12 V supply (10.8–13.2 V).
- U3: fixed 3.3 V LDO, SOT-223.
- 3V3 load budget (sheet 2): MCU 40 mA, radio 310 mA while streaming
  (continuous for minutes at a time), sensors 50 mA; sustained 400 mA.
- Ambient: 0 to 50 °C. Board copper under the tab: 1 in².

Datasheet excerpts for U3 (rev C; synthetic values for this exercise):
- Dropout at 400 mA: 1.2 V max (table 6.5).
- θJA, SOT-223 on 1 in² copper: 60 °C/W (table 6.4).
- Operating junction temperature: −40 to 125 °C (table 6.3).
- Output capacitor: ≥ 10 µF, any ESR (section 8.2). Fitted: 22 µF ceramic.
