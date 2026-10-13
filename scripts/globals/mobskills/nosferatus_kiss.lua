---------------------------------------------
--  Nosferatu's Kiss  (Lord Asag, Voidwatch)
--
--  [D] Damage/absorb amount is a design guess; no retail numbers confirmed.
--  Description: AoE HP drain, recovers HP for the user.
--  Type: Magical (Dark)
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmgmod = 1.5; -- [D]
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_DARK,dmgmod,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_DARK,MOBPARAM_WIPE_SHADOWS);

    skill:setMsg(MobDrainMove(mob, target, MOBDRAIN_HP, dmg));

    return dmg;
end;
