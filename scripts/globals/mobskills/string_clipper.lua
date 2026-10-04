-----------------------------------
-- String Clipper (Heroines' Holdfast automatons/Nashmeira)
-- Placeholder tuning: capture #237 confirms the skill id/animation only; fTP, dmgmod and the
-- additional effect are NOT captured (effect unverified, plain physical).
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-29 (user, 2nd correction): String Clipper IS one of Mnejing_HH's real usable skills
    -- alongside the 4 attachment skills (Flashbulb/Provoke/Shield Bash/Disruptor) -- all 7 are
    -- valid together (mob_skill_lists.sql 'Mnejing_HH'/1151). No confirmed elemental dialog line
    -- exists for this one (the Sequence F/I/W/E/T/W/L/D pool only covers her 4 attachment skills),
    -- so no mobSay call here -- not invented.

    local numhits = 1
    local accmod = 1
    local dmgmod = 0.3
    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_VARIES, 1, 2, 3)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_SLASH, info.hitslanded)

    target:delHP(dmg)
    return dmg
end

