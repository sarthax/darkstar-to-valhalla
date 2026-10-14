---------------------------------------------
--  Quake Blast
--
--  Voidwalker (Orcus): single-target earth damage.
--  [D] Damage numbers are a design guess; captured values: 38
--  Voidwatch (Ogbunabali): AoE earth damage + gear strip [W]; below 50% HP [D]
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
        local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*4,ELE_EARTH,1,TP_NO_EFFECT);
        dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
        MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 30); -- cosmetic: engine does not strip gear
    else
        local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*2,ELE_EARTH,1.0,TP_NO_EFFECT);
        dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_WIPE_SHADOWS);
    end
    target:delHP(dmg);
    return dmg;
end;
