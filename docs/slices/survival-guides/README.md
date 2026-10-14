# Slice: survival-guides (v2)

Survival Guide teleport network: `scripts/globals/survival_guide.lua`, `survival_guide_map.lua`, a `Survival_Guide.lua` npc script for 98 zones, and a `COMMON_SENSE_SURVIVAL` registration text id in each zone's TextIDs (values client-DAT verified in the old branch; Eastern Adoulin from ROM9/5/102.DAT dialog 13845).
Design notes / capture findings from the old branch: `NOTES.md`.

## Base
Stacked on `feature/npc-id-realign-v2`: guide npc ids are client-DAT slots, which only exist after the realign.

## SQL
- `sql/slices/survival-guides/survival_guides_apply.sql` - deletes every Survival_Guide row and inserts 88 rows (also applied to `sql/npc_list.sql`). Positions are marked LSB-arrival or live in the old branch (provisional where no capture).
- `sql/slices/survival-guides/survival_guides_blocked.sql` - 10 guides whose DAT slot is occupied by a different npc after the realign (blank x3, Moogle, Conquest_Banner, Kuchi_Eyjhann, Iroha, Siren, Unity_Master, HazyRune). NOT applied; relocate the occupant first. Needs a decision.
- The old `survival_guides_fix_visibility.sql` is folded into the apply rows and dropped.

## Notes
- 17 guide rows that realign-v2 kept on non-guide DAT slots were removed (several sit on slots the DAT names Summoner / Riftworn Pyxis / Achieve Master); those slots now have no row from this slice.
- Not tested in game. Zero-position guides in zones 89 and 97 and North Gustaberg visibility are still open.
