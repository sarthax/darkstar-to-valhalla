-----------------------------------
--
-- Zone: Lebros_Cavern
--
-----------------------------------

require("scripts/globals/settings");
require("scripts/zones/Lebros_Cavern/IDs");

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
-- 2026-09-15, real dispatch bug found live (same audit sweep as Nyzul_Isle/Ilrusi_Atoll's own
-- addTempItem gaps): this real content (entrypos placement + addTempItem(5345)) existed, but was
-- wired to the WRONG hook -- onZoneIn, not onInstanceZoneIn. onZoneIn fires on the base zone
-- dispatch, not specifically once the player is actually inside the created CInstance -- calling
-- player:getInstance():getEntryPos() there risked a nil-instance error (player:getInstance() has
-- no guarantee of returning a valid instance at that dispatch point), and neither
-- Leujaoam_Sanctum's nor Arrapago_Remnants's own working Zone.lua defines onZoneIn at all for this
-- exact reason -- onInstanceZoneIn is the real hook for this, called with a guaranteed-valid
-- `instance` argument directly (see luautils.cpp::OnInstanceZoneIn). Moved here unchanged
-- otherwise, using the real instance param instead of player:getInstance().

function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    player:addTempItem(5345);
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

-- 2026-09-14, live-bug audit: timeout ejection target was 61 (Mount Zhayolm, an unrelated
-- overworld zone), not 63 (this zone's own real id) -- the exact real bug already documented and
-- fixed in source/scripts/zones/Lebros_Cavern/Zone.lua, but that fix never made it into this
-- checkout. Corrected.
function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
    if (csid == 0x66) then
        player:setPos(0,0,0,0,63);
    end
end;

-----------------------------------
-- onInstanceFailure
-----------------------------------
-- Same real bug as onEventFinish above (61 -> 63), just never carried over to this second
-- function either. Corrected, same source as above.

function onInstanceLoadFailed()
    return 63;
end;

-----------------------------------
-- onInstanceCreated
-----------------------------------
-- 2026-09-14, live map-server error ("undefined procedure onInstanceCreated"): GM-command
-- fallback for !warpassault -- see Ilrusi_Atoll/Zone.lua's comment for the full real explanation.
-- Real fix already existed in source/scripts/zones/Lebros_Cavern/Zone.lua, never deployed here.

function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 63);
    end
end;