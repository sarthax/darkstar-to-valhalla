"""Generate Voidwalker NM SQL (pools/groups/drops/spawns) + thin mob scripts for every zone.

Inputs (read only): LSB data/zones/*/mobs.yaml, LSB scripts/zones/*/mobs/*.lua (wrappers),
scripts/globals/voidwalker_data.lua (ids + first position per zone), DSP sql/*.sql (base pools, items).
Usage: python tools/gen_voidwalker_sql.py <lsb_server_base> <dsp_root>
Writes: sql/slices/voidwalker/all_zones.sql, scripts/zones/<zone>/mobs/<NM>.lua (never overwrites),
        docs/slices/voidwalker/GEN_REPORT.md
Base-pool rule: new pool = DSP pool with the same 20-byte look (model) and mobType 0; jobs/delay/mobType from LSB yaml.
"""
import glob
import os
import re
import sys

import yaml

JOBS = dict(war=1, mnk=2, whm=3, blm=4, rdm=5, thf=6, pld=7, drk=8, bst=9, brd=10, rng=11, sam=12, nin=13,
            drg=14, smn=15, blu=16, cor=17, pup=18, dnc=19, sch=20, geo=21, run=22)
RATE = dict(always=1000, very_common=240, common=150, uncommon=100, rare=50, very_rare=10)
PILOT_POOLS = {}  # filled from batallia_pilot.sql
PILOT_DROPS = {}


# No DSP pool carries these models: clone a same-species pool (family, skills, spells) and set the LSB model.
SPECIES_BASE = {"Blobdingnag": "Viscous_Clot", "Orcus": "Cave_Antlion", "Krabkatoa": "Arrapago_Crab",
                "Dawon": "Cave_Tiger", "Lord_Ruthven": "Vampyr_Jarl"}


def main(lsb, dsp):
    report = []
    data = open(os.path.join(dsp, "scripts/globals/voidwalker_data.lua"), encoding="utf-8").read()
    zone_pos = {}
    for m in re.finditer(r"VOIDWALKER_DATA\[(\d+)\].*?pos = \{\s*\{ (-?\d+), (-?\d+), (-?\d+) \}", data, re.S):
        zone_pos[int(m.group(1))] = m.groups()[1:]
    ids = set(int(i) for i in re.findall(r"(\d{8}),", data))

    pools_sql = open(os.path.join(dsp, "sql/mob_pools.sql"), encoding="utf-8", errors="ignore").read()
    bymodel, bypoolid = {}, {}
    for m in re.finditer(r"mob_pools` VALUES \((\d+,'[^']*','[^']*',\d+,(0x[0-9A-Fa-f]{40}),.*?)\);", pools_sql):
        row = re.findall(r"'[^']*'|[^,]+", m.group(1))
        if len(row) == 25 and row[14] == "0":
            bymodel.setdefault(m.group(2)[:10].upper(), []).append(row)
            bypoolid[int(row[0])] = row
    pilot = open(os.path.join(dsp, "sql/slices/voidwalker/batallia_pilot.sql")).read()
    for m in re.finditer(r"mob_pools` VALUES \((\d+),'(\w+)'", pilot):
        PILOT_POOLS[m.group(2)] = int(m.group(1))
    PILOT_POOLS["Yilbegan"] = 4736
    for m in re.finditer(r"mob_groups` VALUES \(\d+,(\d+),105,\d+,0,(\d+),", pilot):
        pass
    pilot_drop = {}
    for m in re.finditer(r"mob_groups` VALUES \(\d+,(\d+),105,\d+,0,(\d+),", pilot):
        pilot_drop[int(m.group(1))] = int(m.group(2))
    for n, p in PILOT_POOLS.items():
        if pilot_drop.get(p):
            PILOT_DROPS[n] = pilot_drop[p]

    items = open(os.path.join(dsp, "sql/item_basic.sql"), encoding="utf-8", errors="ignore").read()
    item_id = {m.group(2): int(m.group(1)) for m in re.finditer(r"item_basic` VALUES \((\d+),\d+,'([^']*)'", items)}

    spawn_sql = open(os.path.join(dsp, "sql/mob_spawn_points.sql"), encoding="utf-8", errors="ignore").read()
    taken = {int(m.group(1)): m.group(2) for m in re.finditer(r"mob_spawn_points` VALUES \((\d+),'([^']*)'", spawn_sql)}

    # templates + spawns
    tpl, spawns = {}, {}
    for f in glob.glob(os.path.join(lsb, "data/zones/*/mobs.yaml")):
        d = yaml.safe_load(open(f, encoding="utf-8"))
        for top, val in d.items():
            if top == "templates" or not isinstance(val, dict):
                continue
            for mid, e in val.items():
                if mid in ids:
                    spawns[mid] = e
                    tpl[e["template"]] = d["templates"][e["template"]]

    pid, gid, did = 7008, 18178, 4591
    pools, drops, groups, sps, dels = [], [], [], [], []
    pool_of, drop_of = dict(PILOT_POOLS), dict(PILOT_DROPS)
    skipped = []
    for name in sorted(tpl):
        if name in pool_of:
            continue
        t = tpl[name]
        a = t.get("attributes", {})
        lk = a.get("render", {}).get("look", {})
        if lk.get("type") != "standard":
            skipped.append((name, "non-standard look"))
            continue
        mdl = lk["model"]
        key = "0X0000%02X%02X" % (mdl & 255, mdl >> 8)
        cands = bymodel.get(key)
        fallback = False
        if not cands and name in SPECIES_BASE:
            cands = [r for r in bypoolid.values() if r[1].strip("'") == SPECIES_BASE[name]]
            fallback = True
        if not cands:
            skipped.append((name, "no DSP pool with model %d" % mdl))
            continue
        row = list(cands[0])
        if fallback:
            row[4] = "0x0000%02X%02X" % (mdl & 255, mdl >> 8) + "0" * 32
        row[0], row[1], row[2], row[14] = str(pid), "'%s'" % name, "'%s'" % name, "2"
        jobs = a.get("jobs")
        if jobs:
            row[5], row[6] = str(JOBS[jobs[0]]), str(JOBS[jobs[-1]])
        if a.get("combat", {}).get("delay"):
            row[8] = str(a["combat"]["delay"])
        assert len(row) == 25
        pools.append("INSERT INTO `mob_pools` VALUES (%s);" % ",".join(row))
        report.append("pool %d %s <- base '%s' (model %d)%s" % (pid, name, cands[0][1].strip("'"), mdl, " [SPECIES FALLBACK: model from LSB, family/skills/spells from base]" if fallback else ""))
        pool_of[name] = pid
        pid += 1

    for name in sorted(tpl):
        if name in drop_of or name not in pool_of:
            continue
        lines = []
        for dr in tpl[name].get("loot", {}).get("drops", []) or []:
            if "item" not in dr:
                report.append("drop: %s one_of block NOT ported" % name)
                continue
            iid = item_id.get(dr["item"])
            if iid is None:
                report.append("drop: %s item '%s' not in DSP item_basic" % (name, dr["item"]))
                continue
            lines.append((iid, RATE.get(dr["chance"], 100)))
        if lines:
            drop_of[name] = did
            drops += ["INSERT INTO `mob_droplist` VALUES (%d,0,0,1000,%d,%d);" % (did, i, r) for i, r in lines]
            did += 1

    pilot_ids = set(range(17207711, 17207723))
    used_ids = []
    for mid in sorted(spawns):
        if mid in pilot_ids:
            continue
        e = spawns[mid]
        name = e["template"]
        if name not in pool_of:
            continue
        if mid in taken and taken[mid] not in ("Aither", "Thunor", "Lacus", "Yilbegan", "Verthandi", "Urd", "Skuld",
                                                name):
            report.append("CONFLICT: id %d already used in DSP by '%s', skipped %s" % (mid, taken[mid], name))
            continue
        zone = (mid - 0x1000000) >> 12
        t = tpl[name]
        resp = t.get("attributes", {}).get("spawn", {}).get("respawn")
        if not resp:
            resp = 3600
            report.append("respawn defaulted to 3600: %s" % name)
        st = t.get("attributes", {}).get("stats", {})
        lv = e.get("level", [t.get("level", 1)] * 2) if isinstance(e.get("level"), list) else [75, 75]
        x, y, z = zone_pos[zone]
        groups.append("INSERT INTO `mob_groups` VALUES (%d,%d,%d,%d,0,%d,%d,%d,%d,%d,0);" % (
            gid, pool_of[name], zone, resp, drop_of.get(name, 0), st.get("hp", 0), st.get("mp", 0), lv[0], lv[1]))
        sps.append("INSERT INTO `mob_spawn_points` VALUES (%d,'%s','%s',%d,%s,%s,%s,0);" % (
            mid, name, name, gid, x, y, z))
        used_ids.append(mid)
        gid += 1

    out = ["-- Voidwalker all-zones (excluding Batallia pilot). GENERATED by tools/gen_voidwalker_sql.py - idempotent.",
           "-- Pools: copies of the DSP pool with the same look; mobType 2, LSB jobs/delay. Skill/spell lists are the base pool's.",
           "-- Drops: named items only (one_of blocks not ported). Positions are the first voidwalkerpos slot (Lua moves NMs).",
           ""]
    if used_ids:
        out.append("DELETE FROM `mob_spawn_points` WHERE mobid IN (%s);" % ",".join(map(str, used_ids)))
    out.append("DELETE FROM `mob_groups` WHERE groupid BETWEEN 18178 AND %d;" % (gid - 1))
    out.append("DELETE FROM `mob_pools` WHERE poolid BETWEEN 7008 AND %d;" % (pid - 1))
    out.append("DELETE FROM `mob_droplist` WHERE dropid BETWEEN 4591 AND %d;" % (did - 1))
    out += [""] + pools + [""] + drops + [""] + groups + [""] + sps
    open(os.path.join(dsp, "sql/slices/voidwalker/all_zones.sql"), "w", newline="\n").write("\n".join(out) + "\n")

    # mob scripts from LSB wrappers
    made, extra, existing = 0, [], 0
    for f in glob.glob(os.path.join(lsb, "scripts/zones/*/mobs/*.lua")):
        src = open(f, encoding="utf-8").read()
        if "xi.voidwalker.onMobDeath" not in src:
            continue
        zdir = os.path.basename(os.path.dirname(os.path.dirname(f)))
        stem = os.path.splitext(os.path.basename(f))[0]
        dst = os.path.join(dsp, "scripts/zones", zdir, "mobs", stem + ".lua")
        old_title = None
        if os.path.exists(dst):
            cur = open(dst, encoding="utf-8").read()
            if "voidwalker" in cur:
                existing += 1
                continue
            body = [l for l in cur.splitlines() if l.strip() and not l.strip().startswith("--")]
            tm0 = re.search(r"addTitle\((\w+)\)", cur)
            if len(body) > 8 or "function onMobDeath" not in cur:
                extra.append("%s/%s (existing DSP script left unhooked: has other logic)" % (zdir, stem))
                continue
            old_title = tm0.group(1) if tm0 else None
        km = re.search(r"xi\.voidwalker\.onMobDeath\(mob, \w+, \w+, (nil|xi\.keyItem\.(\w+))\)", src)
        ki = km.group(2) if km and km.group(2) else "nil"
        tm = re.search(r"addTitle\(xi\.title\.(\w+)\)", src)
        if re.search(r"mixins|require|onMobInitialize\s*=\s*function\(mob\)\n\s+\S(?!.*voidwalker)", src):
            extra.append("%s/%s" % (zdir, stem))
        title = ""
        if old_title:
            title = "    if (player ~= nil) then player:addTitle(%s); end\n" % old_title
        elif tm:
            title = "    if (player ~= nil) then player:addTitle(%s); end\n" % tm.group(1)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "w", newline="\n").write(
            "-----------------------------------\n--  Area: %s\n--   NM:  %s (Voidwalker)\n"
            "-----------------------------------\n\nrequire(\"scripts/globals/voidwalker\");\nrequire(\"scripts/globals/titles\");\n\n"
            "function onMobSpawn(mob)\n    voidwalker.onMobSpawn(mob);\nend;\n\n"
            "function onMobFight(mob, target)\n    voidwalker.onMobFight(mob, target);\nend;\n\n"
            "function onMobDisengage(mob)\n    voidwalker.onMobDisengage(mob);\nend;\n\n"
            "function onMobDespawn(mob)\n    voidwalker.onMobDespawn(mob);\nend;\n\n"
            "function onMobDeath(mob, player, isKiller)\n%s    voidwalker.onMobDeath(mob, player, isKiller, %s);\nend;\n"
            % (zdir.replace("_", " "), stem, title, ki.replace("nil", "nil") if ki == "nil" else ki.upper()))
        made += 1

    head = ["# Voidwalker generation report", "",
            "pools %d, drops %d rows, groups %d, spawns %d; scripts written %d (existing kept %d)" % (
                len(pools), len(drops), len(groups), len(sps), made, existing), "",
            "## Skipped templates (no pool)"] + ["- %s: %s" % s for s in skipped] + [
            "", "## Wrappers with extra LSB logic (mods/mixins/requires) - thin wrapper only"] + [
            "- " + e for e in extra] + ["", "## Notes"] + ["- " + r for r in report]
    open(os.path.join(dsp, "docs/slices/voidwalker/GEN_REPORT.md"), "w", newline="\n").write("\n".join(head) + "\n")
    print(head[2])


if __name__ == "__main__":
    main(*sys.argv[1:3])
