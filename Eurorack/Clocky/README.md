# Clocky

A Eurorack clock divider/multiplier module, adapted from the
[SoundForce Clocky](https://soundforce.nl) design.

## What it does

Clocky takes a single master clock input and produces **8 independent
gate outputs (A–H)**. Each output can divide or multiply the incoming
clock by a fixed ratio, selectable per channel via a toggle switch.

| Channel | Default ratio |
| ------- | ------------- |
| A       | ×1            |
| B       | ×2            |
| C       | ×4            |
| D       | ×8            |
| E       | ×16           |
| F       | ×3            |
| G       | ×5            |
| H       | ×7            |

A **RST** jack resets the internal counter to re-synchronise divided
outputs. Ten RGB LEDs provide visual feedback:

| LED            | Behaviour                                    |
| -------------- | -------------------------------------------- |
| LED 0 (TRG)    | Flashes magenta on each incoming clock pulse |
| LED 1 (RST)    | Flashes green on reset                       |
| LEDs 2–9 (A–H) | Blue = divide mode · Green = multiply mode   |

When no clock is connected, the LEDs run an idle rainbow animation.

## Hardware differences from original SoundForce design

| Subsystem    | Original                         | This version                                                            |
| ------------ | -------------------------------- | ----------------------------------------------------------------------- |
| Switch input | PCF8574P (I2C 8-bit expander)    | CD74HC165E (parallel-in serial-out shift register)                      |
| LED display  | 10× PL9823 addressable RGB       | 10× common-anode RGB LEDs, multiplexed via CD4017BE                     |
| LED drivers  | Integrated in PL9823             | 10× 2N3904 NPN emitter-followers (anodes) + 3× 2N3904 NPN cathode sinks |
| Libraries    | Adafruit_NeoPixel, PCF8574, Wire | elapsedMillis only                                                      |

No I2C bus required.

## Pin assignments

```
Pin  | Function     | Group
-----+--------------+---------------------
D0   | (reserved)   | Serial RX
D1   | (reserved)   | Serial TX
D2   | TRIG_PIN     | Inputs
D3   | RESET_PIN    | Inputs (INT1)
D4   | LED_R        | LED cathode sinks
D5   | LED_G        | LED cathode sinks
D6   | LED_B        | LED cathode sinks
D7   | MUX_CLK      | LED mux (CD4017)
D8   | MUX_RST      | LED mux (CD4017)
D9   | SR_SH_LD     | Shift register (HC165)
D10  | SR_CLK       | Shift register (HC165)
D11  | SR_QH        | Shift register (HC165)
D12  | OUT7 (G)     | Gate outputs
D13  | OUT8 (H)     | Gate outputs
A0   | OUT1 (A)     | Gate outputs
A1   | OUT2 (B)     | Gate outputs
A2   | OUT3 (C)     | Gate outputs
A3   | OUT4 (D)     | Gate outputs
A4   | OUT5 (E)     | Gate outputs
A5   | OUT6 (F)     | Gate outputs
```

All 18 usable pins are assigned. A6/A7 are analog-only and unused.

## Firmware

Located in `Firmware/Clocky/`. Built with the Arduino IDE targeting
an Arduino Nano (ATmega328P).

| File                | Purpose                                                             |
| ------------------- | ------------------------------------------------------------------- |
| `Clocky.ino`        | Main sketch: setup, main loop, output timing, switch polling        |
| `variables.h`       | Pin definitions, state variables, colour constants, rainbow pattern |
| `FastWrite.ino`     | Port manipulation for fast gate output toggling                     |
| `LedMux.ino`        | Timer2 ISR for LED multiplexing, CD4017 control, `setLed()` helper  |
| `ShiftRegister.ino` | CD74HC165E reading and toggle state management                      |
| `interrupts.ino`    | Trigger ISR: clock edge detection, divider/multiplier output firing |

### Dependencies

- [elapsedMillis](https://github.com/pfeerick/elapsedMillis)

## LED multiplexing

Timer2 is configured in CTC mode at **10 kHz** (prescaler 64,
OCR2A = 24). The ISR cycles through all 10 LEDs every 1 ms, giving
a 1 kHz per-LED refresh rate with no visible flicker.

Each LED anode has a **4.7 kΩ bleed resistor to GND** to ensure fast
discharge when the NPN emitter-follower turns off; without this,
parasitic capacitance causes ghosting.

Current limiting uses **3 resistors total** (one per colour bus):
~68 Ω for red, ~47–56 Ω for green/blue. Multiplexing guarantees
only one LED is active at a time, so per-bus resistors are safe.

## Input conditioning

Trigger and reset jacks use an NPN transistor stage to safely accept
Eurorack signal levels (0–10 V). **10 kΩ pull-up resistors are required
on D2 and D3** to prevent spurious triggering when no cable is
connected.

## Power

Eurorack 10-pin header → +12 V → 1N5819 Schottky (reverse protection)
→ LM7805 → +5 V. The Arduino Nano is powered from the 5 V pin,
bypassing its onboard regulator.

## Build status

Breadboarding stage. Core LED multiplexing and clock division/
multiplication logic are working.

## Schematic

KiCad 8 project files are in the root directory (`.kicad_sch`,
`.kicad_pcb`, `.kicad_pro`). Note: the schematic has not been fully
updated to reflect the final NPN emitter-follower topology — it still
shows an earlier revision.
