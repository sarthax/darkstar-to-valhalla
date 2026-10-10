-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Chigoe
-----------------------------------
-- 2026-09-09: real fix -- this file didn't exist at all, unlike every other trash mob in this
-- zone (Colibri.lua, Hunting_Wasp.lua, Bifrons.lua, etc. all have their own file wiring the real
-- Armoury Crate temp-drop mechanic). Live-confirmed via map-server error: "luautils::onMobDeath
-- (./scripts/zones/Bhaflau_Remnants/mobs/Chigoe.lua): undefined procedure onMobDeath" -- the
-- engine looked for this exact file/function and found nothing. Matches every sibling file's real,
-- identical pattern.
--
-- 2026-09-09: real fix -- BG Wiki: "Up to 5 of these monsters may be spawned at one time. If 5
-- monsters have been spawned and are alive, the Reactionary Rampart will not spawn another
-- monster until one or more of the 5 have been defeated." Reactionary_Rampart.lua's own
-- activeSummons counter only ever incremented, live-confirmed it permanently caps at 5 and
-- Reinforcements silently stops forever once all 5 Chigoe/Gate Widow ids have popped once --
-- there's no other free real id for the pool to reuse. Frees the slot back on despawn (once the
-- corpse is actually gone, matching Reinforcements' own `not summon:isSpawned()` re-use check)
-- rather than on death, so a same-tick death+immediate respawn attempt doesn't race the corpse.
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

