-----------------------------------
-- Assault: Egg Conservation
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros

-----------------------------------
-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21 pattern above)
-- 6 Qiqirn Egglers mobs
-----------------------------------
local MOB_GROUP_28 = {
    17035396, 17035397, 17035398, 17035399, 17035400, 17035401,
}

-----------------------------------
-- afterInstanceRegister
-----------------------------------

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_28_START, 28)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-----------------------------------
-- onInstanceCreated
-----------------------------------

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_28) do
        SpawnMob(v, instance)
    end

    -- Set up Rune of Release and Ancient Lockbox at standard positions
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(49.999, -40.837, 96.999, 0)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(50.000, -40.070, 99.999, 0)
end

-----------------------------------
-- onInstanceTimeUpdate
-----------------------------------

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

-----------------------------------
-- onInstanceFailure
-----------------------------------

function onInstanceFailure(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

-----------------------------------
-- onInstanceProgressUpdate
-----------------------------------

function onInstanceProgressUpdate(instance, progress)
    -- Kill-all-6 mechanic: completion threshold is when all egglers are dead
    if progress >= 6 then
        instance:complete()
    end
end

-----------------------------------
-- onInstanceComplete
-----------------------------------

function onInstanceComplete(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 5, 10)
    end

    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setStatus(STATUS_NORMAL)
    box:setStatus(STATUS_NORMAL)
end

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player, csid, option)
end
