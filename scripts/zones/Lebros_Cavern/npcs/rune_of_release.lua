require("scripts/globals/teleports")
-----------------------------------
-- Area: Lebros Cavern
-----------------------------------
require("scripts/globals/besieged")
local ID = Lebros
-----------------------------------
-- 2026-08-18: the old logic only awarded points at all for id == 21 or 23 (a flat 1000, minus
-- 100/extra party member past 3) -- every other mission in this zone gave ZERO Assault points
-- on completion.
-- 2026-08-30, REPLACED with the user's own compiled Assault Rewards reference worksheet
-- ("Max AP (3 players / base)" column), superseding the individual real-capture values used
-- before (single-capture values aren't absolute -- objectives met, party composition, and
-- reward-boosting equipment can all skew them; the worksheet's baseline doesn't depend on any of
-- that). Operation: Black Pearl (29) has no worksheet value ("verify exact maximum" in the
-- source notes) -- left at its prior real-capture value since nothing better exists yet.
-- Party-size falloff shape kept as before -- its exact rate past 3 players is still unconfirmed.
local BASE_ASSAULT_POINTS =
{
    [21] = 1100, -- Excavation Duty (user-provided Assault Rewards worksheet)
    [22] = 1200, -- Lebros Supplies (user-provided Assault Rewards worksheet)
    [23] = 1000, -- Troll Fugitives (user-provided Assault Rewards worksheet)
    [24] = 1000, -- Evade and Escape (user-provided Assault Rewards worksheet)
    [25] = 1100, -- Siegemaster Assassination (user-provided Assault Rewards worksheet)
    [27] = 1166, -- Wamoura Farm Raid (user-provided Assault Rewards worksheet)
    [28] = 1333, -- Egg Conservation (user-provided Assault Rewards worksheet)
    [29] = 1246, -- Operation: Black Pearl (real capture, solo -- no worksheet value available)
    [30] = 1500, -- Better Than One (user-provided Assault Rewards worksheet)
    -- Apkallu Breeding (26): deliberately NOT a flat value -- see APKALLU_PAIR_VALUE below.
}

-- 2026-08-18/2026-09-02: Apkallu Breeding (26) points scale with correctly-matched pairs, not
-- party size. ffxiclopedia: max score is 8/8 correct pairs = 1300 (1430 with armband); mission
-- completes (per the real "speak to Rhap Nelhah to end early" mechanic, now built -- see
-- npcs/Rhap_Nelhah.lua and npcs/Lebros_Apkallu.lua) as soon as the player has at least 1
-- correct pair.
-- CORRECTED 2026-09-02: a real capture ("Apkallu Breeding [W] (1 Match).zip") gives an exact,
-- unambiguous data point -- solo, exactly 1 correct match, 825 Assault points. That flatly
-- disproves the earlier "1300/8 = 162.5 flat per pair" formula (which would give only ~162 for 1
-- match, not 825) -- the real curve is clearly NOT linear from zero. 825 at 1 match is 63% of the
-- 1300 max, meaning the first pair alone is worth most of the reward, with smaller per-pair gains
-- after that -- consistent with the wiki's own "for each correct pairing BEYOND THE FIRST, you get
-- ADDITIONAL Assault points" phrasing (the first pair being the big unlock, not equal to point 2
-- through 8). Modeled as linear interpolation between the 2 real anchors we have (825 @ 1 match,
-- 1300 @ 8 matches -- the wiki's own confirmed max) rather than a 0-anchored line. The earlier
-- "550" data point mentioned in this comment's prior revision was never confirmed to be for a
-- different pair count (could equally be an older/buggy build's already-wrong output) -- dropped
-- in favor of this pass's directly-confirmed, capture-title-labeled value.
local APKALLU_BASE_1_MATCH = 825
local APKALLU_MAX_8_MATCHES = 1300
local APKALLU_PER_EXTRA_MATCH = (APKALLU_MAX_8_MATCHES - APKALLU_BASE_1_MATCH) / 7 -- ~67.857

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()

    if (instance:completed()) then
        player:startEvent(100, 2)
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
        if id == 26 then
            local matches = math.max(instance:getProgress(), 1)
            points = math.floor(APKALLU_BASE_1_MATCH + APKALLU_PER_EXTRA_MATCH * (matches - 1)) - math.max(playerpoints, 0)
        elseif BASE_ASSAULT_POINTS[id] then
            points = BASE_ASSAULT_POINTS[id] - math.max(playerpoints, 0)
        end
        points = math.max(points, 0)
        for i, v in pairs(chars) do
            v:messageSpecial(ID.text.ASSAULT_POINTS_OBTAINED, points)
            v:addAssaultPoint(LEBROS_ASSAULT_POINT, points)
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
        for i, v in pairs(chars) do
            HalvungStagingPoint(v) -- real staging point (globals/teleports.lua), was setPos(0,0,0) = zone default arrival
        end
    end
end

