-----------------------------------
-- 
-- Zone: Yahse Hunting Grounds
-- 
-----------------------------------

require("scripts/globals/settings");
require("scripts/globals/dances_with_luopans");
package.loaded["scripts/zones/Yahse_Hunting_Grounds/TextIDs"] = nil;
require("scripts/zones/Yahse_Hunting_Grounds/TextIDs");

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
    -- Ergon Locus circle (F-6), Dances with Luopans
    zone:registerRegion(1, -447, 7, 362, 0, 0, 0);
end;

-----------------------------------
-- onZoneIn
-----------------------------------

function onZoneIn(player,prevZone)
    local cs = -1;
if ((player:getXPos() == 0) and (player:getYPos() == 0) and (player:getZPos() == 0)) then
player:setPos(361,4,-211,136);
end
    return cs;
end;

-----------------------------------
-- onRegionEnter          
-----------------------------------

function onRegionEnter(player,region)
    DWL.onLocusEnter(player); -- Dances with Luopans: Ergon Locus circles
end;

-----------------------------------
-- onRegionLeave
-----------------------------------

function onRegionLeave(player,region)
    DWL.onLocusLeave(player);
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

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

