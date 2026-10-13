-----------------------------------
-- Salvage: Zhayolm Remnants
-----------------------------------
-- 2026-10-01: port of LandSandBoat's Zhayolm_Remnants instance to Topaz's instance API, modeled on
-- the working Arrapago/Bhaflau instance files. All ids are Topaz's own (IDs.lua); text ids were
-- verified against a same-session dialog.yml pull.
--
-- Differences from LSB, forced by this fork's API:
--   * trigger areas -> zone:registerRegion + onRegionEnter (csid = 199 + regionID, bare call)
--   * LSB does stage bookkeeping in onEventUpdate; here it runs in onEventFinish (option == 1)
--   * csid 101 (zone-in intro) is NOT played: no confirmed Topaz calling convention for it
-- Port gaps (NOT invented): Poroggo Gent has only 24 Topaz ids, LSB's north path 3 needs 25-36.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
require("scripts/zones/Zhayolm_Remnants/IDs")
local util = require("scripts/zones/Zhayolm_Remnants/zhayolm_util")
-----------------------------------
local slice = util.slice
local D = Zhayolm.npcs.DOOR

-- mobTable[stage][progress] = groups to spawn on arrival (LSB's mobTable, Topaz ids)
local mobTable =
{
    [1] =
    {
        [1] =
        {
            Zhayolm.mobs.PUK,
            Zhayolm.mobs.ZIZ,
            Zhayolm.mobs.VAGRANT_LINDWURM,
            Zhayolm.mobs.BULL_BUGARD,
            slice(Zhayolm.mobs.MAMOOL_JA_ZENIST, 1, 4),
        },
    },
    [2] =
    {
        [1] = slice(Zhayolm.mobs.DRACO_LIZARD, 9, 16),
        [2] = slice(Zhayolm.mobs.DRACO_LIZARD, 1, 8),
        [3] = slice(Zhayolm.mobs.WYVERN, 9, 16),
        [4] = slice(Zhayolm.mobs.WYVERN, 1, 8),
    },
    [3] =
    {
        [0] =
        {
            { -- south path
                slice(Zhayolm.mobs.MAMOOL_JA_ZENIST, 6, 12),
                slice(Zhayolm.mobs.MAMOOL_JA_SPEARMAN, 2, 8),
                slice(Zhayolm.mobs.MAMOOL_JA_STRAPPER, 1, 7),
                slice(Zhayolm.mobs.MAMOOL_JA_BOUNDER, 2, 4),
                Zhayolm.mobs.ARCHAIC_RAMPART[1],
            },
            { -- north path
                slice(Zhayolm.mobs.MAMOOL_JA_SAVANT, 2, 11),
                slice(Zhayolm.mobs.MAMOOL_JA_SOPHIST, 1, 10),
                slice(Zhayolm.mobs.MAMOOL_JA_MIMICKER, 1, 12),
                Zhayolm.mobs.ARCHAIC_RAMPART[2],
            },
        },
    },
    [4] =
    {
        [1] = -- south path
        {
            Zhayolm.mobs.MAMOOL_JA_ZENIST[13],
            Zhayolm.mobs.MAMOOL_JA_SPEARMAN[9],
            Zhayolm.mobs.MAMOOL_JA_STRAPPER[8],
            Zhayolm.mobs.MAMOOL_JA_BOUNDER[5],
            Zhayolm.mobs.FIRST_RAMPART[1],
            Zhayolm.mobs.SECOND_RAMPART[1],
            Zhayolm.mobs.THIRD_RAMPART[1],
            Zhayolm.mobs.FOURTH_RAMPART[1],
            slice(Zhayolm.mobs.POROGGO_GENT, 5, 12),
        },
        [2] = -- north path
        {
            slice(Zhayolm.mobs.MAMOOL_JA_SAVANT, 12, 13),
            slice(Zhayolm.mobs.MAMOOL_JA_SOPHIST, 10, 11),
            slice(Zhayolm.mobs.MAMOOL_JA_MIMICKER, 13, 14),
            Zhayolm.mobs.FIRST_RAMPART[2],
            Zhayolm.mobs.SECOND_RAMPART[2],
            Zhayolm.mobs.THIRD_RAMPART[2],
            Zhayolm.mobs.FOURTH_RAMPART[2],
            slice(Zhayolm.mobs.POROGGO_GENT, 13, 24),
        },
        [3] =
        {
            slice(Zhayolm.mobs.MAMOOL_JA_SAVANT, 14, 15),
            slice(Zhayolm.mobs.MAMOOL_JA_SOPHIST, 12, 13),
            slice(Zhayolm.mobs.MAMOOL_JA_MIMICKER, 15, 16),
            Zhayolm.mobs.FIRST_RAMPART[3],
            Zhayolm.mobs.SECOND_RAMPART[3],
            Zhayolm.mobs.THIRD_RAMPART[3],
            Zhayolm.mobs.FOURTH_RAMPART[3],
            -- LSB also spawns POROGGO_GENT 25-36 here; Topaz has no such ids
        },
    },
    [5] =
    {
        [1] = -- north
        {
            slice(Zhayolm.mobs.ARCHAIC_GEARS, 1, 8),
            slice(Zhayolm.mobs.ARCHAIC_GEARS, 9, 12),
            slice(Zhayolm.mobs.ARCHAIC_GEARS, 25, 32),
            slice(Zhayolm.mobs.ARCHAIC_GEARS, 13, 24),
            slice(Zhayolm.mobs.ARCHAIC_RAMPART, 7, 10),
            Zhayolm.mobs.ARCHAIC_CHARIOT[2],
        },
        [2] = -- south
        {
            slice(Zhayolm.mobs.ARCHAIC_GEAR, 1, 8),
            slice(Zhayolm.mobs.ARCHAIC_GEAR, 17, 20),
            slice(Zhayolm.mobs.ARCHAIC_GEAR, 9, 16),
            slice(Zhayolm.mobs.ARCHAIC_RAMPART, 3, 6),
            Zhayolm.mobs.ARCHAIC_CHARIOT[2],
        },
    },
    [6] =
    {
        [1] =
        {
            Zhayolm.mobs.ARCHAIC_CHARIOT[3],
            slice(Zhayolm.mobs.ARCHAIC_RAMPART, 11, 12),
        },
    },
    [7] =
    {
        [1] = { Zhayolm.mobs.BATTLECLAD_CHARIOT },
    },
}

local pathos =
{
    EFFECT_ENCUMBRANCE_I,
    EFFECT_OBLIVISCENCE,
    EFFECT_OMERTA,
    EFFECT_IMPAIRMENT,
    EFFECT_DEBILITATION,
}

-- number of party members who have shed every pathos
local function removedPathos(instance)
    local count = 0
    for _, p in pairs(instance:getChars()) do
        local clean = true
        for _, effect in ipairs(pathos) do
            if p:hasStatusEffect(effect) then
                clean = false
            end
        end
        if clean then
            count = count + 1
        end
    end
    return count
end

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(Zhayolm.text.TIME_TO_COMPLETE, instance:getTimeLimit())
    player:messageSpecial(Zhayolm.text.SALVAGE_START, 1)
    player:addStatusEffectEx(EFFECT_ENCUMBRANCE_I, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 6000)
    player:addStatusEffectEx(EFFECT_OBLIVISCENCE, EFFECT_OBLIVISCENCE, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_OMERTA, EFFECT_OMERTA, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_IMPAIRMENT, EFFECT_IMPAIRMENT, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_DEBILITATION, EFFECT_DEBILITATION, 0x1FF, 0, 6000)
    for i = 0, 15 do
        player:unequipItem(i)
    end
end

function onInstanceCreated(instance)
    instance:setStage(1)
    instance:setProgress(1)
    instance:setLocalVar('dayElement', VanadielDayElement() + 1) -- +1 because Firesday is 0
    instance:setLocalVar('timeEntered', os.time())
    util.spawnGroup(instance, mobTable[1][1])
    util.unsealDoors(instance, D._210)

    -- Slot/Socket stay hidden until the floor-2 transports reveal them (LSB: csid 200 / 203)
    for _, id in ipairs({ Zhayolm.npcs.SOCKET, Zhayolm.npcs.SLOT }) do
        local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if npc then
            npc:setStatus(STATUS_DISAPPEAR)
        end
    end
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, Zhayolm.text)

    if instance:getStage() == 5 and instance:getLocalVar('spawned5th') == 0 then
        local count = removedPathos(instance)
        local progress = instance:getProgress()

        if progress == 1 and count >= 3 then
            instance:setLocalVar('spawned5th', 1)
            SpawnMob(Zhayolm.mobs.POROGGO_MADAME[7], instance)
        elseif progress == 2 and count >= 1 then
            instance:setLocalVar('spawned5th', 1)
            SpawnMob(Zhayolm.mobs.POROGGO_MADAME[6], instance)
        end
    end
end

function onInstanceFailure(instance)
    for _, mob in pairs(instance:getMobs()) do
        DespawnMob(mob:getID(), instance)
    end
    for _, v in pairs(instance:getChars()) do
        v:messageSpecial(Zhayolm.text.MISSION_FAILED, 10, 10)
        v:startEvent(1) -- bare call, same as Arrapago/Bhaflau
    end
end

function onInstanceComplete(instance)
end

-- Regions 1-11 are the stage telepads, 12/13 the boss-floor exit pair (csid 211)
function onRegionEnter(player, region)
    local instance = player:getInstance()
    if not instance then
        return
    end

    local areaID = region:GetRegionID()

    if instance:getLocalVar('stageComplete') == instance:getStage() or instance:completed() then
        if areaID <= 11 then
            player:startEvent(199 + areaID)
        elseif instance:getLocalVar('exitPoint') == areaID and player:getLocalVar('responded') == 0 then
            player:startEvent(211)
            player:setLocalVar('responded', 1)
        end
    elseif areaID == 9 and instance:getLocalVar('notComplete') == 1 then
        player:startEvent(206)
    elseif player:getLocalVar('responded') == 0 then
        player:messageSpecial(Zhayolm.text.NOT_RESPONDING)
        player:setLocalVar('responded', 1)
    end
end

function onRegionLeave(player, region)
    player:setLocalVar('responded', 0)
end

local function bossFloorSpawn(instance, madameIndex, minutes)
    local boss = GetMobByID(Zhayolm.mobs.POROGGO_MADAME[madameIndex], instance)
    if
        boss and
        instance:getLocalVar('timeEntered') + (minutes * 60) >= os.time() and
        boss:getLocalVar('spawned') == 0
    then
        SpawnMob(Zhayolm.mobs.POROGGO_MADAME[madameIndex], instance)
        boss:setLocalVar('spawned', 1)
    end
end

function onEventFinish(player, csid, option)
    local instance = player:getInstance()
    if not instance then
        return
    end

    if csid == 1 then
        for _, effect in ipairs(pathos) do
            player:delStatusEffectSilent(effect)
        end
        player:setPos(-580, 0, -433, 64, ALZADAAL_UNDERSEA_RUINS)
        return
    end

    if csid == 211 and option == 1 then
        for _, v in pairs(instance:getChars()) do
            v:startEvent(1)
        end
        return
    end

    if option ~= 1 or csid < 200 or csid > 210 then
        return
    end

    -- floor 4: a party that took the north path without finishing can re-enter via region 9
    if csid == 206 and instance:getLocalVar('notComplete') == 1 and instance:getLocalVar('stageComplete') ~= instance:getStage() then
        if util.onTransportUpdate(player, instance) then
            util.unsealDoors(instance, D._21c)
            instance:setLocalVar('notComplete', 0)
            instance:setProgress(instance:getProgress() == 2 and 3 or 2)
            util.teleportGroup(player)
        end
        return
    end

    if instance:getLocalVar('stageComplete') ~= instance:getStage() then
        return
    end
    if not util.onTransportUpdate(player, instance) then
        return
    end

    if csid >= 200 and csid <= 203 then
        instance:setStage(2)
        instance:setProgress(csid - 199)
    elseif csid == 204 then
        instance:setStage(3)
        instance:setProgress(0)
        util.unsealDoors(instance, { D._219, D._21a })
    elseif csid == 205 then -- south path
        instance:setStage(4)
        instance:setProgress(1)
        util.unsealDoors(instance, D._21b)
    elseif csid == 206 then -- north path
        instance:setStage(4)
        instance:setProgress(math.random(2, 3))
        util.unsealDoors(instance, D._21c)
    elseif csid == 207 then
        instance:setStage(5)
        instance:setProgress(2)
    elseif csid == 208 then
        instance:setStage(5)
        instance:setProgress(1)
    elseif csid == 209 then
        instance:setStage(6)
        instance:setProgress(1)
        if instance:getLocalVar('killedNMs') >= 4 then
            SpawnMob(Zhayolm.mobs.POROGGO_MADAME[8], instance)
        end
    elseif csid == 210 then
        instance:setStage(7)
        instance:setProgress(1)
        util.unsealDoors(instance, D._21g)
    end

    util.teleportGroup(player)

    local stageTable = mobTable[instance:getStage()]
    local groups = stageTable and stageTable[instance:getProgress()]
    if groups then
        util.spawnGroup(instance, groups)
    end

    if csid == 200 then
        local npc = instance:getEntity(bit.band(Zhayolm.npcs.SOCKET, 0xFFF), TYPE_NPC)
        if npc then npc:setStatus(STATUS_NORMAL) end
    elseif csid == 203 then
        local npc = instance:getEntity(bit.band(Zhayolm.npcs.SLOT, 0xFFF), TYPE_NPC)
        if npc then npc:setStatus(STATUS_NORMAL) end
    elseif csid == 205 then
        bossFloorSpawn(instance, 4, 47)
    elseif csid == 206 then
        bossFloorSpawn(instance, 5, 30)
    elseif csid == 207 then
        util.unsealDoors(instance, D._21e)
    elseif csid == 208 then
        util.unsealDoors(instance, D._21d)
    elseif csid == 210 then
        instance:setLocalVar('exitPoint', math.random(12, 13))
    end
end

