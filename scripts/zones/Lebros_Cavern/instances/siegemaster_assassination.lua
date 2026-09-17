-----------------------------------
-- Assault: Siegemaster Assassination
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Lebros

-----------------------------------
-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21 pattern above)
-- 8 Old Troll mobs for the assassinate mission
-----------------------------------
local MOB_GROUP_25 = {
    17035328, 17035329, 17035330, 17035331, 17035332, 17035333, 17035334, 17035335,
}

-----------------------------------
-- afterInstanceRegister
-----------------------------------

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_25_START, 25)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-----------------------------------
-- onInstanceCreated
-----------------------------------

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_25) do
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
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

-----------------------------------
-- onInstanceProgressUpdate
-----------------------------------

function onInstanceProgressUpdate(instance, progress)
    -- Boss kill mission - completion tracked by mob death, not progress threshold
end

-----------------------------------
-- onInstanceComplete
-----------------------------------

function onInstanceComplete(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 5, 10)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player, csid, option)
end
