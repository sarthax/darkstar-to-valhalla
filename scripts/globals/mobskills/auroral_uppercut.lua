-----------------------------------
--  Auroral Uppercut
--
-----------------------------------
require("scripts/zones/Empyreal_Paradox/TextIDs")
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    if mob:getZoneID() == 77 then -- Nyzul Isle -- Heroines' Holdfast Prishe: CoP shield gating/text does not apply
        -- 2026-09-29: same fix as nullifying_dropkick.lua -- flavor quip never fired for HH Prishe.
        -- dialog.yml id 7585 confirmed this session (exact match, capture #240, no drift in this range).
        return 0
    end
    if (target:hasStatusEffect(EFFECT_PHYSICAL_SHIELD) or target:hasStatusEffect(EFFECT_MAGIC_SHIELD)) then
        return 1
    end
    mob:showText(mob, PRISHE_TEXT + 4)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    if mob:getZoneID() == 77 then
        tpz.heroines.skillSay(mob, 7585) -- once per use (onMobSkillCheck runs every AI tick)
    end

    local numhits = 1
    local accmod = 1
    local dmgmod = 1.0
    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_VARIES, 1, 2, 3)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded)

    target:delHP(dmg)
    return dmg
end

