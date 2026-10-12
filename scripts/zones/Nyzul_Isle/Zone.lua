-----------------------------------
-- 
-- Zone: Nyzul_Isle
-- 
-----------------------------------
package.loaded["scripts/zones/Nyzul_Isle/IDs"] = nil;
-----------------------------------

require("scripts/globals/keyitems");
require("scripts/globals/missions");
require("scripts/globals/settings");
require("scripts/zones/Nyzul_Isle/IDs");

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

    if (player:getXPos() == 0 and player:getYPos() == 0 and player:getZPos() == 0) then
        if (player:getCurrentMission(TOAU) == PATH_OF_DARKNESS) then
            cs = 51;
        end
    end

    return cs;
end;

-----------------------------------
-- onInstanceZoneIn
-----------------------------------
-- 2026-09-15, real gap found live: this whole function didn't exist in this file, so
-- player:addTempItem(5348) (the "Undersea Ruins Fireflies" temp item -- reused as the [4]/[6]
-- param on the real csid 201 floor-transfer call, see Rune_of_Transfer.lua's own comment) never
-- got granted at all, and instance:getEntryPos() placement never ran either. Real content ported
-- from Topaz's own Nyzul_Isle/Zone.lua onInstanceZoneIn, adapted to this engine's own bare-global
-- convention already established in Leujaoam_Sanctum/Zone.lua's onInstanceZoneIn -- including NOT
-- returning cs: DSP's real C++ dispatch (luautils.cpp::OnInstanceZoneIn) expects 0 Lua returns and
-- logs a ShowError on every single zone-in if a value is returned (confirmed against both
-- Leujaoam_Sanctum's and Arrapago_Remnants's own working onInstanceZoneIn, neither of which
-- returns anything) -- Topaz's equivalent hook tolerates/uses a return value, this engine's does
-- not, so this is NOT a straight copy-paste port despite matching content otherwise. The
-- PATH_OF_DARKNESS mission-cutscene check from this file's own onZoneIn (unreachable here since
-- Nyzul Isle is entered purely as an instance -- see the header note above) isn't duplicated for
-- the same reason: any real cs trigger would need a different mechanism than a discarded return
-- value.

function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    player:addTempItem(5348);
    player:setLocalVar("HH_FullClearDone", 0)
    player:setLocalVar("HH_PendingEjectMs", 0)
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

    if(csid == 1) then
        player:setPos(0,0,0,0,72);
    end
end;

-----------------------------------
-- onInstanceLoadFailed
-----------------------------------
-- 2026-09-14, live map-server bug: this function didn't exist at all. Real fix already existed in
-- source/scripts/zones/Nyzul_Isle/Zone.lua (never deployed) -- returns the real entrance zone id
-- (72), matching this zone's own onEventFinish above, not Nyzul_Isle's own zone id (77).

function onInstanceLoadFailed()
    return 72;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-14, live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- see Ilrusi_Atoll/Zone.lua's comment for the full real explanation.
-- Real fix already existed in source/scripts/zones/Nyzul_Isle/Zone.lua, never deployed here.
-- Unlike the 5 Assault zones (which warp back to their own shared entrance/instance zoneid),
-- Nyzul Isle Investigation's real target is 77 -- Nyzul Isle's own real, standalone zone id
-- (confirmed via sql/zone_settings.sql) -- matching the real, already-verified source content.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 77);
    end
end;

