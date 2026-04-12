# Electronics-Projects

A collection of various electronics projects I've worked on over the years.

## Categories

- [Eurorack](#eurorack) — Modular synthesizer modules
- [Nixie](#nixie) — Nixie tube and Dekatron display projects
- [Spice Models](#spice-models) — SPICE simulation models

---

## Eurorack

Eurorack-format modular synthesizer modules, designed in KiCad.

| Project                                              | Description                                                                                                                                      |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Clocky](Eurorack/Clocky/)                           | Clock divider/multiplier — 8 gate outputs (÷/× per channel), RGB LED feedback, Arduino Nano firmware. Adapted from the SoundForce Clocky design. |
| [Dual Log/Linear VCA](Eurorack/Dual_Log_Linear_VCA/) | Dual voltage-controlled amplifier with switchable logarithmic and linear response curves.                                                        |
| [Eurorack PSU](Eurorack/Eurorack_PSU/)               | Eurorack power supply unit providing ±12 V and +5 V rails for a modular case.                                                                    |
| [LFO RW](Eurorack/LFO_RW/)                           | Low-frequency oscillator module with multiple waveform outputs.                                                                                  |
| [LFO VC](Eurorack/LFO_VC/)                           | Voltage-controlled LFO with CV over rate.                                                                                                        |
| [Quad Attenuator](Eurorack/Quad_Attenuator/)         | Four-channel passive/active attenuator panel.                                                                                                    |
| [VCA](Eurorack/VCA/)                                 | Voltage-controlled amplifier module.                                                                                                             |
| [VCF State Variable](Eurorack/VCF_State_Variable/)   | State-variable voltage-controlled filter with simultaneous low-pass, band-pass, and high-pass outputs.                                           |

---

## Nixie

High-voltage power supplies and display projects for Nixie and Dekatron tubes.

| Project                                     | Description                                                        |
| ------------------------------------------- | ------------------------------------------------------------------ |
| [Dekatron PSU MK1](Nixie/Dekatron_PSU_MK1/) | High-voltage power supply designed for Dekatron counting tubes.    |
| [Nixie PSU MK1](Nixie/Nixie_PSU_MK1/)       | High-voltage boost converter power supply for Nixie tube displays. |

---

## Spice Models

[`Spice_Models/`](Spice_Models/) — A library of SPICE simulation model files (`.MOD` / `.LIB`) for common components used across projects, including transistors, diodes, op-amps, regulators, and transformers.
