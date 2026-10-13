-----------------------------------
-- Powder Keg (Lion, Heroines' Holdfast)
-- Ported from LandSandboat's powder_keg.lua via the Trust framework; fTP/durations are LSB's
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
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_DEFENSE_DOWN, 20, 0, 60)
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_MAGIC_DEF_DOWN, 20, 0, 60)
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 4, 30, MOBSKILL_PHYSICAL, MOBPARAM_PIERCE)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Lion Powder Keg 4-30 (2 samples). Additional effects are NOT captured.
