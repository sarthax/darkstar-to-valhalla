import re,json,collections,sys
sys.argv=['x']
exec(open('npc.py').read().split("print(len(L),len(D))")[0])
hp=json.load(open('hp.json'))
zn={}
for m in re.finditer(r"VALUES \((\d+),\d+,'[^']*',\d+,'([^']*)'",open(LSB+'/sql/zone_settings.sql').read()): zn[m[2]]=int(m[1])
zn_inv={v:k for k,v in zn.items()}
def live(rs,zone,name):
    return [r for r in rs if r['zone']==zone and r['name']==name and not r['nc'] and (r['x'],r['y'],r['z'])!=(0,0,0)]
print('script | table dest | LSB npc_list | DSP npc_list')
for key in sorted(hp['LN']):
    zf,n=key.split('|'); zid=zn.get(zf)
    if zid is None: print('?zone',zf); continue
    idx=hp['LN'][key]['idx']
    T=hp['L'][str(idx)]
    l=live(L,zid,n); d=live(D,zid,n)
    def f(rs): return ' / '.join(f"{r['id']}({r['x']:g},{r['y']:g},{r['z']:g}) r{r['rot']}" for r in rs) or 'NONE'
    flag=''
    if not d: flag+=' DSP-MISSING'
    if not l: flag+=' LSB-MISSING'
    if len(d)>1: flag+=' DSP-DUP'
    if l and d and (l[0]['x'],l[0]['y'],l[0]['z'],l[0]['rot'])!=(d[0]['x'],d[0]['y'],d[0]['z'],d[0]['rot']): flag+=' POSDIFF'
    if flag: print(f"{zf}/{n} idx{idx} tbl({T['x']:g},{T['y']:g},{T['z']:g}) |LSB {f(l)} |DSP {f(d)} |{flag}")
