-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Abquhbah
-----------------------------------
-- 2026-08-31, real "Promotion: Lance Corporal" mechanic -- see npcs/lance_corporal_common.lua for
-- the full charVar/porting writeup. Real events 5030-5034 confirmed present on this exact entity
-- (16982157) via this zone's own client-compiled event table (mission_toolkit.py) -- Abquhbah
-- starts the quest (5030), shows real per-stage reminders (5032/5033/5034), and owns the real
-- completion event (5031, confirmed NOT on Nafiwaa's own table despite LSB routing it through a
-- trigger-area walk-in there -- see this file's own onTrigger for the routing correction).
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/titles")
require("scripts/globals/npc_util")
package.loaded["scripts/zones/Aht_Urhgan_Whitegate/TextIDs"] = nil;
require("scripts/zones/Aht_Urhgan_Whitegate/TextIDs");
local questCommon = require("scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common")
-----------------------------------
function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local stage = player:getVar("PromotionLC")

    if stage == questCommon.stage.WAIT then
        -- 2026-08-31 CORRECTED (2nd pass): real completion (event 5031) IS triggered by talking to
        -- Abquhbah directly, per user confirmation -- an earlier pass wrongly routed this through a
        -- zone region walk-in instead. Real sequence: wait a game day, zone OUT of Whitegate, THEN
        -- return and talk to Abquhbah -- the "zoned back in" half is tracked via Zone.lua's own
        -- onZoneIn (LCZonedBack charVar, since this codebase has no direct "has left this zone"
        -- flag). The completion cutscene itself continues with Naja Salaheem presenting the real
        -- 3-way choice (user-confirmed) -- that's client-side cutscene content within event 5031
        -- itself, nothing further to build server-side beyond gating onEventFinish on the correct
        -- answer (see that handler below).
        -- 2026-08-31 real fix: every confirmed-working event call in this codebase (PFC/SP's own
        -- 5000/5002/5020/5022 in Naja_Salaheem.lua, user-confirmed live) always passes the FULL
        -- 10-argument signature (csid + 9 zeros), never a bare startEvent(csid) -- this file's own
        -- LC calls were bare, and 5030 specifically froze the client in live testing until manually
        -- cancelled. Padding to match the established real convention exactly.
        if VanadielDayOfTheYear() ~= player:getVar("LCSubmitDay") and player:getVar("LCZonedBack") == 1 then
            player:startEvent(5031, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        else
            player:startEvent(5034, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- real "still waiting" reminder
        end
        return
    end

    if stage == questCommon.stage.FIRST_MIX or stage == questCommon.stage.REMIX then
        player:startEvent(5033, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- real "off gathering samples" reminder
        return
    end

    if stage == questCommon.stage.START then
        player:startEvent(5032, 0, 0, 0, 0, 0, 0, 0, 0, 0) -- real "go see Nafiwaa" reminder
        return
    end

    -- Not on this quest yet -- real acceptance gate: 25+ AssaultPromotion points and the real SP
    -- quest already completed. This codebase has no separate quest-completion tracker for
    -- Promotion: Superior Private (see Naja_Salaheem.lua) -- possessing the real SP badge is the
    -- direct, already-real signal that quest finished (the badge is only ever granted on SP
    -- completion, csid 5022).
    if player:getVar("AssaultPromotion") >= 25 and player:hasKeyItem(SP_WILDCAT_BADGE)
        and player:getVar("PromotionLC") == questCommon.stage.NOT_ACCEPTED
        and not player:hasKeyItem(LC_WILDCAT_BADGE) then
        player:startEvent(5030, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return
    end

    -- 2026-08-27 real generic rank-progress display -- pre-existing content, kept as the fallback
    -- for every other interaction with Abquhbah.
    local promotion = player:getVar("AssaultPromotion")
    local rank = 0

    if promotion <= 7 then
        rank = 1
    elseif promotion >= 8 and promotion <= 11 then
        rank = 2
    elseif promotion >= 12 and promotion <= 18 then
        rank = 3
    elseif promotion >= 19 then
        rank = 4
    end

    player:startEvent(255, rank)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 5030 then
        player:setVar("PromotionLC", questCommon.stage.START)
    elseif csid == 5031 then
        -- 2026-08-31 CORRECTED against real capture (LC Rank Mission Pt.2, Rabadaba,
        -- 2021-02-25 22:47:17): the previous "index 1 grants the promotion" note was an untested
        -- assumption from reading the dat text order and was WRONG -- it silently discarded the
        -- title/badge/key item AND the mixing-quality item reward on every real completion, since
        -- real players always send option 0 for the correct answer. Real capture: "OUTGOING >
        -- Event Option (0x05B): NPC: 478650 (Rabadaba/player), Event: 5031, Option: 0" immediately
        -- followed by success dialogue (message 6670, "...Hold it!") and the quest continuing
        -- normally into Naja Salaheem's scene -- no retry/failure loop. Event 5031 is a 3-way
        -- choice ("What is a mercenary's duty?" -- real dat-extracted text index 6643 -- "Um..."(0)
        -- / "Helping his fellow mercenaries."(1) / "Completing his set tasks."(2)); the real
        -- correct answer is index 0, not 1. Picking a wrong answer leaves PromotionLC at WAIT so
        -- the player can just walk back into the region and try again.
        if option ~= 0 then
            return
        end

        local reward = questCommon.getQuestReward(player)
        if reward then
            if not npcUtil.giveItem(player, { { reward.item, reward.amount } }) then
                return
            end
        end

        -- 2026-09-14, fixed real naming collision -- LANCE_CORPORAL is globals/titles.lua's TITLE
        -- id (490), not the "promoted to Lance Corporal!" text id (6664) -- see TextIDs.lua's
        -- matching comment. messageSpecial was silently announcing the wrong id.
        player:messageSpecial(PROMOTED_TO_LANCE_CORPORAL)
        player:addTitle(LANCE_CORPORAL)
        player:addKeyItem(LC_WILDCAT_BADGE)
        player:messageSpecial(KEYITEM_OBTAINED, LC_WILDCAT_BADGE)
        -- 2026-08-31 REMOVED player:delKeyItem(SP_WILDCAT_BADGE) -- root cause of a real
        -- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
        -- bug: getMercenaryRank() (besieged.lua) determines rank by COUNTING how many
        -- wildcat badges the player currently holds (cumulative -- PSC/PFC/SP promotions in
        -- Naja_Salaheem.lua all only ADD their badge, never delete the prior one, by design).
        -- Deleting SP_WILDCAT_BADGE here dropped a real LC player's badge count back to 3 (PSC+
        -- PFC+LC), which getMercenaryRank() reads as SP-tier -- exactly why Yahsra's Assault
        -- mission menu showed only up to SP-tier missions despite the player actually being LC.
        -- Wildcat badges are meant to be permanent/cumulative, matching every other rank tier.

        player:setVar("PromotionLC", questCommon.stage.NOT_ACCEPTED)
        player:setVar("AssaultPromotion", 0)
        player:setVar("LCProg", 0)
        player:setVar("LCOption", 0)
        player:setVar("LCSubmitDay", 0)
    end
end

