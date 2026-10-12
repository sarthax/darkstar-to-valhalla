-----------------------------------
-- Sixth Element (Ovjang, Heroines' Holdfast)
-- Placeholder: capture #237 confirms id 2897 (Topaz mob_skills 3244) / anim 2035 only. Element,
-- damage and radius are NOT captured; modelled as a single-target non-elemental magic hit.
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
    -- 2026-09-29 (user): Ovjang's "Sixth Element - Dark and Earth" dialog moved to Ovjang.lua's
    -- own entity.onMobWeaponSkill -- shared mobskill scripts like this one shouldn't carry
    -- HH-specific flavor text. See Ovjang.lua for the real wiring.
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 820, 820, MOBSKILL_MAGICAL, MOBPARAM_NONE, MOBPARAM_WIPE_SHADOWS)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Ovjang Sixth Element 820 twice, fixed. Additional effects are NOT captured.
