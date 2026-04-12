# Nixie PSU MK1

A high-voltage boost converter power supply for Nixie tube displays.

## What it does

Steps up a low DC input voltage to approximately 170 V DC — the typical anode supply voltage for IN-series Nixie tubes.

## Key components

| Component       | Role                           |
| --------------- | ------------------------------ |
| MC34063AP       | Switching regulator controller |
| IRF740          | N-channel MOSFET power switch  |
| PN2907ABU       | PNP transistor (gate drive)    |
| 220 µH inductor | Boost energy storage           |
| BAV21           | High-voltage rectifier diode   |
| 1N4148          | Signal diode                   |
| 100 kΩ trim pot | Output voltage adjustment      |

The output voltage is set by a resistor divider (fixed resistor + trim pot) feeding back to the MC34063 sense pin, allowing fine adjustment around the target voltage.

## Files

KiCad 8 project files are in the root directory (`.kicad_sch`, `.kicad_pcb`, `.kicad_pro`).
