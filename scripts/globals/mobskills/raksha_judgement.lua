---------------------------------------------------
-- Raksha: Judgement (Hahava, Voidwatch)
-- Self-centred AoE, Bind/Silence/Amnesia [J] (~500-1100)
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
    local info = MobPhysicalMove(mob,target,skill,1,1.0,2.5,TP_NO_EFFECT,1,1,1);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    MobStatusEffectMove(mob, target, EFFECT_BIND, 1, 0, 30);
    MobStatusEffectMove(mob, target, EFFECT_SILENCE, 1, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_AMNESIA, 1, 0, 30);
    return dmg;
end;
