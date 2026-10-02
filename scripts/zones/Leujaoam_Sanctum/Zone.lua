-----------------------------------
--
-- Zone: Leujaoam_Sanctum
--
-----------------------------------

require("scripts/globals/settings");
require("scripts/zones/Leujaoam_Sanctum/IDs");

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
end;

-----------------------------------
-- onInstanceZoneIn
-----------------------------------

function onInstanceZoneIn(player,instance)
    local cs = -1;

    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

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
    if (csid == 0x66) then
        player:setPos(0,0,0,0,79);
    end
end;

-----------------------------------
-- onInstanceFailure
-----------------------------------
-- 2026-09-14, live-bug audit: was 79 (Caedarva Mire, an unrelated overworld zone), not 69 (this
-- zone's own real id) -- the exact real bug already documented and fixed in
-- source/scripts/zones/Leujaoam_Sanctum/Zone.lua, but that fix never made it into this checkout.
-- Corrected.

function onInstanceLoadFailed()
    return 69;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-14, live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- createInstance()'s ready callback is normally resolved via
-- PChar->m_event.Script, which is only ever set by a real NPC-triggered event; GM commands go
-- through commandhandler.cpp and never set it, so luautils::OnInstanceCreated (luautils.cpp:3702)
-- falls back to this zone's own Zone.lua instead, expecting a global onInstanceCreated(player,
-- target, instance) here. Real fix already existed in
-- source/scripts/zones/Leujaoam_Sanctum/Zone.lua (never deployed) -- was never missing logic,
-- just never actually shipped to this checkout.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 69);
    end
end;