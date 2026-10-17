# Slice: run-geo-spell-acquisition

Branch `feature/run-geo-spell-acquisition` (cut from `main` cd6be08f76). Covers every way a player obtains RUN/GEO spells,
plus any spell effects not yet modeled, with their Lua and SQL. Research: `SPELL_SOURCES_RESEARCH.md` (read first).
Rules: never invent ids (verify spell/item/csid/text ids from a fresh same-session pull); `!checknav` coordinates; run
`tools/check_sql_id_collisions.py --file <sql> --db` and `tools/check_npc_ids.py` before import.

## Workstreams
| # | Stream | Scope | Status |
|---|---|---|---|
| W1 | Geomantic Reservoirs | 30 reservoirs: 6 missing npc rows (zones 105,108,110,151,266 + 2nd in 111), fix 0,0,0 row in 102, per-zone scripts + shared `geomantic_reservoir.lua`, event 15000, text ids, level gate decision, skill-up proc | code done 2026-10-16, untested in game. No level gate (matches LSB); skill-up proc and helper entities not modeled |
| W2 | Indi- scrolls | Already stocked (Ishvad/Eukalline). Optional: secondary Orb/BCNM drop sources, Indi-Poison quest reward | verified done |
| W3 | RUN spell vendors | Audit DSP vendor stock vs wiki table (Hasim, Tya Padolih, Zafif, Brave Ox, Gekko, Regine/Kususu, Amalasanda, nation vendors...) and add missing rows | not started |
| W4 | Drops/battlefields | BCNM/mob drops for Refresh, Phalanx, Ice Spikes, Temper, Orb-gated Indi- scrolls (mob_droplist/bcnm_loot; collision-check first) | not started |
| W5 | Quests/ROE | Know One's Onions, Inside the Belly, Crusade (ROE), Indi-Poison reward | not started |
| W6 | Spell effects | Audit spell_list rows + Lua for every GEO/RUN spell (Indi/Geo/Luopan, En-, Embolden, Temper, Crusade, Foil, Spikes...); implement missing effects/status | not started |
| W7 | Verification | Live web cross-check (BG Wiki live, FFXIclopedia, wikiwiki.jp), DSP spell_list levels, in-game test plan | not started |

## Not in this slice
Unlock quests (feature/run-geo-unlock-quests), job abilities/stats (feature/run-geo-jobs), gear acquisition.

## W3 audit (2026-10-16)
- Present: Hasim Bar-element scrolls (+ra), Tya Padolih Regen/II/Baramnesia, Zafif/Brave Ox Flash, Gekko Regen IV (50,400), Ledericus Foil.
- Added: Brave Ox Crusade (item 5103, 143,451 per wiki research).
- Missing, no per-item price in offline wiki dump (do not invent): Hasim Barsleep 4680, Barpoison 4681, Barparalyze 4682, Barblind 4683, Barsilence 4684, Barpetrify 4685, Barvirus 4686; Aquaveil 4663 (Regine/Kususu 368); Blaze Spikes 4857 (Amalasanda 10,428), Shock Spikes 4859 (Hilkomu-Makimu/Mamaroon 9,000, Chutarmire 8,280); Ice Spikes 4858, Temper 4705 are drop/quest only.
- Needs live web price check (W7) before adding.
- W3 update: LSB scripts are the price baseline (landsandboat-reference). Hasim now stocks Barsleep/poison/paralyze/blind/silence/petrify/virus (+ra for five) at LSB prices. Aquaveil (Regine/Kususu) and Shock Spikes (Hilkomu, Mamaroon, Chutarmire) were already present in DSP. Fame/rank pricing: nation shops use the 3rd field as a tier and the core applies region/fame adjustments; Hasim is a flat general shop. Open: Blaze Spikes at Amalasanda (DSP guild_shops row 60416 needs min/max/stock values, LSB sells flat 10,428).

## W4 audit (2026-10-16)
- DSP already has bcnm_loot for Refresh/Ice Spikes/Phalanx: Under Observation (lootDropId 16), Jungle Boogymen (10), Amphibian Assault (156), plus Refresh/Ice Spikes in mob_droplist. No RUN/GEO-specific loot work needed for these.
- Eight LSB battlefields that drop them (Royal Succession, Steamed Sprouts, Royal Jelly, Worm's Turn, Tails of Woe, Factory Rejects, Undying Promise, Legion XI) have lootDropId 0 in DSP bcnm_info: a general BCNM loot gap, not RUN/GEO. Out of scope unless asked (LSB weights/10 = DSP rolls, one bcnm_loot group per LSB group).
- Scroll of Temper and Indi- plates dropped from Orb battlefields: LSB has NO such drop data (Indi plates only via Abyssea pyxis, ROE records, Dances with Luopans), so nothing to port; do not invent. Temper source stays open.

## W5 audit: quests and RoE (2026-10-16)
- Know One's Onions (Blaze Spikes, item 4857): present in DSP (Port_Windurst/Kohlo-Lakolo.lua adds 4857). Nothing to do.
- Inside the Belly (wiki lists Ice Spikes as a reward): DSP Zaldon.lua has no 4858 and LSB Inside_the_Belly.lua has no Ice Spikes either. Unconfirmed wiki claim; do not build without a client/capture source. Ice Spikes already drops from BCNM/mobs (W4).
- Indi-Poison: Dances with Luopans reward, already in feature/run-geo-unlock-quests.
- RoE: DSP has NO Records of Eminence system (no scripts/globals/roe*, no server support). LSB RoE records 1281-1287 are level milestones; only two give spells: GEO 75 = Plate of Indi-Frailty (1282, retro), RUN 75 = Scroll of Crusade (1286, retro). Both are also obtainable elsewhere (Indi-Frailty: Eukalline vendor; Crusade: Brave Ox, added in W3). Building RoE is a separate large feature: out of scope, no quests needed.
- Possible cheap substitute if wanted: grant the level-75 Crusade/Indi-Frailty once via a level-up hook. Not built; needs your call.

## Custom spell shop backlog (tabled 2026-10-16)
Valhalla can add spells to a custom spell shop, so these sourceless/unconfirmed spells are tabled for it rather than built from invented drops/quests:
- Scroll of Temper (4705): no LSB/DSP source (Orb battlefield drops unverified).
- Scroll of Ice Spikes (4858): only via BCNM/mob drops; wiki's Inside the Belly reward unconfirmed.
- Orb-battlefield Indi- plates (Fade/Frailty/Gravity/Malaise/Vex secondary sources): shop-sold already at Eukalline; nothing missing.
- Spells only from RoE (Indi-Frailty, Crusade): already vendor-sold; no gap.
- Regen III (RUN 70): no vendor listed on wiki.
- Eight loot-less battlefields (Refresh/Phalanx/Ice Spikes sources) remain a general BCNM gap.
- Not yet audited: En- spells, Embolden and other RUN-unique spells' sources.

## W6 spell effects audit (2026-10-16)
- Crusade (476): row re-enabled with RUN 88 (PLD 88 kept); new `spells/crusade.lua` applies EFFECT_ENMITY_BOOST power 30 / 300s (LSB params). Effect script already existed.
- Temper (493): script and EFFECT_MULTI_STRIKES already existed; spell_list RUN level set to 99 (it was 0, so RUN could not learn it).
- Foil (840): STILL BLOCKED. Row commented out; DSP has EFFECT_FOIL (568) but no SPECIAL_ATTACK_EVASION modifier (needs a C++ modifier.h entry + combat hook) and no effect script. Do not enable the row until the engine mod exists; the Ledericus scroll teaches nothing meanwhile.
- Live SQL appended to w1_live.sql. Untested in game.
- Remaining audit: Indi/Geo/Luopan, En-spells, Embolden, spikes.
