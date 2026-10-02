-----------------------------------
--  Gates of Hades
--
--  Description: Deals severe Fire damage to enemies within an area of effect. Additional effect: Burn
--  Type:  Magical
--
--
--  Utsusemi/Blink absorb: Wipes shadows
--  Range: 20' radial
--  Notes: Only used when a cerberus's health is 25% or lower (may not be the case for Orthrus). The burn effect takes off upwards of 20 HP per tick.
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/monstertpmoves")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
  if(mob:getFamily() == 316) then
    local mobSkin = mob:getModelId()

    if (mobSkin == 1793) then
        return 0
    else
        return 1
    end
  end
    local result = 1
    local mobhp = mob:getHPP()

    -- 2026-09-07: CORRECTED -- real semantics confirmed against mob_controller.cpp:310:
    -- `OnMobSkillCheck(...) == 0` triggers using the skill -- 0 = valid, nonzero = invalid. This
    -- file's ORIGINAL logic (`if mobhp <= 25 then result = 0`) was already CORRECT the whole
    -- time and matched its own header ("Only used when a cerberus's health is 25% or lower") --
    -- earlier today this got inverted to `if mobhp > 25` believing 1 meant valid, which was
    -- backwards. Restored the original, correct comparison.
    if (mobhp <= 25) then
        result = 0
    end

    -- 2026-09-07: real fix -- BG Wiki (Nyzul Isle Investigation): "The floor 100 bosses, unlike
    -- at floors 60 and 80, can use their families' signature low-health desperation moves... only
    -- start to be used once their health is lowered to approximately 25-33%." Scoped to Nyzul's
    -- own Cerberus only (getZoneID check) -- Sarameya/Orthrus have no "floor" concept and keep
    -- their real, un-gated HP-threshold behavior above. Correct semantics: force back to invalid
    -- (1) if the base HP condition passed (0) but we're in Nyzul on the wrong floor.
    if (result == 0 and mob:getZoneID() == NYZUL_ISLE) then
        local instance = mob:getInstance()
        local floor = instance and instance:getLocalVar("Nyzul_Current_Floor")
        if (not floor or floor ~= 100) then
            result = 1
        end
    end

    return result
end

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_BURN
    local power = 21

    MobStatusEffectMove(mob, target, typeEffect, power, 3, 60)

    local dmgmod = 1.8
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*6, ELE_FIRE, dmgmod, TP_NO_EFFECT)
    -- DSP-PORT-MERGE: tpz.attackType.MAGICAL/tpz.damageType.FIRE -> DSP's own MOBSKILL_MAGICAL/
    -- MOBPARAM_FIRE (FIRE happens to match numerically, but mapped by NAME for consistency with
    -- fulmination.lua's LIGHTNING case, which does NOT match by number -- see NAMESPACE_TRANSLATION.md).
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_FIRE, MOBPARAM_WIPE_SHADOWS)
    -- DSP-PORT-MERGE: DSP has no takeDamage binding at all -- real convention is delHP(dmg).
    target:delHP(dmg)
    return dmg
end

