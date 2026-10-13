"""Mob id vs client DAT check. Usage: py -3 tools/check_mob_ids.py host user pw db <pull_dir> [<pull_dir2> ...]
pull_dir = folder tree of mission_toolkit pulls containing entities.yml (use --out-dir <dir>/<zoneid> per zone).
Reports mob_spawn_points whose slot is named differently in the client DAT, and mobs sitting on NPC slots.
Ignore: zones with dynamic names (Promyvion 16-21, Dynamis 134/135, Abyssea, Salvage) and ids past the DAT table."""
import sys, re, glob, yaml, collections, mysql.connector as m
h, u, p, d = sys.argv[1:5]
c = m.connect(host=h, user=u, password=p, database=d); q = c.cursor()
N = lambda s: re.sub(r'[^a-z0-9]', '', str(s).lower())
dat = {}
for pd in sys.argv[5:]:
    for f in glob.glob(pd + '/**/entities.yml', recursive=True):
        for e in yaml.safe_load(open(f))['names']: dat[e['id']] = e['name']
zones = {(i >> 12) & 0xfff for i in dat}
q.execute("select mobid,mobname,polutils_name from mob_spawn_points")
bad = [(i, mn, dat.get(i)) for i, mn, pn in q.fetchall()
       if (i >> 12) & 0xfff in zones and dat.get(i) is not None and N(dat[i]) not in (N(mn), N(pn))]
print(len(bad), "mob rows named differently in the client DAT")
cnt=collections.Counter((b[0]>>12)&0xfff for b in bad)
for b in bad:
    if (b[0]>>12)&0xfff in (168,139,146,129,165,163,152,148): print("  ",b[0],(b[0]>>12)&0xfff,b[0]-0x1000000-(((b[0]>>12)&0xfff)<<12),b[1],"|dat:",b[2])
print(sorted(cnt.items(), key=lambda x:-x[1]))
