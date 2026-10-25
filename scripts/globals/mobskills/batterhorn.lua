---------------------------------------------
--  Batterhorn  (Stachysaurus, Voidwatch)
--  [F] frontal conal damage + knockback; skill id 2099 anim 1437 [C]. Multiplier [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("VW_DEADLINE") == 0) then return 1; end -- Voidwatch-only: base mobs sharing this skill stay inert (no Lua existed before VW)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob, target, skill, 1, 1, 2.5, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded);
    target:delHP(dmg);
    return dmg;
end;
