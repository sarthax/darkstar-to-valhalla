from rekey_plan import *
for z in (101,104):
    dd,cc,mv=plan(z)
    moved={di for di,_,_,_ in mv}
    existing={i:n for i,n in dd}
    tgt={}
    for di,ci,dn,cn in mv: tgt.setdefault(ci,[]).append(dn)
    print(z,'dup targets',[k&0xFFF for k,v in tgt.items() if len(v)>1])
    # collisions: target occupied by an unmoved row
    for di,ci,dn,cn in mv:
        if ci in existing and ci not in moved:
            print('  collide',di&0xFFF,dn,'->',ci&0xFFF,'occupied by',existing[ci])
    # unmatched DSP rows in range not moved and not equal-id match to client
    cl=dict(cc)
    for i,n in dd:
        if i not in moved and norm(cl.get(i,''))!=norm(n):
            print('  unmatched',i&0xFFF,n,'| client has',cl.get(i))
