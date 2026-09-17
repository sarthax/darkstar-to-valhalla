-----------------------------------
-- Assault: Operation: Black Pearl
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Lebros

-----------------------------------
-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21 pattern above)
-- Boss + trash mobs for the boss-kill mission
-----------------------------------
local MOB_GROUP_29 = {
    -- 1 Boss
    17035402, -- JORPORBOR_THE_HELLRAKER
    -- 4 Troll Combatant mobs
    17035403, 17035404, 17035405, 17035406,
    -- 20 Wamouracampa mobs (level range based)
    17035407, 17035408, 17035409, 17035410, 17035411, 17035412, 17035413, 17035414,
    17035415, 17035416, 17035417, 17035418, 17035419, 17035420, 17035421, 17035422,
    17035423, 17035424, 17035425, 17035426,
    -- 20 Crimson Eruca mobs
    17035427, 17035428, 17035429, 17035430, 17035431, 17035432, 17035433, 17035434,
    17035435, 17035436, 17035437, 17035438, 17035439, 17035440, 17035441, 17035442,
    17035443, 17035444, 17035445, 17035446,
    -- 20 Vulcanian Bomb mobs
    17035447, 17035448, 17035449, 17035450, 17035451, 17035452, 17035453, 17035454,
    17035455, 17035456, 17035457, 17035458, 17035459, 17035460, 17035461, 17035462,
    17035463, 17035464, 17035465, 17035466,
}

-----------------------------------
-- afterInstanceRegister
-----------------------------------

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_29_START, 29)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-----------------------------------
-- onInstanceCreated
-----------------------------------

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_29) do
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
    -- Boss kill mission - only the boss's death completes the instance
    -- Progress is tracked by the boss's mob object via onMobDeath hooks
end

-----------------------------------
-- onInstanceComplete
-----------------------------------

function onInstanceComplete(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 7, 8) -- J-9 area
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
