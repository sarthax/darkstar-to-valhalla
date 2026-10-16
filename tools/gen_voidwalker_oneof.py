"""Port LSB `one_of` loot pools for Voidwalker NMs as independent mob_droplist rows (this DSP core has no grouped drops).

Each pool = chance C (RATE, /1000) of dropping ONE item, picked by weight w/sum(w). Independent-row equivalent:
itemRate = C * w / sum(w), rounded half up, min 1. Pools of the same NM are summed per item (separate rolls).
Usage: py -3 tools/gen_voidwalker_oneof.py <lsb_server_base> [--write]
Output: sql/slices/voidwalker/drops_oneof.sql (DELETE+INSERT per dropid, only the one_of items; named drops untouched).
"""
import glob, os, re, sys, yaml, collections
RATE = dict(always=1000, very_common=240, common=150, uncommon=100, rare=50, very_rare=10)
NMS = ["Blobdingnag", "Dawon", "Krabkatoa", "Lord_Ruthven", "Orcus", "Yilbegan"]
DROPID = {"Blobdingnag": 4591, "Krabkatoa": 4599, "Orcus": 4602, "Lord_Ruthven": 4601, "Dawon": 4594, "Yilbegan": 4590}
lsb = sys.argv[1]
dsp = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
items = open(os.path.join(dsp, "sql/item_basic.sql"), encoding="utf-8", errors="ignore").read()
item_id = {m.group(2): int(m.group(1)) for m in re.finditer(r"item_basic` VALUES \((\d+),\d+,'([^']*)'", items)}
tpl = {}
for f in glob.glob(os.path.join(lsb, "data/zones/*/mobs.yaml")):
    d = yaml.safe_load(open(f, encoding="utf-8"))
    for n in NMS:
        if n in d.get("templates", {}) and n not in tpl:
            tpl[n] = d["templates"][n]
out, rep = [], []
for n in NMS:
    drops = (tpl.get(n, {}).get("loot", {}) or {}).get("drops", []) or []
    named = {d["item"] for d in drops if "item" in d}
    acc = collections.Counter()
    for d in drops:
        if "one_of" not in d:
            continue
        w = d["one_of"]
        tot = float(sum(w.values()))
        for k, v in w.items():
            iid = item_id.get(k)
            if iid is None:
                rep.append("%s: item '%s' not in item_basic" % (n, k)); continue
            if k in named:
                rep.append("%s: '%s' is also a named drop" % (n, k))
            acc[iid] += RATE[d["chance"]] * v / tot
    if not acc:
        rep.append("%s: no one_of pools in LSB" % n); continue
    did = DROPID[n]
    out.append("-- %s (dropid %d): %d one_of items" % (n, did, len(acc)))
    out.append("DELETE FROM `mob_droplist` WHERE dropid=%d AND itemId IN (%s);" % (did, ",".join(str(i) for i in sorted(acc))))
    for iid, r in sorted(acc.items()):
        out.append("INSERT INTO `mob_droplist` VALUES (%d,0,0,1000,%d,%d);" % (did, iid, max(1, int(r + 0.5))))
if "--write" in sys.argv:
    open(os.path.join(dsp, "sql/slices/voidwalker/drops_oneof.sql"), "w").write("\n".join(out) + "\n")
print("\n".join(rep)); print(len(out), "lines")
