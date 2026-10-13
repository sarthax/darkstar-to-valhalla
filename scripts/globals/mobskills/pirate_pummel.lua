-----------------------------------
-- Pirate Pummel (Lion, Heroines' Holdfast)
-- Ported from LandSandboat's pirate_pummel.lua via the Trust framework; fTP/durations are LSB's
-- own uncaptured placeholders (capture #237 shows ~24-30 dmg per use on players).
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    tpz.heroines.skillSay(mob, tpz.heroines.LION_LINES[math.random(#tpz.heroines.LION_LINES)])
    local numhits = 2
    local accmod = 1
    local dmgmod = 0.3
    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_VARIES, 1, 2, 3)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_PIERCE, info.hitslanded)

    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_BURN, 1, 0, 20)

    target:delHP(dmg)
    return dmg
end

