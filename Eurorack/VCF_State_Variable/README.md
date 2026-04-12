# VCF State Variable

A state-variable voltage-controlled filter (VCF) Eurorack module.

## What it does

The state-variable topology produces three simultaneous filter outputs from the same input signal:

| Output | Response |
|--------|----------|
| LP | Low-pass |
| BP | Band-pass |
| HP | High-pass |

The module accepts up to three audio inputs and three CV inputs for cutoff frequency control. Resonance is also voltage-controllable via dedicated CV inputs on the cutoff board.

## Key components

| Component | Role |
|-----------|------|
| LM13700 | Dual OTA — voltage-controlled integrator stages |
| TL072 | Op-amp summation and buffering |
| 2N3904 / 2N3906 | NPN/PNP transistor linearisation stages |
| 1N4148 | Clipping diodes |

## Files

The design is split across two KiCad schematics:

| File | Contents |
|------|----------|
| `VCF_State_Variable.kicad_sch` | Main filter board (signal path, I/O jacks, power) |
| `Cutoff_Board.kicad_sch` | Cutoff and resonance CV processing sub-board |

PCB and project files are in the root directory.
