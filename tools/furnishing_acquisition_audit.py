#!/usr/bin/env python3
"""Furnishing acquisition audit: for every item_furnishing row, record where it comes from
(retail, per the BG Wiki dump) and whether our server data currently provides that source.

REFERENCE ONLY: wiki text is player-written. Tags are keyword-derived hints for prioritising
work, not verified facts. Synth ingredient obtainability is checked against OUR live DB/Lua only.

Usage (from D:\\Claude\\dsp-branches):  py -3 tools/furnishing_acquisition_audit.py [--out docs/furnishings]
Needs the live DB (creds from conf/map_darkstar.conf) and D:/Claude/FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz.
"""
import argparse, collections, csv, gzip, json, os, re
import mysql.connector

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI = 'D:/Claude/FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz'


def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())


def connect():
    c = open(ROOT + '/conf/map_darkstar.conf').read()
    g = lambda k: re.search(k + r':\s*(\S+)', c).group(1)
    return mysql.connector.connect(host=g('mysql_host'), port=int(g('mysql_port')), user=g('mysql_login'),
                                   password=g('mysql_password'), database=g('mysql_database'))


def load_sources(cur):
    """src[itemid] -> set of source labels present in our server data."""
    src = collections.defaultdict(set)

    def q(sql, label):
        try:
            cur.execute(sql)
            for r in cur:
                src[r[0]].add(label)
        except Exception as e:
            print('skip', label, str(e)[:60])
    for col in ('Result', 'ResultHQ1', 'ResultHQ2', 'ResultHQ3'):
        q(f"select {col} from synth_recipes where {col}>0", 'synth')
    q("select itemid from guild_shops", 'guild_shop')
    q("select itemId from mob_droplist", 'mob_drop')
    q("select itemId from bcnm_loot", 'bcnm_loot')
    q("select result from gardening_results", 'gardening')
    cur.execute("select itemid from item_basic")
    allids = {r[0] for r in cur}
    kw = re.compile(r'addItem|giveItem|reward|stock|shop|treasure|drop|trade|price', re.I)
    num = re.compile(r'(?<![\w.])(\d{2,5})(?![\w.])')
    for root, _, files in os.walk(ROOT + '/scripts'):
        for fn in files:
            if not fn.endswith('.lua') or fn in ('TextIDs.lua',):
                continue
            p = os.path.join(root, fn)
            lines = open(p, encoding='latin-1').read().splitlines()
            isshop = any('dsp.shop' in l or 'stock' in l for l in lines)
            for l in lines:
                if l.strip().startswith('--') or (not isshop and not kw.search(l)):
                    continue
                for m in num.findall(l):
                    if int(m) in allids:
                        src[int(m)].add('lua_shop' if isshop else 'lua_ref')
    return src


TAGS = [  # (tag, regex over flags + non-synth wikitext)
    ('goblin_box', r'goblin box|goblin mystery'),
    ('login_campaign', r'login campaign|repeat login|login point'),
    ('event_starlight', r'starlight'),
    ('event_sunbreeze', r'sunbreeze'),
    ('event_harvest', r'harvest festival|halloween|pumpkin'),
    ('event_other', r'valentione|egg hunt|ballistae|festival'),
    ('quest', r'\bquest\b|\[\[[^\]]*\]\] quest|reward'),
    ('mob_drop', r'dropped by|drops?\b|monster|\bnm\b'),
    ('npc_sale', r'sold by|vendor|purchased|guild merchant|\bgil\b'),
    ('mog_garden', r'mog garden|gardening|flowerpot'),
    ('abyssea_voidwatch', r'abyssea|voidwatch|pyxis'),
    ('moogle_mog_tablet', r'mog tablet|moogle'),
    ('assault_salvage_other', r'assault|salvage|nyzul|limbus|dynamis|besieged'),
]


def wiki_pages(names_norm):
    out = {}
    with gzip.open(WIKI, 'rt', encoding='utf-8') as f:
        for line in f:
            p = json.loads(line)
            if 'Furnishing' not in p.get('categories', []):
                continue
            if any(c.lower() == 'catseyexi' for c in p.get('categories', [])):
                continue
            out[norm(p['title'])] = p
            m = re.search(r'\|ffxidb=(\d+)', p['wikitext'])
            if m:
                out[int(m.group(1))] = p
    return out


def parse_ingredients(block):
    ing = []
    m = re.search(r'\|Recipe=\s*(.*?)\n\|(?:NQ|HQ)', block, re.S)
    if not m:
        m = re.search(r'\|Ingredients=\s*(.*?)\n\}\}', block, re.S)
    if m:
        for l in m.group(1).splitlines():
            mm = re.match(r'\*\s*\[\[([^\]|]+)(?:\|[^\]]*)?\]\](?:\s*x\s*(\d+))?', l.strip())
            if mm:
                ing.append((mm.group(1).strip(), int(mm.group(2) or 1)))
    return ing


def parse_synth(wt):
    res = []
    for kind, pat in (('synth', r'\{\{Item Synth\s*\n(.*?)\n\}\}'), ('synergy', r'\{\{Item Synergy\s*\n(.*?)\n\}\}\s*\n?\}\}')):
        for m in re.finditer(pat, wt, re.S | re.I):
            b = m.group(1)
            g = lambda k: (re.search(r'\|' + k + r'=([^\n]*)', b) or [None, ''])[1].strip()
            res.append(dict(kind=kind, craft=g('Craft Name') or g('Primary Craft'), level=g('Craft Level') or g('Primary Craft Rank'),
                            crystal=g('Crystal'), key_item=g('Key Item'), ingredients=parse_ingredients(b)))
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=ROOT + '/docs/furnishings')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    db = connect()
    cur = db.cursor()
    cur.execute("select f.itemid,f.name,f.storage,f.aura,f.element,f.moghancement from item_furnishing f")
    F = {r[0]: r for r in cur}
    cur.execute("select itemid,name,sortname from item_basic")
    name2id = {}
    for iid, n, sn in cur:
        for k in (n, sn):
            if k:
                name2id.setdefault(norm(k), iid)
    src = load_sources(cur)
    pages = wiki_pages(None)
    rows, ing_rows = [], []
    for iid, (_, name, storage, aura, elem, mog) in sorted(F.items()):
        ours = sorted(src.get(iid, ()))
        page = pages.get(iid) or pages.get(norm(name))
        tags, synths, notes = [], [], ''
        if page:
            wt = page['wikitext']
            synths = parse_synth(wt)
            rest = re.sub(r'\{\{Item Synth Table.*?\n\}\}\s*\n\}\}', '', wt, flags=re.S)
            rest = re.sub(r'\{\{Item Synergy Table.*', lambda m: '', rest, flags=re.S) if False else rest
            body = rest.lower()
            flagm = re.search(r'\|flags=([^\n]*)', wt)
            for t, rx in TAGS:
                if re.search(rx, body):
                    tags.append(t)
            if synths:
                tags.insert(0, 'crafted')
            nm = re.search(r'==\s*Notes\s*==(.*?)(?:\n==|\Z)', wt, re.S)
            notes = re.sub(r'\s+', ' ', re.sub(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]', r'\1', nm.group(1) if nm else ''))[:300].strip()
            flags = flagm.group(1) if flagm else ''
        else:
            flags = ''
        # ingredient obtainability for crafted route
        recipe_ok = None
        for s in synths:
            miss = []
            for n, q in s['ingredients']:
                ii = name2id.get(norm(n))
                have = sorted(src.get(ii, ())) if ii else []
                ing_rows.append(dict(furnishing=name, furn_id=iid, route=s['kind'], craft=s['craft'], ingredient=n, qty=q,
                                     ingredient_id=ii or '', our_sources=','.join(have)))
                if not have:
                    miss.append(n)
            s['missing_ingredients'] = miss
            s['obtainable'] = not miss and bool(s['ingredients'])
        if synths:
            recipe_ok = any(s['obtainable'] for s in synths)
        ours_real = [x for x in ours if x != 'lua_ref']
        rows.append(dict(itemid=iid, name=name, storage=storage, aura=aura, element=elem, moghancement=mog,
                         our_sources=','.join(ours), wiki_page='yes' if page else 'no', wiki_flags=flags,
                         retail_tags=','.join(tags), wiki_synth_routes=len(synths),
                         synth_in_our_db='synth' in ours,
                         craftable_with_our_ingredients='' if recipe_ok is None else recipe_ok,
                         missing_ingredients='; '.join(sorted({m for s in synths for m in s.get('missing_ingredients', [])}))[:300],
                         status=('have_source' if ours_real else 'NO_SOURCE'), notes=notes))
    def w(name, data):
        with open(f'{a.out}/{name}', 'w', newline='', encoding='utf-8') as f:
            wr = csv.DictWriter(f, fieldnames=list(data[0]))
            wr.writeheader()
            wr.writerows(data)
    w('furnishing_sources.csv', rows)
    w('furnishing_recipe_ingredients.csv', ing_rows)
    c = collections.Counter(r['status'] for r in rows)
    tagc = collections.Counter(t for r in rows if r['status'] == 'NO_SOURCE' for t in r['retail_tags'].split(',') if t)
    print(len(rows), dict(c), 'wiki pages matched:', sum(r['wiki_page'] == 'yes' for r in rows))
    print('NO_SOURCE retail tags:', dict(tagc))
    print('ingredient rows', len(ing_rows), 'missing', sum(1 for r in ing_rows if not r['our_sources']))


if __name__ == '__main__':
    main()
