---------------------------------------------
-- Norn Arrows (Belphoebe): AoE damage + Encumbrance [W]; scripted in her BREEZES cycle
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*5,ELE_WIND,1,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_WIND,MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 60); -- cosmetic
    target:delHP(dmg);
    return dmg;
end;
