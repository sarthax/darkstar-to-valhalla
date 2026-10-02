-----------------------------------
-- 
-- Zone: Ilrusi_Atoll
--  zone 55
-----------------------------------

require("scripts/globals/settings");
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/settings");
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

   --------------RANDOMIZE COFFER------------------------
  local correctcoffer = math.random(17002505,17002516);
  SetServerVariable("correctcoffer",correctcoffer);
  -- DEBUG (disabled): printf("corect_golden_salvage_coffer: %u",correctcoffer);
  ---------------------------------------------------
  
 
    return cs;
end;

-----------------------------------
-- onInstanceZoneIn
-----------------------------------
-- 2026-09-15, real gap found live (same class of bug as Nyzul_Isle/Zone.lua -- see that file's own
-- comment for the full writeup): this whole function didn't exist here, so player:addTempItem(5347)
-- never fired and instance:getEntryPos() placement never ran on entering this zone's instance.
-- Ported from Topaz's own Ilrusi_Atoll/Zone.lua onInstanceZoneIn, adapted to this engine's real
-- bare-global convention (no return value -- see Nyzul_Isle/Zone.lua's comment for why).

function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    player:addTempItem(5347);
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
        player:setPos(0,0,0,0,55);
    end
end;

-----------------------------------
-- onInstanceLoadFailed
-----------------------------------
-- 2026-09-14, live map-server bug: this function didn't exist at all, so an instance-creation
-- failure had no real ejection target. Real fix already existed in
-- source/scripts/zones/Ilrusi_Atoll/Zone.lua (never deployed) -- returns this zone's own real id.

function onInstanceLoadFailed()
    return 55;
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
-- source/scripts/zones/Ilrusi_Atoll/Zone.lua (never deployed) -- was never missing logic, just
-- never actually shipped to this checkout.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 55);
    end
end;

