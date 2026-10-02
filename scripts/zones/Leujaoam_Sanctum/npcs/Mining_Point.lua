-----------------------------------
-- Area: Leujaoam Sanctum (Orichalcum Survey)
-- NPC: Mining Point
-----------------------------------
-- 2026-09-14: this file used to also handle Counting Sheep's (mission 5) 7 real Mining Points,
-- which share this exact npc_list.name ('Mining_Point') with Orichalcum Survey's 10 -- Topaz's
-- script lookup is by name within a zone folder, so both missions' Mining Points would resolve to
-- this one file. That branch required scripts/zones/Leujaoam_Sanctum/npcs/counting_sheep_common
-- -- a real module that only ever existed in this project's source/ tree, never shipped in this
-- package (Counting Sheep is intentionally excluded, see MANIFEST.md) -- so every trigger of ANY
-- Mining Point in this zone crashed on a missing require(), including Orichalcum Survey's own,
-- which IS in scope. Removed the Counting Sheep branch and its dependency entirely per user
-- direction (2026-09-14): not porting Counting Sheep yet, add it back (with its own real common
-- module) once more Assault zones are done and this package gets overwritten/expanded.
-----------------------------------
local ID = Leujaoam
require("scripts/globals/status")
-----------------------------------
local PICKAXE_ITEM       = 605
local ORE_ITEM           = 739
local PEBBLE_ITEM        = 17296
local ZINC_ORE_ITEM      = 642
local ORE_CHANCE_PCT     = 50 -- 2026-09-14, temporarily raised for testing ore-grant path; real value is 2-5.
local HAZARD_CHANCE_PCT  = 20 -- More worms
-- 2026-08-27, user-requested: was pulling from the shared, global MINING_BREAK_CHANCE
-- (scripts/globals/settings.lua, 33%) also used by regular overworld HELM mining -- changing that
-- would have affected mining everywhere, not just this mission. Decoupled into its own constant so
-- this mission's break rate can be tuned independently.
local MISSION_MINING_BREAK_CHANCE = 20
local PEBBLE_CHANCE_PCT  = 50 -- More items

local CYCLE_HIDE_SECONDS = 120 -- How often mining points move.
local USES_BEFORE_CYCLE  = 6  -- How many attempts at mining a node.  I went with 6

-- CSID Event Mappings
-- Currently while testing, Topaz does not have these CSID mapped to packets. So nothing will happen and you have to cancel out of the "frozen 
-- Animation for the script to continue.  Originally I had this set to play a kneel emote but decided to code it to the standard CSID
-- As Mining "should" work on Valhalla and these are valid IDS per Nilas.
local CSID_MINE_START    = 1041 -- Standard mining motion 1041
local CSID_ORE_OBTAINED  = 1042 -- Orichalcum Ore obtained fanfare 1042
local CSID_TOOL_BREAK    = 1043 -- Pickaxe shatters 1043
local CSID_NODE_DEPLETED = 1044 -- Node exhausted / cycled 1044
local CSID_SILENT_MISS   = 1045 -- You find nothing 1045
local CSID_HAZARD_SPAWN  = 1046 -- Mineral Eater aggro trigger 1046
local CSID_NODE_SHIFT    = 1047 -- Point relocates 1047
local CSID_INELIGIBLE    = 1048 -- Cannot mine / Missing tool 1048


local function removePickaxe(player)
    -- 2026-08-27, live-reported: delTempItem() isn't a real function -- only addTempItem() exists
    -- in lua_baseentity.cpp. Removing a temp item uses delItem() pointed at the temp-items
    -- container instead (same pattern as Mulwahah.lua's ore turn-in fix).
    player:delItem(PICKAXE_ITEM, 1, LOC_TEMPITEMS)
end

local function cyclePoint(npc, instance)
    npc:setLocalVar("attempts", 0)
    npc:hideNPC(CYCLE_HIDE_SECONDS)

    for i = 1, 10 do
        local candidate = instance:getEntity(bit.band(ID.npc["MINING_POINT" .. i], 0xFFF), TYPE_NPC)
        if candidate and candidate:getID() ~= npc:getID() and candidate:getStatus() ~= STATUS_NORMAL then
            candidate:setStatus(STATUS_NORMAL)
            break
        end
    end
end

local function cycleIfExhausted(npc, instance, player)
    local attempts = npc:getLocalVar("attempts") + 1
    if attempts >= USES_BEFORE_CYCLE then
        -- 7530: Used when the mining spot is depleted
        player:messageSpecial(ID.text.CANNOT_MINE_NOW)
        cyclePoint(npc, instance)
    else
        npc:setLocalVar("attempts", attempts)
    end
end

local function resolveMining(player, npc)
    local instance = player:getInstance()

    -- 1. Tool Break Roll
    if math.random(100) <= MISSION_MINING_BREAK_CHANCE then
        removePickaxe(player)
        -- CSID_TOOL_BREAK (1043)
        -- 7531: Used when the pickaxe breaks randomly
        player:messageSpecial(ID.text.MINING_TOOL_BROKE, PICKAXE_ITEM)
        cycleIfExhausted(npc, instance, player)
        return
    end

    local roll = math.random(1, 100)

    -- 2. Success Roll (Orichalcum Ore)
    if roll <= ORE_CHANCE_PCT then
        player:addTempItem(ORE_ITEM)
        -- CSID_ORE_OBTAINED (1042)
        -- 7525: Used when obtaining the Ore item instead of a generic temp item message
        player:messageSpecial(ID.text.FINDS_ITEM, ORE_ITEM)

        for i = 1, 8 do
            local qiqirn = GetMobByID(ID.mob[2]["QIQIRN_MINER" .. i], instance)
            if qiqirn then
                qiqirn:setAggressive(true)
                qiqirn:engage(player:getShortID())
            end
        end
        cycleIfExhausted(npc, instance, player)

    -- 3. Hazard Roll (Mineral Eater)
    elseif roll <= ORE_CHANCE_PCT + HAZARD_CHANCE_PCT then
        local eater = GetMobByID(ID.mob[2].MINERAL_EATER, instance)
        if eater and not eater:isSpawned() then
            eater:setSpawn(npc:getXPos(), npc:getYPos(), npc:getZPos(), 0)
            eater:spawn()
            eater:engage(player:getShortID())
        end
        -- 7530: Used when a worm spawns and interrupts the attempt
        player:messageSpecial(ID.text.CANNOT_MINE_NOW)
        
        -- CSID_HAZARD_SPAWN (1046) & CSID_NODE_SHIFT (1047)
        cyclePoint(npc, instance)

    -- 4. Miss / Pool Item Roll
    else
        if math.random(100) <= PEBBLE_CHANCE_PCT then
            local lootItem = (math.random(2) == 1) and PEBBLE_ITEM or ZINC_ORE_ITEM
            player:addTreasure(lootItem)
        else
            -- CSID_SILENT_MISS (1045)
            -- 7524: Standard failed roll message
            player:messageSpecial(ID.text.MINING_FIND_NOTHING)
        end
        
        -- CSID_NODE_DEPLETED (1044)
        -- Check if this attempt causes the node to cycle out
        cycleIfExhausted(npc, instance, player)
    end
end

local function tryMine(player, npc)
    -- 7529: Used when attempting to interact with a mining point when more than 2 yalms away
    if player:checkDistance(npc) > 2 then
        player:messageSpecial(ID.text.MOVE_CLOSER)
        return
    end

    -- Reject if player already holds the ore or has no pickaxe
    -- CSID_INELIGIBLE (1048) logic
    if player:hasItem(ORE_ITEM) then
        player:messageSpecial(ID.text.CANNOT_MINE_NOW)
        return
    elseif not player:hasItem(PICKAXE_ITEM) then
        -- 7528: Mining is possible here if you have a <pickaxe>
        player:messageSpecial(ID.text.MINING_POSSIBLE, PICKAXE_ITEM)
        return
    end

    -- Orient toward node
    player:lookAt(npc:getPos())

    -- 2026-08-27, user-confirmed live: player:startEvent(CSID_MINE_START) never resolved on its
    -- own -- Topaz has no real packet mapping for CSID 1041, so the client just shows a frozen
    -- mining animation with no way to naturally finish it; onEventFinish only fired if the player
    -- manually canceled out of it. In practice this meant resolveMining() almost never actually
    -- ran, so nobody ever saw a pickaxe break or a Zinc Ore -- not bad odds, a dead code path.
    -- Left the CSID-based flow in place (commented below, not deleted) since it may work as
    -- intended on a server with the real CSID packet mapped (e.g. Valhalla) -- swap this back if
    -- so. For now, use a short timer as a stand-in "mining swing" delay and resolve directly.
    -- player:startEvent(CSID_MINE_START)
    -- 2026-09-14, crash-reported (heap corruption in CBaseEntity::SetLocalVar via a queued AI
    -- action): npc was captured by this closure and used 2s later with no liveness check. If the
    -- node gets cycled/hidden by another interaction, or the instance tears down, in that window,
    -- the deferred callback ran resolveMining() -> cycleIfExhausted() -> npc:setLocalVar() through
    -- a stale/freed CBaseEntity*. Re-resolve by id when the timer actually fires instead of
    -- trusting the captured pointer, and bail cleanly if it's gone.
    -- 2026-09-14, live-reported follow-up, real cause found in luautils.cpp: the global
    -- GetNPCByID's 2nd argument must be a CLuaBaseEntity (it internally reads ->PInstance off it),
    -- not a CLuaInstance -- passing `instance` threw "bad argument #2 ... CBaseEntity expected,
    -- got userdata" regardless of timing/staleness. Use this file's own already-correct pattern
    -- instead (see cyclePoint() above): instance:getEntity() as a method call.
    local npcId = npc:getID()
    player:timer(2000, function(player)
        local instance = player:getInstance()
        local liveNpc = instance and instance:getEntity(bit.band(npcId, 0xFFF), TYPE_NPC)
        if liveNpc then
            resolveMining(player, liveNpc)
        end
    end)
end

function onTrade(player, npc, trade)
    if trade:getItemCount() == 1 and trade:hasItemQty(PICKAXE_ITEM, 1) then
        player:confirmTrade()
        tryMine(player, npc)
    end
end

function onTrigger(player, npc)
    tryMine(player, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    -- 2026-08-27: paired with the player:startEvent(CSID_MINE_START) comment-out in tryMine()
    -- above -- re-enable both together if testing on a server with CSID 1041 actually mapped.
    --[[
    if csid == CSID_MINE_START then
        local npc = player:getEventTarget()
        if npc then
            resolveMining(player, npc)
        end
    end
    --]]
end

