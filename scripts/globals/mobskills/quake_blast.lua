---------------------------------------------
-- Quake Blast (Ogbunabali): AoE earth damage + gear strip [W]; below 50% HP [D]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return (mob:getHPP() < 50) and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*4,ELE_EARTH,1,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 30); -- cosmetic: engine does not strip gear
    target:delHP(dmg);
    return dmg;
end;
