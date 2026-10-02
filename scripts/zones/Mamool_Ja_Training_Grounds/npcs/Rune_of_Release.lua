require("scripts/globals/teleports")
-----------------------------------
-- Area: Mamool Ja Training Grounds
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/besieged")
-----------------------------------
-- 2026-08-18: same systemic gap found and fixed in Lebros_Cavern's and Leujaoam_Sanctum's
-- Rune_of_Release.lua -- this zone's version only ever awarded points for id == 12, so every
-- other Mamool Ja mission (Breaking Morale included) has been giving ZERO Assault points on
-- completion. Restructured to a lookup table so future capture-confirmed values can be added
-- without re-deriving this same fix.
-- 2026-08-30, REPLACED with the user's own compiled Assault Rewards reference worksheet
-- ("Max AP (3 players / base)" column), superseding the individual real-capture values used
-- before. User's own reasoning: single-capture values aren't absolute -- they can be skewed by
-- whether every objective was met, party composition, or reward-boosting equipment, none of which
-- the worksheet's baseline figure depends on.
-- Breaking Morale (14), The Double Agent (15), and Imperial Treasure Retrieval (16) are NOT flat
-- -- see the per-mission deduction/bonus logic in onEventFinish below, same convention as Lebros's
-- Apkallu Breeding (deliberately variable, not a table entry).
local BASE_ASSAULT_POINTS =
{
    [11] = 1100, -- Imperial Agent Rescue (user-provided Assault Rewards worksheet)
    [12] = 1000, -- Preemptive Strike (user-provided Assault Rewards worksheet)
    [13] = 1200, -- Sagelord Elimination (user-provided Assault Rewards worksheet)
    -- [14] Breaking Morale -- variable, see BREAKING_MORALE_MAX below.
    -- [15] The Double Agent -- variable, see DOUBLE_AGENT_BASE below.
    -- [16] Imperial Treasure Retrieval -- variable, see GEM_BASE/GEM_PER_ITEM below.
    [17] = 1533, -- Blitzkrieg (user-provided Assault Rewards worksheet -- wiki also reports up to
                 -- 2303 with optional prisoner/Firedrake objectives, not modeled by this flat value)
    -- Marids in the Mist (18): worksheet notes "1333 for capturing all 8; killing yields only
    -- 266" -- a real capture-vs-kill distinction this codebase doesn't currently track (the
    -- mission's real mechanic per its own header models it as kill-all-26, not a capture
    -- objective). Left at the worksheet's flat max pending that mechanic being verified/built --
    -- flagging so a future pass doesn't assume this is fully correct as-is.
    [18] = 1333, -- Marids in the Mist (user-provided Assault Rewards worksheet, capture-all max)
    [19] = 1000, -- Azure Ailments (user-provided Assault Rewards worksheet)
    [20] = 1500, -- The Susanoo Shuffle (user-provided Assault Rewards worksheet)
}

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()

    if (instance:completed()) then
        player:startEvent(100, 1)
    end

    return 1

end

function onEventUpdate(player, csid, option)
end

-- 2026-08-30: The Double Agent (id 15) docks Assault points per wrong capture guess. Base and
-- penalty both replaced with the user's Assault Rewards worksheet ("1200 base minus 66 AP per
-- false accusation") -- supersedes the earlier wiki-derived 1980 base / 74-per-guess fit.
-- wrongGuesses itself is tracked on the instance (setLocalVar, incremented by
-- npcs/Qiqirn_Spy.lua's onEventFinish on every failed capture) so it's visible here across the
-- two separate NPC scripts without any extra plumbing.
local DOUBLE_AGENT_BASE = 1200
-- 2026-09-02: user clarified the exact worksheet wording -- "66.67 point penalty, rounded down,
-- for every false accusation." The rounding applies to the CUMULATIVE total (floor(66.67 * n)),
-- not to a pre-rounded 66-per-guess flat rate -- those two only match at n=1 and diverge from
-- n=2 onward (e.g. 3 wrong guesses: floor(66.67*3)=200, but 66*3=198, a real 2-point shortfall
-- that gets worse with more wrong guesses). Kept as a per-mission-id table (float now, not int)
-- for the same reason the original 2026-08-30 version was -- future missions may need their own
-- real per-guess rate.
local WRONG_GUESS_PENALTY =
{
    [15] = 66.67, -- The Double Agent (user-provided Assault Rewards worksheet)
}

-- 2026-08-30: Breaking Morale (id 14) worksheet modifier -- "Varies based on items collected.
-- Each chest less than 8 is a 66.6 point deduction, rounded down." progress already tracks
-- crates successfully turned in to Quhaaja (npcs/Quhaaja.lua's instance:setProgress() calls, both
-- the normal completion and the give-up path), so it's exactly the real "items collected" count
-- this formula needs, no extra plumbing required.
local BREAKING_MORALE_MAX = 1333
local BREAKING_MORALE_DEDUCTION_PER_CHEST = 66.6

-- 2026-08-30: Imperial Treasure Retrieval (id 16) worksheet modifier -- "200 + 133 AP per gem;
-- 9 gems is commonly cited as maximum (1397)". gemsScored is tracked on the instance (see
-- npcs/Zahakahm.lua's onTrigger), same real per-gem counter used for its own completion text.
local GEM_BASE = 200
local GEM_PER_ITEM = 133

function onEventFinish(player, csid, option)

    local instance = player:getInstance()
    local chars = instance:getChars()
    local id = instance:getID()
    local points = 0
    local playerpoints = ((#chars -3)*100)

    if (csid == 100 and option == 1) then
        if id == 14 then
            local chestsCollected = instance:getProgress()
            points = BREAKING_MORALE_MAX - math.floor(BREAKING_MORALE_DEDUCTION_PER_CHEST * (8 - chestsCollected))
        elseif id == 15 then
            points = DOUBLE_AGENT_BASE
        elseif id == 16 then
            points = GEM_BASE + (GEM_PER_ITEM * (instance:getLocalVar("gemsScored") or 0))
        elseif BASE_ASSAULT_POINTS[id] then
            points = BASE_ASSAULT_POINTS[id]
        end
        points = points - math.max(playerpoints, 0)
        if WRONG_GUESS_PENALTY[id] then
            points = points - math.floor(WRONG_GUESS_PENALTY[id] * instance:getLocalVar("wrongGuesses"))
        end
        points = math.max(points, 0)
        for i, v in pairs(chars) do
            v:messageSpecial(ASSAULT_POINTS_OBTAINED, points)
            v:addAssaultPoint(MAMOOL_ASSAULT_POINT, points)
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
            MamoolJaStagingPoint(v) -- real staging point (globals/teleports.lua), was setPos(0,0,0) = zone default arrival
        end
    end
end

