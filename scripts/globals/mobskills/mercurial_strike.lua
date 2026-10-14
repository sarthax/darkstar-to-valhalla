---------------------------------------------
-- Mercurial Strike (Cottus): fixed damage 111..1111, wipes shadows; value saved for Cottus follow-up chain [W]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local vals = {111,222,333,444,555,666,777,888,999,1111};
    local dmg = vals[math.random(#vals)];
    mob:setLocalVar("MS_VAL", dmg);
    mob:setLocalVar("MS_CHAIN", 1);
    skill:setMsg(msgBasic.DAMAGE);
    target:delHP(dmg);
    return dmg;
end;
