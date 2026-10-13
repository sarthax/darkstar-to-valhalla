-----------------------------------
-- Walk the Plank (Lion, Heroines' Holdfast)
-- Ported from LandSandboat's walk_the_plank.lua via the Trust framework; fTP/durations are LSB's
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
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_BIND, 1, 0, 20)
    target:dispelStatusEffect()
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 24, 84, MOBSKILL_PHYSICAL, MOBPARAM_PIERCE)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Lion Walk the Plank 24-84 (3 non-zero samples). Additional effects are NOT captured.
