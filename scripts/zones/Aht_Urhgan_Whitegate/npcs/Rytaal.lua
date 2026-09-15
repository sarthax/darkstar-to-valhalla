-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Rytaal
-- Type: Standard NPC
-- !pos 112.002 -1.338 -45.038 50
-----------------------------------
package.loaded["scripts/zones/Aht_Urhgan_Whitegate/TextIDs"] = nil;
-----------------------------------
require("scripts/zones/Aht_Urhgan_Whitegate/TextIDs");
require("scripts/globals/keyitems");
require("scripts/globals/missions");
require("scripts/globals/besieged");
require("scripts/globals/npc_util");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)

    -- 2026-09-14, reconciled against Topaz's current Rytaal.lua (this file had never been touched
    -- by the backport project in either engine -- 0 dated fix comments on both sides -- and had
    -- drifted onto a real-calendar-day cooldown instead of the rest of the codebase's real-time
    -- convention). os.date("%j") is day-of-year (1-366) -- diffday wraps to a large NEGATIVE value
    -- every Dec 31 -> Jan 1, silently breaking the Imperial Army ID Tag's daily-refill cooldown at
    -- every year boundary. Matches Topaz's own real epoch-time-based calculation now.
    local lastIDtag = player:getVar("LAST_IMPERIAL_TAG");
    local tagCount = player:getCurrency("id_tags");
    local diffday = math.floor((os.time() - lastIDtag) / (60 * 60 * 24));
    local currentAssault = player:getCurrentAssault();
    local haveimperialIDtag;

    if (player:getCurrentMission(TOAU) == PRESIDENT_SALAHEEM and player:getVar("AhtUrganStatus") == 0) then
        player:startEvent(269,0,0,0,0,0,0,0,0,0);
    elseif (player:getCurrentMission(TOAU) <= IMMORTAL_SENTRIES or player:getMainLvl() <= 49) then
        player:startEvent(270);
    elseif (currentAssault ~= 0 and hasAssaultOrders(player) == 0) then
        if (player:getVar("AssaultComplete") == 1) then
            player:messageText(player,RYTAAL_MISSION_COMPLETE);
            player:completeAssault(currentAssault);
        else
            player:messageText(player,RYTAAL_MISSION_FAILED);
            player:addAssault(0);
        end
        player:setVar("AssaultComplete",0);
    elseif ((player:getCurrentMission(TOAU) > PRESIDENT_SALAHEEM) or (player:getCurrentMission(TOAU) == PRESIDENT_SALAHEEM and player:getVar("AhtUrganStatus") >= 1)) then
        if (lastIDtag == 0) then -- first time you get the tag
            tagCount = 1;
            player:setCurrency("id_tags", tagCount);
            player:setVar("LAST_IMPERIAL_TAG", os.time());
        elseif (diffday > 0) then
            tagCount = tagCount + diffday ;
            if (tagCount > 3) then -- store 3 TAG max
                tagCount = 3;
            end
            player:setCurrency("id_tags", tagCount);
            player:setVar("LAST_IMPERIAL_TAG", os.time());
        end

        if (player:hasKeyItem(IMPERIAL_ARMY_ID_TAG)) then
            haveimperialIDtag = 1;
        else
            haveimperialIDtag = 0;
        end
        player:startEvent(268,IMPERIAL_ARMY_ID_TAG,tagCount,currentAssault,haveimperialIDtag);
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);

    local tagCount = player:getCurrency("id_tags");
    local currentAssault = player:getCurrentAssault();

    if (csid == 269) then
        player:setVar("AhtUrganStatus",1);
    elseif (csid == 268 and option == 1 and player:hasKeyItem(IMPERIAL_ARMY_ID_TAG) == false and tagCount > 0) then
        npcUtil.giveKeyItem(player, IMPERIAL_ARMY_ID_TAG);
        player:setCurrency("id_tags", tagCount - 1);
    elseif (csid == 268 and option == 2 and player:hasKeyItem(IMPERIAL_ARMY_ID_TAG) == false and hasAssaultOrders(player) ~= 0) then
        if (player:hasKeyItem(LEUJAOAM_ASSAULT_ORDERS)) then
            player:delKeyItem(LEUJAOAM_ASSAULT_ORDERS);
        elseif (player:hasKeyItem(MAMOOL_JA_ASSAULT_ORDERS)) then
            player:delKeyItem(MAMOOL_JA_ASSAULT_ORDERS);
        elseif (player:hasKeyItem(LEBROS_ASSAULT_ORDERS)) then
            player:delKeyItem(LEBROS_ASSAULT_ORDERS);
        elseif (player:hasKeyItem(PERIQIA_ASSAULT_ORDERS)) then
            player:delKeyItem(PERIQIA_ASSAULT_ORDERS);
        elseif (player:hasKeyItem(ILRUSI_ASSAULT_ORDERS )) then
            player:delKeyItem(ILRUSI_ASSAULT_ORDERS);
        elseif (player:hasKeyItem(NYZUL_ISLE_ASSAULT_ORDERS)) then
            player:delKeyItem(NYZUL_ISLE_ASSAULT_ORDERS);
        end
        npcUtil.giveKeyItem(player, IMPERIAL_ARMY_ID_TAG);
        player:delAssault(currentAssault);
    end

end;
