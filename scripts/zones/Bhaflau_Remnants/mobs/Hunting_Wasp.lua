-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Hunting Wasp
-----------------------------------
-- 2026-09-06: real captured id/position (Mission Toolkit captures #110/#111), no Lua script
-- existed for this mob type before -- see scripts/globals/salvage.lua's spawnTempChest comment
-- for why the drop-chest call belongs here rather than in a shared/centralized hook.
--
-- 2026-09-09: real fix -- Reactionary_Rampart.lua's activeSummons counter only ever incremented
-- (live-confirmed on Floor 1's Chigoe pool: Reinforcements permanently stops once all 5 real ids
-- have popped once). Frees the slot back on despawn so Floor 2's Rampart doesn't hit the same cap.
-----------------------------------
require("scripts/globals/salvage")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local rampart = instance and GetMobByID(Bhaflau.mobs.REACTIONARY_RAMPART[2], instance)
    if rampart then
        local active = rampart:getLocalVar("activeSummons")
        if active > 0 then
            rampart:setLocalVar("activeSummons", active - 1)
        end
    end
end

