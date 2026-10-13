# Mob rows sitting on client NPC slots (2026-10-12)
Found by tools/check_mob_ids.py + npc_list join. None are referenced by any Lua (grep of scripts/ and IDs.lua), except zone 187 (Dynamis-Windurst Avatar_Icon, used by dynamis.lua/bcnm_battlefield.sql; dynamic zone, intentional, leave).
These are BCNM/event zones whose mob slots are not in the static client DAT, so the correct slot cannot be derived. Not moved, not pruned.
| zone | mobid(s) | mob | npc on slot |
|---|---|---|---|
| 148 | 17383482 | Diamond_Quadav | qm1 |
| 152 | 17399851/52 | Yagudo_Avatar, Tzee_Xicu | Ramblix, Goblin_Footprint |
| 163 | 17445214-16 | Shantotto | Goblin_Footprint, blank, ??? |
| 165 | 17453295/97/313/314 | Volker, Ayame, Riko_Kupenreich x2 | Moogle, ???, blank |
| 168 | 17465568-70 | Grav_iton, Eald_narche, Kam_lanaut | Moogle x3 |
| 139 | 17347056-60, 17347075 | Clan Reaper/Wolf mobs, Lhu_Mhakaracca | numbered/placeholder npcs |
| 146 | 17375760 | Buu_Xolo | Moogle |
Zones 159, 293, 274, 93, 86: no npc-slot collision remains in the live join (the earlier flags were name-only differences).
Same-name npc+mob mirrors (e.g. zone 152 Yagudo_*, 163 Eald_narche) are intentional and fine.
Next step if one of these fights misbehaves: capture the fight, take the real mob id, and re-key that single row.
