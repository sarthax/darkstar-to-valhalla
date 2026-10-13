# Survival Guides (feature/survival-guides)

Cut from `main` (1b81cabea2) on 2026-10-12. Valhalla has no Survival Guides; Explorer Moogles already exist.

## Reference (not copied yet)
LSB snapshot: `DSP-LSB-Gap-Audit/evidence/lsb_snapshot/server-base/scripts/globals/teleports/survival_guide.lua` and `survival_guide_map.lua` (98 guides: zone, group, groupMask, groupIndex, destination pos). Per-zone `npcs/Survival_Guide.lua` in 98 LSB zones.

## Needed
1. C++ teleport registry: Lua bindings `hasTeleport`, `addTeleport`, `getTeleportMenu`, `setTeleportMenu`, `getTeleportTable` (type SURVIVAL) + persistence.
2. Event csid: LSB uses 8500 with 8 params; verify per zone against the client, never assume.
3. Destination table: verify the 98 positions (Y axis inverted; `!checknav` before use).
4. `npc_list`: ~59 live Survival_Guide rows, the rest commented NOT_CAPTURED with 0,0,0 positions.
5. Costs (LSB): 1000 gil or 50 valor tabs; Rhapsody in White KI = 1/5. Key item ids must be checked via id_bridge.py.
6. Thrifty Transit hook (feature/mog-tablets-super-kupowers): fee 0 and free-travel param bit 0x0400 when `MOG_TABLET.hasPower(THRIFTY_TRANSIT)`.

## Drift check (2026-10-12, client DAT pull of all 98 zones vs `sql/npc_list.sql`)
- All 98 guide zones have exactly one "Survival Guide" entity in the client DAT; 98 rows exist in npc_list (59 live, 39 NC at 0,0,0).
- 77 rows match the client id exactly. 21 are off (field-zone drift, mostly -1/-2): 17187561 vs 17187594 (W Ronfaure), 17195729/30, 17199771/73, 17203956 vs 17203947, 17207965/67, 17220213/14, 17224379/81, 17228421/23, 17232317/19, 17236368/70, 17244667/69, 17248914 vs 17248951, 17257122/24, 17261223/25, 17265320/22, 17269302/04, 17281673/75, 17285711/13, 17289815/17, 17556037 vs 17555977 (King Ranperre), 17772804/07 (Ru'Lude). Client id is authoritative.
- "New survival guide" text id differs from LSB in every zone (e.g. W Ronfaure client 12422/12424 vs LSB 12451); take them from each zone's dialog.yml.
- Eastern Adoulin: no matching text in the pull; check separately.

## Capture facts (Survival_Guide capture)
- csid 8500 via 0x034, param[0] low word = 2 or 0x081c.. (menu state), param[2] 0x4000000 (+0x20 once registered), param[3] 0xfff.
- Client replies (0x05B): option 7 = open teleport menu, 3 = set layout (high word = layout index), 1 = teleport (high word = destination index in the group, e.g. 2, 28), final EndPara 0 closes.
