require("scripts/globals/teleports")
-----------------------------------
-- Area: Leujaoam Sanctum
-----------------------------------
require("scripts/globals/besieged")
local ID = Leujaoam
-----------------------------------
-- 2026-08-18: the old logic only awarded points for id == 1 (flat 1000, minus 100/extra party
-- member past 3) -- every other mission in this zone gave ZERO Assault points on completion.
-- 2026-08-30, REPLACED with the user's own compiled Assault Rewards reference worksheet
-- ("Max AP (3 players / base)" column), superseding the individual real-capture values used
-- before. User's own reasoning: single-capture values aren't absolute -- they can be skewed by
-- whether every objective was met, party composition, or reward-boosting equipment, none of which
-- the worksheet's baseline figure depends on. Party-size falloff shape kept as before -- its exact
-- rate past 3 players is still not independently confirmed.
local BASE_ASSAULT_POINTS =
{
    [1]  = 1000, -- Leujaoam Cleansing (user-provided Assault Rewards worksheet)
    [2]  = 1200, -- Orichalcum Survey (user-provided Assault Rewards worksheet)
    [3]  = 1100, -- Escort Professor Chanoix (user-provided Assault Rewards worksheet)
    -- [4] Shanarha Grass Conservation -- variable, see SHANARHA_AP_PER_VEGETATION/MAX below.
    [5]  = 1166, -- Counting Sheep (user-provided Assault Rewards worksheet)
    [6]  = 1000, -- Supplies Recovery (user-provided Assault Rewards worksheet)
    [7]  = 1000, -- Azure Experiments (user-provided Assault Rewards worksheet)
    [8]  = 1333, -- Imperial Code (user-provided Assault Rewards worksheet)
    [9]  = 1666, -- Red versus Blue (user-provided Assault Rewards worksheet)
    [10] = 1500, -- Bloody Rondo (user-provided Assault Rewards worksheet)
}

-- 2026-08-30, Shanarha Grass Conservation (id 4) user-specified modifier: "50 AP per vegetation
-- remaining, still capped at 1333." vegetation_remaining is tracked on the instance already
-- (mobs/Coney.lua decrements it on each real eat; instances/shanarha_grass_conservation.lua sets
-- the starting count).
local SHANARHA_AP_PER_VEGETATION = 50
local SHANARHA_AP_MAX = 1333

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()

    if (instance:completed()) then
        player:startEvent(100, 0)
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
        if id == 4 then
            local remaining = instance:getLocalVar("vegetation_remaining")
            local shanarhaBase = math.min(SHANARHA_AP_MAX, SHANARHA_AP_PER_VEGETATION * remaining)
            points = shanarhaBase - math.max(0, playerpoints)
        elseif BASE_ASSAULT_POINTS[id] then
            points = BASE_ASSAULT_POINTS[id] - math.max(0, playerpoints)
        end
        points = math.max(points, 0)
        for i, v in pairs(chars) do
            v:messageSpecial(ID.text.ASSAULT_POINTS_OBTAINED, points)
            v:addAssaultPoint(LEUJAOAM_ASSAULT_POINT, points)
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
    if (csid == 102) then
        AzouphIsleStagingPoint(player) -- real staging point (globals/teleports.lua), was setPos(0,0,0) = zone default arrival
    end
end

