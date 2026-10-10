-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Reserve Draugar
-----------------------------------
-- 2026-09-05: real fix -- this file was missing entirely (real SQL row, no script -- "undefined
-- procedure" errors on death). Wired to the real temp-chest drop mechanic (scripts/globals/
-- salvage.lua's spawnTempChest), same as this zone's other real trash mobs.
-- 2026-09-05 (later): DRG-job variant (Reserve_Draugar_AR_drg, mJob=14) real pet pairing -- ids
-- 17080424/17080427, each paired with a real Draugars_Wyvern pet (17080425/17080428, +1 offset,
-- confirmed via sql/mob_pets.sql). The real engine-native mob_pets attach mechanism (used for
-- open-world mobs everywhere else in the game) does NOT work here -- confirmed live: real boot
-- error "zoneutils::loadMOBList PMaster is NULL" for both ids, because that linking code only runs
-- once at server boot against the zone's persistent entity list, and instance_loader.cpp has no
-- equivalent for per-instance mobs -- Arrapago's own mob entities don't exist yet at boot time.
-- Built as a manual Lua workaround instead, using the same real setSpawn()+SpawnMob() mechanism
-- already proven working for this zone's Archaic Rampart pets, but summoned ONCE (not a repeating
-- multi-slot refill like Rampart) to match DRG's real one-time Call Wyvern mechanic. Follow/
-- share-target/despawn-on-death are hand-rolled here since only the C++ mob_pets attach grants
-- those automatically, and that path is unavailable for instanced content.
-----------------------------------
-- 2026-09-06: real fix -- Topaz's name-driven script lookup routes EVERY mob named
-- "Reserve_Draugar" through this same file (confirmed via mob_spawn_points.sql: ids
-- 17080420/422/423 are plain melee variants with no pet at all, only 17080424/427 are the real
-- DRG masters). The pet-summon logic below unconditionally used mob:getID()+1 as "the pet" for
-- ANY Reserve_Draugar, with no gate -- for the non-DRG variants that neighbor is just whatever
-- mob happens to spawn next in the id sequence, which for 17080420 is Merrow_Chantress (17080421)
-- -- live-confirmed: engaging a plain Reserve_Draugar was spawning/repositioning a nearby Merrow
-- as if it were this mob's summoned pet. Real fix: gate all pet logic to only the two real DRG
-- master ids.
local DRG_MASTER_IDS = { [17080424] = true, [17080427] = true }
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobSpawn(mob)
    mob:setLocalVar("wyvernSummoned", 0)
end

function onMobEngaged(mob, target)
    if DRG_MASTER_IDS[mob:getID()] and mob:getLocalVar("wyvernSummoned") == 0 then
        mob:setLocalVar("wyvernSummoned", 1)
        local instance = mob:getInstance()
        local POS = mob:getPos()
        local pet = GetMobByID(mob:getID() + 1, instance)

        pet:setSpawn(POS.x, POS.y, POS.z, POS.rot)
        SpawnMob(mob:getID() + 1, instance)
        pet:updateEnmity(target)
    end
end

function onMobFight(mob, target)
    if not DRG_MASTER_IDS[mob:getID()] then
        return
    end

    local instance = mob:getInstance()
    local pet = GetMobByID(mob:getID() + 1, instance)

    if pet:isSpawned() then
        -- keep the wyvern on the same target and near its master (no real C++ PMaster/PPet link
        -- to do this automatically for an instanced mob, so it's refreshed every fight tick)
        pet:updateEnmity(target)

        local POS = mob:getPos()
        local petPos = pet:getPos()
        if math.abs(POS.x - petPos.x) > 15 or math.abs(POS.z - petPos.z) > 15 then
            pet:setPos(POS.x, POS.y, POS.z, POS.rot)
        end
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat). Restored to spawnTempChest,
-- this file's own pre-existing mechanism.
function onMobDeath(mob, player, isKiller)
    if DRG_MASTER_IDS[mob:getID()] then
        local instance = mob:getInstance()
        DespawnMob(mob:getID() + 1, instance) -- real DRG mechanic: wyvern despawns with its master
    end
    salvageUtil.spawnTempChest(mob)
end

function onMobDespawn(mob)
    if DRG_MASTER_IDS[mob:getID()] then
        local instance = mob:getInstance()
        DespawnMob(mob:getID() + 1, instance)
        mob:setLocalVar("wyvernSummoned", 0)
    end
end

