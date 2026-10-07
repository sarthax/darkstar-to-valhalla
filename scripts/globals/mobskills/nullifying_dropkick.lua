-----------------------------------
--  Nullifying Dropkick
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
        -- 2026-09-29 (user): "Prishe does not print her mob skill moves into the chat... all other
        -- heroine bosses work correctly." Unlike Mumor's/Ovjang's mobskill scripts, this shared
        -- CoP/HH file never called mob:say-equivalent for HH's Prishe -- the engine's own
        -- OnMobSkillFinished always sends the generic damage msg (185), but the flavor quip text
        -- ("Nullifying Dropkick to your fat head!") only fires if a script sends it explicitly, same
        -- as tpz.heroines.mumorSay. dialog.yml id 7584 confirmed this session (exact match, capture
        -- #240 "Mumor Heroine's Holdfast", same numeric id, no drift in this range) -- real HH Prishe
        -- line, not invented.
        return 0
    end
    if (target:hasStatusEffect(EFFECT_PHYSICAL_SHIELD) or target:hasStatusEffect(EFFECT_MAGIC_SHIELD)) then
        mob:showText(mob, PRISHE_TEXT + 5)
        return 0
    end
    return 1
end

function onMobWeaponSkill(target, mob, skill)
    if mob:getZoneID() == 77 then
        tpz.heroines.skillSay(mob, 7584) -- once per use (onMobSkillCheck runs every AI tick)
    end

    local numhits = 1
    local accmod = 1
    local dmgmod = 2.0
    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_VARIES, 1, 2, 3)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded)

    target:delStatusEffect(EFFECT_PHYSICAL_SHIELD)
    target:delStatusEffect(EFFECT_MAGIC_SHIELD)

    target:delHP(dmg)
    return dmg
end

