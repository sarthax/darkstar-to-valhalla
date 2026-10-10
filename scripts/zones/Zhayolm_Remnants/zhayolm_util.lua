-----------------------------------
-- Zhayolm Remnants -- shared Salvage door/stage helpers.
-----------------------------------
-- 2026-10-01: Topaz-API port of LandSandBoat's xi.salvage helpers (onDoorOpen, sealDoors,
-- unsealDoors, spawnGroup, groupKilled, deSpawnStage, onTransportUpdate, teleportGroup,
-- openBossDoor). Same unSealed-localVar door model as Bhaflau's door_util.lua, but the spawn/kill
-- helpers recurse through nested tables because LSB's Zhayolm mobTable nests named sub-groups
-- (NORTH_EAST, FIRST_ROOM_GEARS, ...). Kept zone-local like Bhaflau's rather than touching the
-- shared scripts/globals/salvage.lua.
-----------------------------------
require("scripts/globals/status")
require("scripts/globals/world")
require("scripts/globals/salvage")
require("scripts/zones/Zhayolm_Remnants/IDs")
-----------------------------------
function onDoorOpen(npc, stage, progress)
    local instance = npc:getInstance()

    if npc:getAnimation() == ANIMATION_CLOSE_DOOR and npc:getLocalVar('unSealed') == 1 then
        npc:setLocalVar('unSealed', 0)
        if stage ~= nil then
            instance:setStage(stage)
        end
        if progress ~= nil then
            instance:setProgress(progress)
        end
        npc:setAnimation(ANIMATION_OPEN_DOOR)
        npc:untargetable(true)
        return true
    end

    return false
end

local function setSeal(instance, ids, value)
    if type(ids) ~= "table" then
        ids = { ids }
    end
    for _, id in pairs(ids) do
        local door = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if door then
            door:setLocalVar('unSealed', value)
        end
    end
end

function sealDoors(instance, ids) setSeal(instance, ids, 0) end
function unsealDoors(instance, ids) setSeal(instance, ids, 1) end

-- Visits every mob id in a (possibly nested) table with fn(id).
local function each(group, fn)
    if type(group) == "table" then
        for _, v in pairs(group) do
            each(v, fn)
        end
    elseif group ~= nil then
        fn(group)
    end
end

function spawnGroup(instance, group)
    each(group, function(id)
        local mob = SpawnMob(id, instance)
        if mob then
            mob:setLocalVar('spawned', 1)
        end
    end)
end

-- True once every mob in the group has been spawned and is dead.
function groupKilled(instance, group)
    local done = true
    each(group, function(id)
        local mob = GetMobByID(id, instance)
        if mob and (mob:getLocalVar('spawned') == 0 or mob:isAlive()) then
            done = false
        end
    end)
    return done
end

function slice(tbl, first, last)
    local sliced = {}
    for i = first, last do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

function deSpawnStage(instance)
    for _, mob in pairs(instance:getMobs()) do
        DespawnMob(mob:getID(), instance)
    end
end

-- Same single-user transport lock as LSB's onTransportUpdate: the first player to take a telepad
-- clears the old stage's mobs/temp chests and is the only one whose arrival spawns the next stage.
function onTransportUpdate(player, instance)
    if instance:getLocalVar('transportUser') ~= 0 then
        return false
    end

    instance:setLocalVar('transportUser', player:getID())
    instance:setLocalVar('stageComplete', 0)
    salvageUtil.resetTempBoxes(player)
    deSpawnStage(instance)
    -- LSB also release()s other chars stuck in an event here; Topaz has no isInEvent(), and
    -- followers are pulled by teleportGroup's own startEvent(3) anyway

    player:timer(10000, function(p)
        instance:setLocalVar('transportUser', 0)
    end)
    return true
end

-- Followers play the baked transport event (csid 3) and are moved to the triggering player.
function teleportGroup(player)
    local instance = player:getInstance()
    local pos = player:getPos()

    for _, v in pairs(instance:getChars()) do
        if v:getID() ~= player:getID() then
            v:startEvent(3, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- same padded csid-3 call as Arrapago/Bhaflau
            v:timer(4000, function(p)
                p:setPos(pos.x, pos.y, pos.z, pos.rot)
                p:setHP(p:getMaxHP())
                p:setMP(p:getMaxMP())
                local pet = p:getPet()
                if pet then
                    pet:setPos(pos.x, pos.y, pos.z, pos.rot)
                    pet:setHP(pet:getMaxHP())
                    pet:setMP(pet:getMaxMP())
                end
            end)
        end
    end
end

-- Boss door pair: this door (id) and its sibling (id - 1, the _21h behind _21i).
function openBossDoor(npc)
    if npc:getAnimation() == ANIMATION_CLOSE_DOOR then
        local instance = npc:getInstance()
        npc:setAnimation(ANIMATION_OPEN_DOOR)
        local other = GetNPCByID(npc:getID() - 1, instance)
        if other then
            other:setAnimation(ANIMATION_OPEN_DOOR)
        end
    end
end

-----------------------------------
-- Mob progression (LSB onMobDeath hooks, folded into one dispatcher keyed on the mob's id so the
-- per-mob stub files only need a single call). Returns true if it already handled the temp chest.
-- NOT ported (no Topaz equivalent / unverified): LSB's setDropID boss drop lists, setMaxHP on the
-- north-path Madame, and the Gent -> Madame[1] spawn gated on LSB's playerHealth()/cellsUsed.
-----------------------------------
local ITEM_FIGHTERS_DRINK = 5386
local ITEM_DUSTY_POTION   = 5431
local ITEM_DUSTY_ETHER    = 5432
local ITEM_STRANGE_MILK   = 5437

local function has(tbl, id)
    for _, v in ipairs(tbl) do
        if v == id then
            return true
        end
    end
    return false
end

local function chest(mob, item, amount)
    salvageUtil.spawnTempChest(mob, { rate = 1000, itemID_1 = item, itemAmount_1 = amount })
    return true
end

local function spawnBoss(instance, id, x, y, z)
    local boss = GetMobByID(id, instance)
    if boss and boss:getLocalVar('spawned') == 0 then
        boss:setLocalVar('spawned', 1)
        SpawnMob(id, instance)
        if x then
            boss:setPos(x, y, z, 0)
        end
    end
end

local D = Zhayolm.npcs.DOOR
local DRACO_NE, DRACO_SE = slice(Zhayolm.mobs.DRACO_LIZARD, 9, 16), slice(Zhayolm.mobs.DRACO_LIZARD, 1, 8)
local WYV_SW, WYV_NW     = slice(Zhayolm.mobs.WYVERN, 9, 16), slice(Zhayolm.mobs.WYVERN, 1, 8)

-- stage-2 clear per progress: which hidden NPCs appear and which other room groups spawn
local stage2Clear =
{
    [1] = { npcs = { Zhayolm.npcs.SLOT },                  groups = { DRACO_SE, WYV_SW, WYV_NW } },
    [2] = { npcs = { Zhayolm.npcs.SLOT, Zhayolm.npcs.SOCKET },   groups = { DRACO_NE, WYV_SW, WYV_NW } },
    [3] = { npcs = { Zhayolm.npcs.SLOT, Zhayolm.npcs.SOCKET },   groups = { DRACO_NE, DRACO_SE, WYV_NW } },
    [4] = { npcs = { Zhayolm.npcs.SOCKET },                groups = { DRACO_NE, DRACO_SE, WYV_SW } },
}

local function clearStage2(instance, progress)
    local c = stage2Clear[progress]
    instance:setLocalVar('stageComplete', 2)
    for _, id in ipairs(c.npcs) do
        local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if npc then
            npc:setStatus(STATUS_NORMAL)
        end
    end
    unsealDoors(instance, { D._215, D._216, D._217, D._218 })
    for _, g in ipairs(c.groups) do
        spawnGroup(instance, g)
    end
    -- LSB quirk kept as-is: the first call also sets the instance progress to 5
    onDoorOpen(instance:getEntity(bit.band(D._215, 0xFFF), TYPE_NPC), nil, 5)
    onDoorOpen(instance:getEntity(bit.band(D._216, 0xFFF), TYPE_NPC))
    onDoorOpen(instance:getEntity(bit.band(D._217, 0xFFF), TYPE_NPC))
    onDoorOpen(instance:getEntity(bit.band(D._218, 0xFFF), TYPE_NPC))
end

local south3 =
{
    slice(Zhayolm.mobs.MAMOOL_JA_ZENIST, 6, 12),
    slice(Zhayolm.mobs.MAMOOL_JA_SPEARMAN, 2, 8),
    slice(Zhayolm.mobs.MAMOOL_JA_STRAPPER, 1, 7),
    slice(Zhayolm.mobs.MAMOOL_JA_BOUNDER, 2, 4),
    Zhayolm.mobs.ARCHAIC_RAMPART[1],
}
local north3 =
{
    slice(Zhayolm.mobs.MAMOOL_JA_SAVANT, 2, 11),
    slice(Zhayolm.mobs.MAMOOL_JA_SOPHIST, 1, 10),
    slice(Zhayolm.mobs.MAMOOL_JA_MIMICKER, 1, 12),
    Zhayolm.mobs.ARCHAIC_RAMPART[2],
}

-- stage 3: clearing either path's group spawns that path's stage boss (Madame[3]) at its door
local function stage3Boss(instance)
    if groupKilled(instance, south3) then
        spawnBoss(instance, Zhayolm.mobs.POROGGO_MADAME[3], 380, -4, 389)
    elseif groupKilled(instance, north3) then
        spawnBoss(instance, Zhayolm.mobs.POROGGO_MADAME[3], 300, -4, 526)
    end
end

local rampartDays =
{
    { Zhayolm.mobs.FIRST_RAMPART,  0 --[[FIRESDAY]],  1 --[[EARTHSDAY]] },
    { Zhayolm.mobs.SECOND_RAMPART, 2 --[[WATERSDAY]], 3 --[[WINDSDAY]] },
    { Zhayolm.mobs.THIRD_RAMPART,  4 --[[ICEDAY]],    5 --[[LIGHTNINGDAY]] },
    { Zhayolm.mobs.FOURTH_RAMPART, 6 --[[LIGHTSDAY]], 7 --[[DARKSDAY]] },
}

local trio1 =
{
    { Zhayolm.mobs.PUK, Zhayolm.mobs.POROGGO_GENT[1] },
    { Zhayolm.mobs.ZIZ, Zhayolm.mobs.POROGGO_GENT[2] },
    { Zhayolm.mobs.VAGRANT_LINDWURM, Zhayolm.mobs.POROGGO_GENT[3] },
    { Zhayolm.mobs.BULL_BUGARD, Zhayolm.mobs.POROGGO_GENT[4] },
}

function onMobDeath(mob)
    local instance = mob:getInstance()
    if not instance then
        return false
    end

    local id       = mob:getID()
    local stage    = instance:getStage()
    local progress = instance:getProgress()

    -- floor 1: each trash group spawns its Poroggo Gent when wiped
    if stage == 1 then
        for _, t in ipairs(trio1) do
            if has(t[1], id) and groupKilled(instance, t[1]) then
                SpawnMob(t[2], instance)
            end
        end
        if has(Zhayolm.mobs.POROGGO_GENT, id) and progress == 1 then
            instance:setProgress(2)
            return chest(mob, ITEM_FIGHTERS_DRINK, 10)
        elseif has(Zhayolm.mobs.MAMOOL_JA_ZENIST, id) then
            return chest(mob, ITEM_DUSTY_POTION, 18)
        end
        return false
    end

    -- floor 2: the room's stage boss clears it; room trash chains to its boss
    if stage == 2 then
        if has(Zhayolm.mobs.MAMOOL_JA_SAVANT, id) then
            if progress == 1 then clearStage2(instance, 1) end
            return chest(mob, ITEM_STRANGE_MILK, 10)
        elseif has(Zhayolm.mobs.MAMOOL_JA_ZENIST, id) then
            if progress == 2 then clearStage2(instance, 2) end
            return chest(mob, ITEM_DUSTY_ETHER, 10)
        elseif has(Zhayolm.mobs.MAMOOL_JA_SPEARMAN, id) then
            if progress == 3 then clearStage2(instance, 3) end
            return chest(mob, ITEM_DUSTY_POTION, 10)
        elseif has(Zhayolm.mobs.MAMOOL_JA_BOUNDER, id) then
            if progress == 4 then clearStage2(instance, 4) end
            return chest(mob, ITEM_STRANGE_MILK, 10)
        elseif has(Zhayolm.mobs.DRACO_LIZARD, id) then
            if groupKilled(instance, DRACO_NE) then spawnBoss(instance, Zhayolm.mobs.MAMOOL_JA_SAVANT[1]) end
            if groupKilled(instance, DRACO_SE) then spawnBoss(instance, Zhayolm.mobs.MAMOOL_JA_ZENIST[5]) end
        elseif has(Zhayolm.mobs.WYVERN, id) then
            if groupKilled(instance, WYV_SW) then spawnBoss(instance, Zhayolm.mobs.MAMOOL_JA_SPEARMAN[1]) end
            if groupKilled(instance, WYV_NW) then spawnBoss(instance, Zhayolm.mobs.MAMOOL_JA_BOUNDER[1]) end
        end
        return false
    end

    if stage == 3 then
        stage3Boss(instance)
        if has(Zhayolm.mobs.ARCHAIC_RAMPART, id) then
            return chest(mob, nil, nil)
        end
        return false
    end

    -- floor 4: whichever Rampart matches the entering day's element completes the stage
    if stage == 4 then
        for _, r in ipairs(rampartDays) do
            if has(r[1], id) then
                local day = instance:getLocalVar('dayElement') - 1
                if day == r[2] or day == r[3] then
                    instance:setLocalVar('stageComplete', 4)
                else
                    instance:setLocalVar('notComplete', 1)
                end
            end
        end
        return false
    end

    if stage == 5 and has(Zhayolm.mobs.ARCHAIC_RAMPART, id) and id ~= Zhayolm.mobs.ARCHAIC_RAMPART[6] and id ~= Zhayolm.mobs.ARCHAIC_RAMPART[10] then
        return chest(mob, nil, nil)
    end

    -- floor 6: 13 kills (gears/gear/chariot) open the exit door
    if stage == 6 and (has(Zhayolm.mobs.ARCHAIC_GEAR, id) or has(Zhayolm.mobs.ARCHAIC_GEARS, id) or has(Zhayolm.mobs.ARCHAIC_CHARIOT, id)) then
        instance:setLocalVar('6th Door', instance:getLocalVar('6th Door') + 1)
    end

    return false
end

