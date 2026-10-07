---------------------------------------------------
-- Raksha: Vengeance (Hahava, Voidwatch)
-- AoE, <50% HP only [F,J]; Stun + Weakness; blocks item use not built (see UNIMPLEMENTED)
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
    local info = MobPhysicalMove(mob,target,skill,1,1.0,3.0,TP_NO_EFFECT,1,1,1);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 6);
    MobStatusEffectMove(mob, target, EFFECT_WEAKNESS, 1, 0, 120);
    return dmg;
end;
