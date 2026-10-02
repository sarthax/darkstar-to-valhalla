---------------------------------------------
--  Knockout  (Demolition Duty automaton / Automaton_Harlequin list 363)
--  DSP port of the Topaz mobskills/knockout.lua (same formula: TP_DMG_BONUS, dmgmod 2, fTP 1.5/2.5/3.5).
--  Without a script onMobSkillCheck is undefined and the skill is silently never used.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
---------------------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local numhits = 1;
    local accmod = 1;
    local dmgmod = 2;
    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_BONUS, 1.5, 2.5, 3.5);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_NONE, info.hitslanded);

    target:delHP(dmg);
    return dmg;
end;
