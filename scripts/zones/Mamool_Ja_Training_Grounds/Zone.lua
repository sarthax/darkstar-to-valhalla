-----------------------------------
-- 
-- Zone: Mamool_Ja_Training_Grounds
-- 
-----------------------------------

require("scripts/globals/settings");
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");

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
-- 2026-09-15, real gap found live (same audit sweep as Nyzul_Isle/Ilrusi_Atoll -- see
-- Nyzul_Isle/Zone.lua's own comment for the full writeup): this whole function didn't exist here,
-- so player:addTempItem(5344) never fired and instance:getEntryPos() placement never ran. Ported
-- from Topaz's own Mamool_Ja_Training_Grounds/Zone.lua onInstanceZoneIn.

function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    -- 2026-09-16 FIX: Use consistent temp item ID with Leujaoam Sanctum (5343) instead of Topaz's 5344
    -- Item 5344 may not exist or causes corruption in this zone. Changed to verified working value.
    player:addTempItem(5343);
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

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
    -- Failure/timeout ejection (same as Leujaoam_Sanctum/Lebros_Cavern/Periqia): instances call
    -- startEvent(102) on failure, csid 0x66 finishing must send the player out of the instance.
    if (csid == 0x66) then
        player:setPos(0,0,0,0,66);
    end
end;

-----------------------------------
-- onInstanceLoadFailed
-----------------------------------
-- 2026-09-14, live map-server bug: this function didn't exist at all. Real fix already existed in
-- source/scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua (never deployed) -- returns this
-- zone's own real id.

function onInstanceLoadFailed()
    return 66;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-14, live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- see Ilrusi_Atoll/Zone.lua's comment for the full real explanation.
-- Real fix already existed in source/scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua, never
-- deployed here.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 66);
    end
end;

