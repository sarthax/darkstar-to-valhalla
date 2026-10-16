---------------------------------------------
--  Chilling Roar
--
--  Voidwalker NM Yilbegan. Ice breath with Paralyze.
--  Damage numbers are DESIGN GUESSES (not wiki-sourced); tune after testing.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_PARALYSIS, 25, 0, 120);
    local dmgmod = MobBreathMove(mob, target, 0.333, 0.625, ELE_ICE, 500);
    local dmg = MobFinalAdjustments(dmgmod,mob,skill,target,MOBSKILL_BREATH,MOBPARAM_ICE,MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    return dmg;
end;
