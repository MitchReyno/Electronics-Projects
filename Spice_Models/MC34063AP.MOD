* ================================================================
* MC34063AP - DC-DC Converter Controller (Behavioural)
* Step-up, step-down, inverting capable
* 3-40V input, 1.5A switch current
*
* PIN CONNECTIONS:
*   1: Switch Collector (SC)
*   2: Switch Emitter   (SE)
*   3: Timing Capacitor (CT)
*   4: GND
*   5: Feedback input   (VFB) - connect resistor divider here
*   6: Vcc
*   7: IPK current sense (connect 0.33R between pin 7 and pin 2)
*   8: Driver Collector  (same function as pin 1 internally)
*
* USAGE:
*   XU1  SC  SE  CT  GND  VFB  VCC  IPK  DRV  MC34063AP
*
* Vout = 1.25 * (1 + R_upper/R_lower)
* Fosc = 1 / (4 * Ct * 1250)  e.g. 1nF -> 200kHz
*
* Add .ic v(ct_node)=0 to your netlist for reliable startup.
* ================================================================
.SUBCKT MC34063AP  1 2 3 4 5 6 7 8
*                 SC SE CT GND VFB VCC IPK DRV
*
* --- INTERNAL REFERENCE ---
* 1.25V bandgap reference
EREF  VREF  4  VALUE={1.25}
*
* --- OSCILLATOR ---
* Sawtooth on CT pin: charge at 35uA, discharge when Vct > 1.25V
* Use B-source (nonlinear) to avoid feedback instability.
* Net charge current: 35uA when Vct < 1.25, discharge via large
* conductance when Vct >= 1.25 (models internal comparator+switch).
BOSC  3  4  I=IF(V(3,4) < 1.25, 35u, -1m)
*
* Internal clock signal: high when CT is charging (Vct < 1.25V)
BCLK  CLK  4  V=IF(V(3,4) < 1.25, 5, 0)
*
* --- ERROR COMPARATOR ---
* Output high when VFB < Vref (output voltage too low, keep switching)
BCOMP  COMP  4  V=IF(V(5,4) < 1.25, 5, 0)
*
* --- CURRENT LIMIT ---
* Stop switching when V(IPK,SE) > 0.33V (~1A through 0.33R sense)
BIPK  IPKLIM  4  V=IF(V(7,2) < 0.33, 5, 0)
*
* --- OUTPUT ENABLE ---
* Switch on when: CLK high AND feedback says regulate AND no overcurrent
BEN  EN  4  V=IF(V(CLK,4) > 2.5 && V(COMP,4) > 2.5 && V(IPKLIM,4) > 2.5, 5, 0)
*
* --- POWER SWITCH (pins 1 and 2) ---
* Models the internal NPN power transistor
* Vce(sat) ~ 1V via series resistor
* Use voltage-controlled switch for clean on/off
SOUT  1  SW_INT  EN  4  SW_PWR
RSW   SW_INT  2  1.0
*
* --- DRIVER OUTPUT (pin 8) ---
* Pin 8 mirrors switch collector with series resistance
* Must not drive reactive loads directly - add Rdrv
RDRV  1  8  100
*
* --- QUIESCENT CURRENT ---
IQ  6  4  2.5m
*
.MODEL SW_PWR SW (RON=0.5 ROFF=100MEG VT=2.5 VH=0.5)
*
.ENDS MC34063AP
*
* ================================================================
* SIMULATION TIPS:
*
* 1. Always add initial condition on timing cap:
*    .ic v(ct_node)=0
*
* 2. Use small timestep - at least 1/100 of switching period:
*    .tran 100n 5m
*    (for 200kHz switching with 1nF Ct)
*
* 3. Typical step-up (boost) circuit connections:
*    - V1 between VIN+ and VIN-
*    - L1 between VIN+ and SC (pin 1)
*    - SE (pin 2) to VIN-
*    - D1 (cathode to Vout) from SC (pin 1)
*    - Cout between Vout and VIN-
*    - R_upper from Vout to VFB (pin 5)
*    - R_lower from VFB (pin 5) to VIN-
*    - Ct between CT (pin 3) and VIN-
*    - 0.33R between IPK (pin 7) and SE (pin 2)
*    - VCC (pin 6) to VIN+
*    - GND (pin 4) to VIN-
*    - DRV (pin 8) not connected or tied to SC (pin 1)
* ================================================================
