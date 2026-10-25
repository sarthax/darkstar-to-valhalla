---------------------------------------------
--  Gravitic Horn
--
--  Voidwalker (Orcus): single-target damage, melee range.
--  [D] Damage numbers are a design guess; captured values: 1043, 2156
--  Voidwatch (Ogbunabali): frontal cone, % HP damage + hate reset [W]; below 50% HP [D]
--  No capture for the VW version; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

local function isVW(mob)
    return mob:getLocalVar("VW_DEADLINE") ~= 0;
end

function onMobSkillCheck(target,mob,skill)
    if (isVW(mob)) then return (mob:getHPP() < 50) and 0 or 1; end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmg;
    if (isVW(mob)) then
        dmg = math.floor(target:getHP() * 0.5);
        dmg = MobFinalAdjustments(dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
        mob:resetEnmity(target);
    else
        local info = MobPhysicalMove(mob,target,skill,1,1,4.0,TP_NO_EFFECT);
        dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_PIERCE,info.hitslanded);
    end
    target:delHP(dmg);
    return dmg;
end;
