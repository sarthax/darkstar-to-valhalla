# salvage-zhayolm

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports Zhayolm Remnants Salvage I (instance 62) from the Topaz tree to DSP. Backup of the original work: valhalla branch `salvage-wip-2026-10-09`.

## Contents
- `scripts/zones/Zhayolm_Remnants/` - `IDs.lua` (global `Zhayolm`), `Zone.lua`, `zhayolm_util.lua`, `instances/zhayolm_remnants.lua`, 21 npc scripts, 33 mob scripts.
- `sql/slices/salvage-zhayolm/01..05` - run in order.

## Decisions
- Text ids were checked by text against a fresh dialog.yml pull of zone 73; several Topaz values were off (e.g. 6383/6389/6390/6392, CELL_OFFSET 7213).
- DSP's `instance_list` has no `instance_zone` column; row rewritten in the 12-column form.
- Live Topaz `mob_groups` are NOT copied (ids collide with DSP's PK and its dropids differ). Existing DSP zone-73 groups are updated to spawntype 128 / respawn 0 instead; DSP dropids kept. Archaic_Chariot moves to DSP group 2379 (pool 216).
- Shared `mob_pools` / `mob_droplist` left untouched. Live pools differ from DSP (namevis 0 vs 1, aggro, links...) but those are upstream Topaz changes, not Salvage work.
- Mob script names follow DSP pool names (`Mamool_Ja_s_Lizard`, `Mamool_Ja_s_Wyvern`).
- Armoury_Crate: client entity pull lists a block of crates 17076579-17076588+, so both ids are real. Build uses 17076579 (matches `IDs.lua`); DSP's 17076584 row is replaced.

## Known gaps
- 387 live spawn rows are (0,0,0) placeholders; the instance loader never loads them, so they are not carried. Much of Zhayolm is not actually positioned.
- Poroggo Gent: only 24 Topaz ids exist; LSB north path 3 needs ids 25-36. Not invented.
- Existing `TextIDs.lua` in the zone folder is stale and unused.
- Topaz `IDs.lua` text ids 7000-7002 do not match the client.
- Arrapago/Bhaflau/Silver Sea must define globals `Arrapago`/`Bhaflau`/`SilverSea` (only `Arrapago` exists) before their cells work.
