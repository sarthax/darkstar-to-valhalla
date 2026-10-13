import re,glob,os,sys,json
LSB='D:/Claude/landsandboat-reference'; DSP='D:/Claude/dsp-branches'
# zone ids from LSB zone enum
zid={}
for m in re.finditer(r"INSERT INTO `zone_settings` VALUES \((\d+),\d+,'[^']*',\d+,'([^']*)'",open(LSB+'/sql/zone_settings.sql',encoding='utf8').read()):
    zid[re.sub(r'[^A-Z0-9]+','_',m[2].upper()).strip('_')]=int(m[1])
zid['ABYSSEA_ULEGUERAND']=253
def lsb_table():
    t={}
    for m in re.finditer(r'\[\s*(\d+)\]\s*=\s*\{\s*group\s*=\s*(\d+),\s*fee\s*=\s*(\d+),\s*dest\s*=\s*\{\s*([-\d.]+),\s*([-\d.]+),\s*([-\d.]+),\s*([-\d.]+),\s*xi\.zone\.([A-Z0-9_]+)\s*\}\s*\},?\s*--\s*(.*)',open(LSB+'/scripts/globals/homepoint.lua',encoding='utf8').read()):
        i=int(m[1]); t[i]=dict(group=int(m[2]),fee=int(m[3]),x=float(m[4]),y=float(m[5]),z=float(m[6]),rot=int(float(m[7])),zone=zid.get(m[8],m[8]),name=m[9].strip())
    return t
def dsp_table():
    t={}
    for m in re.finditer(r'^homepoints\[(\d+)\]\s*=\s*\{\s*(\d+),\s*(\d+),\s*([-\d.]+),\s*([-\d.]+),\s*([-\d.]+),\s*([-\d.]+),\s*(\d+),\s*(\d+)\};\s*--\s*(.*)',open(DSP+'/scripts/globals/homepoint.lua',encoding='utf8').read(),re.M):
        t[int(m[1])]=dict(pn=int(m[2]),bit=int(m[3]),x=float(m[4]),y=float(m[5]),z=float(m[6]),rot=int(float(m[7])),zone=int(m[8]),cost=int(m[9]),name=m[10].strip())
    return t
L=lsb_table();D=dsp_table()
print('LSB',len(L),'DSP',len(D))
def npcs(root,lsb):
    r={}
    for p in glob.glob(root+'/scripts/zones/*/npcs/HomePoint*.lua'):
        s=open(p,encoding='utf8',errors='ignore').read()
        zone=p.replace(chr(92),'/').split('/zones/')[1].split('/')[0]
        n=os.path.basename(p)[:-4]
        if lsb:
            m=re.search(r'hpIndex\s*=\s*(\d+)',s); e=re.search(r'hpEvent\s*=\s*(\d+)',s)
            idx=int(m[1]) if m else None; ev=int(e[1]) if e else None
        else:
            m=re.search(r'homepointMenu\(\s*player\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*,\s*(\d+)',s)
            idx=int(m[2]) if m else None; ev=int(m[1],0) if m else None
        r[(zone,n)]=dict(idx=idx,ev=ev,file=p)
    return r
LN=npcs(LSB,True);DN=npcs(DSP,False)
json.dump(dict(L=L,D=D,LN={f'{k[0]}|{k[1]}':v for k,v in LN.items()},DN={f'{k[0]}|{k[1]}':v for k,v in DN.items()}),open('hp.json','w'))
# table diffs
print('\n== table diffs (idx) ==')
for i in sorted(set(L)|set(D)):
    l=L.get(i);d=D.get(i)
    if not l or not d: print(i,'missing in',('LSB' if not l else 'DSP'));continue
    diffs=[]
    for k in('x','y','z','rot','zone'):
        if abs(l[k]-d[k])>1e-6: diffs.append(f'{k}: DSP {d[k]} vs LSB {l[k]}')
    if diffs: print(i,l['name'],'|',d['name'],'|','; '.join(diffs))
print('\n== npc scripts: zone/file/idx/event diffs ==')
for k in sorted(set(LN)|set(DN)):
    l=LN.get(k);d=DN.get(k)
    if not l or not d: print(k,'only in',('DSP' if not l else 'LSB'), (l or d)['idx']);continue
    if l['idx']!=d['idx'] or l['ev']!=d['ev']: print(k,'LSB',l['idx'],l['ev'],'DSP',d['idx'],d['ev'])
# idx coverage
print('\n== table idx with no NPC ==')
for nm,N,T in(('LSB',LN,L),('DSP',DN,D)):
    used={}
    for k,v in N.items(): used.setdefault(v['idx'],[]).append(k)
    print(nm,'missing:',[ (i,T[i]['name']) for i in sorted(T) if i not in used])
    print(nm,'dup:',{i:v for i,v in used.items() if len(v)>1})
