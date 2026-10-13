-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Princess Pudding
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    local slot = instance:getEntity(bit.band(Arrapago.npcs[2][2].SLOT, 0xFFF), TYPE_NPC)
        slot:setStatus(STATUS_DISAPPEAR)
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat).
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
end

