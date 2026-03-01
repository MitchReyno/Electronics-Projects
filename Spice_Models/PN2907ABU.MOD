* ================================================================
* PN2907ABU - PNP General Purpose BJT
* 60V, 600mA, TO-92
*
* PIN CONNECTIONS: 1=Emitter  2=Base  3=Collector
*
* Parameters derived from ON Semi datasheet:
*   Vceo = 60V, Ic = 600mA, hFE = 100-300 @ 150mA
*   Vbe(sat) ~ 0.75V, Vce(sat) ~ 0.25V @ 150mA
* ================================================================
.MODEL PN2907ABU PNP (
+ IS=1.5E-14
+ BF=200
+ NF=1.3
+ VAF=50
+ IKF=0.6
+ ISE=1.5E-14
+ NE=1.5
+ BR=4
+ NR=2
+ VAR=10
+ RB=10
+ RC=0.3
+ RE=0.2
+ CJE=24E-12
+ VJE=0.75
+ MJE=0.33
+ CJC=8E-12
+ VJC=0.75
+ MJC=0.33
+ TF=0.6E-9
+ TR=60E-9
+ EG=1.11
+ XTI=3)
