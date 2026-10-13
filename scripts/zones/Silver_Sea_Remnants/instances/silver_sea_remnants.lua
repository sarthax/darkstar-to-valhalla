-----------------------------------
-- Salvage: Silver Sea Remnants
-----------------------------------
-- 2026-10-01: port of LandSandBoat's Silver Sea Remnants instance, which itself only implements
-- entry (pathos, temp item, time limit), failure and exit -- LSB has NO stage/door progression for
-- this zone, and none is invented here. Floor doors (_240.._24y) and any telepad regions are
-- therefore unbuilt (see docs/project-memory work queue). Pathos and unequip match Arrapago.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
require("scripts/zones/Silver_Sea_Remnants/IDs")
-----------------------------------
local pathos =
{
    EFFECT_ENCUMBRANCE_I,
    EFFECT_OBLIVISCENCE,
    EFFECT_OMERTA,
    EFFECT_IMPAIRMENT,
    EFFECT_DEBILITATION,
}

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(SilverSea.text.TIME_TO_COMPLETE, instance:getTimeLimit())
    player:addStatusEffectEx(EFFECT_ENCUMBRANCE_I, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 6000)
    player:addStatusEffectEx(EFFECT_OBLIVISCENCE, EFFECT_OBLIVISCENCE, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_OMERTA, EFFECT_OMERTA, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_IMPAIRMENT, EFFECT_IMPAIRMENT, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_DEBILITATION, EFFECT_DEBILITATION, 0x1FF, 0, 6000)
    for i = 0, 15 do
        player:unequipItem(i)
    end
    -- temp item 5401 (S. Remnants Fireflies) is granted by Zone.lua's onZoneIn
end

function onInstanceCreated(instance)
    instance:setStage(1)
    instance:setProgress(1)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, SilverSea.text)
end

function onInstanceFailure(instance)
    for _, mob in pairs(instance:getMobs()) do
        DespawnMob(mob:getID(), instance)
    end
    for _, v in pairs(instance:getChars()) do
        v:messageSpecial(SilverSea.text.MISSION_FAILED, 10, 10)
        v:startEvent(1) -- bare call, same as Arrapago/Bhaflau/Zhayolm
    end
end

function onInstanceComplete(instance)
end

function onEventFinish(player, csid, option)
    if csid == 1 then
        for _, effect in ipairs(pathos) do
            player:delStatusEffectSilent(effect)
        end
        player:setPos(580, 0, 500, 192, ALZADAAL_UNDERSEA_RUINS)
    end
end

