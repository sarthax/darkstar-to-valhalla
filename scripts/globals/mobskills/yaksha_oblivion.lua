---------------------------------------------------
-- Yaksha: Oblivion (Hahava, Voidwatch)
-- AoE all-stats down, <50% HP only [F,J]; unelemental physical
-- Evidence: [J wikiwiki.jp Hahava, F FFXIclopedia]; damage/durations [D] (see docs/voidwatch/UNIMPLEMENTED.md)
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob,target,skill,1,1.0,2.0,TP_NO_EFFECT,1,1,1);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    MobStatusEffectMove(mob, target, EFFECT_STR_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_DEX_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_VIT_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_AGI_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_INT_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_MND_DOWN, 20, 0, 120);
    MobStatusEffectMove(mob, target, EFFECT_CHR_DOWN, 20, 0, 120);
    return dmg;
end;
