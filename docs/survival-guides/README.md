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
