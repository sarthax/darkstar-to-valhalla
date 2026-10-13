# Mog Tablets + Super Kupowers (framework slice)

Branch `feature/mog-tablets-super-kupowers`, cut from `master-dsp`. No SQL import needed: the 29 `Mog-Tablet` npc_list rows and the Ru'Lude Explorer Moogle row (17772773) already exist in `sql/npc_list.sql`.

## What is built
- `scripts/globals/mog_tablets.lua` (state machine, messaging, tablet trigger, power activation) and `mog_tablet_data.lua` (zone, tablet npc id, spot list).
- `npcs/Mog-Tablet.lua` in the 29 field zones; 2-line hooks in those Zone.lua (`onInitialize`, `onZoneIn`) and Ru'Lude `onZoneIn`.
- `RuLude_Gardens/npcs/Explorer_Moogle.lua`: csid 10111 turn-in (Kupofried's Ring 15840 + tablet reward), 10109 info menu (options 1 and 3), 10114 story.
- `MOG_TABLET_ALL_POWERS` in settings.lua.
- Power API for hooks: `MOG_TABLET.hasPower(MOG_TABLET.POWERS.X, zoneId)`.

## Evidence [C] (captures in Playthrough Captures/Mog Tablet)
- Turn-in: csid 10111, EndPara 2, two item grants (15840 + 3973 for Piety). Power bit = 1<<(power-1) (522 = Martial+Treasure+Swift). Tablet order 0..10 matches the LSB enum. Login message text for active powers. Zi'Tah find text and broadcast text.

## Power effects (status 2026-10-12)
| Power | Status | Where |
|---|---|---|
| Thrifty Transit | partial | `conquest.lua` OP_TeleFee returns 0 in own-outpost zones. Explorer Moogles (5 city NPCs, 300 gil teleports already on Valhalla) are shown/hidden by `MOG_TABLET.applyExplorerMoogles` when `MOG_TABLET_GATE_EXPLORER_MOOGLES = 1` (default 0 = always visible, as on Valhalla); re-applied on scatter/activate/expire. Survival Guides do not exist on Valhalla: separate feature branch, then add the free-fee hook (fee 0 + free-travel param bit 0x0400 per LSB) |
| Martial Master | done | skill-up +`MOG_TABLET_SKILLUP_RATE` (25) under Signet; Valhalla already has 2x |
| Blood of the Vampyr | done | mods 871/872 (`VAMPYR_REGEN/REFRESH`), added in `TickRegen` when HP/MP < 51%; Fellows not covered. No existing LSB/Topaz mod, so new |
| Treasure Hound | done | Signet Gilfinder/TH +1 |
| Artisan's Advantage | done | mod 873 in `doSynthFail`; needs ADVANCED image support (imagery effect power >= 3); default -20% of loss chance (`MOG_TABLET_ARTISAN_LOSS_SUPPORT`). JP wiki (wiki.ffo.jp/html/18146.html) gives no number; ffxilogdialy measured 53.5% -> 43.7% loss per failure (~-18%) |
| Myriad Mystery Boxes | done | `caskets.lua` |
| Dilatory Digestion | done | mod 874 `FOOD_DURATION` (+`MOG_TABLET_FOOD_DURATION`, 100 = twice as long), applied to `EFFECT_FOOD` in `CStatusEffectContainer::AddStatusEffect`. Sigil/Sanction food-duration comments still unwired |
| Boundary Buster | done | conquest points doubled |
| Bountiful Bazaar | done | 54 city regional vendor scripts accept the power in place of region ownership |
| Swift Shoes | partial | Quickening on resting; Alter Egos/Fellows/Automatons and some removal conditions missing |
| Crystal Caboodle | done | mods 869/870: crystal drop chance 20% -> 40% (`MOG_TABLET_CRYSTAL_RATE`), 10% of crystals become clusters; hook in `mobentity.cpp` |

New mods 869-874 in `modifier.h` and `status.lua`: confirm no clash with Valhalla ids. Map server rebuild needed (C++). Quickening SQL: `UPDATE status_effects SET flags = 4194484 WHERE id = 176;`. Everything here is untested in-game and the C++ is uncompiled.

## Not built / unverified
- Remaining power gaps: see table above.
- Spots: only the npc_list seed positions (16 zones) plus 2 capture positions (Zi'Tah, Valkurm). The other 13 zones have no spot, so they never host a tablet. Fill via the toolkit Super Kupopower page.
- Valkurm: capture tablet id 17199761, DSP row 17199763. Left as DSP's; check on a live client.
- Event 10109 option 4 poll and per-zone list replies (params not decoded); csid 10111 params after the 4th verified only for Piety; "reward already held" dialog is a placeholder.
- Affected-zone list = 29 field zones + Ru'Lude only. No 87-yalm reveal (status toggles, normal entity range applies). Messages are plain text because client TextIDs differ by generation.
- Single-process assumption (GetZone():getPlayers() broadcast).

## Test plan
1. Restart map server. GM: `MOG_TABLET.gmReset()` then check `[MOGTAB]Zone0..10` server vars, 11 visible Mog-Tablet NPCs.
2. Go to a tablet, click: found text, broadcast to other zones, tablet disappears.
3. Ru'Lude Explorer Moogle: csid 10111 plays, receive Kupofried's Ring + reward. Repeat while holding the reward: blocked.
4. After 11 found: powers announced, zone-in lists 3 powers, Moogle option 1 shows them.
5. `MOG_TABLET.gmForcePowers(522, 1)` to test expiry/rescatter.
