#!/usr/bin/env python3
"""Guard against slice SQL clobbering another slice's mob_pools / mob_groups / mob_droplist ids.

Scans every local branch (+ working tree) for rows defining those ids, deduped by blob, and reports:
  * ID COLLISION  - the same (table, id) defined by two different files with different row text
  * WIDE DELETE   - a `DELETE ... BETWEEN a AND b` / `IN (...)` that covers ids the same file never inserts
  * DB CLASH      - (--db) live row for an id exists with a different name/pool than the file's row

Usage (from the dsp-branches root):
  py -3 tools/check_sql_id_collisions.py --file sql/slices/foo/all.sql [--db]   # gate a new/changed file
  py -3 tools/check_sql_id_collisions.py --all [--db]                           # full audit
Exit code 1 on any finding. Run it BEFORE importing any slice SQL. Base files (sql/mob_*.sql) count as owners.
"""
import argparse, os, re, subprocess, sys, collections

TABLES = {"mob_pools": "poolid", "mob_groups": "groupid", "mob_droplist": "dropid"}
ROW = re.compile(r"^\s*(?:INSERT|REPLACE)\s+INTO\s+`?(mob_pools|mob_groups|mob_droplist)`?(?:\s*\([^)]*\))?\s+VALUES\s*\((\d+),(.*?)\)\s*;?\s*(?:--.*)?$", re.I)
DEL_BTW = re.compile(r"DELETE\s+FROM\s+`?(mob_pools|mob_groups|mob_droplist)`?\s+WHERE\s+`?\w+`?\s+BETWEEN\s+(\d+)\s+AND\s+(\d+)", re.I)
DEL_EQ = re.compile(r"DELETE\s+FROM\s+`?(mob_pools|mob_groups|mob_droplist)`?\s+WHERE\s+`?\w+`?\s*=\s*(\d+)", re.I)
BASE = {"sql/mob_pools.sql", "sql/mob_groups.sql", "sql/mob_droplist.sql"}  # --all skips pairs against base files (slices override stock on purpose)
INTERESTING = re.compile(r"^sql/(slices/.+\.sql|mob_pools\.sql|mob_groups\.sql|mob_droplist\.sql)$")


def git(*a, inp=None):
    return subprocess.run(["git", *a], capture_output=True, input=inp).stdout


def parse(text):
    rows, dels = [], []
    for line in text.splitlines():
        if line.lstrip().startswith("--"):
            continue
        m = ROW.match(line)
        if m:
            rows.append((m.group(1).lower(), int(m.group(2)), m.group(3).strip()))
            continue
        m = DEL_BTW.search(line)
        if m:
            dels.append((m.group(1).lower(), int(m.group(2)), int(m.group(3))))
            continue
        m = DEL_EQ.search(line)
        if m:
            dels.append((m.group(1).lower(), int(m.group(2)), int(m.group(2))))
    return rows, dels


def collect():
    """path -> {blobsha: (rows, dels)} across all local branches."""
    refs = git("for-each-ref", "--format=%(refname:short)", "refs/heads").decode().split()
    blobs = {}
    for r in refs:
        for line in git("ls-tree", "-r", r, "--", "sql").decode().splitlines():
            meta, path = line.split("\t", 1)
            sha = meta.split()[2]
            if INTERESTING.match(path):
                blobs.setdefault((path, sha), r)
    out = collections.defaultdict(list)
    for (path, sha), r in blobs.items():
        txt = git("cat-file", "blob", sha).decode("utf-8", "ignore")
        rows, dels = parse(txt)
        if rows or dels:
            out[path].append((r, rows, dels))
    return out


def live_rows():
    import mysql.connector
    c = {}
    for l in open("conf/map_darkstar.conf"):
        m = re.match(r"\s*mysql_(\w+):\s*(\S+)", l)
        if m:
            c[m.group(1)] = m.group(2)
    cn = mysql.connector.connect(host=c["host"], port=int(c["port"]), user=c["login"], password=c["password"], database=c["database"])
    cur = cn.cursor()
    res = {}
    cur.execute("select poolid,name from mob_pools"); res["mob_pools"] = dict(cur.fetchall())
    cur.execute("select groupid,poolid from mob_groups"); res["mob_groups"] = dict(cur.fetchall())
    cur.execute("select distinct dropid from mob_droplist"); res["mob_droplist"] = {r[0]: 1 for r in cur.fetchall()}
    return res


def norm(table, rest):
    f = re.findall(r"'[^']*'|[^,]+", rest)
    return (f[0] if table == "mob_pools" else f[0] if table == "mob_groups" else "")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--file"); ap.add_argument("--all", action="store_true"); ap.add_argument("--db", action="store_true")
    a = ap.parse_args()
    if not (a.file or a.all):
        ap.error("give --file PATH or --all")
    owners = collect()
    target = {}
    if a.file:
        rows, dels = parse(open(a.file, encoding="utf-8-sig").read())
        target[a.file.replace("\\", "/")] = [("WORKTREE", rows, dels)]
    else:
        target = owners
    bad = 0
    # id -> {path: set(row text)}
    defs = collections.defaultdict(lambda: collections.defaultdict(set))
    for path, vers in owners.items():
        for _, rows, _ in vers:
            for t, i, rest in rows:
                defs[(t, i)][path].add(re.sub(r"\s+", "", rest))
    for path, vers in target.items():
        if a.all and path in BASE:
            continue
        for br, rows, dels in vers:
            mine = {(t, i) for t, i, _ in rows}
            for t, i, rest in rows:
                others = {p: s for p, s in defs[(t, i)].items() if p != path and not (a.all and p in BASE)}
                for p, s in others.items():
                    if t == "mob_droplist" or re.sub(r"\s+", "", rest) not in s:
                        print(f"ID COLLISION {t} {i}: {path} [{br}] vs {p}"); bad += 1; break
            for t, lo, hi in dels:
                extra = [i for (tt, i) in list(defs) if tt == t and lo <= i <= hi and (t, i) not in mine and any(p != path for p in defs[(tt, i)])]
                if extra:
                    print(f"WIDE DELETE {t} {lo}-{hi} in {path} [{br}] also covers ids owned elsewhere: {sorted(extra)[:8]}"); bad += 1
    if a.db:
        live = live_rows()
        for path, vers in target.items():
            for br, rows, _ in vers:
                for t, i, rest in rows:
                    if i in live[t] and t != "mob_droplist":
                        f = re.findall(r"'[^']*'|[^,]+", rest)
                        want = f[0].strip("'") if t == "mob_pools" else int(f[0])
                        have = live[t][i]
                        if want != have and not any(p != path and i and (t, i) in defs and p in defs[(t, i)] for p in defs[(t, i)]):
                            print(f"DB CLASH {t} {i}: {path} wants {want!r}, live has {have!r}"); bad += 1
    print("OK: no id collisions" if not bad else f"{bad} problem(s)")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
