import json,re,csv,collections
vw=json.load(open(r"C:/Users/Kevin/AppData/Local/Temp/claude/D--Claude/bf255238-11ec-43d4-8e92-43aa5ef1393a/scratchpad/vw.json"))
nms=[r for r in vw if 'Notorious Monster' in r['categories'] or ('Bestiary' in r['categories'] and 'Voidwatch' in r['categories'])]
def norm(s): return re.sub(r'[^a-z0-9]','_',s.lower()).strip('_')
def load(p): return open(p,encoding='utf-8',errors='ignore').read().splitlines()
R={'lsb':'D:/Claude/landsandboat-reference/sql/','dsp':'D:/Claude/dsp-master/sql/'}
data={}
for k,b in R.items():
    pools=load(b+'mob_pools.sql'); groups=load(b+'mob_groups.sql') ; 
    sp=load(b+'mob_spawn_points.sql')
    data[k]=(pools,groups,sp)
def pools_for(k,name):
    n=norm(name); out=[]
    for l in data[k][0]:
        m=re.match(r"INSERT INTO `mob_pools` VALUES \((\d+),'([^']*)'",l)
        if m and norm(m.group(2))==n: out.append(int(m.group(1)))
    return out
def groups_for(k,pids):
    out=[]
    for l in data[k][1]:
        m=re.match(r"INSERT INTO `mob_groups` VALUES \((\d+),(\d+),(\d+),'([^']*)'",l)
        if m and int(m.group(2)) in pids: out.append((int(m.group(3)),int(m.group(1))))
    return out
def sp_for(k,name):
    n=norm(name); c=0; z=set()
    for l in data[k][2]:
        m=re.match(r"INSERT INTO `mob_spawn_points` VALUES \((\d+),\d+,'([^']*)'",l)
        if m and norm(m.group(2))==n: c+=1; z.add((int(m.group(1))-0x1000000)>>12)
    return c,sorted(z)
rows=[]
for r in sorted(nms,key=lambda r:r['title']):
    t=r['title']; w=r['wikitext']
    zone=re.findall(r'\|Zone=\s*([^\n|]+)',w); tier=re.findall(r'\|VW Tier=\s*(\w*)',w); path=re.findall(r'\|VW Path=\s*(\w*)',w)
    ki=re.findall(r'\{\{KI\}\}\s*\[\[([^\]]+)\]\]',w)
    row={'wiki':t,'zone':'/'.join(dict.fromkeys(z.strip() for z in zone)),'path':'/'.join(dict.fromkeys(path)),'tier':'/'.join(dict.fromkeys(tier)),'wiki_chars':len(w)}
    for k in ('lsb','dsp'):
        p=pools_for(k,t); g=groups_for(k,p); s=sp_for(k,t)
        row[k+'_pool']=','.join(map(str,p)); row[k+'_groups']=len(g); row[k+'_spawn']=s[0]; row[k+'_zones']=','.join(map(str,sorted({z for z,_ in g})))
    rows.append(row)
out="D:/Claude/docs/voidwatch/research/vwnm_inventory.csv"
import os; os.makedirs(os.path.dirname(out),exist_ok=True)
with open(out,'w',newline='',encoding='utf-8') as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
print(len(rows))
for r in rows: print(r['wiki'][:22].ljust(22),r['zone'][:20].ljust(20),r['path'][:7].ljust(7),r['tier'][:4].ljust(4),'LSB',r['lsb_pool'][:5].ljust(5),r['lsb_groups'],r['lsb_spawn'],'| DSP',r['dsp_pool'][:5].ljust(5),r['dsp_groups'],r['dsp_spawn'])
print('LSB pool',sum(1 for r in rows if r['lsb_pool']),'grp',sum(1 for r in rows if r['lsb_groups']),'sp',sum(1 for r in rows if r['lsb_spawn']))
print('DSP pool',sum(1 for r in rows if r['dsp_pool']),'grp',sum(1 for r in rows if r['dsp_groups']),'sp',sum(1 for r in rows if r['dsp_spawn']))
