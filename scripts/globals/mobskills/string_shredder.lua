-----------------------------------
-- String Shredder (Heroines' Holdfast automatons/Nashmeira)
-- Placeholder tuning: capture #237 confirms the skill id/animation only; fTP, dmgmod and the
-- additional effect are NOT captured (effect unverified, plain physical).
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
    -- 2026-09-29 (user, 2nd correction): String Shredder IS one of Mnejing_HH's real usable skills
    -- alongside the 4 attachment skills (Flashbulb/Provoke/Shield Bash/Disruptor) -- all 7 are
    -- valid together (mob_skill_lists.sql 'Mnejing_HH'/1151). No confirmed elemental dialog line
    -- exists for this one (the Sequence F/I/W/E/T/W/L/D pool only covers her 4 attachment skills),
    -- so no mobSay call here -- not invented. (heroines_holdfast still required for flatDamage.)
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 200, 250, MOBSKILL_PHYSICAL, MOBPARAM_SLASH)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mnejing String Shredder 224 (1 sample, range widened). Additional effects are NOT captured.
