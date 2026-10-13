
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
-- 2026-09-05: real fix -- REVISED with real ground-truth confirmation. _22h has no real
-- descriptive name at all in our own client data -- its actual name is the literal string "_22h",
-- unlike every genuine door in this zone (all of which are really named "Gilded Doors"). Per user's
-- read (confirmed by that naming anomaly): this is not a door itself, it's the passive mechanism/
-- hinge piece that animates alongside the real door (_22i, "Gilded Gateway"). Not independently
-- clickable -- no onTrigger CS logic of its own. Animated/locked from _22i.lua's own onEventFinish.
function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result, door)
end

