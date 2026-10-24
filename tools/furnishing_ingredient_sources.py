#!/usr/bin/env python3
"""Cross-reference non-ok recipe ingredients (script/missing) against Lua mentions and the BG Wiki page.
Usage: py -3 tools/furnishing_ingredient_sources.py"""
import csv, gzip, json, os, re, sys
sys.path.insert(0, 'D:/Claude/mission_toolkit/src')
import mysql.connector
from workbench.server_admin.synth import recipes as R
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = ROOT + '/docs/furnishings'
c = open(ROOT + '/conf/map_darkstar.conf').read(); g = lambda k: re.search(k + r':\s*(\S+)', c).group(1)
db = mysql.connector.connect(host=g('mysql_host'), port=int(g('mysql_port')), user=g('mysql_login'), password=g('mysql_password'), database=g('mysql_database'))
av = R.Availability(db, ROOT)
rows = [r for r in csv.DictReader(open(OUT + '/furnishing_recipe_ingredients_toolkit.csv', encoding='utf-8')) if r['toolkit_status'] in ('script', 'missing')]
names = {}
for r in rows:
    names.setdefault(r['ingredient'], r)
nk = lambda x: re.sub(r'[^a-z0-9]', '', x.lower())
cu = db.cursor(); cu.execute("select itemid,name from item_basic")
dbname = {i: n for i, n in cu}
want = {}
for n, r in names.items():
    want[nk(n)] = n
    want[nk(dbname.get(int(r['ingredient_id']), n))] = n
wiki = {}
with gzip.open('D:/Claude/FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz', 'rt', encoding='utf-8') as f:
    for line in f:
        p = json.loads(line)
        k = nk(p['title'])
        if k in want and 'CatsEyeXI' not in p.get('categories', []):
            wiki[want[k].lower()] = p['wikitext']

TABLE = re.compile(r'\{\{Item ([A-Za-z ]+?) Table(.*?)(?=\n\{\{Item [A-Za-z ]+ Table|\n==|\Z)', re.S)
FIELD = re.compile(r'\|(Name|Mob|NPC|Seller|Zone|Type|Notes|Item Name)=([^\n|}]+)')
LINK = re.compile(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]')
TPL = re.compile(r'\{\{[^{}]*\}\}')


def wiki_info(n):
    t = wiki.get(n.lower())
    if not t:
        return 'no wiki page', ''
    flags = (re.search(r'\|flags=([^\n]*)', t) or [0, ''])[1]
    parts = []
    for m in TABLE.finditer(t):
        kind = m.group(1)
        if kind in ('Synth', 'Synergy', 'Used In Synth', 'Used In Synergy', 'Other'):
            continue
        vals = [v.strip() for _, v in FIELD.findall(m.group(2)) if v.strip()]
        parts.append(kind + ': ' + ', '.join(dict.fromkeys(vals))[:200])
    for h in ('Obtained', 'Acquisition', 'Notes'):
        m = re.search(r'==\s*' + h + r'[^=]*==(.*?)(?:\n==|\Z)', t, re.S | re.I)
        if m:
            parts.append(h + ': ' + re.sub(r'\s+', ' ', LINK.sub(r'\1', TPL.sub('', m.group(1))))[:200])
    return flags, ' || '.join(parts)


out = []
for n, r in sorted(names.items()):
    iid = int(r['ingredient_id']); d = av.direct(iid)
    sc = '; '.join(f"{s['file']}({s['kind']})" for s in d['scripts'][:4])
    fl, info = wiki_info(n)
    furn = sorted({x['furnishing'] for x in rows if x['ingredient'] == n})
    out.append(dict(ingredient=n, item_id=iid, toolkit_status=r['toolkit_status'], used_by=', '.join(furn)[:200],
                    our_lua_refs=sc, wiki_flags=fl, wiki_obtain=info))
with open(OUT + '/furnishing_ingredient_source_xref.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=list(out[0])); w.writeheader(); w.writerows(out)
for o in out:
    print(o['toolkit_status'], o['ingredient'], o['item_id'], '|', o['our_lua_refs'][:120], '|', o['wiki_obtain'][:230])
