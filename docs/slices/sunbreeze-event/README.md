# sunbreeze-event

Sunbreeze 2021 Superheroine Stage Show add-on for Windurst Walls (default off: `SUNBREEZE_2021_ADDON = 0` in settings). Show module, hourly schedule (`onGameHour`), Mumor / Uka Totlihn / Wahboud casts, event Moogle, curtain-call animations, and install/uninstall SQL. Details: `docs/slices/sunbreeze-2021-addon/README.md`.

## Dependency: emote hook (engine)
Audience emotes reach the add-on through `onPlayerEmote` in `scripts/globals/player.lua` (added here). The C++ side that calls it (`luautils::OnPlayerEmote`, fired from `SmallPacket0x05D`) is part of the heroines-holdfast slice (commit 29fa97f139), not this one. Without it the show still runs but audience emote input is inert.

## SQL
`sql/slices/sunbreeze-2021-addon/stage_show_npcs_windurst_walls.sql` (install) and `_UNINSTALL.sql`; `hide_city_symphonic_curator.sql` hides the city Symphonic Curator during the event. Windurst Walls npc rows used by the cast already exist in `npc_list.sql`; the install SQL adds the stage props/vendors. Run by hand, not part of the base import.
