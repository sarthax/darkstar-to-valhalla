# Campaign Operations (WORK IN PROGRESS)
Housing branch for Campaign Ops work; just started, expect more commits.

Done so far:
- `scripts/globals/campaign.lua`; [S] zone NPC scripts (Southern San d'Oria [S] x15, Bastok Markets [S] x2, Windurst Waters [S] x2)
- `GetCampaignValue` / `SetCampaignValue` Lua bindings (luautils; table/column whitelist for campaign_nation / campaign_map)
- 0x071 campaign map packet filled from DB (`src/map/packets/campaing_map.cpp`, falls back to static retail snapshot if tables incomplete)
- `ALLIED_SIGIL` TextID lines for the three [S] zones (kept here, not in textids-sweep)
- SQL import scripts: `sql/slices/campaign-ops/campaign_map.sql`, `campaign_nation.sql`

Needs C++ rebuild + map-server restart. Not tested in game.
