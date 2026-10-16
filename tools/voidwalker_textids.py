"""Build the per-zone Voidwalker text-id table from fresh mission_toolkit pulls.

Usage: python tools/voidwalker_textids.py <pull_dir> <out_csv>
Matches by message TEXT (never by LSB numbers). Reports zones where a key is missing/ambiguous.
"""
import csv
import os
import re
import sys

import yaml

KEYS = [
    ("VOIDWALKER_NO_MOB", "quivers ever so slightly, but emits no light"),
    ("VOIDWALKER_MOB_TOO_FAR", "quivers ever so slightly and emits a faint light"),
    ("VOIDWALKER_MOB_HINT", "sending a radiant beam"),
    ("VOIDWALKER_SPAWN_MOB", "A monster materializes out of nowhere"),
    ("VOIDWALKER_DESPAWN", "The monster fades before your eyes"),
    ("VOIDWALKER_UPGRADE_KI_1", "slightly deeper hue"),
    ("VOIDWALKER_UPGRADE_KI_2", "deeper, richer hue"),
    ("VOIDWALKER_BREAK_KI", "shatters into tiny fragments"),
    ("VOIDWALKER_OBTAIN_KI", "Obtained key item:"),
]


def norm(s):
    return re.sub(r"\s+", " ", str(s)).strip()


def main(pull_dir, out_csv):
    rows, problems = [], []
    for zone in sorted(os.listdir(pull_dir)):
        path = os.path.join(pull_dir, zone, "dialog.yml")
        if not os.path.isfile(path):
            problems.append(f"{zone}: no dialog.yml")
            continue
        entries = yaml.safe_load(open(path, encoding="utf-8"))["entries"]
        text = {int(k): norm(v) for k, v in entries.items()}
        row = {"zone": zone}
        brk = None
        for name, needle in KEYS:
            hits = sorted(i for i, t in text.items() if needle in t)
            if name == "VOIDWALKER_BREAK_KI" and hits:
                brk = hits[0]
            if name == "VOIDWALKER_OBTAIN_KI":
                # the one immediately after BREAK_KI (generic KEYITEM_OBTAINED is a different, early id)
                hits = [i for i in hits if brk is not None and i == brk + 1]
            if name == "VOIDWALKER_DESPAWN":
                # prefer the id inside the voidwalker block (right after SPAWN_MOB)
                sp = int(row.get("VOIDWALKER_SPAWN_MOB") or 0)
                near = [i for i in hits if sp and i == sp + 1]
                hits = near or hits
            if len(hits) != 1:
                problems.append(f"{zone}: {name} hits={hits}")
            row[name] = hits[0] if hits else ""
        rows.append(row)
    with open(out_csv, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["zone"] + [k for k, _ in KEYS])
        w.writeheader()
        w.writerows(rows)
    print(f"{len(rows)} zones -> {out_csv}")
    for p in problems:
        print("PROBLEM", p)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
