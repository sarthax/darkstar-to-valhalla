-----------------------------------
-- Area: Zhayolm Remnants
--  Mob: Jakko
-----------------------------------
-- 2026-09-04: real Slot NM (see npcs/Slot.lua). Zhayolm's own Slot NM does not follow the
-- Socket-hide/cell-drop convention (that's Arrapago/Bhaflau/Silver Sea's Slot NMs are plain
-- trade-pop encounters per Topaz's own real Slot.lua/npcUtil.tradeHas pattern with no onMobSpawn
-- or onMobDeath hook) -- kept empty to match, no fabricated loot/status logic.
-----------------------------------
-- LSB increments killedNMs on Jakko's spawn (sic), not its death; kept as-is for parity
function onMobSpawn(mob)
    local instance = mob:getInstance()
    if instance then
        instance:setLocalVar('killedNMs', instance:getLocalVar('killedNMs') + 1)
    end
end

