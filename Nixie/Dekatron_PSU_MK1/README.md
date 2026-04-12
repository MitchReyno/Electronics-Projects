# Dekatron PSU MK1

A high-voltage power supply for Dekatron counting/display tubes.

## What it does

Provides the high-voltage DC supply required to operate Dekatron tubes (e.g. GC10B, OG-4). Dekatrons typically require ~400–450 V for the anode and guide pins, with the exact voltage depending on the tube type.

The design is a boost converter topology adapted from the Nixie PSU MK1, with component values adjusted for the higher output voltage.

## Key components

| Component | Role                           |
| --------- | ------------------------------ |
| MC34063AP | Switching regulator controller |
| IRF740    | N-channel MOSFET power switch  |
| PN2907ABU | PNP transistor (gate drive)    |
| BAV21     | High-voltage rectifier diode   |
| 1N4148    | Signal diode                   |

## Files

KiCad project files are in the root directory (`.kicad_sch`, `.kicad_pcb`, `.kicad_pro`).

> **Note:** The KiCad files in this directory are named `Nixie_PSU_MK1.*` — they represent the adapted design for Dekatron use.
