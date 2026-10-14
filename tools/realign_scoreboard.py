#!/usr/bin/env python3
"""Realign scoreboard: live npc_list / mob_spawn_points vs client DAT (names) and LSB (position, look).

Run:  py -3 tools/realign_scoreboard.py
Writes docs/slices/npc-id-realign/SCOREBOARD.md (+ history), and worklist CSVs in
docs/slices/npc-id-realign/worklists/. Re-run after each fix batch to refresh.

Rules baked in: rows at 0,0,0 are NOT assessed (placed dynamically by CS/battlefield/condition).
Blank-named rows are props, never worklist items. Positions compared by zone+name, tolerance 2 units.
"""
import re, glob, csv, json, os, sys, datetime, collections as C
import yaml, mysql.connector as m

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'docs', 'slices', 'npc-id-realign')
DAT_GLOB = os.environ.get('DAT_GLOB', 'D:/Claude/scratchpad/cz_pull*/**/entities.yml')
LSB = os.environ.get('LSB_SQL', 'D:/Claude/landsandboat-reference/sql/')
TOL = 2.0
N = lambda s: re.sub(r'[^a-z0-9]', '', str(s or '').lower())
zone = lambda i: (i >> 12) & 0xfff

def conf():
    d = {}
    for ln in open(os.environ.get('DSP_CONF', 'D:/Claude/dsp-branches/conf/map_darkstar.conf'), encoding='utf8', errors='replace'):
        mo = re.match(r'\s*(mysql_\w+):\s*(\S+)', ln)
        if mo: d[mo.group(1)] = mo.group(2)
    return d

dat = {}
for f in glob.glob(DAT_GLOB, recursive=True):
    for e in yaml.safe_load(open(f))['names']: dat[e['id']] = e['name']
dat_zones = {zone(i) for i in dat}

tok = re.compile(r"'(?:[^']|'')*'|[^,]+")
def rows(name):
    p = LSB + name + '.sql'; pre = 'INSERT INTO `%s` VALUES (' % name
    for ln in open(p, encoding='utf8', errors='replace'):
        if ln.startswith(pre):
            yield [t.strip() for t in tok.findall(ln[ln.index('(') + 1:ln.rindex(')')])]
sv = lambda t: t.strip("'")

lnpc = C.defaultdict(list); lmob = C.defaultdict(list)
for r in rows('npc_list'):
    try: x, z = float(r[4]), float(r[6]); i = int(r[0])
    except Exception: continue
    ent = (x, z, r[15].lower().replace('0x', '') if len(r) > 15 else '')
    for k in {N(sv(r[1])), N(sv(r[2]))}:
        if k: lnpc[(zone(i), k)].append(ent)
for r in rows('mob_spawn_points'):
    try: x, z = float(r[7]), float(r[9]); i = int(r[0])
    except Exception: continue
    for k in {N(sv(r[2])), N(sv(r[3]))}:
        if k: lmob[(zone(i), k)].append((x, z, ''))

cf = conf()
db = m.connect(host='127.0.0.1', user=cf['mysql_login'], password=cf['mysql_password'], database=os.environ.get('DSP_DB', cf.get('mysql_database', 'dspdb_fresh')))
q = db.cursor()
def fetch(sql): q.execute(sql); return q.fetchall()
npcs = fetch('select npcid,name,polutils_name,pos_x,pos_z,hex(look) from npc_list')
mobs = fetch("select mobid,mobname,polutils_name,pos_x,pos_z,'' from mob_spawn_points")
have = {r[0] for r in npcs} | {r[0] for r in mobs}

def dist(ref, x, z): return min(max(abs(a - x), abs(b - z)) for a, b, _ in ref)

res = {}; work = {'name_mismatch': [], 'position_diff': [], 'look_diff': []}
for kind, R, L in (('npc', npcs, lnpc), ('mob', mobs, lmob)):
    c = C.Counter()
    for i, n, pn, x, z, lk in R:
        nm, pm = N(n), N(pn); z_ = zone(i)
        c['rows'] += 1
        if not (nm or pm): c['blank (props, not assessed)'] += 1; continue
        if z_ not in dat_zones or i not in dat: c['no DAT entity at id (not assessed)'] += 1
        elif N(dat[i]) in (nm, pm): c['name = DAT'] += 1
        else:
            c['name differs from DAT'] += 1
            work['name_mismatch'].append((kind, i, z_, i & 0xfff, n, pn, dat[i]))
        if x == 0 and z == 0: c['at 0,0,0 (not assessed)'] += 1; continue
        ref = L.get((z_, pm)) or L.get((z_, nm))
        if not ref: c['no LSB same-name row'] += 1; continue
        d = dist(ref, x, z)
        if d <= TOL: c['position = LSB'] += 1
        else:
            c['position differs from LSB'] += 1
            work['position_diff'].append((kind, i, z_, n, pn, x, z, round(d, 1)))
        if kind == 'npc' and lk:
            if any(e[2] == lk.lower() for e in ref): c['look = LSB'] += 1
            else:
                c['look differs from LSB'] += 1
                work['look_diff'].append((kind, i, z_, n, pn, lk.lower()))
    res[kind] = c
res['dat_unbuilt'] = sum(1 for i, d in dat.items() if (i & 0xfff) < 1024 and N(d) and i not in have)

os.makedirs(os.path.join(OUT, 'worklists'), exist_ok=True)
hdr = {'name_mismatch': 'kind,id,zone,slot,live_name,live_polutils,dat_name',
       'position_diff': 'kind,id,zone,name,polutils,pos_x,pos_z,max_axis_distance_to_nearest_LSB',
       'look_diff': 'kind,id,zone,name,polutils,live_look'}
for k, v in work.items():
    with open(os.path.join(OUT, 'worklists', k + '.csv'), 'w', newline='', encoding='utf8') as f:
        w = csv.writer(f); w.writerow(hdr[k].split(','))
        w.writerows(sorted(v, key=(lambda r: -r[-1]) if k == 'position_diff' else (lambda r: (r[2], r[1]))))

hp = os.path.join(OUT, 'scoreboard_history.json')
hist = json.load(open(hp)) if os.path.exists(hp) else []
snap = {'date': datetime.datetime.now().strftime('%Y-%m-%d %H:%M'),
        'npc_name_bad': res['npc']['name differs from DAT'], 'mob_name_bad': res['mob']['name differs from DAT'],
        'npc_pos_bad': res['npc']['position differs from LSB'], 'mob_pos_bad': res['mob']['position differs from LSB'],
        'npc_look_bad': res['npc']['look differs from LSB']}
hist.append(snap); json.dump(hist, open(hp, 'w'), indent=1)

keys = ['rows', 'name = DAT', 'name differs from DAT', 'position = LSB', 'position differs from LSB',
        'look = LSB', 'look differs from LSB', 'no LSB same-name row', 'no DAT entity at id (not assessed)',
        'at 0,0,0 (not assessed)', 'blank (props, not assessed)']
md = ['# Realign scoreboard', '', 'Generated by `tools/realign_scoreboard.py` (re-run to refresh). Live DB vs client DAT (names) and LSB (position/look, matched by zone+name, tolerance %s units).' % TOL, '',
      'Not assessed by design: rows at 0,0,0 (placed dynamically by CS/battlefield/condition), blank-named props, DAT entities with no row (unbuilt content, deferred).', '',
      '| Check | NPC | Mob |', '|---|---:|---:|']
for k in keys: md.append('| %s | %d | %d |' % (k, res['npc'][k], res['mob'][k]))
md += ['', 'DAT named entities with no row in either table (unbuilt, deferred): **%d**' % res['dat_unbuilt'], '',
       '## Worklists (genuine issues, `worklists/`)', '',
       '- `name_mismatch.csv` - row name differs from the DAT slot (check for SE renames first: position+look match LSB but name differs)',
       '- `position_diff.csv` - named, non-zero rows far from every same-name LSB row, largest first (mobs often have several spawn points; verify before editing)',
       '- `look_diff.csv` - NPC model differs from every same-name LSB row', '',
       '## History', '', '| Date | NPC name bad | Mob name bad | NPC pos bad | Mob pos bad | NPC look bad |', '|---|---:|---:|---:|---:|---:|']
for s_ in hist[-30:]: md.append('| %s | %d | %d | %d | %d | %d |' % (s_['date'], s_['npc_name_bad'], s_['mob_name_bad'], s_['npc_pos_bad'], s_['mob_pos_bad'], s_['npc_look_bad']))
open(os.path.join(OUT, 'SCOREBOARD.md'), 'w', encoding='utf8').write(chr(10).join(md) + chr(10))
print(chr(10).join(md))
