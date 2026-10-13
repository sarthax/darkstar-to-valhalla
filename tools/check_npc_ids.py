"""Post-import consistency check. Usage: py -3 tools/check_npc_ids.py host user pw db
Reports: (1) npc_list.sql vs live DB differences, (2) treasure_spawn_points ids missing from npc_list,
(3) UpdateTreasureSpawnPoint()/hard-coded zone npc ids in scripts that are missing from npc_list,
(4) mob/npc id collisions, (5) mobs at 0,0,0. Exit code 1 if anything is wrong."""
import re, sys, os, mysql.connector as m
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
h, u, p, d = sys.argv[1:5]
_c = m.connect(host=h, user=u, password=p, database=d); q = _c.cursor()
bad = 0
def rep(t, rows, info=False):
    global bad
    print("%-52s %d" % (t, len(rows)))
    for r in rows[:15]: print("   ", r)
    bad += bool(rows) and not info
q.execute("select npcid,name from npc_list"); live = dict(q.fetchall())
fl = {}
for l in open(os.path.join(root, "sql", "npc_list.sql"), encoding="utf8", errors="replace"):
    r = re.match(r"INSERT INTO `npc_list` VALUES \((\d+),'([^']*)'", l)
    if r: fl[int(r[1])] = r[2].strip()
rep("npc_list.sql rows missing from live DB", sorted(set(fl) - set(live)))
rep("live rows missing from npc_list.sql (live-only!)", sorted(set(live) - set(fl)))
rep("name differs file vs live", [(i, fl[i], live[i]) for i in live if i in fl and fl[i] != live[i].strip()])
q.execute("select npcid from treasure_spawn_points where npcid not in (select npcid from npc_list)")
rep("treasure_spawn_points orphans", q.fetchall())
q.execute("select mobid,mobname from mob_spawn_points where mobid in (select npcid from npc_list)")
rep("[info] mob_spawn_points id collides with npc_list", q.fetchall(), True)
q.execute("select mobid,mobname from mob_spawn_points where pos_x=0 and pos_y=0 and pos_z=0")
rep("[info] mob_spawn_points at 0,0,0 (base zones; instances never load these)", q.fetchall(), True)
miss = []
for dp, _, fs in os.walk(os.path.join(root, "scripts")):
    for f in fs:
        if not f.endswith(".lua"): continue
        t = open(os.path.join(dp, f), encoding="utf8", errors="replace").read()
        for i in re.findall(r"UpdateTreasureSpawnPoint\((\d+)\)|GetNPCByID\((\d{8})\)", t):
            i = int(i[0] or i[1])
            if i not in live: miss.append((os.path.relpath(os.path.join(dp, f), root), i))
rep("script npc ids not in npc_list", miss)
sys.exit(1 if bad else 0)
