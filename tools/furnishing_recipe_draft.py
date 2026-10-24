#!/usr/bin/env python3
"""Draft synth_recipes INSERTs for furnishings the toolkit check found unobtainable but whose wiki recipe
has every ingredient already available. REVIEW ONLY: wiki is reference, output is a proposal.
Usage: py -3 tools/furnishing_recipe_draft.py [--out docs/furnishings]"""
import csv, gzip, json, os, re, sys, argparse
import mysql.connector
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI = 'D:/Claude/FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz'
CRAFT = {'alchemy': 'Alchemy', 'bonecraft': 'Bone', 'clothcraft': 'Cloth', 'cooking': 'Cook', 'goldsmithing': 'Gold',
         'leathercraft': 'Leather', 'smithing': 'Smith', 'woodworking': 'Wood'}
CRYSTAL = {'fire': 4096, 'ice': 4097, 'wind': 4098, 'earth': 4099, 'lightning': 4100, 'thunder': 4100, 'water': 4101, 'light': 4102, 'dark': 4103}
nk = lambda x: re.sub(r'[^a-z0-9]', '', x.lower())
CONT = re.compile(r'^(?:[a-z]+_)+?of_')


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--out', default=ROOT + '/docs/furnishings'); a = ap.parse_args()
    c = open(ROOT + '/conf/map_darkstar.conf').read(); g = lambda k: re.search(k + r':\s*(\S+)', c).group(1)
    db = mysql.connector.connect(host=g('mysql_host'), port=int(g('mysql_port')), user=g('mysql_login'), password=g('mysql_password'), database=g('mysql_database'))
    cu = db.cursor()
    cu.execute("select itemid,name,sortname from item_basic")
    byname, idname = {}, {}
    for i, n, sn in cu:
        idname[i] = n; byname.setdefault(nk(sn or n), i); byname.setdefault(nk(n), i); byname.setdefault(nk(CONT.sub('', n, count=1)), i)
    targets = {int(r['itemid']): r for r in csv.DictReader(open(a.out + '/furnishing_toolkit_check.csv', encoding='utf-8'))
               if r['toolkit_status'] != 'ok' and r['wiki_recipe_verdict'] == 'craftable'}
    pages = {}
    with gzip.open(WIKI, 'rt', encoding='utf-8') as f:
        for line in f:
            p = json.loads(line); m = re.search(r'\|ffxidb=(\d+)', p['wikitext'])
            if m and int(m.group(1)) in targets and 'Furnishing' in p.get('categories', []):
                pages[int(m.group(1))] = p
    sql, rep = [], []
    for iid, t in sorted(targets.items()):
        wt = pages[iid]['wikitext']; name = t['name']
        blocks = re.findall(r'\{\{Item Synth\s*\n(.*?)\n\}\}', wt, re.S | re.I)
        for b in blocks:
            gv = lambda k: (re.search(r'\|' + k + r'=([^\n]*)', b) or [0, ''])[1].strip()
            issues = []
            craft = gv('Craft Name').lower(); lvl = gv('Craft Level')
            if craft not in CRAFT or not lvl.isdigit(): rep.append((iid, name, 'SKIP: craft/level unparsed', craft, lvl)); continue
            if gv('Key Item'): issues.append('KeyItem needed: ' + gv('Key Item'))
            sk = {v: 0 for v in CRAFT.values()}; sk[CRAFT[craft]] = int(lvl)
            for sc, sl in re.findall(r'\[\[([A-Za-z]+)\]\]\s*-\s*\((\d+)\)', gv('Sub Craft')):
                if sc.lower() in CRAFT: sk[CRAFT[sc.lower()]] = int(sl)
            cry = CRYSTAL.get(gv('Crystal').lower())
            ings = []
            m = re.search(r'\|Recipe=\s*(.*?)\n\|(?:NQ|HQ)', b, re.S)
            for l in (m.group(1).splitlines() if m else []):
                mm = re.match(r'\*\s*\[\[([^\]|]+)(?:\|[^\]]*)?\]\](?:\s*x\s*(\d+))?', l.strip())
                if mm:
                    ii = byname.get(nk(mm.group(1)))
                    if not ii: issues.append('unresolved ' + mm.group(1))
                    ings += [ii or 0] * int(mm.group(2) or 1)
            if cry is None or not ings or len(ings) > 8: issues.append(f'crystal={cry} ingredients={len(ings)}')
            hq = []
            for k in ('HQ', 'HQ1', 'HQ2', 'HQ3'):
                pass
            if issues:
                rep.append((iid, name, 'SKIP: ' + '; '.join(issues), craft, lvl)); continue
            ings = sorted(ings) + [0] * (8 - len(ings))
            row = [0, 1, 0, sk['Alchemy'], sk['Bone'], sk['Cloth'], sk['Cook'], sk['Gold'], sk['Leather'], sk['Smith'], sk['Wood'],
                   cry, cry + 142] + ings + [iid, iid, iid, iid, 1, 1, 1, 1]
            sql.append((iid, name, row)); rep.append((iid, name, 'DRAFT', craft, lvl))
    # next free ids from the slice range handled by caller; ID left to AUTO_INCREMENT via NULL
    with open(a.out + '/furnishing_synth_recipes_DRAFT.sql', 'w', encoding='utf-8') as f:
        f.write('-- DRAFT synth_recipes for furnishings. Source: BG Wiki (reference only). NOT imported. Review crystal HQ id, HQ results, skill levels.\n')
        f.write('-- ID is NULL (AUTO_INCREMENT). All HQ results default to the NQ item (wiki lists no distinct HQ).\n')
        for iid, name, row in sql:
            vals = ','.join('NULL' if i == 0 else str(v) for i, v in enumerate(row))
            ing_names = ', '.join(idname.get(v, '?') for v in row[13:21] if v)
            f.write(f"INSERT INTO `synth_recipes` VALUES ({vals}); -- {name} ({iid}): {ing_names}\n")
    with open(a.out + '/furnishing_synth_recipes_DRAFT_report.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f); w.writerow(['itemid', 'name', 'result', 'craft', 'level']); w.writerows(rep)
    print(len(sql), 'drafted;', sum(1 for r in rep if r[2] != 'DRAFT'), 'skipped')
    for r in rep:
        if r[2] != 'DRAFT': print(r)


main()
