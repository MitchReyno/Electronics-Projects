# Clocky Alt — Project Context

## Overview

This is an adapted version of the **SoundForce Clocky** Eurorack clock divider/multiplier module. The original design uses a PCF8574P I2C I/O expander for reading 8 toggle switches and PL9823 addressable RGB LEDs for status display. This adaptation replaces both with simpler, non-I2C alternatives.

## What the module does

Clocky takes a single master clock input (via the TRG jack) and produces 8 independent gate outputs (A–H). Each output can either **divide** or **multiply** the incoming clock by a configurable ratio (default: ×1, ×2, ×4, ×8, ×16, ×3, ×5, ×7). A toggle switch per channel selects divide vs multiply mode. A RST jack resets the internal counter to re-synchronize divided outputs.

10 LEDs provide visual feedback:
- **LED0 (TRG):** Flashes on each incoming clock pulse (currently set to magenta/purple)
- **LED1 (RST):** Flashes green on reset
- **LED2–9 (A–H):** Show when each output fires — blue = divide mode, green = multiply mode

When no clock is connected, the LEDs run an idle rainbow animation.

## Hardware changes from original

| Subsystem | Original | Adapted version |
|-----------|----------|-----------------|
| Switch input | PCF8574P (I2C 8-bit expander) | CD74HC165E (parallel-in serial-out shift register) |
| LED display | 10× PL9823 (WS2812-compatible addressable RGB) | 10× common-anode RGB LEDs, multiplexed via CD4017BE decade counter |
| LED anode switching | N/A (PL9823 has integrated driver) | 10× 2N3904 NPN in emitter-follower config, driven by CD4017 outputs |
| LED cathode sinking | N/A | 3× 2N3904 NPN (one per color bus: R, G, B) |
| Current limiting | N/A | 3× resistors total (one per color bus, not per LED — safe because multiplexing ensures only one LED active at a time) |
| Libraries removed | Adafruit_NeoPixel, PCF8574, Wire | N/A |
| Libraries kept | elapsedMillis | elapsedMillis |

## Pin assignments (current, cleaned up)

```
 Pin  | Function         | Group
------+------------------+------------------
 D0   | (reserved)       | Serial RX
 D1   | (reserved)       | Serial TX
 D2   | TRIG_PIN         | Inputs (INT0)
 D3   | RESET_PIN        | Inputs
 D4   | LED_R            | LED cathode sinks
 D5   | LED_G            | LED cathode sinks
 D6   | LED_B            | LED cathode sinks
 D7   | MUX_CLK          | LED mux (CD4017)
 D8   | MUX_RST          | LED mux (CD4017)
 D9   | SR_SH_LD         | Shift register (HC165)
 D10  | SR_CLK           | Shift register (HC165)
 D11  | SR_QH            | Shift register (HC165)
 D12  | OUT7 (G)         | Gate outputs
 D13  | OUT8 (H)         | Gate outputs
 A0   | OUT1 (A)         | Gate outputs
 A1   | OUT2 (B)         | Gate outputs
 A2   | OUT3 (C)         | Gate outputs
 A3   | OUT4 (D)         | Gate outputs
 A4   | OUT5 (E)         | Gate outputs
 A5   | OUT6 (F)         | Gate outputs
 A6   | (analog only)    | Unusable as digital
 A7   | (analog only)    | Unusable as digital
```

All pins used as generic digital I/O. No PWM, no analog reads. All 18 usable pins are assigned — zero spare.

## Pin constraints

- **D2 must be TRIG_PIN** — uses INT0 hardware interrupt (`attachInterrupt(INT0, trigger_int, CHANGE)`)
- **D0/D1** reserved for serial debugging
- **A6/A7** are analog-only on ATmega328P — cannot be digital outputs
- **D13** has onboard LED — will flicker with OUT8 (H) gate activity (acceptable)
- If an OLED display is wanted later, SDA/SCL (normally A4/A5) are occupied by gate outputs E and F — would require freeing pins, possibly by using an HC595 shift register for gate outputs

## Firmware files

All files live in the same Arduino sketch folder:

- **Clocky_alt.ino** — Main sketch: setup, main loop (idle rainbow, reset handling, output timing, switch polling)
- **variables.h** — Pin definitions, LedColor struct, state variables, color constants, rainbow pattern
- **FastWrite.ino** — Port manipulation for fast gate output toggling (inverted logic: HIGH clears bit, LOW sets bit, because outputs drive 2N3904 open-collector stages)
- **LedMux.ino** — Timer2 ISR for LED multiplexing, CD4017 control, setLed() helper, rainbow/allOff functions
- **ShiftRegister.ino** — CD74HC165E reading (readSwitches byte, updateToggles with index remapping)
- **interrupts.ino** — Trigger ISR (clock rising/falling edge detection, divider/multiplier output firing, LED state updates)

## LED multiplexing design

### How it works
- **Timer2** configured in CTC mode at **10kHz** (prescaler 64, OCR2A = 24)
  - IMPORTANT: Prescaler 64 on ATmega328P Timer2 requires `(1 << CS22) | (1 << CS20)`, not `(1 << CS22)` alone (which is prescaler 256 = 2.5kHz = visible flicker)
- ISR fires every 100µs, cycling through 10 LEDs → each LED refreshes at 1kHz (flicker-free)
- ISR sequence: blank all cathodes → advance CD4017 clock → set cathodes for new LED
- The blanking-before-advance prevents ghosting (wrong color briefly showing on the next LED)

### NPN emitter-follower topology
- CD4017 Qn output (active HIGH) → 1k base resistor → 2N3904 NPN base
- NPN collector → +5V
- NPN emitter → LED common anode
- When Qn goes HIGH, emitter presents ~4.3V (5V - 0.7V Vbe) to LED anode
- With 3V LED Vf, ~1.3V across series resistor

### Floating anode problem
- When the NPN turns off, the LED anode floats (no discharge path)
- Parasitic capacitance holds the ~4.3V charge, taking 2-3 clock cycles to decay
- **Fix: 4.7k bleed resistor from each LED anode to GND** (10 resistors total)
- Provides fast discharge within the 100µs timeslot
- If still slow, try 2.2k or 1k

### Series resistors
- Only 3 resistors needed (one per color bus), NOT 30 (one per LED per color)
- Safe because multiplexing guarantees only one LED is powered at any given time
- Placed between shared cathode bus and NPN collector
- Values: ~68R for red (2V Vf), ~47-56R for green/blue (3.2V Vf) at 20mA
- Can push lower for higher instantaneous current to compensate for 10% duty cycle

## Switch reading (CD74HC165E)

- Polled every 50ms in main loop (no interrupt-driven detection)
- SH/LD pulsed low to latch parallel inputs, then 8 bits clocked out MSB-first on QH
- 10k pull-up resistors on each switch input (switch closed = GND = logic 0)
- `toggle_index[8] = {7,6,5,4,3,2,1,0}` reverses physical-to-logical mapping (from original design)

## Gate output stage

- Unchanged from original: Nano pin → 10k base resistor → 2N3904 NPN → output jack
- 10k collector pull-up to +5V
- Open-collector, active low: Nano HIGH = transistor ON = output LOW (gate pulse)
- FastWrite uses inverted port manipulation (LOW sets bit, HIGH clears bit)
- Port mapping: cases 0–5 use PORTC bits 0–5 (A0–A5), cases 6–7 use PORTB bits 4–5 (D12–D13)

## Trigger/Reset input conditioning

- 3.5mm jack → 100k resistor to GND → 2N3904 NPN base
- NPN collector pulled up to +5V via 10k
- Collector output to Arduino pin (inverted: external HIGH → NPN on → Arduino sees LOW)
- Handles Eurorack voltage levels (0-10V) safely — transistor clamps, Arduino only sees 0-5V
- **Both D2 and D3 need 10k pull-up resistors** to prevent floating/spurious triggering when no cable is connected

## Power supply

- Eurorack 10-pin header → +12V through 1N5819 Schottky (reverse protection) → 47µF decoupling → LM7805 → +5V
- 100nF ceramic on 7805 output
- Arduino powered via 5V pin (bypasses onboard regulator)
- Safe to have USB and circuit power connected simultaneously (Nano has built-in Schottky on USB 5V line)

## Known issues / bugs found and fixed

1. **Original FastWrite.ino bug:** Case 2 (D7) used `PORTD |= B11000000` which sets both bit 7 AND bit 6, accidentally also triggering output index 1. Fixed to only set bit 7.
2. **volatile struct copy:** `led_state[]` is `volatile LedColor` — C++ won't implicitly copy volatile structs. Must use member-by-member copy: `LedColor first = {led_state[0].r, led_state[0].g, led_state[0].b};`
3. **Timer2 prescaler:** CS22 alone = prescaler 256 (not 64). Need `(1 << CS22) | (1 << CS20)` for prescaler 64.
4. **PNP inversion problem:** CD4017 outputs are active-high, PNP turns on with base LOW → 9 LEDs on, 1 off (inverted). Solved by switching to NPN emitter-followers instead of PNPs.
5. **CD4017 CLK input:** Pure CMOS voltage-driven (no current needed), no Schmitt trigger hysteresis. Threshold ~2.5V at 5V supply. Direct drive from Arduino is clean enough; CD40106 buffer available if ringing occurs.

## Component inventory (relevant parts available)

- 100× 2N3904 (NPN), 100× 2N3906 (PNP), 20× BC327 (PNP), 20× BC337 (NPN)
- 25× CD74HC165E, 25× CD74HC595E, 2× SN74HC595N, 2× CD4094BE
- 29× CD4017BE
- 30× CD40106BE (Schmitt inverters — available if inversion needed)
- LM7805 regulators, 1N5819 Schottky diodes
- Common-anode RGB LEDs
- Full IC and semiconductor inventory available in CSV files

## Future considerations discussed but not implemented

- **BPM display:** 3-digit 7-segment or OLED (SSD1306). BPM = 60000000/period. Pin budget is the blocker — no spare pins.
- **Ratio display + live adjustment:** Single rotary encoder + OLED showing all 8 ratios. Would need pin reassignment (e.g., HC595 for gate outputs to free up pins for I2C).
- **ULN2803 Darlington array:** Could replace individual NPN transistors on cathode sinks if acquired, but not currently in inventory.

## KiCad schematic

A KiCad 8 schematic (.kicad_sch) and project file (.kicad_pro) were generated. The `lib_symbols` section is empty — KiCad resolves from local libraries on open. Layout needs manual cleanup after opening. Global labels connect the 6 sections (power, Arduino, switch input, LED driver, output buffers, trigger/reset inputs). Note: the KiCad schematic has NOT been updated to reflect the NPN emitter-follower change or the pin reassignment — it still shows the earlier PNP topology.

## Current build status

- Breadboarding stage
- LED multiplexing working after prescaler fix (10kHz confirmed on scope)
- NPN emitter-followers replacing original PNP attempt
- Bleed resistors (4.7k) needed on each LED anode to fix floating discharge
- Trigger/reset input conditioning circuit may not yet be wired — D2/D3 were floating and causing spurious triggers
- 10k pull-ups needed on D2 and D3
