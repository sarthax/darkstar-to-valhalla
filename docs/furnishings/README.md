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
