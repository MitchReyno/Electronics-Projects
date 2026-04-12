# Eurorack

Eurorack-format modular synthesizer modules, all designed in KiCad 8.

## Modules

| Module                                      | Description                                                                                                                          |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| [Clocky](Clocky/)                           | Clock divider/multiplier — 8 gate outputs with per-channel ÷/× ratios, RGB LED feedback, Arduino Nano firmware                       |
| [Dual Log/Linear VCA](Dual_Log_Linear_VCA/) | Dual voltage-controlled amplifier with switchable logarithmic and linear response                                                    |
| [LFO RW](LFO_RW/)                           | Low-frequency oscillator module                                                                                                      |
| [LFO VC](LFO_VC/)                           | Voltage-controlled LFO — 6 simultaneous waveform outputs (sine, triangle, sawtooth, ramp, square, inverted square) with CV over rate |
| [Quad Attenuator](Quad_Attenuator/)         | Four-channel attenuator — panel design files                                                                                         |
| [VCA](VCA/)                                 | Voltage-controlled amplifier module                                                                                                  |
| [VCF State Variable](VCF_State_Variable/)   | State-variable voltage-controlled filter with simultaneous LP, BP, and HP outputs                                                    |

## Power Supply

| Module                        | Description                                                                 |
| ----------------------------- | --------------------------------------------------------------------------- |
| [Eurorack PSU](Eurorack_PSU/) | Mains-powered linear PSU providing ±12 V and ±5 V rails for a Eurorack case |

## Common

[`Common/`](Common/) contains shared assets used across modules (logo SVG etc.).
