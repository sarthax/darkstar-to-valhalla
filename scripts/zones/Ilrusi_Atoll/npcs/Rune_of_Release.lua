require("scripts/globals/teleports")
-----------------------------------
-- Area: Ilrusi Atoll
--  NPC: Rune of Release
-- !pos 412 -9 54 55
-----------------------------------
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/besieged")
-----------------------------------
-- 2026-08-18: same single-id-gated points bug found and fixed in the other 4 zones -- only
-- id 41/43 ever paid out here, every other Ilrusi Atoll mission gave 0 points. Restructured to
-- a lookup table.
-- 2026-08-30, REPLACED with the user's own compiled Assault Rewards reference worksheet
-- ("Max AP (3 players / base)" column), superseding the individual real-capture values used
-- before (single-capture values aren't absolute -- objectives met, party composition, and
-- reward-boosting equipment can all skew them). Deserter (48) and Desperately Seeking
-- Cephalopods (49) have no worksheet value ("verify exact maximum" in the source notes) --
-- left at their prior real-capture values since nothing better exists yet.
-- 2026-08-30: Demolition Duty (44) is NOT flat -- see DEMOLITION_AP_PER_SCORE below. Real wiki
-- data point: "a score of 10 (one repair, no replacements) was worth 1000 points each for a party
-- of 3" -- a clean 100 AP/score-point fit, matching the worksheet's flat 1000 exactly at a clean
-- score-10 run (single data point, not independently re-confirmed).
local DEMOLITION_AP_PER_SCORE = 100

local BASE_ASSAULT_POINTS =
{
    [41] = 1100, -- Golden Salvage (user-provided Assault Rewards worksheet)
    [42] = 1200, -- Lamia No.13 (user-provided Assault Rewards worksheet)
    [43] = 1100, -- Extermination (user-provided Assault Rewards worksheet)
    -- [44] Demolition Duty -- variable, see DEMOLITION_AP_PER_SCORE above.
    [45] = 1166, -- Searat Salvation (user-provided Assault Rewards worksheet)
    [46] = 1333, -- Apkallu Seizure (user-provided Assault Rewards worksheet)
    [47] = 1000, -- Lost and Found (user-provided Assault Rewards worksheet)
    [48] = 952,  -- Deserter (real capture, solo -- no worksheet value available)
    [49] = 1100, -- Desperately Seeking Cephalopods (real capture, solo -- no worksheet value available)
    [50] = 1500, -- Bellerophon's Bliss (user-provided Assault Rewards worksheet)
}

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()

    if (instance:completed()) then
        player:startEvent(100, 4)
    end

    return 1
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    local instance = player:getInstance()
    local chars = instance:getChars()
    local id = instance:getID()
    local points = 0
    local playerpoints = ((#chars -3)*100)

    if (csid == 100 and option == 1) then
        if id == 44 then
            points = (instance:getLocalVar("demolitionScore") * DEMOLITION_AP_PER_SCORE) - math.max(playerpoints, 0)
        elseif BASE_ASSAULT_POINTS[id] then
            points = BASE_ASSAULT_POINTS[id] - math.max(playerpoints, 0)
        end
        points = math.max(points, 0)
        for i, v in pairs(chars) do
            v:messageSpecial(ASSAULT_POINTS_OBTAINED, points)
            v:addAssaultPoint(ILRUSI_ASSAULT_POINT, points)
            v:setVar("AssaultComplete", 1)
            v:addVar("AssaultsCompleted", 1)
            if (v:hasCompletedAssault(v:getCurrentAssault())) then
                local currentPromotion = (v:getVar("AssaultPromotion") or 0) + 1
                capPromotionPoints(v, currentPromotion)
            else
                local currentPromotion = (v:getVar("AssaultPromotion") or 0) + 5
                capPromotionPoints(v, currentPromotion)
            end
            v:startEvent(102)
        end
    end
    if csid == 102 then
        for i, v in pairs(chars) do
            IlrusiAtollStagingPoint(v) -- real staging point (globals/teleports.lua), was setPos(0,0,0) = zone default arrival
        end
    end
end

