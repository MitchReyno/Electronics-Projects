* ================================================================
* GBU6G Bridge Rectifier
* 6A, 400V single-phase bridge rectifier
* Vishay/generic compatible
*
* PIN CONNECTIONS:
*   1: DC+ output
*   2: AC input 1  
*   3: AC input 2
*   4: DC- output
*
* Bridge configuration:
*   D1: AC1(2) -> DC+(1)   [bottom-right]
*   D2: DC-(4) -> AC1(2)   [bottom-left]  
*   D3: AC2(3) -> DC+(1)   [top-right]
*   D4: DC-(4) -> AC2(3)   [top-left]
*
* GBU6G parameters (400V variant):
*   If(avg)  = 6A
*   Ifsm     = 200A (surge)
*   Vrrm     = 400V
*   Vf       = 1.1V @ 6A
*   Trr      = 3us (soft recovery, standard rectifier)
*
* Model parameters derived from GBU6G datasheet:
*   IS  = 1.5E-9   (saturation current; sets Vf ~ 1.1V @ 6A)
*   N   = 1.85     (ideality factor; shapes Vf curve)
*   RS  = 0.022    (series resistance; accounts for bulk resistance)
*   BV  = 400      (reverse breakdown voltage)
*   IBV = 5E-6     (reverse current at BV)
*   TT  = 3E-6     (transit time; sets Trr ~ 3us)
*   CJO = 50E-12   (junction capacitance)
*   VJ  = 0.6      (junction potential)
*   M   = 0.5      (grading coefficient)
*   EG  = 1.11     (silicon bandgap)
*   XTI = 3        (IS temperature exponent)
*
* ================================================================
.SUBCKT GBU6G  1 2 3 4
*            DC+ DC- AC1 AC2
*
* D1: AC1 -> DC+
D1  2  1  GBU6G_DIODE
* D2: DC- -> AC1
D2  4  2  GBU6G_DIODE
* D3: AC2 -> DC+
D3  3  1  GBU6G_DIODE
* D4: DC- -> AC2
D4  4  3  GBU6G_DIODE
*
.MODEL GBU6G_DIODE D (
+ IS=1.5E-9
+ N=1.85
+ RS=0.022
+ BV=400
+ IBV=5E-6
+ TT=3E-6
+ CJO=50E-12
+ VJ=0.6
+ M=0.5
+ EG=1.11
+ XTI=3)
*
.ENDS GBU6G
*
* ================================================================
* USAGE:
*
* XD7  DCPLUS  DCMINUS  AC1  AC2  GBU6G
*
* With transformer secondary and smoothing cap:
*   XD7    +12V  -12V  SECA_P  SECA_N  GBU6G
*   CSMOOTH  +12V  -12V  2200u
*
* Expected output (resistive load, 6A full load):
*   Vdc ~ Vpeak - 2*Vf = 16.97 - 2.2 = 14.77V unloaded
*   Regulation depends on transformer impedance and load
* ================================================================
