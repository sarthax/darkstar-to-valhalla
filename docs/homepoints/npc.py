import re,json,collections
LSB='D:/Claude/landsandboat-reference';DSP='D:/Claude/dsp-branches'
def rows(path):
    out=[]
    for ln in open(path,encoding='utf8',errors='ignore'):
        nc=ln.startswith('-- NC')
        m=re.search(r"INSERT INTO `npc_list` VALUES \((\d+),'([^']*)','([^']*)',(-?\d+),(-?[\d.]+),(-?[\d.]+),(-?[\d.]+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(0x[0-9a-fA-F]+),(\d+),(NULL|'[^']*'),(\d+)\)",ln)
        if not m: continue
        if 'ome' not in m[3] and 'ome' not in m[2]: continue
        if 'Home Point' not in m[3] and 'HomePoint' not in m[2]: continue
        out.append(dict(id=int(m[1]),zone=(int(m[1])>>12)&0xFFF,name=m[2],pol=m[3],rot=int(m[4]),x=float(m[5]),y=float(m[6]),z=float(m[7]),flags=m[15],look=m[16],nc=nc,line=ln.strip()[:200]))
    return out
L=rows(LSB+'/sql/npc_list.sql');D=rows(DSP+'/sql/npc_list.sql')
print(len(L),len(D))
Ld={r['id']:r for r in L};Dd={r['id']:r for r in D}
zn={}
for m in re.finditer(r"VALUES \((\d+),\d+,'[^']*',\d+,'([^']*)'",open(LSB+'/sql/zone_settings.sql').read()): zn[int(m[1])]=m[2]
print('LSB-only ids:')
for i in sorted(set(Ld)-set(Dd)): r=Ld[i];print(' ',i,zn.get(r['zone']),r['name'],r['x'],r['y'],r['z'],'rot',r['rot'])
print('DSP-only ids:')
for i in sorted(set(Dd)-set(Ld)): r=Dd[i];print(' ',i,zn.get(r['zone']),r['name'],r['x'],r['y'],r['z'],'NC' if r['nc'] else '')
print('both, differing:')
for i in sorted(set(Ld)&set(Dd)):
    a,b=Ld[i],Dd[i]
    d=[f'{k}: DSP {b[k]} LSB {a[k]}' for k in('name','rot','x','y','z','flags','look') if a[k]!=b[k]]
    if b['nc']: d.append('DSP NC(commented)')
    if d: print(' ',i,zn.get(a['zone']),a['name'],'|',';'.join(d))
