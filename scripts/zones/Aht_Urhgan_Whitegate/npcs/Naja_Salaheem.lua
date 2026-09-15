-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Naja Salaheem
-- Type: Standard NPC
-- !pos 22.700 -8.804 -45.591 50
-----------------------------------
require("scripts/zones/Aht_Urhgan_Whitegate/Shared")
package.loaded["scripts/zones/Aht_Urhgan_Whitegate/TextIDs"] = nil;
require("scripts/zones/Aht_Urhgan_Whitegate/TextIDs");
require("scripts/globals/besieged")
require("scripts/globals/missions")
require("scripts/globals/keyitems")
require("scripts/globals/titles")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
    if (npcUtil.tradeHas(trade, 2163) and player:getVar("PromotionPFC") == 1) then -- Rank to PFC
        player:startEvent(5002, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
end

function onTrigger(player, npc)

    local needToZone = player:needToZone()

    -- 2026-08-27, user-reported: the generic LC-Captain promotion check used to run first, so any
    -- time the player had 25+ AssaultPromotion points it hijacked EVERY interaction with Naja --
    -- including real, unrelated dialogue (e.g. the Falzum/Nafiwaa Alchemists' Guild hand-off).
    -- Also discovered via mission_toolkit.py's real event disassembly: Naja's client-compiled
    -- script only genuinely owns events 5030/5031 -- 5032-5037 belong to Abquhbah/Nafiwaa's own
    -- entities, not Naja's, so calling startEvent() with those numbers from her never should have
    -- been routed through her script to begin with. Full per-NPC promotion content across
    -- Naja/Abquhbah/Nafiwaa is future work; for now this generic points-only placeholder is moved
    -- to fire ONLY as a last resort (see bottom of this function, right before "go back to work"),
    -- so it can never preempt real mission/quest dialogue again.

    -- 2026-09-14, user-reported live (PSC quest gave no badge): the generic AssaultPromotion-based
    -- PFC/SP offer checks used to run FIRST, so any time a player had accumulated 25+
    -- AssaultPromotion points from unrelated assault testing, they preempted EVERY mission-story
    -- branch below (IMMORTAL_SENTRIES's csid 3002, which is what actually grants PSC_WILDCAT_BADGE,
    -- included) -- same bug class the 2026-08-27 fix above already solved for the LC-Captain
    -- placeholder specifically ("moved to fire ONLY as a last resort... so it can never preempt
    -- real mission/quest dialogue again"), just never extended to PFC/SP. Moved the whole
    -- AssaultPromotion block below all real getCurrentMission(TOAU) branches so mission-critical
    -- story dialogue (and any one-time badge/key item it grants) always takes priority over the
    -- side points-based promotion offers.
    if (player:getCurrentMission(TOAU) == IMMORTAL_SENTRIES and player:getVar("AhtUrganStatus") == 1) then
        player:startEvent(3002, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == PRESIDENT_SALAHEEM and player:getVar("AhtUrganStatus") == 1) then
        player:startEvent(73, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == PRESIDENT_SALAHEEM and player:getVar("AhtUrganStatus") == 2 and needToZone == false) then
        player:startEvent(3020, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == KNIGHT_OF_GOLD and player:getVar("AhtUrganStatus") == 0) then
        player:startEvent(3021, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == WESTERLY_WINDS and player:getVar("AhtUrganStatus") == 1) then
        player:startEvent(3028, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == UNDERSEA_SCOUTING) then
        player:startEvent(3051, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == ASTRAL_WAVES) then
        player:startEvent(3052, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == IMPERIAL_SCHEMES and player:getVar("TOAUM11_STARTDAY") ~= VanadielDayOfTheYear() and needToZone == false) then
        player:startEvent(3070, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == ROYAL_PUPPETEER) then
        player:startEvent(3071, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == THE_DOLPHIN_CREST) then
        player:startEvent(3072, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == THE_BLACK_COFFIN) then
        player:startEvent(3073, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == GHOSTS_OF_THE_PAST) then
        if (doRoyalPalaceArmorCheck(player) == true) then
            player:startEvent(3074, 1, 0, 0, 0, 0, 0, 0, 1, 0)
        else
            player:startEvent(3074, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        end
    elseif (player:getCurrentMission(TOAU) == GUESTS_OF_THE_EMPIRE) then
        if (doRoyalPalaceArmorCheck(player) == true) then
            if (player:getVar("AhtUrganStatus") == 0) then
                player:startEvent(3076, 1, 0, 0, 0, 0, 0, 0, 1, 0)
            else
                player:startEvent(3077, 1, 0, 0, 0, 0, 0, 0, 1, 0)
            end
        else
            if (player:getVar("AhtUrganStatus") == 0) then
                player:startEvent(3076, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            else
                player:startEvent(3077, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            end
        end
    elseif (player:getCurrentMission(TOAU) == PASSING_GLORY and player:getVar("TOAUM18_STARTDAY") ~= VanadielDayOfTheYear() and needToZone == false) then
        player:startEvent(3090, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == IN_THE_BLOOD) then
        player:startEvent(3113, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == SENTINELS_HONOR) then
        if(player:getVar("TOAUM18_STARTDAY") ~= VanadielDayOfTheYear() and needToZone == false) then
            player:startEvent(3130, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        else
            player:startEvent(3120, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        end
    elseif (player:getCurrentMission(TOAU) == FANGS_OF_THE_LION) then
        player:startEvent(3138, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == NASHMEIRAS_PLEA and player:hasKeyItem(MYTHRIL_MIRROR) == false) then
        player:startEvent(3149, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == RAGNAROK) then
        player:startEvent(3139, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == IMPERIAL_CORONATION) then
        player:startEvent(3150, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == THE_EMPRESS_CROWNED) then
        player:startEvent(3144, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    elseif (player:getCurrentMission(TOAU) == ETERNAL_MERCENARY) then
        player:startEvent(3154, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    -- 2026-09-14, moved below all real mission-story branches above -- see this function's opening
    -- comment for why. Logic itself unchanged.
    elseif (player:getVar("AssaultPromotion") >= 25 and player:hasKeyItem(PFC_WILDCAT_BADGE) == false and player:getVar("PromotionPFC") == 0) then
        player:startEvent(5000, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- PFC rank is available
    elseif (player:getVar("PromotionPFC") == 1) then
        -- 2026-08-27, user-reported: talking to Naja again before trading the Imp Wing fell
        -- through to the SP-offer check below, which only looked at AssaultPromotion >= 25 (still
        -- true -- it isn't reset until the badge is actually granted) with no check that the
        -- player had actually received the PFC badge yet. That let SP's cutscene (5020) fire
        -- while the player was still mid-PFC-quest, before ever getting the PFC badge. Re-showing
        -- the PFC offer while PromotionPFC == 1 keeps the player in the correct trade-wait state
        -- instead of leaking into a later rank's flow.
        player:startEvent(5000, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- still waiting on Imp Wing trade
    elseif (player:getVar("PromotionSP") == 1 and player:hasKeyItem(DARK_RIDER_HOOFPRINT) == true) then
        player:startEvent(5022, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- Superior Private rank complete
    elseif (player:getVar("AssaultPromotion") >= 25 and player:hasKeyItem(SP_WILDCAT_BADGE) == false and player:getVar("PromotionSP") == 0 and player:hasKeyItem(PFC_WILDCAT_BADGE) == true) then
        player:startEvent(5020, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- Superior Private rank is available
    -- 2026-08-27, user-requested: disabled ahead of the first handover stage (PSC/PFC/SP quests
    -- only). The LC-Captain placeholder awarded badges without any real quest requirement (just
    -- 25 AssaultPromotion points), and the LC event id in particular turned out to collide with
    -- real, unrelated client content (the Mythralline Wellspring/Alchemists' Guild questline --
    -- see topaz_lc_wildcat_badge_quest_research memory).
    -- 2026-08-31 UPDATE: SP->LC now has a real implementation -- npcs/Abquhbah.lua/Nafiwaa.lua
    -- (ported from a real LandSandBoat reference source, real event ids/text cross-checked against
    -- this client's own dat via mission_toolkit.py). It does NOT route through Naja at all, same as
    -- the real LSB structure -- nothing to re-enable here for LC specifically. This generic
    -- point-only placeholder remains commented out and now covers ONLY the ranks above LC
    -- (Corporal through Captain, `promotionEventIds` indices 5+) -- those still have no real quest
    -- content. Do not re-enable until each of THOSE ranks has a real, verified quest requirement;
    -- LC must stay routed through Abquhbah/Nafiwaa, not this block, even once re-enabled for others.
    --[[
    elseif canPromote(player) and getMercenaryRank(player) >= 4 then
        local currentRank = getMercenaryRank(player)
        local promotionEventIds = {nil, nil, nil, nil, nil, 5034, 5035, 5036, 5037} -- indices 3/4 (SP/LC) removed -- real quests now, not this table
        local nextEvent = promotionEventIds[currentRank]
        if nextEvent and player:getVar("PromotionRankPending") ~= nextEvent then
            player:setVar("PromotionRankPending", nextEvent)
            player:startEvent(nextEvent, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        else
            player:startEvent(3003, 1, 0, 0, 0, 0, 0, 0, 1, 0) -- go back to work
        end
    --]]
    else
        player:startEvent(3003, 1, 0, 0, 0, 0, 0, 0, 1, 0) -- go back to work

        -- player:messageSpecial(0)--  need to find correct normal chat CS..
    end

end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if (csid == 73) then
        player:setVar("AhtUrganStatus", 2)
    elseif (csid == 3002) then
        player:setVar("AhtUrganStatus", 0)
        player:completeMission(TOAU, IMMORTAL_SENTRIES)
        player:addMission(TOAU, PRESIDENT_SALAHEEM)
        player:addCurrency("imperial_standing", 150)
        player:addTitle(PRIVATE_SECOND_CLASS)
        player:addKeyItem(PSC_WILDCAT_BADGE)
        player:messageSpecial(KEYITEM_OBTAINED, PSC_WILDCAT_BADGE)
    elseif (csid == 3020) then
        player:setVar("AhtUrganStatus", 0)
        player:completeMission(TOAU, PRESIDENT_SALAHEEM)
        player:addMission(TOAU, KNIGHT_OF_GOLD)
    elseif (csid == 3028) then
        if (player:getFreeSlotsCount() == 0) then
            player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, 2185)
        else
            player:addItem(2185, 2)
            player:setVar("AhtUrganStatus", 0)
            player:completeMission(TOAU, WESTERLY_WINDS)
            player:addMission(TOAU, A_MERCENARY_LIFE)
            player:messageSpecial(ITEM_OBTAINED, 2185)
            player:needToZone(true)
        end
    elseif (csid == 3052) then
        player:completeMission(TOAU, ASTRAL_WAVES)
        player:needToZone(true)
        player:setVar("TOAUM11_STARTDAY", VanadielDayOfTheYear())
        player:addMission(TOAU, IMPERIAL_SCHEMES)
    elseif (csid == 3070) then
        player:completeMission(TOAU, IMPERIAL_SCHEMES)
        player:setVar("TOAUM11_STARTDAY", 0)
        player:addMission(TOAU, ROYAL_PUPPETEER)
    elseif (csid == 3072) then
        player:completeMission(TOAU, THE_DOLPHIN_CREST)
        player:addMission(TOAU, THE_BLACK_COFFIN)
    elseif (csid == 3074) then
        player:completeMission(TOAU, GHOSTS_OF_THE_PAST)
        player:addMission(TOAU, GUESTS_OF_THE_EMPIRE)

        if(option == 2) then
            player:setVar("AhtUrganStatus", 1)
        end
    elseif (csid == 3090) then
        player:completeMission(TOAU, PASSING_GLORY)
        player:setVar("TOAUM18_STARTDAY", 0)
        player:addMission(TOAU, SWEETS_FOR_THE_SOUL)
    elseif (csid == 3113) then
        player:completeMission(TOAU, IN_THE_BLOOD)
        player:setVar("TOAUM33_STARTDAY", VanadielDayOfTheYear())
        player:needToZone(true)
        player:addItem(2187)
        player:messageSpecial(ITEM_OBTAINED, 2187)
        player:addMission(TOAU, SENTINELS_HONOR)
    elseif (csid == 3130) then
        player:completeMission(TOAU, SENTINELS_HONOR)
        player:setVar("TOAUM33_STARTDAY", 0)
        player:addMission(TOAU, TESTING_THE_WATERS)
    elseif (csid == 3138) then
        player:completeMission(TOAU, FANGS_OF_THE_LION)
        player:addKeyItem(MYTHRIL_MIRROR)
        player:messageSpecial(KEYITEM_OBTAINED, MYTHRIL_MIRROR)
        player:setTitle(NASHMEIRAS_LOYALIST)
        player:addMission(TOAU, NASHMEIRAS_PLEA)
    elseif (csid == 3139) then
        player:completeMission(TOAU, RAGNAROK)
        player:addMission(TOAU, IMPERIAL_CORONATION)
    elseif (csid == 3144) then
        player:completeMission(TOAU, THE_EMPRESS_CROWNED)
        player:addItem(16070)
        player:messageSpecial(ITEM_OBTAINED, 16070)
        player:addMission(TOAU, ETERNAL_MERCENARY)
    elseif (csid == 3149) then
        player:messageSpecial(KEYITEM_OBTAINED, MYTHRIL_MIRROR)
        player:addKeyItem(MYTHRIL_MIRROR)
    elseif (csid == 3076 and option == 0) then
        player:setVar("AhtUrganStatus", 1)
    elseif csid == 5000 then
        player:setVar("PromotionPFC", 1)
    elseif csid == 5002 then
        player:confirmTrade()
        player:messageSpecial(KEYITEM_OBTAINED, PFC_WILDCAT_BADGE)
        player:addKeyItem(PFC_WILDCAT_BADGE)
        player:setVar("PromotionPFC", 0)
        player:setVar("AssaultPromotion", 0)
    elseif csid == 5020 then
        player:setVar("PromotionSP", 1)
    elseif csid == 5022 then
        player:messageSpecial(KEYITEM_OBTAINED, SP_WILDCAT_BADGE)
        player:addKeyItem(SP_WILDCAT_BADGE)
        player:delKeyItem(DARK_RIDER_HOOFPRINT) -- temp key item, consumed on SP promotion
        player:setVar("PromotionSP", 0)
        player:setVar("AssaultPromotion", 0)
    -- 2026-08-27, user-requested: disabled ahead of the first handover stage (PSC/PFC/SP quests
    -- only) -- see the matching onTrigger comment above. Left commented rather than removed so the
    -- PromotionRankPending guard logic doesn't need to be re-derived once real per-rank quests for
    -- LC-Captain are implemented.
    --[[
    elseif csid >= 5030 and csid <= 5037 then
        local isPendingPromotion = player:getVar("PromotionRankPending") == csid
        if isPendingPromotion then
            player:setVar("PromotionRankPending", 0)
        end
        if isPendingPromotion then
            promoteRank(player)
        end
    --]]
    end
end

