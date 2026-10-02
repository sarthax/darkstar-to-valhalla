-----------------------------------
-- func: resetmercrank <player>
-- desc: Resets the GM or target's mercenary rank back to Private Second Class (PSC)
--       by removing all higher-rank wildcat badges and clearing promotion charvars.
--       For testing the assault rank promotion quest chain from scratch.
-----------------------------------

require("scripts/globals/besieged")
require("scripts/globals/keyitems")

cmdprops =
{
    permission = 1,
    parameters = "s"
}

local function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!resetmercrank {player}")
end

onTrigger = function(player, target)

    -- validate target
    local targ
    if (target == nil) then
        targ = player
    else
        targ = GetPlayerByName(target)
        if (targ == nil) then
            error(player, string.format("Player named '%s' not found!", target))
            return
        end
    end

    -- remove every badge above PSC (badges[1] = PSC, keep that one)
    local removed = 0
    for i = 2, #ASSAULT_RANK_BADGES do
        local badge = ASSAULT_RANK_BADGES[i]
        if targ:hasKeyItem(badge) then
            targ:delKeyItem(badge)
            removed = removed + 1
        end
    end

    -- clear promotion state charvars
    targ:setVar("AssaultPromotion", 0)
    targ:setVar("PromotionPFC", 0)
    targ:setVar("PromotionSP", 0)
    targ:setVar("AssaultsCompleted", 0)

    -- 2026-08-31, real "Promotion: Lance Corporal" charvars added -- see
    -- scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common.lua. Without this, resetting
    -- back to PSC left stale LC quest state behind (still mid-mixing, or still waiting on the
    -- day-gate), breaking a clean re-run of the chain for testing.
    targ:setVar("PromotionLC", 0)
    targ:setVar("LCProg", 0)
    targ:setVar("LCOption", 0)
    targ:setVar("LCSubmitDay", 0)
    targ:setVar("LCZonedBack", 0)
    targ:setVar("LCTubesFilled", 0) -- 2026-08-31, added alongside the wellspring double-message fix

    -- Real temp key items picked up mid-quest that a badge-only sweep won't catch (SP's Dark Rider
    -- Hoofprint proof, LC's 5 empty/filled test tubes).
    local tempKeyItems =
    {
        DARK_RIDER_HOOFPRINT,
        EMPTY_TEST_TUBE_1, EMPTY_TEST_TUBE_2, EMPTY_TEST_TUBE_3,
        EMPTY_TEST_TUBE_4, EMPTY_TEST_TUBE_5,
        TEST_TUBE_1, TEST_TUBE_2, TEST_TUBE_3, TEST_TUBE_4, TEST_TUBE_5,
    }
    for _, ki in ipairs(tempKeyItems) do
        if targ:hasKeyItem(ki) then
            targ:delKeyItem(ki)
            removed = removed + 1
        end
    end

    player:PrintToPlayer(string.format("%s's mercenary rank reset to PSC. Removed %i badge(s)/temp key item(s).", targ:getName(), removed))
end
