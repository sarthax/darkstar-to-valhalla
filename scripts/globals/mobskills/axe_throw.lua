-- Axe Throw (axe-wielding Mamool Ja). Ported from Topaz axe_throw.lua
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

-- Mamool Ja Training Grounds (zone 66) gate splash: same behavior as Topaz mobskills (gates are
-- zone-scoped, in-range 8 of the caster). `frac` nil = one-hit destroy.
local function splashGates(mob, frac)
    local instance = mob:getInstance()
    if instance and mob:getZoneID() == 66 then
        for _, g in pairs(instance:getMobs()) do
            if g:getName() == "Dilapidated_Gate" and g:isAlive() and g:checkDistance(mob) <= 8 then
                local amt = g:getMaxHP()
                if frac then amt = math.ceil(g:getMaxHP() * frac) end
                if amt >= g:getHP() then g:setHP(0) else g:delHP(amt) end
            end
        end
    end
end

function onMobSkillCheck(target, mob, skill)
    -- animationsub 1 = weapon already thrown (Topaz gate)
    if mob:AnimationSub() == 1 then
        return 1
    end
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    local info = MobRangedMove(mob, target, skill, 1, 1, 2.5, TP_NO_EFFECT)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_SLASH, info.hitslanded)
    mob:AnimationSub(1) -- loses its axe
    target:delHP(dmg)
    splashGates(mob, nil)
    return dmg
end
