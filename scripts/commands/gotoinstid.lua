-----------------------------------
-- func: gotoinstid
-- desc: Go to given mob or npc ID, checking your current instance first before falling back to
--       the global zone. Companion to !gotoid (which only ever does the global zone lookup and
--       will silently miss anything that only exists inside an instance, e.g. Assault mission
--       mobs/props) -- for validating real capture-derived spawn positions against what's
--       actually live in an instance without eyeballing coordinates by hand.
-----------------------------------
require("scripts/globals/status")

cmdprops =
{
    permission = 1,
    parameters = "i"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!gotoinstid <mobId|npcId>")
end

function onTrigger(player, target)

    -- validate npc
    if not target or target == 0 then
        error(player, "You must enter a mob or NPC ID.")
        return
    end

    local instance = player:getInstance()
    local scope = "global"

    -- is entity up?
    local isUp = false
    local targ = nil
    local pos0 = false

    if instance then
        targ = instance:getEntity(bit.band(target, 0xFFF), TYPE_NPC)
        if not targ then
            targ = GetMobByID(target, instance)
        end
        if targ then
            scope = "instance"
        end
    end

    if not targ then
        targ = GetNPCByID(target)
        if not targ then
            targ = GetMobByID(target)
        end
    end

    if targ then
        local pos = targ:getPos()
        pos0 = (pos.x == 0 and pos.y == 0 and pos.z == 0)
        if scope == "instance" then
            -- instance-scoped entities don't track a separate "status"/"spawned" toggle the same
            -- way global ones do -- if we found it in the instance at all and it's not sitting at
            -- the 0,0,0 placeholder, treat it as up.
            isUp = not pos0
        elseif targ:getStatus() == STATUS_NORMAL and not pos0 then
            isUp = true
        elseif targ:isSpawned() and not pos0 then
            isUp = true
        end
    end

    if not targ then
        player:goToEntity(target)
    elseif pos0 then
        player:PrintToPlayer(string.format("%s (%i) has not been given coordinates.", targ:getName(), targ:getID()))
    else
        -- determine whether we need zoneId parameter
        local gotoZone = nil
        if targ:getZoneID() ~= player:getZoneID() then
            gotoZone = targ:getZoneID()
        end

        -- display message
        local scopeLabel = (scope == "instance") and " (found in your current instance)" or " (global zone)"
        if isUp then
            player:PrintToPlayer(string.format("Going to %s (%i)%s.", targ:getName(), targ:getID(), scopeLabel))
        else
            player:PrintToPlayer(string.format("%s (%i)%s is not currently up. Going to last known coordinates.", targ:getName(), targ:getID(), scopeLabel))
        end

        -- half a second later, go.  this delay gives time for previous message to appear
        player:timer(500, function(player)
            player:setPos(targ:getXPos(), targ:getYPos(), targ:getZPos(), targ:getRotPos(), gotoZone)
        end)
    end
end
