require("scripts/globals/teleports")
-----------------------------------
-- Area: Ilrusi Atoll
--  NPC: Rune of Release
-- !pos 412 -9 54 55
-----------------------------------
local ID = Periqia
require("scripts/globals/besieged")
-----------------------------------
-- 2026-08-18: same single-id-gated points bug found and fixed in the other 4 zones -- only
-- id 32 ever paid out here, every other Periqia mission gave 0 points. Restructured to a lookup
-- table.
-- 2026-08-30, REPLACED with the user's own compiled Assault Rewards reference worksheet
-- ("Max AP (3 players / base)" column), superseding the individual real-capture values used
-- before (single-capture values aren't absolute -- objectives met, party composition, and
-- reward-boosting equipment can all skew them). Wake the Puppet (39) notes "up to 6 puppets
-- increases AP" but gives no per-puppet formula -- left at the worksheet's flat base.
local BASE_ASSAULT_POINTS =
{
    [31] = 1100, -- Seagull Grounded (user-provided Assault Rewards worksheet)
    [32] = 1000, -- Requiem (user-provided Assault Rewards worksheet)
    [33] = 1100, -- Saving Private Ryaaf (user-provided Assault Rewards worksheet)
    [34] = 1100, -- Shooting Down the Baron (user-provided Assault Rewards worksheet)
    [35] = 1200, -- Building Bridges (user-provided Assault Rewards worksheet)
    [36] = 1000, -- Stop the Bloodshed (user-provided Assault Rewards worksheet)
    [37] = 1600, -- Defuse the Threat (user-provided Assault Rewards worksheet)
    [38] = 1333, -- Operation: Snake Eyes (user-provided Assault Rewards worksheet)
    [39] = 1200, -- Wake the Puppet (user-provided Assault Rewards worksheet)
    [40] = 1500, -- The Price is Right (user-provided Assault Rewards worksheet)
}

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()

    if (instance:completed()) then
        player:startEvent(100, 3)
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
        if BASE_ASSAULT_POINTS[id] then
            points = BASE_ASSAULT_POINTS[id] - math.max(playerpoints, 0)
        end
        for i, v in pairs(chars) do
            v:messageSpecial(ID.text.ASSAULT_POINTS_OBTAINED, points)
            v:addAssaultPoint(PERIQIA_ASSAULT_POINT, points)
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
            DvuccaIsleStagingPoint(v) -- real staging point (globals/teleports.lua), was setPos(0,0,0) = zone default arrival
        end
    end
end

