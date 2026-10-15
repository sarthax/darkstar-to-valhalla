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
    if (mob:getLocalVar("VW_DEADLINE") == 0) then return 1; end -- Voidwatch-only: base mobs sharing this skill stay inert (no Lua existed before VW)
    return (mob:getHPP() < 50) and 0 or 1; -- <50% HP only [F,J]
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob,target,skill,1,1.0,3.0,TP_NO_EFFECT,1,1,1);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 6);
    MobStatusEffectMove(mob, target, EFFECT_WEAKNESS, 1, 0, 120);
    return dmg;
end;
