# Mog House Flowerpot Gardening (Topaz/LSB -> DSP)

In-Mog-House pot gardening (plant, feed crystals, examine, harvest, dry, wilt) plus the `!garden` GM debug command. Gap-audit lead L-025. Not the Mog Garden zone.

**Status (2026-10-05): built and tested in-game.** Tested in-game 2026-10-05 via `!garden`: pots and seeds work; crystal feeding through to mature, then harvest, works as expected. Not every pot/seed/crystal combination has been tested. Original check: syntax-checked with `cl /Zs` (VS2019, C++17). See `docs/GARDENING_BACKPORT_SPEC.md` §4, §7, §8 for verification results and known gaps.

## Contents
| Path | What |
|---|---|
| `cpp-dsp/src/map/` | 6 NEW whole files: `items/item_flowerpot.*`, `utils/gardenutils.*`, `packets/furniture_interact.*` (gardenutils includes the `!garden` `DebugCommand`) |
| `cpp-dsp/patches/` | 12 per-file patches (`git apply`) for the files this port edits: `packet_system.cpp` (0x0FC-0x0FF handlers + registration + 0x00C hook), `charentity.cpp` (PostTick -> `UpdateGardening` while in Mog House), `map.cpp/.h` (config keys, `gardenutils::Initialize`), `lua_baseentity.cpp/.h` (`gardenDebug`), `message_standard.*` (2 new ctors), `message_basic.h` (MSGBASIC_GARDENING_* 256-258), `Makefile.in`, `DSGame-server.vcxproj(.filters)` |
| `lua-dsp/scripts/commands/garden.lua` | the `!garden` command |
| `sql-dsp/gardening_results.sql` | 2444 rows, copied unmodified from Topaz; all 135 result item ids exist in DSP `item_basic` |
| `conf/map_darkstar.conf.snippet` | 4 `garden_*` switches (all default 0) |
| `docs/` | `GM_COMMAND_garden.md`, `GARDENING_BACKPORT_SPEC.md` |

## Install (onto a DSP checkout)
1. Copy `cpp-dsp/src/map/*` into the DSP `src/map/` tree.
2. From the DSP root: `git apply --ignore-whitespace cpp-dsp/patches/*.patch` (check first with `--check`; patches are made against the DSP baseline just before this port, hunks filtered to gardening only, so line numbers may drift on a different checkout - apply by hand if needed).
3. Append `conf/map_darkstar.conf.snippet` to `conf/map_darkstar.conf`.
4. Copy `lua-dsp/scripts/commands/garden.lua` to `scripts/commands/`.
5. Import `sql-dsp/gardening_results.sql` (`py -3 tools/DBtool.py`; SQL edits have no live effect until imported).
6. Rebuild the map server and restart it.
7. Test: see `docs/GM_COMMAND_garden.md` quick test run.

## Deviations from Topaz
LSB aura logic with DSP 0-based elements (Topaz's aura block is buggy); `uint16` cumulative weight; day-element conversion fixed; null/id/type checks in 0x0FC-0x0FF; empty-result guard. Pots stay plain `CItemFurnishing` and are cast to `CItemFlowerpot` (no added data members).

## Known gaps / unverified
1. Basic message ids 256-258 (Topaz-only) unconfirmed against DSP's client; if examine text is wrong/blank, suspect these first. Standard ids 132/133/134/136/137 match LSB.
2. DSP `item_furnishing.sql` flowerpot rows have aura 0 / moghancement 0 (Topaz: mog 515, aura 2,1,1,1,2,4). Only matters if `garden_mh_aura_matters` is enabled.
3. No `GARDENING_WILT_BONUS` mod / Moghancement in DSP, so wilt time is a fixed 36 Vana days.
4. 0x0FF struct not checked against LSB `0x0ff_myroom_plant_stop`; Wildgrass wiki comparison not rerun.
5. `!garden grow` past a crystal stage skips the feed; client may not redraw the pot until re-entering the Mog House.

## Moghancement add-on (2026-10-06)
`moghancement/` holds the furniture-aura -> key item -> modifier system (Moghancement/Moglification) plus the `!moghancement` GM command. Patches are `git diff` against the dsp-master baseline (`git apply --ignore-whitespace moghancement/patches/*.patch`; verified with `git apply --check -R` against dsp-master). Copy `moghancement/lua-dsp/scripts/commands/moghancement.lua` to `scripts/commands/`, import `sql/item_furnishing.sql` (patch includes rows for 540-542, 562, 563), rebuild, restart.
- Adds mods 862-868 (`modifier.h`, `status.lua`), key items 543/2849-2855 names (`keyitems.lua`, `item_furnishing.h`), consumers in `charutils.cpp` (Gilfinder), `conquest_system.cpp`, death exp loss (`charentity.cpp`), `moghancementDebug` binding.
- Status: aura message, `!moghancement set`, and Gilfinder confirmed in game 2026-10-06. Untested: relog persistence, element swap, exp/conquest consumers.
- Gaps: see `docs/GARDENING_BACKPORT_SPEC.md` §10 (Valhalla desynthesis must apply `DESYNTH_SUCCESS`; resist 20 is a placeholder; 543/2851/2856 unwired, no client text; moogle aura text not wired).
- `docs/GARDENING_BACKPORT_SPEC.md` in this package is refreshed to include §10.
