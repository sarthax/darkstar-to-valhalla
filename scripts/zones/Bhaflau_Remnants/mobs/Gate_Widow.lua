-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Gate Widow
-----------------------------------
-- 2026-09-09: real fix -- this file didn't exist at all, same real bug already found and fixed on
-- Chigoe.lua ("undefined procedure onMobDeath") -- Gate Widow is Floor 1's rare NM summon
-- (Reactionary_Rampart.lua's RARE_POOLS), so it would hit the identical crash the first time one
-- actually died. Matches Chigoe.lua's pattern exactly, including the activeSummons slot-freeing
-- fix (BG Wiki: "high chance to drop Enlil's Brayettes and/or Macha's Cuffs" -- same real Salvage
-- temp-chest mechanic as every other summon here, just with better real drop odds baked into its
-- own mob_pools/drop table, not handled in this file).
-----------------------------------
require("scripts/globals/salvage")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local rampart = instance and GetMobByID(Bhaflau.mobs.REACTIONARY_RAMPART[1], instance)
    if rampart then
        local active = rampart:getLocalVar("activeSummons")
        if active > 0 then
            rampart:setLocalVar("activeSummons", active - 1)
        end
    end
end

