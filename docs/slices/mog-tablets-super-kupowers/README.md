# Slice: mog-tablets-super-kupowers (v2)

Mog Tablets (29 zones) and the Super Kupower effects. Power status table: `KUPOPOWER_STATUS.md`.

## Base / stacking
Branch `feature/mog-tablets-super-kupowers-v2` is stacked, in this order, on:
1. `master-dsp`
2. `feature/treasure-caskets-v2` (tag `slice/treasure-caskets-v12`) - Myriad Mystery Box wiring edits `caskets.lua`.
3. Moghancement (commit c058959dd3, tag `slice/moghancement-v1`) - defines MOD_CONQUEST_BONUS, MOD_GILFINDER etc. (861-868) that Boundary Buster / Treasure Hound use. Not optional.

If merging onto a different base, bring those two slices first.

## Contents
Mog tablet NPC scripts + state machine (`mog_tablets.lua`, `mog_tablet_data.lua`), Treasure Hound, Martial Master, Swift Shoes (Quickening), Boundary Buster, Thrifty Transit, Bountiful Bazaar, Crystal Caboodle (mods 869/870, mobentity.cpp), Blood of the Vampyr, Artisan's Advantage (synthutils.cpp), Dilatory Digestion (FOOD_DURATION).
Contains one DB change: `sql/status_effects.sql` Quickening flags (see commit cabbcbf784 / live: `UPDATE status_effects SET flags = 4194484 WHERE id = 176;`).

## Dependencies on the id-realign slice
`mog_tablet_data.lua` holds hard-coded Mog-Tablet npc ids as they are in `master-dsp` (e.g. West_Ronfaure 17187553). `slice/npc-id-realign` moves those rows (West_Ronfaure -> 17187586, South_Gustaberg -> 17216226, West_Sarutabaruta -> 17248890, others +/-1). After applying the realign, update the `npc =` ids in this file from the realigned `npc_list` (the old polluted branch carried the realigned values). Not verified here for all 29 zones.

## Dropped from the old branch
Abyssea-light reset hooks (healing/visitant effects) and the Sunbreeze/2F settings flags belong to other slices.
