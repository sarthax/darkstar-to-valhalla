---------------------------------------------
-- Gravitic Horn (Ogbunabali): frontal cone, % HP damage + hate reset [W]; below 50% HP [D]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return (mob:getHPP() < 50) and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmg = math.floor(target:getHP() * 0.5);
    dmg = MobFinalAdjustments(dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
    mob:resetEnmity(target);
    target:delHP(dmg);
    return dmg;
end;
