"""Rift/Pyxis/Maw id impact analysis: DSP live npc_list vs same-session client entities.yml pulls.
Usage: python rift_id_impact.py <pulls_dir>   (pulls_dir/z<id>/*/entities.yml from mission_toolkit)"""
import sys,glob,yaml,mysql.connector,csv,collections
P=sys.argv[1]
CN=mysql.connector.connect(host='127.0.0.1',user='root',password='UF6uthty',database='dspdb_fresh');M=CN.cursor()
def kind(n):
    n=n.replace('_',' ').lower()
    return 'Rift' if n.startswith('planar rift') else 'Pyxis' if n.startswith('riftworn pyxis') else 'Maw' if n.startswith('cavernous maw') else None
M.execute("select npcid,name from npc_list"); dsp=collections.defaultdict(list)
for i,n in M.fetchall(): dsp[(i>>12)&0xFFF].append((i,n))
zones=sorted(z for z,l in dsp.items() if any(kind(n) for i,n in l))
out=[];tails=[]
for z in zones:
    fs=glob.glob(f'{P}/z{z}/*/entities.yml')
    if not fs: out.append((z,'NO_PULL','','','','',''));continue
    d=yaml.safe_load(open(fs[0],encoding='utf-8')); L=d if isinstance(d,list) else next(v for v in d.values() if isinstance(v,list))
    cl={e['id']:(e.get('name') or '') for e in L}
    cols={};offs=set();notes=[]
    for k in('Rift','Pyxis','Maw'):
        d_=sorted(i for i,n in dsp[z] if kind(n)==k); c_=sorted(i for i,n in cl.items() if kind(n)==k)
        cols[k]=f"{[i&0xFFF for i in d_]}->{[i&0xFFF for i in c_]}"
        if d_ and not c_: notes.append(f'{k}_absent_in_client')
        elif len(d_)==len(c_): offs.update(c-d for d,c in zip(d_,c_))
        elif d_: notes.append(f'{k}_count {len(d_)}v{len(c_)}')
    if notes and not offs: st=';'.join(notes)
    elif offs=={0}: st='MATCH'
    elif len(offs)==1: st='SHIFT'
    else: st='SHIFT_MIXED'
    if notes and offs: st+=' ('+';'.join(notes)+')'
    off=next(iter(offs)) if len(offs)==1 else None
    tl=''
    if off:
        first=min(i for i,n in dsp[z] if kind(n))
        tail=[(i,n) for i,n in dsp[z] if i>=first]
        ag=sum(1 for i,n in tail if cl.get(i+off,'').replace(' ','_').lower()==n.lower())
        tl=f'{ag}/{len(tail)} tail rows agree at {off:+d}'
    out.append((z,st,sorted(offs),cols['Rift'],cols['Pyxis'],cols['Maw'],tl))
w=csv.writer(open(P+'/../rift_id_impact.csv','w',newline=''));w.writerow(['zone','status','offsets','rift','pyxis','maw','tail']);w.writerows(out)
for r in out: print(*r,sep=' | ')
print(collections.Counter(r[1].split(' ')[0] for r in out))
