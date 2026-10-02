require("scripts/globals/status")
-----------------------------------
-- Assault: Seagull Grounded
-----------------------------------
local ID = Periqia
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_31_START, 31)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
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

    for i, v in pairs(ID.mob[31]) do
        forceAggro(SpawnMob(v, instance))
    end

    -- Real position, confirmed via retail capture packet logs -- do NOT confuse this with
    -- Excaliace.lua's WIN_CONDITION_POS, which is a deliberate proximity-TRIGGER point placed in
    -- the center of the cave (near the Debaucher) so his approach starts his flee-until-killed
    -- behavior -- not where the Rune/Lockbox themselves actually sit (against the cave wall,
    -- confirmed separately). 2026-08-23: mistakenly overwritten with WIN_CONDITION_POS's
    -- coordinates that same day -- reverted back to the real capture-confirmed spot.
    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setPos(-495, -9.899, -72, 0)
    box:setPos(-495, -9.695, -75, 0)

    -- 2026-08-23: RE-APPLIED setStatus(NORMAL). The earlier revert was based on a false
    -- regression -- CInstance (used for Assault instances) inherits CZoneEntities, and
    -- CZoneInstance::SpawnNPCs() (zone_instance.cpp:334) calls straight into
    -- CZoneEntities::SpawnNPCs() (zone_entities.cpp:544), the SAME status==NORMAL||MOB gate
    -- used for non-instanced NPCs -- LoadNPCList() skipping DUNGEON_INSTANCED only affects the
    -- static world-load registration, not this per-player visibility/sync broadcast, which IS
    -- shared. The apparent "regression" when this was first tried was actually a real, separate
    -- engine bug: the user chain-warped directly from another Assault instance into this one
    -- without a fresh zone entry, and the log showed a genuine stale-instance-attachment error
    -- ("Gwendy was still attached to instanceid 34" while instance 31 was loading) at that exact
    -- moment -- unrelated to this status change. A fresh zone entry afterward showed dialog
    -- working fine even with status still reverted to 1, confirming status wasn't the problem
    -- that day. Re-applying NORMAL now to fix the actual remaining bug (visible movement).
    -- 2026-09-01: Excaliace's own setStatus(NORMAL) call REMOVED -- he's a real mob now (converted
    -- from npc_list, see sql/mob_pools.sql poolid 6995), already spawned + status-set by the
    -- SpawnMob() loop above like every other ID.mob[31] entry; GetNPCByID() would return nil for
    -- him now regardless (see topaz_shared_entity_id_targid_collision memory on why he can't be
    -- registered as both an npc and a mob at once).
    instance:getEntity(bit.band(ID.npc._1K6, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(ID.npc._1KX, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(ID.npc._1KZ, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(ID.npc._JK1, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(ID.npc._JK3, 0xFFF), TYPE_NPC):setAnimation(8)

end

function onInstanceTimeUpdate(instance, elapsed)
    local players = instance:getChars()
    local lastTimeUpdate = instance:getLastTimeUpdate()
    local remainingTimeLimit = (instance:getTimeLimit()) * 60 - (elapsed / 1000)
    local wipeTime = instance:getWipeTime()
    local message = 0

    if (remainingTimeLimit < 0) then
        instance:fail()
        return
    end

    if (wipeTime == 0) then
        local wipe = true
        for i, v in pairs(players) do
            if v:getHP() ~= 0 then
                wipe = false
                break
            end
        end
        if (wipe) then
            for i, v in pairs(players) do
                v:messageSpecial(ID.text.PARTY_FALLEN, 3)
            end
            instance:setWipeTime(elapsed)
        end
    else
        if (elapsed - wipeTime) / 1000 > 180 then
            instance:fail()
            return
        else
            for i, v in pairs(players) do
                if v:getHP() ~= 0 then
                    instance:setWipeTime(0)
                    break
                end
            end
        end
    end

    if (lastTimeUpdate == 0 and elapsed > 20 * 60000) then
        message = 600
    elseif (lastTimeUpdate == 600 and remainingTimeLimit < 300) then
        message = 300
    elseif (lastTimeUpdate == 300 and remainingTimeLimit < 60) then
        message = 60
    elseif (lastTimeUpdate == 60 and remainingTimeLimit < 30) then
        message = 30
    elseif (lastTimeUpdate == 30 and remainingTimeLimit < 10) then
        message = 10
    end

    if (message ~= 0) then
        for i, v in pairs(players) do
            if (remainingTimeLimit >= 60) then
                v:messageSpecial(ID.text.TIME_REMAINING_MINUTES, remainingTimeLimit / 60)
            else
                v:messageSpecial(ID.text.TIME_REMAINING_SECONDS, remainingTimeLimit)
            end
        end
        instance:setLastTimeUpdate(message)
    end
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)

    if (progress > 0) then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 5, 11) -- F-11 (capture Thris Nov2025)
    end

    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setStatus(STATUS_NORMAL)
    box:setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

