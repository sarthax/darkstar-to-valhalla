---------------------------------------------
-- Kaleidoscopic Fury: below 50% HP [forum #1140, BG wiki]; resets JA/spell timers, all stats down, strong Dia + defense down
-- Aello (Voidwatch) skill. [C] anim id/usage from Wiggo Aello capture; effects/damage [W]/[D] flagged.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    if (mob:getName() == "Aello") then return (mob:getHPP() < 50) and 0 or 1; end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_LIGHT,1,TP_NO_EFFECT); -- [D]
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_LIGHT,MOBPARAM_IGNORE_SHADOWS);
    target:resetRecasts();
    local stats = {EFFECT_STR_DOWN, EFFECT_DEX_DOWN, EFFECT_VIT_DOWN, EFFECT_AGI_DOWN, EFFECT_INT_DOWN, EFFECT_MND_DOWN, EFFECT_CHR_DOWN};
    for _, e in ipairs(stats) do MobStatusEffectMove(mob, target, e, 50, 0, 120); end -- "-50 or more" [forum]
    MobStatusEffectMove(mob, target, EFFECT_DEFENSE_DOWN, 25, 0, 120);                  -- [D]
    target:addStatusEffect(EFFECT_DIA, 40, 3, 120, 0, 25);                               -- "50-80/tick" [forum]; power approximated [D]
    target:delHP(dmg);
    return dmg;
end;
