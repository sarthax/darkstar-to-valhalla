---------------------------------------------
-- Oppressive Glare (Ushumgal): Terror + Curse gaze [W]; below 50% HP [D]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    if (mob:getName() == "Ushumgal") then return (mob:getHPP() < 50) and 0 or 1; end -- [D] gate
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    if (mob:getName() ~= "Ushumgal") then -- other users (e.g. Kukulkan) keep the original no-effect stub
        skill:setMsg(msgBasic.NO_EFFECT);
        return 0;
    end
    MobStatusEffectMove(mob, target, EFFECT_CURSE_II, 50, 0, 30); -- Curse [W]
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 8));
    return EFFECT_TERROR;
end;
