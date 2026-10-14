---------------------------------------------
--  Norn Arrows
--
--  Voidwalker (Verthandi): AoE ranged attack, knockback, Encumbrance (wiki).
--  Damage numbers are DESIGN GUESSES (not wiki-sourced); tune after testing.
--  Voidwatch (Belphoebe): AoE damage + Encumbrance [W]; scripted in her BREEZES cycle
--  No capture for the VW version; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmg;
    if (mob:getLocalVar("VW_DEADLINE") ~= 0) then
        local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*5,ELE_WIND,1,TP_NO_EFFECT);
        dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_WIND,MOBPARAM_IGNORE_SHADOWS);
        MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 60); -- cosmetic
    else
        MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 1, 0, 60);

        local info = MobPhysicalMove(mob,target,skill,1,4,5,TP_DMG_VARIES,1,2,3);
        dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_RANGED,MOBPARAM_PIERCE,MOBPARAM_IGNORE_SHADOWS);
    end
    target:delHP(dmg);
    return dmg;
end;
