import re,json,math
exec(open('npc.py').read().split("print(len(L),len(D))")[0])
hp=json.load(open('hp.json'))
zn={}
for m in re.finditer(r"VALUES \((\d+),\d+,'[^']*',\d+,'([^']*)'",open(LSB+'/sql/zone_settings.sql').read()): zn[m[2]]=int(m[1])
for who,rs,T in(('DSP',D,hp['D']),('LSB',L,hp['L'])):
    print('==',who)
    for key,v in sorted(hp['LN'].items(),key=lambda kv:kv[1]['idx']):
        zf,n=key.split('|');z=zn[zf];t=T[str(v['idx'])]
        c=[r for r in rs if r['zone']==z and r['name']==n and not r['nc'] and (r['x'],r['y'],r['z'])!=(0,0,0)]
        if not c: continue
        r=c[0];dd=math.hypot(r['x']-t['x'],r['z']-t['z']);dy=abs(r['y']-t['y'])
        if dd>8 or dy>6: print(f"idx{v['idx']} {zf}/{n}: npc({r['x']:g},{r['y']:g},{r['z']:g}) dest({t['x']:g},{t['y']:g},{t['z']:g}) d={dd:.1f} dy={dy:.1f} zoneT={t['zone']} zone={z}")
        if t['zone']!=z: print('ZONE MISMATCH',v['idx'],zf,t['zone'],z)
