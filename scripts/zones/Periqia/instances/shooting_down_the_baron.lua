-----------------------------------
-- Assault: Shooting Down the Baron
-----------------------------------
-- Built 2026-08-18 from data found sitting unwired in this repo's own SQL: Black Baron (boss)
-- plus 5 Periqia Pugil (obstacles), comment-labeled "-- Shooting Down the Baron" in
-- sql/mob_spawn_points.sql. Objective is singular ("Eliminate the Black Baron") -- only his
-- death is tracked, same shape as Sagelord Elimination.
-- 2026-08-23: real wiki mechanic (no aggro, no Widescan, warps to a new unclaimed location every
-- ~15% HP lost, doesn't regen) added -- see mobs/Black_Baron.lua for the full writeup. No changes
-- needed here; the warp behavior lives entirely in the mob's own onMobFight.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Periqia
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_34_START, 34)
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
    for i, v in pairs(ID.mob[34]) do
        forceAggro(SpawnMob(v, instance))
    end

    -- 2026-08-23: real positions, triple-confirmed exact across 3 independent captures (Thris
    -- PathLog + Giichi/Siknawz NPCLogger snapshots, all agreeing to 3 decimals) -- were sitting at
    -- npc_list's shared default (-60.047,-15.282,415.192 / -61.961,-15.250,422.430), correct for
    -- other Periqia missions reusing these same 2 npcids but wrong for this one.
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(-143.905, -15.257, -65.603, 138)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(-147.803, -15.370, -67.707, 144)

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress >= 1 then
        instance:complete()
    end
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 8, 8)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

