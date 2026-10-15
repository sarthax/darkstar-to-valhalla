# Mercenary Rank Promotions (PSC/PFC/SP/LC) - Shared Assault Infrastructure Package

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 23 files: DSP-converted Lua scripts (deploy these)
- `sql/` -- 1 files: Topaz-format SQL, still LIVE in this package (no `sql-dsp/` conversion exists yet)
- `archive-topaz/` -- 28 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (28)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The shared Whitegate mercenary-rank promotion system (Naja Salaheem's PSC/PFC/SP granting, the real Lance Corporal questline across 3 zones, the Warhorse Hoofprint SP/Corporal trial across 4 zones) plus the 5 real per-zone Assault mission-giver+shop NPCs. Packaged separately from any single zone's Assault missions because this content is genuinely zone-agnostic shared infrastructure -- every per-zone Assault package (Leujaoam Sanctum, Mamool Ja Training Grounds, Lebros Cavern, Periqia, Ilrusi Atoll) depends on it, and it should be applied once, not duplicated per zone. Rune_of_Release.lua (the promotion-point-awarding mission-exit NPC) is deliberately NOT included here despite calling into this package's capPromotionPoints -- it lives inside each Assault zone's own instance flow, reads that zone's own IDs.lua/currency constants, and its BASE_ASSAULT_POINTS table covers that zone's own full 10-mission list -- so it belongs in each zone's own Assault package, not here. 'Calls a shared function' was the wrong test for what belongs in a shared package; 'lives inside a to-be-packaged Assault zone and depends on that zone's own instance/mission content' is the right one.

## Contents
- `lua/` — 28 Lua scripts
- `sql/` — row-level extracts: npc_list (25)
- (no C++ reference included)
- `navmesh/` — none
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
This is a shared-infrastructure package, not a standalone mission -- apply it ONCE to the target engine, before or alongside the first per-zone Assault package that needs it (Leujaoam Sanctum, Mamool Ja Training Grounds, Lebros Cavern, Periqia, Ilrusi Atoll).
1. Import sql/npc_list.sql -- 25 rows: 8 Whitegate hub NPCs (Naja Salaheem/Abquhbah/Nafiwaa/Yahsra/Isdebaaq/Famad/Lageegee/Bhoy Yhupplo), 12 Warhorse Hoofprint rows across 4 zones, 5 Mythralline Wellspring rows (4 Wajaom Woodlands + 1 Bhaflau Thickets).
2. Copy lua/ into the target scripts/ tree at matching relative paths.
3. Each per-zone Assault package's own IDs.lua (delivered separately, not duplicated here) must define ASSAULT_POINTS_OBTAINED and that zone's own <ZONE>_ASSAULT_POINT constant, since Yahsra/Isdebaaq/Famad/Lageegee/Bhoy_Yhupplo reference their own zone's text/point constants.
3b. Rune_of_Release.lua (the mission-completion/exit NPC that actually calls capPromotionPoints) is NOT part of this package -- it lives inside each Assault zone's own instance flow and ships with that zone's own Assault package instead, alongside its own real npc_list.sql row and IDs.lua. This package only provides the shared besieged.lua function it calls into.
4. On the DSP backport side: besieged.lua should NOT be ported wholesale (DSP already has its own independently-evolved besieged.lua covering getMercenaryRank/getAssaultRank/badges identically) -- only the NEW tpz.besieged.capPromotionPoints/canPromote/promoteRank/warhorseHoofprintTrigger functions need adding to DSP's own file. Rytaal.lua (the Imperial Army I.D. Tag distributor every giver in this package gates on) also does NOT need porting -- DSP's own copy is already a complete, working implementation, confirmed by direct file read (see mission-packages/nyzul_isle_investigation/lua-dsp/MERGE_DECISIONS.md's Rytaal entry for the full verification).
5. Restart/reimport per this codebase's own dbtool.py + map-server restart convention.

## Known open issues / TODOs
- SP promotion (Dark Rider hoofprint) and Corporal promotion (Quartz Transmitter) are both granted via examining any Warhorse_Hoofprint object -- deliberately simplified from retail (which has exactly ONE hoofprint active server-wide at a time, following one wide-roaming Dark Rider NM across 20+ real zones on a day/night spawn timer). This implementation keeps all 3 real hoofprint spots in all 4 zones this session has real positions for permanently active instead, per explicit user decision to make the trial findable within a practical quest window. The Dark Rider NM itself is not implemented (purely cosmetic/optional per user decision, not required for either promotion).
- Corporal's own promotion quest (the actual quest that sets PromotionCorporal=1 and gates on QUARTZ_TRANSMITTER) does not exist in this codebase yet -- Naja_Salaheem.lua's own comments confirm LC-Captain has no real implementation. The Corporal branch in besieged.lua's warhorseHoofprintTrigger is wired per the real wiki text so nothing needs to change here once that quest is eventually built, but it can never fire yet.
- LC (Lance Corporal) quest requires real-time gating (a full Vana'diel day wait + zoning out and back into Whitegate) -- this is real, verified content (Abquhbah.lua/lance_corporal_common.lua), not a placeholder, but worth calling out as a real multi-session quest, not a single-sitting interaction.
