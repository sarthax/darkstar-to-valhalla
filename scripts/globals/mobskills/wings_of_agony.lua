---------------------------------------------
-- Wings of Agony: AoE physical, paralysis (non-removable [W]) / sleep
-- Aello (Voidwatch) skill. [C] anim id/usage from Wiggo Aello capture; effects/damage [W]/[D] flagged.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob,target,skill,1,2,2.0,TP_DMG_VARIES,1,2,3); -- [D]
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_WIND,info.hitslanded);
    MobStatusEffectMove(mob, target, EFFECT_PARALYSIS, 25, 0, 120); -- [D] power/duration
    MobStatusEffectMove(mob, target, EFFECT_SLEEP_I, 1, 0, 30);     -- [D]
    target:delHP(dmg);
    return dmg;
end;
