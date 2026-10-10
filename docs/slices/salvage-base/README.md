# salvage-base: shared dependencies for all Salvage zone slices

Every `salvage-<zone>` slice requires this slice first. The zone slices carry only their own zone folder, SQL and docs.

## Carried by this branch
- `scripts/globals/salvage.lua` (`salvageUtil`: instance helpers, temp chests via each zone's `ARMOURY_CRATE` pool)
- `scripts/mixins/families/gears.lua`, `rampart.lua` (Arrapago; TICK-based ports)
- `sql/slices/salvage-base/00_status_effects.sql` (pathos effects 259-264; idempotent)

## C++ / engine dependencies (already in `main`; NOT changed by this slice)
Excerpts of the exact lines are in `cpp/`. A tree without them (e.g. another server) must have them before the zone slices work:
- `status_effect.h`: EFFECT_ENCUMBRANCE 259, OBLIVISCENCE 260, IMPAIRMENT 261, OMERTA 262, DEBILITATION 263, PATHOS 264
- `zone.h` / `zoneutils.cpp`: ZONE_ZHAYOLM/ARRAPAGO/BHAFLAU/SILVER_SEA_REMNANTS 73-76 (region mapping)
- Pathos gates: OMERTA in `magic_state.cpp`; IMPAIRMENT in `ability_state.cpp`, `mobskill_state.cpp`, `player_controller.cpp` (weaponskills); OBLIVISCENCE in `battleentity.cpp`
- `ai_container.cpp`: `TICK` listener event (used by the mixins)
- `lua_baseentity.cpp` methods: AnimationSub, updateAnimationSub, hideName, untargetable, pathThrough, addListener
- Instance loader excludes (0,0,0) mob_spawn_points rows (why zero-position placeholder mobs are not carried)

## Engine events DSP lacks (features NOT ported because of it)
`TAKE_DAMAGE` (Bhaflau Empathic Flan), `CRITICAL_TAKE` and `COMBAT_TICK` (Topaz weapon_break/qutrub mixins, gears uses TICK instead).

## Verify
`py -3 docs/slices/salvage-base/verify_base.py <repo_root>` exits 1 and lists anything missing.
