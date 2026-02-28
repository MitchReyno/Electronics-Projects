* ================================================================
* 20VA Mains Transformer - 240V Primary, 12V-0-12V CT Secondary
*
* Realistic model including winding resistances, leakage inductances,
* magnetising inductance, and core loss.
*
* Ratings:
*   Primary:   240V RMS, 50Hz, 83mA max
*   Secondary: 12V-0-12V RMS (24V total), 833mA max
*   Turns ratio: 10:1 (primary to each half-secondary)
*
* PIN CONNECTIONS:
*   1: Primary terminal 1 (Live)
*   2: Primary terminal 2 (Neutral)
*   3: Secondary end 1    (+12V AC)
*   4: Center tap         (0V AC reference)
*   5: Secondary end 2    (-12V AC)
*
* Physical model:
*   The CT secondary is a single winding with a tap at the midpoint.
*   Modelled as two series-connected half-windings (each 12V, 115mH),
*   sharing one core with the primary.
*   The two halves are naturally in series and antiphase about the CT,
*   so no polarity tricks are needed.
*
* Parameter derivation:
*   Total secondary: 24V, turns ratio to primary = 240/24 = 10:1
*   Each half:       12V, Lhalf = Lpri / 10^2 = 92 / 100 = 920mH
*
*   Lm   = 92H    (magnetising inductance, referred to primary)
*   Rc   = 288k   (core loss; ~0.2W = 1% of 20VA)
*   Rp   = 145R   (primary winding resistance)
*   Rs   = 0.05R  (each half-secondary winding resistance)
*   k    = 0.98   (coupling coefficient)
*
* ================================================================
.SUBCKT XFMR_240_CT12  1 2 3 4 5
*                      P1 P2 S+ CT S-
*
* --- PRIMARY ---
RP    1    7    145
RC    7    2    288k
LPRI  7    2    92
*
* --- CT SECONDARY ---
* Two half-windings in series, joined at center tap (pin 4).
* Both couple to the same primary via K.
*
* Upper half: pin 3 (+12V end) to CT (pin 4)
* RS on the pin-3 side; internal node 8 is the winding terminal.
RS_UP  8    3    0.05
LSEC_UP  8    4    230m
*
* Lower half: CT (pin 4) to pin 5 (-12V end)
* Winding direction reversed so pin 5 swings opposite to pin 3.
* RS on the pin-5 side; internal node 9 is the winding terminal.
RS_LO  9    5    0.05
LSEC_LO  4    9    230m
*
* Single K: all windings on one shared core
KCORE  LPRI  LSEC_UP  LSEC_LO  0.98
*
.ENDS XFMR_240_CT12
*
* ================================================================
* USAGE - FULL-WAVE CT RECTIFIER (+/-12V DC rails):
*
*   VPRI  LIVE  NEUTRAL  SIN(0 339.4 50)
*   XTRA  LIVE  NEUTRAL  ACPLUS  CT  ACMINUS  XFMR_240_CT12
*
*   Full-wave CT rectification (2 diodes only):
*   D1  ACPLUS   DCPLUS  D1N5408
*   D2  ACMINUS  DCPLUS  D1N5408
*   D3  DCMINUS  ACPLUS  D1N5408
*   D4  DCMINUS  ACMINUS D1N5408
*
*   Smoothing caps (CT = circuit GND):
*   CP  DCPLUS   CT  2200u
*   CN  CT  DCMINUS  2200u
*
*   Regulators:
*   XU12P  DCPLUS   CT  +12VREG  LM7812
*   XU12N  CT  DCMINUS  -12VREG  LM7912
*
* Expected voltages (at CT as reference):
*   ACPLUS/ACMINUS: +/-12V RMS, +/-16.97V peak
*   DCPLUS (unloaded, after rectifier): ~16.3V (16.97 - 0.7V diode drop)
*   DCMINUS (unloaded): ~-16.3V
*   After LM7812/LM7912: +/-12V regulated
* ================================================================
