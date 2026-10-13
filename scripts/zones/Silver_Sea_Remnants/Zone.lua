-----------------------------------
--
-- Zone: Silver_Sea_Remnants
--
-----------------------------------
require("scripts/zones/Silver_Sea_Remnants/IDs")
-----------------------------------
function onInitialize(zone)
end

function onZoneIn(player, prevZone)
    local cs = -1

    player:addTempItem(5401)

    return cs
end

function onInstanceZoneIn(player, instance)
    if not player:getInstance() then
        player:setPos(580, 0, 500, 192, 72)
        return
    end

    local pos = player:getPos()
    if pos.x == 0 and pos.y == 0 and pos.z == 0 then
        local entrypos = instance:getEntryPos()
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot)
    end
end

function onInstanceLoadFailed()
    return 72
end

function onRegionEnter(player, region)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

-----------------------------------
-- GM-command fallback for !warpassault (2026-09-04) -- mirrors Arrapago_Remnants/Zone.lua's real,
-- already-working onInstanceCreated exactly (zoneid changed to this zone's own, 76).
-----------------------------------
function onInstanceCreated(player, target, instance)
    if instance then
        player:setInstance(instance)
        player:setPos(0, 0, 0, 0, 76)
    end
end

