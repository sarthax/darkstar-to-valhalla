# Voidwatch mechanics digest (BG Wiki, scraped 2026-10-06)

**All [W] — wiki claims, reference only, NOT verified against client/captures.** Raw pages: `research/wiki_raw/`
(`Category_Voidwatch.wiki` = main mechanics page; also Weaknesses, Guide, Quests, Atmacite/Periapt categories, Phase Displacer,
Voiddust, Cruor, Provenance(+Watcher), Kupofried's corundum, Cells, Revitalizer, Treasure Hunter, Atmacite Refiner, Kaggen, Modron).
Fetched via `research/fetch_wiki_pages.py` (MediaWiki API, redirects=1).

## Entry requirements
- Lv75+, Adventurer's Certificate (rank 3+), any stratum abyssite KI. Only the **initiator** needs abyssite tier >= battle tier.
- Abyssites from Officers (Crimson=San d'Oria, Indigo=Bastok, Jade=Windurst; incl. [S] cities); White via quest *Drafted by the Duchy*
  (after all 3 city paths); Ashen=Kieran (Norg), Hyacinth=Owain (Tavnazian Safehold), Amber=Camille (Wajaom Woodlands).
- Tier advance: Atmacite Refiner NPC (crimson/indigo/jade/white I->II, IV->V) or quest progression (white II->III, III->IV, V->VI; ashen/hyacinth/amber).
  Credit only counts if abyssite is at the correct tier *when the NM dies*.
- **Voidstone** KI: needed per participant for loot/KI/periapt/alignment-scaled exp+cruor. 1 per 20h (12h w/ 2 Periapts of Exploration),
  unlimited stock on Officer, starts on first Officer talk at 75+. Trade 1 Voiddust -> voidstone KI. Stock-consumption setting (2016) via Officer menu, default off.
  Non-voidstone members still get base exp/cruor + abyssite credit.
- Provenance uses Kupofried's corundum (4 Crystal Petrifacts) instead of voidstone.

## Battle procedure
- Examine one of 3 Planar Rifts (choice irrelevant). Trade Phase Displacer (Ardrick, Jugner Forest) -> Void cluster; up to 5, initiator only; each weakens NM (~ -5 lvl each; "5 = -25").
- On start: voidstone consumed per participant, full HP/MP restore to alliance, periapt-granted temp items, **30 min limit**.
- Zilart fights have multiple enemies, only primary must die.
- **Voidwatcher status (475)**: lost if >~50' from rift (warning first), or NM unclaimed/no hate ~15-30s (NM despawns). Not lost on disconnect.
  Non-voidwatchers cannot participate in any way (no healing/raising).
- Success -> **Riftworn Pyxis** at rift position for 3 min (or until all done), then Rift respawns. Each player examines for own loot.

## Weaknesses / stagger (see Voidwatch_Weaknesses.wiki, full trigger tables)
- Per battle: 6 normal, 2 high, 1 extreme weakness, random from JA/pet/WS/spell tables. Replaced with same-tier trigger after hit; extreme once only.
  Hints via Periapts (guidance/percipience/sapience/clarity). `/fume` by hate target after 5 min rerolls set (30s w/ Rhapsody in Mauve). Gasha & Nympha Eunomia reroll per spawn phase.
- Hit effects: alignment up, cumulative NM atk/matk down, restore temp items, stagger (5/20/30 s, additive), Synchronic Blitz window.
  Hit during NM TP move/cast = bigger bonus (window shrinks on high tiers; none on Bismarck/Morta).
- Provenance: no alignment, no blitz.

## Spectral alignment (red=item quality, blue=item quantity, green=cruor, yellow=exp, white=periapt/atmacite chance)
- Base 100% (R/B/G/Y), 0% white. Caps: stagger+blitz R/B 350, G/Y 225, W 100; ascent cells (Rubicund R, Cobalt B +150 each cap150;
  Jade G, Xanthous Y +75 cap75) + Treasure Hunter (1%/level, multiplicative) -> R/B 500, G/Y 300; Periapts (Glory/Concentration +25, Intensity/Focus +12.5 each) -> max R/B 550, G/Y 325, W 100.
- Per-hit values table in main page lines ~307-493 (normal magic 20/40%, JA/WS 20/40%, high 100/200%, extreme 250%/125%/100%).
## Rewards
- Exp & cruor base by region/tier (City 5000-6500, Jeuno 6000-10000, Zilart 5000/7000-8000, AU/Tavnazia 7500-10000), x green/yellow alignment, only if voidstone used.
- Items: blue% -> count (100%/item, remainder = chance of +1); red% -> chance of the NM's rare/rare-ex drop (always top slot, max one);
  white% = chance of the NM's Periapt/Atmacite (all voidstone users in the alliance); Crystal Petrifacts common; petrifact KIs (Beguiling/Maddening/Seductive) rare, alignment-independent.
- Pulse Panoplia: "obtain as pulse cell" option; 5 cells -> Ardrick; requires NM title.
- Provenance: periapt/atmacite immediate, items from Glimmering Trove.

## Implication for design (Phase 2 input)
Per-participant state needed: voidstone stock + timestamp, abyssite tier per path + per-tier kill credit, alignment accumulators (5), temp-item restore,
weakness set (9 triggers incl. hooks for spells/WS/JA/pet), stagger+blitz damage tracking, treasure hunter, periapt/atmacite KI ownership.
Heavy engine-hook surface (onUseAbility/WS/spell-cast-on-mob hooks, mob TP-ready timing). Cruor + KI + temp item infra partially exists from Abyssea.
