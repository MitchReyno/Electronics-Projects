* ================================================================
* BAV21 - Small Signal High Voltage Diode
* 200V, 250mA, fast switching
*
* PIN CONNECTIONS: Anode=A  Cathode=K
* ================================================================
.MODEL BAV21 D (
+ IS=1.5E-9
+ N=1.65
+ RS=0.9
+ BV=200
+ IBV=1E-5
+ TT=6E-9
+ CJO=2.5E-12
+ VJ=1.0
+ M=0.33
+ EG=1.11
+ XTI=3)
