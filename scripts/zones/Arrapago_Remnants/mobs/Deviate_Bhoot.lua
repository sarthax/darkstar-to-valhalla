-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Deviate Bhoot
-----------------------------------
-- 2026-09-05: real user-confirmed mechanic -- one of this floor's 6 Deviate Bhoot spawns is
-- randomly the NM (bigger, does not link with the others, can use the real 'Perdition' mob skill
-- (sql/mob_skills.sql id 1794, name 'perdition') which can kill the target). Confirmed with the
-- user that neither Topaz's nor LSB's SQL distinguishes which of the 6 identical spawn points is
-- the NM -- it's genuinely random from the pool at runtime, not a fixed id. The NM is chosen here
-- via reservoir sampling as the 6 spawn (guarantees exactly one, uniformly, regardless of spawn
-- order), tracked on the instance so all 6 copies of this same script agree on which one is it.
-- Moveset override is pure Lua -- mob:useMobAbility() bypasses the assigned skill list entirely,
-- same real pattern already used for Nyzul Isle's Shielded_Chariot.lua, per user preference to
-- avoid new/shared mob_skill_lists rows (an older sibling server may have divergent content on
-- that shared table).
-- NOT implemented: the "does not link" behavior -- that's a pool/link-radius property, not
-- something with a confirmed per-instance Lua override, so it's left as a known gap rather than
-- guessed at.
-- NOT implemented: visual size. Checked mob_pools.sql's whole family (52) for an alternate "large"
-- look -- every single named Bhoot variant (Assault/Batteilant/Bhoot/Bhoot_Invader/Deviate/Gelid/
-- Guard/Apex/Horrific/Wayward/Bhoot_NI) shares the exact same modelid (369/0x0171), so there's
-- genuinely no bigger model anywhere in this family to substitute -- confirmed, not just unsearched.
-- There is also no runtime size-scale API at all (mob:getModelSize() is read-only, tied to melee
-- attack range, not rendering -- see battleentity.h's m_ModelSize). NM is functionally distinct
-- (Perdition + rare drop) but not visually distinct from the other 5 for now.
-- Perdition's proc chance/cooldown and the Deimos's Mask rare-drop rate are undocumented estimates,
-- not sourced numbers (real item id 16087 = deimoss_mask, confirmed in sql/item_basic.sql).
-----------------------------------
require("scripts/globals/salvage")
require("scripts/globals/monstertpmoves")
-----------------------------------
local PERDITION     = 1794
local DEIMOSS_MASK  = 16087

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobSpawn(mob)
    local instance = mob:getInstance()
    local count = instance:getLocalVar("bhootSpawnCount") + 1
    instance:setLocalVar("bhootSpawnCount", count)
    if math.random(count) == 1 then
        instance:setLocalVar("bhootNM", mob:getID())
    end
    mob:setLocalVar("usedPerdition", 0)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    if instance:getLocalVar("bhootNM") ~= mob:getID() then
        return
    end
    if mob:getLocalVar("usedPerdition") == 0 and notBusy(mob) and math.random(100) <= 10 then
        mob:useMobAbility(PERDITION)
        mob:setLocalVar("usedPerdition", 1)
        mob:timer(60000, function(m) m:setLocalVar("usedPerdition", 0) end)
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat). Restored to spawnTempChest
-- plus this file's own pre-existing Deimos's Mask NM-drop check.
function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance:getLocalVar("bhootNM") == mob:getID() and math.random(100) <= 5 then
        player:addTreasure(DEIMOSS_MASK, mob)
    end
    salvageUtil.spawnTempChest(mob)
end

