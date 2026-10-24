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
