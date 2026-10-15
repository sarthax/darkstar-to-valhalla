# Assault Ancient Lockbox "???" Item Appraisal - Shared Assault Infrastructure Package

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 4 files: DSP-converted Lua scripts (deploy these)
- `archive-topaz/` -- 4 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (4)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The shared appraisal system (Drahbah/Whitegate, Chochoroon/Al Zahbi, Memeroon/Nashmau) that lets a player trade in an unidentified "???" item -- the reward type every zone's Ancient Lockbox hands out via assault_lockbox.lua's chestTrigger -- for a real item drawn from a weighted pool, for a flat gil fee. Packaged separately from any single zone's Assault missions (same rationale as mercenary_rank_promotions) because it's zone-agnostic hub infrastructure used identically regardless of which zone's Lockbox produced the "???" item. FUNCTIONAL BUT DELIBERATELY PARTIAL -- see known_issues. Handed off in this state for further implementation, not a finished feature.

## Contents
- `lua/` — 4 Lua scripts
- (no SQL included -- all real npcid/mobid data already exists on the target)
- (no C++ reference included)
- `navmesh/` — none
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
This is a shared-infrastructure package, not a standalone mission -- apply it alongside (or before) any per-zone Assault package, since Ancient Lockbox "???" rewards are meaningless without a way to appraise them.
1. No SQL needed at all -- Drahbah, Chochoroon, and Memeroon are already real, already-placed NPCs in this DSP snapshot's own npc_list.sql. Confirmed directly (grep) before writing this config -- do not add npc_list rows for them.
2. Copy lua/ into the target scripts/ tree at matching relative paths. On the DSP side, this REPLACES the target's existing Drahbah.lua/Chochoroon.lua/Memeroon.lua, which are confirmed disabled stubs there (onTrade does nothing at all; onTrigger only plays each NPC's own intro cutscene with that snapshot's own csid -- e.g. Chochoroon's DSP csid is 0x0104/260, NOT Topaz's 7919; these differ per client generation and must NOT be changed when porting -- only onTrade needs real logic added, onTrigger's existing DSP csid call should be kept as-is).
3. appraisal.lua requires scripts/globals/npc_util and scripts/globals/zone -- both already exist natively in DSP (confirmed in this session's earlier work on the Nyzul package) -- do not port Topaz's copies of either, this package doesn't include them.
4. Restart/reimport per this codebase's own dbtool.py + map-server restart convention (Lua-only changes may still need a reimport/restart depending on this codebase's own script-cache behavior).

## Known open issues / TODOs
- Only 2 of 7 real "???" item types have confirmed reward-pool data: "??? Earring" (real retail drop weights) and "??? Box" (equal-chance placeholder across 14 items, exact retail odds not confirmed -- user's own explicit instruction was "just make it random and equal chance"). The other 5 (??? Ring/Cape/Necklace/Axe/Polearm/Headpiece/Sword/Gloves/Bow -- see appraisal.lua's `tpz.appraisal.unsupported` table) have NO pool data at all -- trading one in returns it untouched with a "cannot be appraised yet" message rather than being silently eaten. This is the main thing to build out further.
- Real client dialogue for the appraisal RESULT is not fully implemented -- the item name itself can't currently go through a real client dialogue box (CMessageSpecialPacket's item-name substitution for this specific message is unreverse-engineered in this codebase). Current compromise: a real client 'thinking' dialogue line (verified via dat-extractor, no substitution needed) followed 2 seconds later by a plain PrintToPlayer text result. See appraisal.lua's own header for the 3 approaches already tried and disproven (wrong text ids, raw special-code substitution, an LSB-style CS re-trigger that was live-tested and confirmed NOT to work on this client/server pair).
- Reward routing (solo player gets the item directly, party members go through the shared Treasure Pool) is a new, first-of-its-kind pattern in this codebase -- confirmed via source that no other existing script does this branch already, so it hasn't been cross-validated against a second real use case yet.
