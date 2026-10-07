import re,sys
from rekey_plan import *
Z101=plan(101)[2]
# 104: Voidwatch cluster only (uniform -9 block, DSP 744..756 -> client 735..747); rest deferred
Z104=[(di,di-9,dn,cn) for di,ci,dn,cn in plan(104)[2] if 744<=(di&0xFFF)<=756]
M.execute("select npcid,name from npc_list where (npcid>>12)&0xFFF=104 and (npcid&0xFFF) in (744,745,746,747,748,749,750,751,752,753,754,755,756)")
rows={i:n for i,n in M.fetchall()}
Z104=[(i,i-9,n,'') for i,n in sorted(rows.items()) if n!='blank']
plans={101:[(a,b,c) for a,b,c,_ in Z101],104:[(a,b,c) for a,b,c,_ in Z104]}
out=[];log=[]
for z,mv in plans.items():
    src={a for a,_,_ in mv}
    M.execute("select npcid,name from npc_list where (npcid>>12)&0xFFF=%s",(z,)); ex=dict(M.fetchall())
    dele=[b for a,b,_ in mv if b in ex and b not in src]
    for b in dele:
        assert ex[b]=='blank' or ex[b]=='Geomantic_Reservoir',(b,ex[b])
        out.append(f"DELETE FROM npc_list WHERE npcid={b} AND name='{ex[b]}';"); log.append((z,'DELETED placeholder',b,ex[b],''))
    desc = 1 if all(b>a for a,b,_ in mv) else 0
    for a,b,n in sorted(mv,reverse=bool(desc)):
        out.append(f"UPDATE npc_list SET npcid={b} WHERE npcid={a} AND name='{n}';"); log.append((z,'MOVED',a,n,b))
open('../../../sql/slices/voidwatch-vwnm/rekey_101_104.sql','w').write('-- Voidwatch re-key of zones 101/104 to client ids (see docs/voidwatch/research/REKEY-CHANGELOG.md)\n'+'\n'.join(out)+'\n')
import pickle;pickle.dump(log,open('rekey_log.pkl','wb'))
print(len(out))
