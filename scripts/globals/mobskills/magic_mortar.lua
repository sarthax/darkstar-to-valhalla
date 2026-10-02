---------------------------------------------
--  Magic Mortar  (Demolition Duty automaton / Automaton_Harlequin list 363)
--  DSP port of the Topaz mobskills/magic_mortar.lua: TP_DMG_BONUS with tpvalue 1.5 (linear TP curve).
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
---------------------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmgmod = 1;
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 3, 0, dmgmod, TP_DMG_BONUS, 1.5);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_NONE, 0);

    target:delHP(dmg);
    return dmg;
end;
