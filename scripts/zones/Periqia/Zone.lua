-----------------------------------
--
-- Zone: Periqia
--
-----------------------------------

require("scripts/globals/settings");
require("scripts/zones/Periqia/IDs");

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
end;

-----------------------------------
-- onZoneIn
-----------------------------------

function onZoneIn(player,prevZone)
    local cs = -1;

    return cs;
end;

-----------------------------------
-- onInstanceZoneIn
-----------------------------------
-- 2026-09-15, same real dispatch bug as Lebros_Cavern/Zone.lua -- see that file's own comment for
-- the full writeup. Moved from onZoneIn (wrong hook, risked a nil-instance error via
-- player:getInstance()) to onInstanceZoneIn (real hook, guaranteed-valid instance param).

function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    player:addTempItem(5346);
end;

-----------------------------------
-- onRegionEnter
-----------------------------------

function onRegionEnter(player,region)
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

-----------------------------------
-- onEventFinish
-----------------------------------

-- 2026-09-14, live-bug audit: timeout ejection target was 79 (Caedarva Mire, an unrelated
-- overworld zone), not 56 (this zone's own real id) -- the exact real bug already documented and
-- fixed in source/scripts/zones/Periqia/Zone.lua, but that fix never made it into this checkout.
-- Corrected.
function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
    if (csid == 0x66) then
        player:setPos(0,0,0,0,56);
    end
end;

-----------------------------------
-- onInstanceFailure
-----------------------------------
-- Same real bug as onEventFinish above (79 -> 56), just never carried over to this second
-- function either. Corrected, same source as above.

function onInstanceLoadFailed()
    return 56;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-14, live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- see Ilrusi_Atoll/Zone.lua's comment for the full real explanation.
-- Real fix already existed in source/scripts/zones/Periqia/Zone.lua, never deployed here.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 56);
    end
end;
