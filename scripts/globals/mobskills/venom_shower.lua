---------------------------------------------------
-- Venom Shower (Krabimanjaro)
-- Self-centred AoE water damage + Poison, then a Plague aura (BG wiki Krabkatoa; capture: used on self, anim 1778).
-- Numbers are judgement calls.
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_POISON, 20, 3, 120);
    MobStatusEffectMove(mob, target, EFFECT_PLAGUE, 5, 3, 60);

    local dmgmod = MobBreathMove(mob, target, 0.15, 5, ELE_WATER, 200);
    local dmg = MobFinalAdjustments(dmgmod,mob,skill,target,MOBSKILL_BREATH,MOBPARAM_WATER,MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    return dmg;
end;
