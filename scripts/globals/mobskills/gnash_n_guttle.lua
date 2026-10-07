---------------------------------------------
--  Gnash 'n Guttle  (Botulus Rex, Voidwatch)
--  [C] single target, HP drained. Damage multiplier [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmg = MobPhysicalMove(mob, target, skill, mob:getWeaponDmg()*3, 1, TP_NO_EFFECT, TP_NO_EFFECT, TP_NO_EFFECT);
    local final = MobFinalAdjustments(dmg.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, MOBPARAM_WIPE_SHADOWS);
    skill:setMsg(MobPhysicalDrainMove(mob, target, skill, MOBDRAIN_HP, final));
    return final;
end;
