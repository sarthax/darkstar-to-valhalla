-----------------------------------
-- func: resetlcquest <player>
-- desc: Resets ONLY the "Promotion: Lance Corporal" quest state back to not-accepted, without
--       touching PSC/PFC/SP progress -- for looping just the LC leg during testing instead of a
--       full !resetmercrank. See scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common.lua
--       for what each charvar means.
-----------------------------------

require("scripts/globals/keyitems")

cmdprops =
{
    permission = 1,
    parameters = "s"
}

local function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!resetlcquest {player}")
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

    -- clear all real LC quest-state charvars
    targ:setVar("PromotionLC", 0)
    targ:setVar("LCProg", 0)
    targ:setVar("LCOption", 0)
    targ:setVar("LCSubmitDay", 0)
    targ:setVar("LCZonedBack", 0)
    targ:setVar("LCTubesFilled", 0) -- 2026-08-31, added alongside the wellspring double-message fix

    -- remove the LC badge (if already granted) and every temp key item the quest hands out along
    -- the way, so the chain can be re-run from Abquhbah's very first trigger.
    local removed = 0
    local keyItemsToStrip =
    {
        LC_WILDCAT_BADGE,
        EMPTY_TEST_TUBE_1, EMPTY_TEST_TUBE_2, EMPTY_TEST_TUBE_3,
        EMPTY_TEST_TUBE_4, EMPTY_TEST_TUBE_5,
        TEST_TUBE_1, TEST_TUBE_2, TEST_TUBE_3, TEST_TUBE_4, TEST_TUBE_5,
    }
    for _, ki in ipairs(keyItemsToStrip) do
        if targ:hasKeyItem(ki) then
            targ:delKeyItem(ki)
            removed = removed + 1
        end
    end

    -- Real acceptance gate is AssaultPromotion >= 25 -- set it back up for an immediate re-test
    -- instead of making the tester run !addassaultpoints separately every loop. Does NOT touch
    -- PromotionSP/SP_WILDCAT_BADGE -- this command is LC-only.
    targ:setVar("AssaultPromotion", 25)

    player:PrintToPlayer(string.format("%s's Lance Corporal promotion quest reset. Removed %i key item(s). AssaultPromotion set to 25.", targ:getName(), removed))
end
