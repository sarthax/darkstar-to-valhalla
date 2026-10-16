-----------------------------------
-- 
-- Zone: Ceizak Battlegrounds
-- 
-----------------------------------

require("scripts/globals/settings");
require("scripts/globals/dances_with_luopans");
package.loaded["scripts/zones/Ceizak_Battlegrounds/TextIDs"] = nil;
require("scripts/zones/Ceizak_Battlegrounds/TextIDs");

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
    -- Ergon Locus circles (K-10 and I-8), Dances with Luopans
    zone:registerRegion(1, 357, 11, -250, 0, 0, 0);
    zone:registerRegion(2, 87, 8, 72, 0, 0, 0);
end;

-----------------------------------
-- onZoneIn
-----------------------------------

function onZoneIn(player,prevZone)
    local cs = -1;
if ((player:getXPos() == 0) and (player:getYPos() == 0) and (player:getZPos() == 0)) then
player:setPos(431,0,178,110);
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

