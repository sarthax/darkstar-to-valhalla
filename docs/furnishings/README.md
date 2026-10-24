# Furnishing acquisition audit

Tracks how every `item_furnishing` row is (or is not) obtainable on our server, with the retail
source category from the BG Wiki dump. Branch: `feature/furnishing-acquisition-audit`.

Regenerate: `py -3 tools/furnishing_acquisition_audit.py` (needs live DB + wiki dump).

Files
- `furnishing_sources.csv` - one row per furnishing: our current sources, retail tags, synth routes, status (`have_source` / `NO_SOURCE`), missing ingredients, wiki notes.
- `furnishing_recipe_ingredients.csv` - one row per recipe ingredient (synth + synergy) with our server sources; empty `our_sources` = ingredient not obtainable on our server.

Caveats
- Retail tags are keyword hints from player-written wiki text (reference only, verify before building). Wiki pages matched by `ffxidb` item id (389/389).
- `our_sources` = synth_recipes, guild_shops, mob_droplist, bcnm_loot, gardening_results, Lua shop files (`lua_shop`) or other Lua mentions (`lua_ref`, weak: unverified, not counted as a source).
- Ingredient names are resolved against `item_basic` names; unresolved names show blank id and count as missing.

Snapshot (2026-10-23): 389 furnishings, 201 have a source, 188 NO_SOURCE. Of the 188, first retail tag:
crafted 65, quest 35, goblin_box 24, npc_sale 19, event_other 13, starlight 11, harvest 10, untagged 6,
login_campaign 2, sunbreeze 2, mog_garden 1. Of the 65 crafted: 7 are craftable with ingredients we
already provide, 58 are blocked by missing ingredients (top blockers: Platinum Silk Thread, Mahogany Lumber, textile dyes, Light Chest).

## Mission Toolkit synth-module check
`furnishing_toolkit_check.csv` / `furnishing_recipe_ingredients_toolkit.csv` run every furnishing and every wiki recipe ingredient
through `workbench.server_admin.synth.recipes.Availability` (vendor, guild shop, wired drop, BCNM, craft route, script ref).
Statuses: ok / script (Lua mention only) / ah_only / missing. Ingredient names resolved by item_basic name with container prefixes stripped.

## Vendor completeness check (vs LSB, 2026-10-23)
Reference: `D:\Claude\mission_toolkit\LandSandBoat` (full tree; `FFXI-Tools/LandSandBoat` is assault-only).
- **Bibiki Bay fishing guild (Mep_Nhapopoluko, guild 519):** ours = 11 of LSB's 12 stock rows; only Moorish Idol (5121) was missing. Live DB matches repo. Patch drafted in `docs/furnishings/patch_bibiki_moorish_idol.sql` (not applied) (price 2142 min / 14280 max; stock numbers assumed). Moorish Idol is also fishable in ours (`fishing_fish`), so the toolkit "missing" was a false negative.
- **Venessa (Ru'Lude Gardens, 17772726):** ours is a stub (one `startEvent(0x2750)`). LSB also handles the 4 Promyvion ENM censers and 23 Vision/Image trades (Valorous Image -> Rheiyoh Leather, Grave -> Habu Skin, Beatific -> Tiger Eye, Ancient -> Oversized Fang, Virgin -> Super Cermet, plus 18 Vision -> earring/ring/rope/mantle). Not built: LSB uses csids 10064/10065/10066 and 10065/10066 are unverified against our client.
- **Chocobo dyes (Chocobuck vendors):** no LSB implementation exists; needs the chocobo raising work (issue #55).
- **Login campaign items (Kitchen Brick/Plate/Stove, kits):** LSB has an event system (`scripts/events/login_campaign*.lua`, Greeter Moogles); ours has none. The kitchen items are commented out in LSB's own data.

## Furnishings missing from item_furnishing (vs LSB, 2026-10-23)
Ours has 389 rows, LSB 495; 106 are missing, none are ours-only. 70 already exist in our `item_basic` (draft: `patch_item_furnishing_missing_rows.sql`, not applied; element converted to our 0-based numbering). 36 (ids 3718-3756 mostly) are not in `item_basic` at all and need client-DAT verification before anything is drafted. Full list: `furnishings_missing_vs_lsb.csv`. Two shared rows differ from LSB: 295 (moghancement 0 vs 2850) and 396 (storage 1 vs 2).

## Client DAT check of the 106 missing furnishings (read-only, 2026-10-23)
Source: `xi_tinkerer.parse_item_info` on our client `ROM/118/106.DAT` (`C:/ValhallaXI/...`). Detail: `furnishings_missing_client_check.csv`.
- **70 with an item_basic row:** all 70 exist in the client with real names (the 11 "differs" are only the client's abbreviated names, e.g. "Gr. Mahogany Bed"). The draft patch is supported by the client.
- **36 without an item_basic row:** 18 are real in our client (294 Campfire; 3718-3728 Adoulinian Tomatoes + 10 statues; 3732 Crimson Chest, 3735 Aurum Coffer, 3736-3739 Well/Doll Stand/Eastern Umbrella/Autumn Tree). The other 18 (54 and 3740-3756) are placeholder "." entries, i.e. newer than our client; do not add them.
- Not drafted: the 18 real ones need `item_basic` rows (flags, price, stack) first, which the DAT does not give; description/furnishing data are in the DAT.

## Draft: 18 new furnishings (patch only, 2026-10-23)
`patch_new_furnishings_18.sql` holds item_basic + item_furnishing INSERTs (36 rows) for the 18 furnishings real in our client but absent from our tables (294, 3718-3728, 3732, 3735-3739). Converted from LSB to our columns (NoSale from flag 4096, element 0-based). Flags, aH and BaseSell are LSB values, unverified; not applied, nothing under `sql/` changed. Obtaining them (events/Adoulin) is not covered.

## Audit follow-ups (2026-10-23, read-only)
- **17 draft recipes**: all 17 inserted into a TEMPORARY copy of synth_recipes (rolled back, live untouched). No ingredient-set collisions with live recipes, no results already present, all results exist in item_basic.
- **Draft ids vs live DB**: none of the 18-item patch ids, Moorish Idol, or the 70 missing-row ids already exist in live item_basic/item_furnishing. No collisions.
- **295 / 396**: draft `patch_item_furnishing_295_396.sql` (295 moghancement 0 -> 2850; 396 storage 1 -> 2, element 2 -> 3 earth). Not applied.
- **Not yet done**: sourcing the 40 blocked ingredients, synergy recipe drafts, remaining-vendor sweep. HQ results in the recipes still default to the NQ item (wiki lists none).

### Ingredient sourcing (2026-10-23, from furnishing_ingredient_source_xref.csv)
The 40 blocked ingredients fall into groups; none is fixed by a recipe or shop edit alone:
- **Event/campaign only** (Sunbreeze 2009-2012: Bell Cricket, Glowfly, White Butterfly, Tiny Goldfish, Goldfish Set, Comet Fragment, Cosmic Designs, Puny Planet Kit; Login Campaign: Kitchen Brick/Plate/Stove, Musichinery/Timbre Case Kit): need the event or campaign system.
- **Chocobo dyes** (Red/Blue sold by NPC for Chocobucks per wiki; Yellow/Green/Black no wiki page): tied to chocobo raising (issue #55).
- **Fishing/vendor**: Moorish Idol (Bibiki, patch already drafted), Titanic Sawfish, Betta, Black Bubble-Eye, Coral Butterfly.
- **Drops/instances**: Scintillant Ingot (Garlaige/Eldieme/Crawlers' Nest [S] monsters), Beech Lumber (instances), Rheiyoh Leather (Valorous Image exchange, Ru'Lude).
- **No wiki page / unknown** (do not guess): Aht Urhgan Brass Ingot/Sheet, Troll Bronze Ingot/Sheet, Flint Glass Sheet, Blue/Red Textile Dye, Copy of Melodious Plans, Woodworking Kits, Light Chest (chocobo digging, Cape Teriggan).

### Vendor sweep and synergy (2026-10-23, read-only)
- **NPC shop sweep (name-based)**: parsed every LSB NPC shop script's `xi.item.NAME` stock lines, resolved via `enum/item.lua`. 21 furnishings are sold by LSB NPC shops (Justi, Ensasa, Gekko, Boytz, etc.); all 21 are already referenced in our scripts or guild_shops. No NPC-shop gap found (check is by id presence, not per-NPC price/stock).
- **Synergy recipes**: only 1 furnishing has a synergy-only route, galley_kitchen (3585), and its toolkit status is blocked (missing ingredients). The server source has no synergy engine references, so no synergy recipe was drafted.

## STATUS: UNFINISHED (2026-10-23)
Analysis and draft patch SQL only. Nothing here is applied to `sql/` or the live DB, and no draft has been live-tested. Open: applying/reviewing the drafts, sourcing the 40 blocked ingredients, galley_kitchen synergy, Venessa, login campaign and chocobo dye vendors.
