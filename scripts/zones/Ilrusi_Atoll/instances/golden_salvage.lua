-----------------------------------
-- Assault: Golden Salvage
-----------------------------------
-- 2026-08-19, user-reported: Ancient Lockbox still unusable, "same issue as Lamia No.13" -- true
-- root cause (this npc, 17002654, is the same zone-shared Ancient Lockbox used by all 10 Ilrusi
-- missions) was already fixed at the data level (npc_list.sql entityFlags 3715 -> 1667, see
-- Assault_Fix_Log.md). Separately, real widescan data from a user-provided win capture
-- ("Ilrusi Atoll PSC - Golden Salvage (Win, Cap60, BST Solo).zip") showed both Rune of
-- Release/Ancient Lockbox were also positioned wrong (real: 380,-7.894,64.999,0 /
-- 380,-7.756,61.999,0 -- previous values were ~35-40 units off with the wrong rotation, 148
-- instead of 0), which independently would have made the lockbox hard/impossible to reach even
-- once targetable. Both fixed below.
-- 2026-08-22: real position map + live !pos captures (user-provided) confirm the actual chest
-- mechanic -- 20 possible chest spawn points, 12 spawn per instance (4 fixed "boat" chests that
-- always appear + 8 drawn randomly from the other 15/16 known slots), 11 of the 12 are live
-- Mimics and 1 is the real chest. Previously this only ever used a fixed set of 12 hardcoded
-- chests with no randomization ("TODO: random the chest locations") and wrong positions on top
-- of that. See IDs.lua's CURSED_CHEST_SLOTS for the position data and sourcing notes.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
require("scripts/globals/utils")
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
local GoldenSalvageData = require("scripts/zones/Ilrusi_Atoll/GoldenSalvageData")
-----------------------------------
-- Real Percipient Fish ids (were ID.mob[1] under the old LandSandBoat-targeted IDs.lua; that
-- per-instance mob-group shape has no old-dsp-reference equivalent at all -- see TextIDs.lua's
-- own header -- so these 8 real mob ids are hardcoded directly here instead, same convention as
-- old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua).
local PERCIPIENT_FISH = { 17002497, 17002498, 17002499, 17002500, 17002501, 17002502, 17002503, 17002504 }
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()

    player:messageSpecial(ASSAULT_41_START, 41)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)
    local chestSlots = GoldenSalvageData.CURSED_CHEST_SLOTS
    local chestIds = chestSlots.chestIds
    local boatRegions = chestSlots.boatChestRegions
    local regions = chestSlots.regions

    -- Build list of non-boat regions (for random selection)
    local nonBoatRegions = {}
    for i = 1, #regions do
        local isBoat = false
        for _, boatRegion in ipairs(boatRegions) do
            if i == boatRegion then
                isBoat = true
                break
            end
        end
        if not isBoat then
            table.insert(nonBoatRegions, i)
        end
    end

    -- Shuffle non-boat regions for random selection
    nonBoatRegions = utils.shuffle(nonBoatRegions)

    local activeChests = {}
    local chestIndex = 1

    -- 2026-09-01 (3rd pass, real fix): chest ids are real mobs (mob_pools poolid 864, no npc_list
    -- rows at all -- confirmed via 2 independent real captures + LandSandBoat's own
    -- implementation, see mob_spawn_points.sql/npc_list.sql's own notes). Mobs load dormant
    -- (instance_loader.cpp never auto-Spawn()s them) -- setSpawn() + SpawnMob() is the correct
    -- activation pair, not setPos() (NPC-only, silently no-ops on a mob id).

    -- Place 4 boat chests at their designated regions
    for _, regionIdx in ipairs(boatRegions) do
        if chestIndex <= #chestIds then
            local region = regions[regionIdx]
            local position = region[math.random(#region)]
            local chestId = chestIds[chestIndex]
            table.insert(activeChests, { id = chestId, regionIdx = regionIdx })
            GetMobByID(chestId, instance):setSpawn(position.x, position.y, position.z, 0)
            SpawnMob(chestId, instance)
            chestIndex = chestIndex + 1
        end
    end

    -- Place 8 random chests from non-boat regions
    for i = 1, 8 do
        if chestIndex <= #chestIds and i <= #nonBoatRegions then
            local regionIdx = nonBoatRegions[i]
            local region = regions[regionIdx]
            local position = region[math.random(#region)]
            local chestId = chestIds[chestIndex]
            table.insert(activeChests, { id = chestId, regionIdx = regionIdx })
            GetMobByID(chestId, instance):setSpawn(position.x, position.y, position.z, 0)
            SpawnMob(chestId, instance)
            chestIndex = chestIndex + 1
        end
    end

    -- Chests that didn't get picked this instance simply stay dormant (never SpawnMob()'d) --
    -- no explicit "disable" call needed, unlike an always-visible NPC.

    -- Randomly select which chest has the Golden Figurehead
    if #activeChests > 0 then
        local figureheadChest = activeChests[math.random(#activeChests)]
        instance:setProgress(instance:getProgress() + figureheadChest.id)
    end

    -- Spawn ambient Percipient Fish (8 total).
    for _, fishId in ipairs(PERCIPIENT_FISH) do
        forceAggro(SpawnMob(fishId, instance))
    end

    -- Real widescan-confirmed positions (2026-08-19) -- previous values (420,-15,72,148 /
    -- 415,-15,75,148) were a generic guess, ~35-40 units off with the wrong rotation.
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setPos(380.000, -7.894, 64.999, 0)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setPos(380.000, -7.756, 61.999, 0)
    -- Rune of Release npc_list row defaults to status 0 (visible/clickable). Hide it (and the Lockbox) until
    -- the mission completes; onInstanceComplete sets both back to STATUS_NORMAL.
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002731, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(17002752, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(17002753, 0xFFF), TYPE_NPC):setAnimation(8)

    -- Door props registered to this instance (instance_entities) but never activated -- same
    -- missing-wiring pattern as _1jd in Lamia No.13. Real capture confirms these exist for this
    -- mission; wiring them in with the same setAnimation(8)-only pattern already used above.
    -- 2026-09-01, user-directed: _1jj set impassable (animation 9) instead of open (8).
    instance:getEntity(bit.band(17002725, 0xFFF), TYPE_NPC):setAnimation(9)
    -- 2026-09-01, user-directed: _1jq set impassable (animation 9) instead of open (8).
    instance:getEntity(bit.band(17002732, 0xFFF), TYPE_NPC):setAnimation(9)
    instance:getEntity(bit.band(17002733, 0xFFF), TYPE_NPC):setAnimation(8)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 7) -- H-7 (capture Thris Nov2025)
    end

    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):hideName(true)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

