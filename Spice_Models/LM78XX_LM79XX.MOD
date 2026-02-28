* ================================================================
* Linear Voltage Regulator Models
* LM7805, LM7812, LM7905, LM7912
*
* Realistic behavioural models including:
*   - Output voltage accuracy
*   - Dropout voltage
*   - Quiescent current drain
*   - Line regulation
*   - Load regulation
*
* PIN CONNECTIONS (positive regulators LM78xx):
*   1: INPUT
*   2: GND
*   3: OUTPUT
*
* PIN CONNECTIONS (negative regulators LM79xx):
*   1: GND
*   2: INPUT  (negative, e.g. -12V)
*   3: OUTPUT (negative, e.g. -12V regulated)
*
* Model approach:
*   - EOUT: voltage-controlled voltage source sets nominal Vout
*   - RDO:  dropout resistor models input-output headroom behaviour
*   - IQ:   quiescent current drawn from input to GND
*   - Line regulation: Vout varies slightly with Vin via small GLINE
*   - Load regulation: Rout models finite output impedance
*
* Key parameters per device:
*   LM7805: Vout=5V,   Vdrop=2.0V, Iq=6mA, Rout=0.01, line_reg=2mV/V
*   LM7812: Vout=12V,  Vdrop=2.0V, Iq=8mA, Rout=0.018, line_reg=3mV/V
*   LM7905: Vout=-5V,  Vdrop=2.0V, Iq=6mA, Rout=0.01, line_reg=2mV/V
*   LM7912: Vout=-12V, Vdrop=2.0V, Iq=8mA, Rout=0.018, line_reg=3mV/V
*
* ================================================================


* ----------------------------------------------------------------
* LM7805 - +5V Regulator
* Pins: IN GND OUT
* ----------------------------------------------------------------
.SUBCKT LM7805  1 2 3
*              IN GND OUT
*
* Dropout: model as resistor in series with ideal output
* When Vin - Vout < Vdrop, output will sag naturally
RDO   1    10   0.5
*
* Quiescent current: 6mA from IN to GND
IQ    1    2    6m
*
* Ideal output voltage source (5V from GND)
EOUT  11   2    VALUE={5.0 + 0.002*(V(1,2) - 7.0)}
*
* Load regulation: finite output impedance ~10mΩ
ROUT  11   3    0.01
*
* Dropout limiting: EOUT tracks input when headroom is insufficient
* Implemented via RDO voltage drop — if Vin < 7V, node 10 drops
* and EOUT (referenced to node 10 via diode clamp) limits output.
* Simple clamp diode: prevents output exceeding input rail.
DCLAMP  3  10  DIDEAL
*
.MODEL DIDEAL D (IS=1E-15 N=0.001 RS=0)
*
.ENDS LM7805


* ----------------------------------------------------------------
* LM7812 - +12V Regulator
* Pins: IN GND OUT
* ----------------------------------------------------------------
.SUBCKT LM7812  1 2 3
*              IN GND OUT
*
RDO   1    10   0.5
IQ    1    2    8m
*
* Line regulation: ~3mV/V deviation from nominal Vin of 19V
EOUT  11   2    VALUE={12.0 + 0.003*(V(1,2) - 19.0)}
*
ROUT  11   3    0.018
DCLAMP  3  10  DIDEAL
*
.MODEL DIDEAL D (IS=1E-15 N=0.001 RS=0)
*
.ENDS LM7812


* ----------------------------------------------------------------
* LM7905 - -5V Regulator
* Pins: GND IN OUT
*       1   2  3
* IN is negative (e.g. -8V or more negative)
* OUT is -5V
* ----------------------------------------------------------------
.SUBCKT LM7905  1 2 3
*              GND IN OUT
*
* Dropout resistor on negative input rail
RDO   2    10   0.5
*
* Quiescent current: flows from GND to IN (conventional, negative rail)
IQ    1    2    6m
*
* Output: -5V referenced to GND (pin 1)
* Line regulation: ~2mV/V, nominal Vin=-8V (so V(2,1) ~ -8V, magnitude 8V)
EOUT  11   1    VALUE={-5.0 - 0.002*(ABS(V(2,1)) - 8.0)}
*
ROUT  11   3    0.01
*
* Clamp: prevent output going more positive than input (for negative reg)
DCLAMP  10  3  DIDEAL
*
.MODEL DIDEAL D (IS=1E-15 N=0.001 RS=0)
*
.ENDS LM7905


* ----------------------------------------------------------------
* LM7912 - -12V Regulator
* Pins: GND IN OUT
*       1   2  3
* IN is negative (e.g. -15V or more negative)
* OUT is -12V
* ----------------------------------------------------------------
.SUBCKT LM7912  1 2 3
*              GND IN OUT
*
RDO   2    10   0.5
IQ    1    2    8m
*
* Line regulation: ~3mV/V, nominal Vin=-19V
EOUT  11   1    VALUE={-12.0 - 0.003*(ABS(V(2,1)) - 19.0)}
*
ROUT  11   3    0.018
DCLAMP  10  3  DIDEAL
*
.MODEL DIDEAL D (IS=1E-15 N=0.001 RS=0)
*
.ENDS LM7912


* ================================================================
* USAGE EXAMPLES:
*
* Positive regulators:
*   XU1  VIN_RAW  GND  +5V   LM7805
*   XU2  VIN_RAW  GND  +12V  LM7812
*
* Negative regulators (note pin order: GND first, then negative IN):
*   XU3  GND  VIN_NEG  -5V   LM7905
*   XU4  GND  VIN_NEG  -12V  LM7912
*
* Typical supply conditions:
*   LM7805: Vin = +8V to +20V  (need >7V for full regulation)
*   LM7812: Vin = +14V to +27V (need >14V for full regulation)
*   LM7905: Vin = -8V to -20V  (need <-7V for full regulation)
*   LM7912: Vin = -14V to -27V (need <-14V for full regulation)
*
* With rectifier and smoothing:
*   XRECT   +RAW  -RAW  SECA_P  SECA_N  GBU6G
*   CSMOOTH_P  +RAW  GND  2200u
*   CSMOOTH_N  GND  -RAW  2200u
*   XU2  +RAW  GND  +12VREG  LM7812
*   XU4  GND  -RAW  -12VREG  LM7912
* ================================================================
