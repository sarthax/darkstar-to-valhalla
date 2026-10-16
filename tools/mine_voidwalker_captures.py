"""Mine Voidwalker NM facts from ingested PacketViewer/Siknawz captures.

Usage: python tools/mine_voidwalker_captures.py <voidwalker_captures_dir> <out.md>
Per NM (actor in actionview simple logs): level/look/index from npclogger, skills (cat 11) and spells (cat 4) with ids,
HP-track kill ranges, melee swing interval + damage range from caplog. Facts are observed, never inferred.
"""
import collections, glob, os, re, sys

NMS = None


def nm_names(root):
    names = set()
    for f in glob.glob(os.path.join(root, "*", "*", "*", "actionview", "simple", "*.log")):
        for m in re.finditer(r"\[Actor: \d+ \(([^)]+)\)\]", open(f, encoding="utf-8", errors="replace").read()):
            names.add(m.group(1))
    return names


def main(root, out):
    players = {"Siknawz"}
    rows = collections.defaultdict(lambda: {"zone": set(), "lvl": set(), "look": set(), "skills": collections.defaultdict(set),
                                           "spells": collections.defaultdict(set), "hp": [], "swing": [], "dmg": [], "cap": set()})
    for cap in sorted(glob.glob(os.path.join(root, "*", "*", "*"))):
        if not os.path.isdir(cap):
            continue
        cname = cap.split(os.sep)[-3]
        for sim in glob.glob(os.path.join(cap, "actionview", "simple", "*.log")):
            zone = os.path.basename(sim)[:-4]
            txt = open(sim, encoding="utf-8", errors="replace").read()
            actors = {}
            for m in re.finditer(r"\[Actor: (\d+) \(([^)]+)\)\] (.+?) > Cat: (\d+) ID: (\d+)", txt):
                aid, an, sk, cat, sid = m.groups()
                if an in players:
                    continue
                actors[aid] = an
                r = rows[(zone, an)]
                r["cap"].add(cname)
                (r["skills"] if cat == "11" else r["spells"] if cat == "4" else r["skills"])[(int(sid), sk)].add(cat)
            for dbf in [os.path.join(cap, "npclogger", "database", zone + ".lua")] if os.path.isfile(os.path.join(cap, "npclogger", "database", zone + ".lua")) else []:
                for line in open(dbf, encoding="utf-8", errors="replace"):
                    m = re.search(r"\['id'\]=(\d+), \['name'\]=\"([^\"]+)\".*?\['level'\]=(\d+).*?\['look'\]=\"([0-9A-Fa-f]+)\"", line)
                    if m and m.group(1) in actors:
                        r = rows[(zone, actors[m.group(1)])]
                        r["lvl"].add(int(m.group(3))); r["look"].add(m.group(4)); r["zone"].add(zone)
            hp = os.path.join(cap, "hptrack", "simple", zone + ".log")
            if os.path.isfile(hp):
                for m in re.finditer(r"Killed \d+ \(([^)]+)\): (\d+)~(\d+)HP(?:, Est\.HP: (\d+))?", open(hp, encoding="utf-8", errors="replace").read()):
                    key = (zone, m.group(1))
                    if key in rows:
                        rows[key]["hp"].append((int(m.group(2)), int(m.group(3)), m.group(4)))
        for cl in glob.glob(os.path.join(cap, "caplog", "*.txt")):
            for (zone, an), r in list(rows.items()):
                if cname not in r["cap"]:
                    continue
                last = None
                for line in open(cl, encoding="utf-8", errors="replace"):
                    m = re.match(r"\[(\d\d):(\d\d):(\d\d)\] " + re.escape(an) + r" hits \w+ for (\d+) points", line)
                    if m:
                        t = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + int(m.group(3))
                        if last is not None and 0 < t - last < 15:
                            r["swing"].append(t - last)
                        last = t
                        r["dmg"].append(int(m.group(4)))
    L = ["# Voidwalker capture findings (observed)", "", "Mined by tools/mine_voidwalker_captures.py from the ingested Discord captures.", ""]
    for (zone, an), r in sorted(rows.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        L.append(f"## {an} - {zone}")
        L.append(f"- captures: {', '.join(sorted(r['cap']))}")
        L.append(f"- level(s): {sorted(r['lvl'])}  look: {sorted(r['look'])}")
        if r["skills"]:
            L.append("- skills/TP moves: " + ", ".join(f"{n} ({i})" for (i, n) in sorted(r["skills"])))
        if r["spells"]:
            L.append("- spells: " + ", ".join(f"{n} ({i})" for (i, n) in sorted(r["spells"])))
        if r["hp"]:
            L.append("- hp-track: " + "; ".join(f"{a}~{b}" + (f" est {e}" if e else "") for a, b, e in r["hp"][:6]))
        if r["dmg"]:
            c = collections.Counter(r["swing"]).most_common(1)
            L.append(f"- melee hits seen: {len(r['dmg'])}, dmg {min(r['dmg'])}-{max(r['dmg'])}" + (f", common interval {c[0][0]}s" if c else ""))
        L.append("")
    open(out, "w", encoding="utf-8", newline="\n").write("\n".join(L))
    print(len(rows), "NM/zone rows ->", out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
