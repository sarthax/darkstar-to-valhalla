-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Psycheflayer
-----------------------------------
-- 2026-09-05: real user-confirmed mechanic -- one of this floor's 6 Psycheflayer spawns is
-- randomly the NM (bigger, does not link with the others, drops Macha's Crown). Same
-- reservoir-sampling approach as Deviate_Bhoot.lua's twin mechanic on the other side of this floor
-- -- see that file's comment for the full rationale. No special TP move is documented for this NM
-- (unlike Deviate Bhoot's Perdition), so none is added here.
-- NOT implemented: the "does not link" behavior -- see Deviate_Bhoot.lua's comment, same reasoning.
-- NOT implemented: visual size. Checked mob_pools.sql's family (233) for an alternate "large" look
-- -- 'Amnaf_Psycheflayer' (modelid 1776/0xF006) exists right next to the regular 'Psycheflayer'
-- (modelid 1775/0xEF06), but per the user (2026-09-05) that's a different skin/color, not a bigger
-- model -- confirmed NOT the right fix, left alone. There is also no runtime size-scale API at all
-- (mob:getModelSize() is read-only, tied to melee attack range, not rendering -- see
-- battleentity.h's m_ModelSize); real visual "bigger" would need a genuinely separate, larger
-- 3D model id, which hasn't been identified. NM is functionally distinct (rare drop) but not
-- visually distinct from the other 5 for now.
-- Drop rate is an undocumented estimate, not a sourced number (real item id 16103 = machas_crown,
-- confirmed in sql/item_basic.sql).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
local MACHAS_CROWN = 16103

function onMobSpawn(mob)
    local instance = mob:getInstance()
    local count = instance:getLocalVar("psycheflayerSpawnCount") + 1
    instance:setLocalVar("psycheflayerSpawnCount", count)
    if math.random(count) == 1 then
        instance:setLocalVar("psycheflayerNM", mob:getID())
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat). Restored to spawnTempChest
-- plus this file's own pre-existing Macha's Crown NM-drop check.
function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance:getLocalVar("psycheflayerNM") == mob:getID() and math.random(100) <= 5 then
        player:addTreasure(MACHAS_CROWN, mob)
    end
    salvageUtil.spawnTempChest(mob)
end

