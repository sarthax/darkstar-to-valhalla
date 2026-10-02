-----------------------------------
-- Area: Ilrusi Atoll (Demolition Duty)
--  NPC: Uzhahn
-----------------------------------
-- DSP port of the Topaz npcs/Uzhahn.lua (same mission, same logic). This file did not exist in
-- old-dsp-reference at all -- with no script, triggering Uzhahn did nothing, so no automaton was
-- ever issued in mission 44. Text ids are the globals already present in this zone's TextIDs.lua.
-- Topaz's ID.npc.* / ID.text.* table lookups are replaced by the literal real ids (17002656 Uzhahn,
-- 17002545 Demolition Automaton) used everywhere else in this DSP zone folder.
-----------------------------------
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/status")
-----------------------------------
local UZHAHN_ID = 17002656
local AUTOMATON_ID = 17002545

local REPAIR_RANGE = 8
local REPAIR_DURATION_MS = 8000
local SCORE_BASE = 10
local SCORE_PENALTY_PER_REPLACEMENT = 2

-- Spawns (or respawns) the automaton bound to `player` as its master.
local function issueAutomaton(player, instance)
    local pos = player:getPos()
    local automaton = GetMobByID(AUTOMATON_ID, instance)
    automaton:setSpawn(pos.x, pos.y, pos.z, pos.rot)
    SpawnMob(AUTOMATON_ID, instance)
    automaton:setPos(pos.x, pos.y, pos.z, pos.rot)
    automaton:setLocalVar("master", player:getID())
    automaton:setLocalVar("leashCounting", 0)
    automaton:setLocalVar("repairing", 0)
    automaton:setLocalVar("wreckageTargetId", 0)
    instance:setLocalVar("automatonId", AUTOMATON_ID)
    instance:setLocalVar("automatonLostToLeash", 0)
end

local function beginRepair(automaton, instance, durationMs)
    automaton:setLocalVar("repairing", 1)
    automaton:setLocalVar("repairHpAtStart", automaton:getHP())
    automaton:timer(durationMs, function()
        if automaton:getLocalVar("repairing") ~= 1 then
            return -- cancelled (took damage) -- Demolition_Automaton.lua already handled the abort
        end
        automaton:setLocalVar("repairing", 0)
        automaton:setHP(automaton:getMaxHP())
        local master = GetPlayerByID(automaton:getLocalVar("master"))
        if master then
            master:messageText(instance:getEntity(bit.band(UZHAHN_ID, 0xFFF), TYPE_NPC), UZHAHN_REPAIR_SUCCESS)
        end
    end)
end

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = player:getInstance()
    if not instance or instance:completed() then
        return
    end

    if instance:getLocalVar("wreckageDestroyed") >= 5 then
        local score = instance:getLocalVar("demolitionScore")
        for i, v in pairs(instance:getChars()) do
            v:messageSpecial(UZHAHN_DEMOLITION_COMPLETE, score)
        end
        -- driven by instances/demolition_duty.lua onInstanceTimeUpdate (npc:timer callbacks derefed a freed npc)
        if instance:getLocalVar("completeStage") == 0 then
            instance:setLocalVar("completeStage", 1)
            instance:setLocalVar("completeAt", os.time() + 4)
        end
        return
    end

    local automatonId = instance:getLocalVar("automatonId")
    local automaton = nil
    if automatonId ~= 0 then
        automaton = GetMobByID(automatonId, instance)
    end

    if automaton and automaton:isAlive() then
        if automaton:getLocalVar("master") ~= player:getID() then
            return -- only one automaton at a time; no real text for this case
        end
        if player:checkDistance(automaton) > REPAIR_RANGE then
            player:messageText(npc, UZHAHN_REPAIR_NO_AUTOMATON)
            return
        end
        if automaton:getHPP() >= 100 then
            return
        end
        player:messageText(npc, UZHAHN_REPAIR_START)
        beginRepair(automaton, instance, REPAIR_DURATION_MS)
        return
    end

    if instance:getLocalVar("automatonEverIssued") == 1 then
        local lostToLeash = instance:getLocalVar("automatonLostToLeash") == 1
        player:messageText(npc, lostToLeash and UZHAHN_AUTOMATON_LOST or UZHAHN_AUTOMATON_BROKEN)
        instance:setLocalVar("demolitionScore", math.max(0, instance:getLocalVar("demolitionScore") - SCORE_PENALTY_PER_REPLACEMENT))
    else
        player:messageText(npc, UZHAHN_ASSIGN_AUTOMATON)
        instance:setLocalVar("automatonEverIssued", 1)
        instance:setLocalVar("demolitionScore", SCORE_BASE)
    end

    issueAutomaton(player, instance)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end
