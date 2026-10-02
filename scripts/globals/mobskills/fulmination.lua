-----------------------------------
-- Fulmination
--
-- Description: Deals heavy magical damage in an area of effect. Additional effect: Paralysis + Stun
-- Type: Magical
-- Utsusemi/Blink absorb: Wipes Shadows
-- Range: 30 yalms
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    if(mob:getFamily() == 316) then
        local mobSkin = mob:getModelId()

        if (mobSkin == 1805) then
            return 0
        else
            return 1
        end
    end
    local family = mob:getFamily()
    local mobhp = mob:getHPP()
    local result = 1

    -- 2026-09-07: CORRECTED (the real, final fix) -- confirmed directly against
    -- mob_controller.cpp:310: `OnMobSkillCheck(...) == 0` is what triggers actually USING the
    -- skill -- 0 = valid, any nonzero = invalid. Every earlier pass on this file today (the
    -- "inversion fix," the "floor gate," even the debug-crash investigation) was built on the
    -- OPPOSITE assumption (1 = valid), so `result` ended up meaning "invalid" in the code but
    -- "valid" to the real engine -- live-confirmed: fired at 89% HP, nowhere near the intended
    -- <=37% threshold, because a "blocked" result of 1 was actually being read as valid. Default
    -- is now 1 (invalid); the real HP condition sets 0 (valid) only when it should fire.
    if (family == 168 and mobhp <= 37) then -- Khimaira <= 37%
        result = 0
    elseif (family == 315 and mobhp <= 50) then -- Tyger <= 50%
        result = 0
    end

    -- 2026-09-07: real fix -- BG Wiki (Nyzul Isle Investigation): "The floor 100 bosses, unlike
    -- at floors 60 and 80, can use their families' signature low-health desperation moves...
    -- only start to be used once their health is lowered to approximately 25-33%." Scoped to
    -- Nyzul's own Khimaira only (getZoneID check) -- every other family-168 mob above keeps its
    -- real, un-gated HP-threshold behavior. Correct semantics: force back to invalid (1) if the
    -- base HP condition passed (0) but we're in Nyzul on the wrong floor.
    local zoneid = mob:getZoneID()
    local instance = mob:getInstance()
    local floor = instance and instance:getLocalVar("Nyzul_Current_Floor")
    if (result == 0 and zoneid == NYZUL_ISLE) then
        if (not floor or floor ~= 100) then
            result = 1
        end
    end

    return result
end

function onMobWeaponSkill(target, mob, skill)

-- TODO: Hits all players near Khimaira, not just alliance.

    local dmgmod = 3
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 4, ELE_THUNDER, dmgmod, TP_MAB_BONUS, 1)
    -- DSP-PORT-MERGE: tpz.attackType.MAGICAL/tpz.damageType.LIGHTNING -> DSP's own MOBSKILL_MAGICAL/
    -- MOBPARAM_THUNDER (by NAME, not number -- DSP's elemental numbering diverges from Topaz's past
    -- FIRE/LIGHT/DARK; Topaz's LIGHTNING=10 would silently become DSP's own ICE=10 if ported by
    -- number, confirmed by tracing a real DSP mobskill -- see NAMESPACE_TRANSLATION.md).
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_THUNDER, MOBPARAM_WIPE_SHADOWS)
    MobStatusEffectMove(mob, target, EFFECT_PARALYSIS, 40, 0, 60)
    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 4)

    -- DSP-PORT-MERGE: DSP has no takeDamage binding at all -- real convention is delHP(dmg)
    -- after MobFinalAdjustments has already applied resist/absorb (see NAMESPACE_TRANSLATION.md).
    target:delHP(dmg)
    return dmg
end

