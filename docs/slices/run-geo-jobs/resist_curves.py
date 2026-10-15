def clamp(v,a,b): return max(a,min(b,v))
def clamp(v,a,b): return max(a,min(b,v))
# DSP: p = 70 - 0.5*(eva-acc) + lvl*3 + pct ; clamp 5..95 ; tiers 1/2..1/16 with thresholds (1-p)^n
def dsp_p(acc_minus_eva, pct=0): return clamp(70+0.5*acc_minus_eva+pct,5,95)/100
def dsp_ev(p): # expected multiplier
    q=1-p; t=[q**k for k in (1,2,3,4)]  # P(<=thr)
    # resvar<=q^4:1/16; <=q^3:1/8; <=q^2:1/4; <=q:1/2; else 1
    return (t[3]*0.0625+(t[2]-t[3])*0.125+(t[1]-t[2])*0.25+(t[0]-t[1])*0.5+(1-t[0]))
# LSB: hit = clamp((50+ (acc-eva+25, halved if <0))/100,.05,.95); 3 sequential tiers (PC max 2 if elem eva==0)
def lsb_p(d):
    h=d+25
    if h<0: h//=2
    return clamp((50+h)/100,.05,.95)
def lsb_ev(p,tiers=3):
    ev=0; reach=1
    for i in range(tiers):
        ev+=reach*p*(0.5**i); reach*=(1-p)
    return ev+reach*0.5**tiers
for v in (0,20,40,60,80,100,120): print(v, round(100*dsp_p(0,-v)), round(100*dsp_p(40,-v)))
for e in (0,50,100,150): print("elemRES",e, round(dsp_ev(dsp_p(-e)),3), "lsb",round(lsb_ev(lsb_p(-e)),3))
print("gap  DSPp  DSPev  LSBp  LSBev3 LSBev2")
for d in (-200,-150,-100,-75,-50,-25,0,25,50,100):
    print(d, round(dsp_p(d),2), round(dsp_ev(dsp_p(d)),3), round(lsb_p(d),2), round(lsb_ev(lsb_p(d),3),3), round(lsb_ev(lsb_p(d),2),3))
