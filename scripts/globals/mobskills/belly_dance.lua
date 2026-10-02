---------------------------------------------
-- Belly Dance (Lamia charm move) -- DSP port of the Topaz Ilrusi Atoll belly_dance.lua.
-- Mission 42 (Lamia No.13): charms a player in range (or, if her hate target is one of the
-- Fallen NPC allies, charms a live Fallen ally instead). Literal ids = Topaz IDs.lua ID.mob[42].
---------------------------------------------
require("scripts/globals/monstertpmoves");
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/msg");

local RANGE = 15
local FALLEN_IDS = { 17002518, 17002519, 17002520 } -- Fallen Volunteer / Imperial Wizard / Imperial Trooper

function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_CHARM_I
    local msg = msgBasic.MISS

    local instance = mob:getInstance()
    if instance then
        local hateTarget = mob:getTarget()
        local hateIsFallen = false
        if hateTarget then
            for _, fallenId in ipairs(FALLEN_IDS) do
                if hateTarget:getID() == fallenId then
                    hateIsFallen = true
                    break
                end
            end
        end

        local candidates = {}
        if hateIsFallen then
            for _, fallenId in ipairs(FALLEN_IDS) do
                local fallen = GetMobByID(fallenId, instance)
                if fallen and fallen:isAlive() and not fallen:hasStatusEffect(EFFECT_CHARM_I) then
                    table.insert(candidates, fallen)
                end
            end
        else
            for _, player in pairs(instance:getChars()) do
                table.insert(candidates, player)
            end
        end

        for _, victim in ipairs(candidates) do
            if mob:checkDistance(victim) <= RANGE then
                msg = MobStatusEffectMove(mob, victim, typeEffect, 0, 3, 150)
                if msg == msgBasic.ENFEEB_IS then
                    mob:charm(victim, 150)
                    break
                end
            end
        end
    end

    skill:setMsg(msg)
    return typeEffect
end
