-----------------------------------
--
-- Zone: Zhayolm_Remnants
--
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
-----------------------------------
-- Telepad regions mirror LSB's trigger areas 1-13 (Topaz: registerRegion(id, x, RADIUS, z, ...)).
function onInitialize(zone)
    zone:registerRegion(1, 420, 5, -340, 0, 0, 0)
    zone:registerRegion(2, 420, 5, -500, 0, 0, 0)
    zone:registerRegion(3, 260, 5, -500, 0, 0, 0)
    zone:registerRegion(4, 260, 5, -340, 0, 0, 0)
    zone:registerRegion(5, 340, 5, -60, 0, 0, 0)
    zone:registerRegion(6, 340, 5, 420, 0, 0, 0)
    zone:registerRegion(7, 340, 5, 500, 0, 0, 0)
    zone:registerRegion(8, -380, 5, -620, 0, 0, 0)
    zone:registerRegion(9, -300, 5, -460, 0, 0, 0)
    zone:registerRegion(10, -340, 5, -100, 0, 0, 0)
    zone:registerRegion(11, -340, 5, 140, 0, 0, 0)
    zone:registerRegion(12, -380, 5, 500, 0, 0, 0)
    zone:registerRegion(13, -380, 5, 500, 0, 0, 0)
end

function onZoneIn(player, prevZone)
    local cs = -1

    return cs
end

function onInstanceZoneIn(player, instance)
    if not player:getInstance() then
        player:setPos(-580, 0, -433, 64, 72)
        return
    end

    local pos = player:getPos()
    if pos.x == 0 and pos.y == 0 and pos.z == 0 then
        local entrypos = instance:getEntryPos()
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot)
    end

    player:addTempItem(5398)
end

function onInstanceLoadFailed()
    return 72
end

-- Region logic lives in instances/zhayolm_remnants.lua (instance handlers take priority).
function onRegionEnter(player, region)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

-----------------------------------
-- GM-command fallback for !warpassault (2026-09-04) -- mirrors Arrapago_Remnants/Zone.lua's real,
-- already-working onInstanceCreated exactly (zoneid changed to this zone's own, 73).
-----------------------------------
function onInstanceCreated(player, target, instance)
    if instance then
        player:setInstance(instance)
        player:setPos(0, 0, 0, 0, 73)
    end
end

