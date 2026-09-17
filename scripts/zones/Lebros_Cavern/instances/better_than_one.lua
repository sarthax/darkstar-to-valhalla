-----------------------------------
-- Assault: Better Than One
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros

-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21 pattern above)
-- Boss + ambient Inferno obstacles
local MOB_GROUP_30 = {
    -- 1 Boss: Black Shuck
    17035470, -- BLACK_SHUCK
    -- 6 Nocuous Inferno obstacle mobs (ambient, unscripted)
    17035471, 17035472, 17035473, 17035474, 17035475, 17035476,
}

-----------------------------------
-- afterInstanceRegister
-----------------------------------

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_30_START, 30)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-----------------------------------
-- onInstanceCreated
-----------------------------------

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_30) do
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
    -- Boss kill mission - only Black Shuck's death completes the instance
    -- The ambient Infernos don't contribute to progress
end

-----------------------------------
-- onInstanceComplete
-----------------------------------

function onInstanceComplete(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 9, 10) -- K-10 area
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
