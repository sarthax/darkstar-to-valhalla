-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Archaic Chariot
-----------------------------------
-- 2026-09-08: real mechanic, ported from LandSandBoat's own real, working Archaic_Chariot.lua --
-- one of the 2 real Floor 4 chariots (IDs.lua's ARCHAIC_CHARIOT, west=17084665, east=17084681,
-- both confirmed real this session). Per the Vana'diel Atlas map the user supplied: "The west
-- chariot will weaken mega boss' defense and magical defense. The east chariot will weaken mega
-- boss' attacks (not homing missile)." Sets a real instance localVar
-- (bossModifier = instance:getProgress()) read by Long-Bowed_Chariot.lua on spawn to apply the
-- matching per-side effect. UDMGMAGIC translated to tpz.mod (same real mod id, confirmed via
-- Empathic_Flan.lua's own earlier port).
-----------------------------------
require("scripts/globals/salvage")
function onMobInitialize(mob)
    mob:setMod(MOD_UDMGMAGIC, -170)
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance then
        instance:setLocalVar('bossModifier', instance:getProgress())
    end

    salvageUtil.spawnTempChest(mob)
end

