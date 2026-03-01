* ================================================================
* IRF740 - N-Channel Power MOSFET
* 400V, 10A, Rds(on)=0.55R, TO-220
*
* PIN CONNECTIONS:
*   1: Gate
*   2: Drain
*   3: Source
*
* Instantiation:
*   X1  Gate  Drain  Source  IRF740
*
* Parameters derived from Vishay datasheet:
*   Vgs(th) = 2-4V (typ 3V)
*   Rds(on) = 0.55R @ Vgs=10V
*   Ciss = 890pF, Coss = 150pF, Crss = 80pF
*   Qg = 42nC -> RG ~ 1R typical internal gate resistance
* ================================================================
.SUBCKT IRF740  1 2 3
*               G D S
*
* Internal gate resistance (models gate bond wire + poly resistance)
RG    1    4    1.0
*
* MOSFET: gate=4(internal), drain=2, source=3, bulk=3
M1    2    4    3    3    IRF740_INT
*
.MODEL IRF740_INT NMOS (
+ LEVEL=3
+ VTO=3.0
+ KP=3.5
+ THETA=0.08
+ VMAX=1E5
+ RS=0.1
+ RD=0.45
+ CBD=150E-12
+ CBS=500E-12
+ CGSO=4.0E-9
+ CGDO=1.0E-9
+ IS=1E-14
+ PB=0.8
+ MJ=0.5
+ MJSW=0.5
+ TNOM=27)
*
.ENDS IRF740
*
* ================================================================
* USAGE:
*   X1  Gate  Drain  Source  IRF740
*
* In KiCad simulation model editor:
*   - Select "SPICE model from file"
*   - Model name: IRF740
*   - Pin assignments: Gate=1, Drain=2, Source=3
* ================================================================
