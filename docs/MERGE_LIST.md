# DSP master merge list: `old-dsp-reference` vs `dsp-fresh`

Generated 2026-10-02 by diffing the two trees (line endings ignored). 42 real differences: 7 `src`, 24 `scripts`, 11 `sql`
(an earlier "35" counted only scripts + sql). Both sit on upstream Darkstar `cd74c6d43c` (2017-10-22).

**Base for the master = `old-dsp-reference`.** It has git history (HEAD `e69acad3f4`, 2026-09-22, already on branch `backport-work`
of github.com/sarthax/darkstar-to-valhalla via its `valhalla` remote), the engine level-cap fix, and the later SQL repairs.
`dsp-fresh` is upstream plus uncommitted working-tree edits. Decisions below say what to bring in from `dsp-fresh`.

Legend: **OLD** keep old as is. **FRESH** take fresh's version. **MERGE** both have unique content, hand-merge. **VERIFY** cannot be decided from the files alone.
"+N" = lines unique to that side. File mtimes are unreliable for ordering (copies, builds).

## src (7)
| File | old / fresh | Decision |
|---|---|---|
| src/map/zone_instance.cpp | old+20 / fresh+6 | **OLD**: re-enables instance level cap on first entry only; fresh still has it commented out |
| src/search/search.cpp, data_loader.cpp, packets/search_list.{cpp,h}, packets/linkshell_list.{cpp,h} | old+1..12 / fresh+2..35 | **FRESH**: search-server packet-overflow fix. Unrelated to Assault; confirm it compiles before adopting |

## scripts (24)
| File | old / fresh | Decision |
|---|---|---|
| globals/common.lua | old+18 / 0 | **OLD** (adds `set{}` helper) |
| globals/utils.lua | old+62 / 0 | **OLD** |
| globals/nyzul/floor_layouts.lua | 0 / fresh+35 | **FRESH** |
| globals/nyzul/lamps.lua | old+4 / fresh+1 | **MERGE** |
| zones/Nyzul_Isle/instances/nyzul_isle_investigation.lua | old+21 / fresh+10 | **MERGE** |
| zones/Aht_Urhgan_Whitegate/Shared.lua | 0 / fresh+7 | **FRESH** |
| zones/Aht_Urhgan_Whitegate/TextIDs.lua | old+81 / fresh+44 | **MERGE** (verify each text id against the client dialog) |
| zones/Aht_Urhgan_Whitegate/Zone.lua | old+14 / 0 | **OLD** |
| zones/Aht_Urhgan_Whitegate/npcs/Rytaal.lua | old+12 / fresh+8 | **MERGE** |
| zones/Arrapago_Remnants/Zone.lua | old+17 / 0 | **OLD** |
| zones/{Bhaflau_Thickets,Caedarva_Mire,Mount_Zhayolm,Wajaom_Woodlands}/TextIDs.lua | old+11..17 / 0 | **OLD** |
| zones/{Alzadaal_Undersea_Ruins/_20m, Arrapago_Reef/_jic, Bhaflau_Thickets/_1g2, Caedarva_Mire/_272,_273, Mount_Zhayolm/_1p3}.lua | old+2 / fresh+1 | **OLD**, diff each once |
| zones/Halvung/mobs/Wamouracampa.lua, Mount_Zhayolm/mobs/Wamoura_Prince.lua | old+14 / fresh+3 | **OLD**, check fresh's 3 lines |
| zones/Ilrusi_Atoll/npcs/Treasure_Coffer.lua | old+2 / fresh+2 | **MERGE** |
| zones/Lebros_Cavern/instances/wamoura_farm_raid.lua | old+28 / fresh+18 | **MERGE** |

## sql (11)
| File | old / fresh | Decision |
|---|---|---|
| instance_entities.sql | old-only 48 keys, fresh-only 0, 4 changed | **OLD**; review the 4 changed keys |
| instance_list.sql | old+59 / fresh+66 | **MERGE** |
| mob_groups.sql | old-only 309 / fresh-only 543 rows | **MERGE**, per-row review |
| mob_pools.sql | old+68 / fresh+26 | **MERGE** (poolids must exist) |
| mob_pool_mods.sql | old+6 / 0 | **OLD** |
| mob_skill_lists.sql / mob_skills.sql | old+35,+10 / fresh+3,+7 | **MERGE** |
| item_usable.sql, mob_family_system.sql | 1 / 1 | **MERGE** |
| npc_list.sql | old-only 58, fresh-only 36, 93 changed | **MERGE**; changed rows include name differences (`npc` vs real name) |
| mob_spawn_points.sql | old-only 358 (351 Nyzul), fresh-only 203 (zones 55,56,63,66,69), 1864 changed | **VERIFY** |

### mob_spawn_points: the risky file
1864 rows differ. Fresh keeps upstream values (e.g. group id 11180, pos 1/1/1/0); old's later repair rewrote them (group id 86, 1.000 positions).
Which is right cannot be told from the files. Check against the live DB / `mob_groups` (does the groupid exist for that zone?) before choosing.
Keep old's 351 Nyzul rows; add fresh's 203 rows only if their groupids resolve.

## Files only in one tree
- Only in fresh: `scripts/commands/warpassault.lua`, `Lebros_Cavern/npcs/rune_of_release.lua`, `Leujaoam_Sanctum/npcs/rune_of_release.lua`
  (old has `Rune_of_Release.lua`; pick one spelling per zone, they collide on Windows).
- Only in old: Lebros instances `better_than_one`, `egg_conservation`, `operation_black_pearl`, `siegemaster_assassination`; Arrapago/Nyzul/Ashu_Talif `TextIDs.lua`; commands `Godmode1`, `gotoentity`, `logpos`, `nyzulflorlayout`; Mamool Ja analysis docs. Keep, but move notes/.md/.py out of `scripts/` into `docs/`.
- Exclude from master: binaries (*.exe, *.pdb), `log/`, `.vs`, navmesh `.nav` files, DB backups.

## Process
1. Branch from `valhalla/backport-work`; never touch `origin`; never stage the navmeshes submodule.
2. Apply FRESH/MERGE items one commit per group; SQL in separate commits.
3. Record in the repo README that this is the backport target; port `Sunbreeze-Addon` and the emote patch onto it.
