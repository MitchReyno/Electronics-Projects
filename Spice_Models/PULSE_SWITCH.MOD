* ================================================================
* PULSE_SWITCH - Ideal timed switch with internal oscillator
*
* Periodically connects/disconnects pins A and B at defined intervals.
* Implemented as a voltage-controlled switch driven by an internal
* PULSE voltage source.
*
* PIN CONNECTIONS:
*   1: Switch terminal A
*   2: Switch terminal B
*
* PARAMETERS:
*   PERIOD  - Total period time (seconds), e.g. 10m = 10ms
*   PW      - Pulse width / on-time (seconds), e.g. 5m = 5ms
*   TRISE   - Rise/fall time of internal control signal (default 1ns)
*             Keep small relative to PW for near-ideal switching.
*
* USAGE:
*   XSWA  NodeA  NodeB  PULSE_SWITCH PARAMS: PERIOD=10m PW=5m
*
* The switch closes (ON) for PW seconds, then opens (OFF) for
* (PERIOD - PW) seconds, repeating indefinitely.
*
* Internal control signal swings 0V (off) to 5V (on).
* Switch threshold is at 2.5V.
*
* ================================================================
.SUBCKT PULSE_SWITCH  1 2  PARAMS: PERIOD=10m PW=5m TRISE=1n
*
* Internal oscillator: PULSE source
* PULSE(V1 V2 TD TR TF PW PER)
*   V1=0 (off level)
*   V2=5 (on level)
*   TD=0 (no initial delay)
*   TR=TRISE, TF=TRISE
*   PW=PW (on-time)
*   PER=PERIOD
VCTRL  CTRL  0  PULSE(0 5 0 {TRISE} {TRISE} {PW} {PERIOD})
*
* Voltage-controlled switch
* Closes when CTRL > Vt=2.5V
* Ron=1m (near-ideal on), Roff=1G (near-ideal off)
SSWITCH  1  2  CTRL  0  SW_IDEAL
*
.MODEL SW_IDEAL SW (RON=1m ROFF=1G VT=2.5 VH=0.5)
*
.ENDS PULSE_SWITCH
*
* ================================================================
* USAGE EXAMPLES:
*
* 50% duty cycle, 1kHz:
*   XSWA  A  B  PULSE_SWITCH PARAMS: PERIOD=1m PW=500u
*
* 10% duty cycle, 100Hz:
*   XSWB  A  B  PULSE_SWITCH PARAMS: PERIOD=10m PW=1m
*
* Custom rise time (slower switching):
*   XSWC  A  B  PULSE_SWITCH PARAMS: PERIOD=10m PW=5m TRISE=100u
*
* NOTE: The internal VCTRL source is referenced to node 0 (global GND).
* This is fine as long as terminal A or B is also referenced to GND
* somewhere in the circuit. If the switch is floating (neither terminal
* connected to GND), add a large resistor (e.g. 1G) from terminal B
* to GND to give the solver a DC path.
* ================================================================
