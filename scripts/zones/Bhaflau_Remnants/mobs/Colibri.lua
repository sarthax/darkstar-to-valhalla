-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Colibri
-----------------------------------
-- 2026-09-06: added the real temp-chest drop call (scripts/globals/salvage.lua's spawnTempChest)
-- -- this file already existed (for the colibri_mimic mixin) but its onMobDeath was empty.
-----------------------------------
-- 2026-09-09: real fix -- Reactionary_Rampart.lua's activeSummons counter only ever incremented
-- (live-confirmed on Floor 1's Chigoe pool: Reinforcements permanently stops once all 5 real ids
-- have popped once). Frees the slot back on despawn so Floor 3's Rampart doesn't hit the same cap.
-----------------------------------
mixins = {require("scripts/mixins/families/colibri_mimic")}
require("scripts/globals/salvage")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local rampart = instance and GetMobByID(Bhaflau.mobs.REACTIONARY_RAMPART[3], instance)
    if rampart then
        local active = rampart:getLocalVar("activeSummons")
        if active > 0 then
            rampart:setLocalVar("activeSummons", active - 1)
        end
    end
end

