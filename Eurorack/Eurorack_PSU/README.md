# Eurorack PSU

A mains-powered linear power supply for a Eurorack modular synthesizer case.

## What it does

Converts 240 VAC mains to the four standard Eurorack DC rails:

| Rail | Regulator |
|------|-----------|
| +12 V | LM7812 |
| −12 V | LM7912 |
| +5 V | LM7805 |
| −5 V | LM7905 |

## Key components

| Component | Role |
|-----------|------|
| Mains transformer (240 VAC, 20:1) | Mains isolation and step-down |
| GBU6A | Full-bridge rectifier |
| LM7812 / LM7912 | ±12 V linear regulators |
| LM7805 / LM7905 | ±5 V linear regulators |
| 10 000 µF bulk caps | Reservoir filtering |
| 1N4007 diodes | Rectifier protection |

## Files

KiCad 8 project files are in the root directory (`.kicad_sch`, `.kicad_pcb`, `.kicad_pro`).

**Revision:** 1 (2026-02-28)
