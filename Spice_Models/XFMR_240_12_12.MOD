* ================================================================
* 20VA Mains Transformer - 240V Primary, Dual Independent 12V Secondaries
* Center-tap capable: connect pins 4 and 5 together for CT configuration.
*
* Ratings:
*   Primary:     240V RMS, 50Hz, 83mA max
*   Secondary A: 12V RMS, 833mA max (~10VA)
*   Secondary B: 12V RMS, 833mA max (~10VA)
*   Turns ratio: 20:1 (primary to each secondary)
*
* PIN CONNECTIONS:
*   1: Primary terminal 1 (Live)
*   2: Primary terminal 2 (Neutral)
*   3: Secondary A terminal 1
*   4: Secondary A terminal 2  } tie together for center tap
*   5: Secondary B terminal 1  }
*   6: Secondary B terminal 2
*
* Center-tap usage:
*   Pins 4+5 joined = CT (0V reference)
*   Pin 3 = +12V AC, Pin 6 = -12V AC
*   Full-wave CT rectifier gives +/-12V DC rails
*
* Parameter derivation:
*   Lm  = 92H     (magnetising inductance, referred to primary)
*   Rc  = 288k    (core loss; ~0.2W = 1% of 20VA)
*   Rp  = 145R    (primary winding resistance; ~1W copper loss)
*   Rs  = 0.05R   (each secondary winding resistance; ~0.25W each)
*   k   = 0.98    (coupling coefficient; ~2% total leakage)
*
* Winding inductances (turns ratio via sqrt(L1/L2)):
*   Primary:     Lpri = 92H
*   Secondary A: Lseca = 92 / 20^2 = 230mH
*   Secondary B: Lsecb = 92 / 20^2 = 230mH
*
* ================================================================
.SUBCKT XFMR_240_12_12  1 2 3 4 5 6
*                       P1 P2 SA1 SA2 SB1 SB2
*
* --- PRIMARY ---
* Primary winding resistance (in series with primary winding)
RP    1    7    145
*
* Core loss resistance (shunt across magnetising branch)
RC    7    2    288k
*
* --- COUPLED WINDINGS ---
* All winding terminals are external pins (after series Rs),
* so center-tap connection at pins 4/5 works correctly.
*
* Primary inductance (magnetising)
LPRI  7    2    92
*
* Secondary A inductance
* Series resistance on each secondary BEFORE the external pin,
* using internal nodes only on the primary/winding side.
* SA: internal node 8 (winding end) -> external pin 3 via Rs
*     external pin 4 is the other winding terminal (direct)
RS_A  8    3    0.05
LSECA 8    4    230m
*
* SB: internal node 9 (winding end) -> external pin 6 via Rs
*     external pin 5 is the other winding terminal (direct)
* NOTE: LSECB is reversed (5->9) so SB is antiphase to SA,
*       giving correct center-tap polarity: pin3=+, CT=0, pin6=-
RS_B  9    6    0.05
LSECB 5    9    230m
*
* Single K statement: all three windings on one shared core
KCORE  LPRI  LSECA  LSECB  0.98
*
.ENDS XFMR_240_12_12
*
* ================================================================
* USAGE - INDEPENDENT SECONDARIES:
*
*   VPRI  LIVE  NEUTRAL  SIN(0 339.4 50)
*   XTRA  LIVE  NEUTRAL  SECA_P  SECA_N  SECB_P  SECB_N  XFMR_240_12_12
*
*   Bridge rectifier on each secondary:
*   XDA  +RAIL_A  -RAIL_A  SECA_P  SECA_N  GBU6G
*   XDB  +RAIL_B  -RAIL_B  SECB_P  SECB_N  GBU6G
*
* ----------------------------------------------------------------
* USAGE - CENTER TAP (full-wave CT rectifier for +/-12V):
*
*   VPRI  LIVE  NEUTRAL  SIN(0 339.4 50)
*   XTRA  LIVE  NEUTRAL  ACPOS  CT  CT  ACNEG  XFMR_240_12_12
*   (pins 4 and 5 both connected to CT node)
*
*   Two diodes for full-wave CT rectification:
*   D1  ACPOS  DCPLUS   D1N5408
*   D2  ACNEG  DCPLUS   D1N5408
*   (cathodes to DC+, anodes to each AC winding end)
*
*   Negative rail (flip diodes):
*   D3  DCMINUS  ACPOS  D1N5408
*   D4  DCMINUS  ACNEG  D1N5408
*
*   Smoothing:
*   CP  DCPLUS   CT  2200u
*   CN  CT  DCMINUS  2200u
*
*   Regulators:
*   XU12  DCPLUS   CT  +12VREG  LM7812
*   XU12N CT  DCMINUS  -12VREG  LM7912
* ================================================================
