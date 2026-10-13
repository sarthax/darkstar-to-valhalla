"""Re-apply live-only npc_list overlays AFTER importing sql/npc_list.sql (which DROPs/recreates the table).
Order: npc_list.sql -> casket_realign_apply.sql -> treasure_caskets.sql -> survival_guides_apply.sql -> this script.
Usage: py -3 apply_overlays.py [host user password db]   (defaults read from conf/map_darkstar.conf-style args)
All files are idempotent (DELETE+INSERT, UPDATE or INSERT IGNORE)."""
import sys, os, mysql.connector as m
host, user, pw, db = (sys.argv[1:5] + ["127.0.0.1", "root", "", "dspdb_fresh"][len(sys.argv[1:5]):])
base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "slices")
FILES = [
    "ephemeral-moogle/ephemeral_moogle.sql",
    "sunbreeze-2021-addon/stage_show_npcs_windurst_walls.sql",
    "heroines-holdfast/npc_list.sql",
    "heroines-holdfast/npc_list_topaz_sync.sql",
    "nyzul-alzadaal/npc_list.sql",
    "nyzul-investigation/npc_list.sql",
    "nyzul-uncharted-survey/npc_list.sql",
]
c = m.connect(host=host, user=user, password=pw, database=db, autocommit=True, charset="utf8"); q = c.cursor()
for f in FILES:
    n = 0
    for st in open(os.path.join(base, f), encoding="utf8", errors="replace").read().split(";\n"):
        st = st.strip()
        if not st or all(l.startswith("--") or not l.strip() for l in st.split("\n")): continue
        st = st.replace("INSERT INTO `npc_list`", "REPLACE INTO `npc_list`", 1) if st.startswith("INSERT INTO `npc_list`") else st
        try: q.execute(st); n += 1
        except Exception as e: print("  ERR", f, str(e)[:100])
    print(f, n, "statements")
