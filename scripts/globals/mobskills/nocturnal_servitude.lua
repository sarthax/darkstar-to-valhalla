---------------------------------------------
-- Nocturnal Servitude (Lord Asag): conal Charm [W]; below 50% HP [D]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return (mob:getHPP() < 50) and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_CHARM_I, 0, 3, 30));
    return EFFECT_CHARM_I;
end;
