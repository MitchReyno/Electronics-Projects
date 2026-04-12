# LFO VC

A voltage-controlled low-frequency oscillator (LFO) Eurorack module.

## What it does

Generates six simultaneous LFO waveforms with voltage control over rate:

| Output | Waveform |
|--------|----------|
| SIN | Sine |
| TRI | Triangle |
| SAW | Sawtooth |
| RMP | Ramp |
| SQR | Square |
| INV_SQR | Inverted square |

CV input controls oscillator rate. A CV output is also provided.

## Key components

| Component | Role |
|-----------|------|
| LM13700 | Dual OTA — oscillator core and CV gain control |
| TL072 (×5) | Op-amp waveshapers and output buffers |
| MPF102 JFET | Triangle-to-sine waveshaping |
| 2N3904 / 2N3906 | NPN/PNP transistor stages |
| 10-pin IDC header | Eurorack ±12 V power |

## Files

KiCad 8 project files are in the root directory (`.kicad_sch`, `.kicad_pcb`, `.kicad_pro`).
A single-channel variant is available as `LFO_VC_Single.kicad_pcb`.
Fabrication outputs are in `Fab Outputs/`.
