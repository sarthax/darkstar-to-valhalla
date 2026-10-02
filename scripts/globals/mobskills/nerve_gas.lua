-----------------------------------
-- Nerve Gas
--
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- Description: Inflicts curse and powerful poison tpz.effect.
-- Type: Magical
-- Wipes Shadows
-- Range: 10' Radial
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)

    if (mob:getFamily() == 316) then -- PW
        local mobSkin = mob:getModelId()
        if (mobSkin == 1796) then
            return 0
        else
            return 1
        end
    elseif (mob:getFamily() == 313) then -- Tinnin can use at will
        return 0
    else
        -- 2026-09-07: real fix -- this fallback branch's only real consumer is Nyzul Isle's
        -- Hydra (mob_skill_lists.sql: family 316=Alfard and 313=Tinnin are handled above; Hydra
        -- falls through to here). It gated on getAnimationSub()==0, and nothing in Hydra.lua ever
        -- sets that substate -- meaning it was permanently valid (0 = valid, confirmed against
        -- mob_controller.cpp:310) with no real HP/floor gating at all. Replaced with BG Wiki's
        -- real gating (Nyzul Isle Investigation): "The floor 100 bosses, unlike at floors 60 and
        -- 80, can use their families' signature low-health desperation moves... only start to be
        -- used once their health is lowered to approximately 25-33%."
        -- 2026-09-07 (later): CORRECTED -- this whole branch was written backwards the first
        -- time (returning 0/valid when a condition FAILED, 1/invalid only when everything
        -- passed) -- exactly inverted from real semantics. Fixed: 0 = valid only when all three
        -- conditions hold, 1 = invalid otherwise.
        if (mob:getZoneID() ~= NYZUL_ISLE) then
            return 1
        end

        if (mob:getHPP() > 25) then
            return 1
        end

        local instance = mob:getInstance()
        local floor = instance and instance:getLocalVar("Nyzul_Current_Floor")
        if (not floor or floor ~= 100) then
            return 1
        end

        return 0
    end

end

function onMobWeaponSkill(target, mob, skill)

    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_CURSE_I, 50, 0, 420))
    MobStatusEffectMove(mob, target, EFFECT_POISON, 20, 3, 60)
    return EFFECT_CURSE_I
end

