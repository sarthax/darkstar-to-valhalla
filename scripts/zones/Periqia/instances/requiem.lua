-----------------------------------
-- Assault: Requiem
-- TODO: random the chest locations
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Periqia
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()

    player:messageSpecial(ID.text.ASSAULT_32_START, 32)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)
    for i, v in pairs(ID.mob[32]) do
        forceAggro(SpawnMob(v, instance))
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(-489.346, -9.78, -326.579, 90)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(-491.96, -9.668, -322.733, 90)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress >= 18 then
        instance:complete()
    end
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 5, 9)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

