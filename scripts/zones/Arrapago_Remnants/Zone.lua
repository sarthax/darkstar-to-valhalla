-----------------------------------
--
-- Zone: Arrapago Remnants
--
-----------------------------------

require("scripts/globals/settings");
require("scripts/zones/Arrapago_Remnants/IDs");

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
    zone:registerRegion(1, 420, 5, -339, 0, 0, 0)
    zone:registerRegion(2, 420, 5, -499, 0, 0, 0)
    zone:registerRegion(3, 259, 5, -499, 0, 0, 0)
    zone:registerRegion(4, 259, 5, -339, 0, 0, 0)
    zone:registerRegion(5, 340, 5, 100, 0, 0, 0)
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

    player:addTempItem(5399);
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

function onInstanceLoadFailed()
    return 72;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-16: live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- createInstance()'s ready callback is normally resolved via
-- PChar->m_event.Script, which is only ever set by a real NPC-triggered event; GM commands go
-- through commandhandler.cpp and never set it, so luautils::OnInstanceCreated (luautils.cpp:3702)
-- falls back to this zone's own Zone.lua instead, expecting a global onInstanceCreated(player,
-- target, instance) here.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 72);
    end
end;
