-----------------------------------
-- Tortoise Song
--
-- Description: Removes all status effects in an area of effect.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: 20' radial
-- Notes:
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------
-- 2026-09-07: CORRECTED -- real semantics, confirmed directly against mob_controller.cpp:310:
-- `luautils::OnMobSkillCheck(...) == 0` is what triggers actually USING the skill -- 0 means
-- "valid, use it," any nonzero means "invalid, skip it." Earlier today this was flipped to
-- `return 1` believing the opposite -- that made Adamantoise NEVER able to use this move at all
-- (exactly the original bug, just via a different wrong value). Reverted to the real always-valid
-- state. Only real consumer in the whole database is Nyzul Isle's Adamantoise (poolid 44 --
-- confirmed the only Adamantoise pool that exists), so this is scoped to exactly the one real mob.
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-07: real fix -- BG Wiki: "Adamantoise's Tortoise Song is enhanced to dispel all
    -- buffs, not just song & roll effects." Was hard-coded to bit.bor(SONG, ROLL) only. Calling
    -- dispelAllStatusEffect() with NO argument already defaults to EFFECTFLAG_DISPELABLE
    -- (lua_baseentity.cpp:9958) -- every dispellable buff, exactly the wiki's "enhanced" behavior
    -- -- so no new flag/enum is needed, just removing the restriction.
    local count = target:dispelAllStatusEffect()

    if (count == 0) then
        skill:setMsg(msgBasic.NO_EFFECT)
    else
        skill:setMsg(msgBasic.DISAPPEAR_NUM)
    end

    return count
end

