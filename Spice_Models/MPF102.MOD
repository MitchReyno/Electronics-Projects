* MPF102 N-Channel JFET
* National Semiconductor
* TO-92 package: Pin 1=Gate, Pin 2=Source, Pin 3=Drain
*
* KiCad SPICE pin mapping:
*   Pin 1 (Gate)   -> port 1
*   Pin 2 (Source) -> port 2
*   Pin 3 (Drain)  -> port 3
*
.MODEL MPF102 NJF(
+ Beta=1.04m
+ Betatce=-0.5
+ Rd=1
+ Rs=1
+ Lambda=2m
+ Vto=-3.41
+ Vtotc=-2.5m
+ Is=33.57f
+ N=1
+ Xti=3
+ Cgd=1.6p
+ M=0.3622
+ Pb=1
+ Fc=0.5
+ Cgs=2.414p
+ Kf=11.73E-18
+ Af=1)
