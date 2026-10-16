-----------------------------------
-- Area: Western Adoulin (256)
--  NPC: Sylvie
-- Starts and ends Dances with Luopans (Geomancer unlock)
-- !pos 78.094 32.000 135.725 256
-- csids 31-37, 39 and TextID 7009 verified against client event/dialog data.
-- Key items: LUOPAN 2290, FISTFUL_OF_HOMELAND_SOIL 2278, JOB_GESTURE_GEOMANCER 2963 (client ROM/175/35.DAT).
-- Items: PETRIFIED_LOG 703, PLATE_OF_INDI_POISON 6074, MATRE_BELL 21460.
-----------------------------------
package.loaded["scripts/zones/Western_Adoulin/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/settings");
require("scripts/globals/quests");
require("scripts/globals/keyitems");
require("scripts/globals/npc_util");
require("scripts/zones/Western_Adoulin/TextIDs");

local PETRIFIED_LOG       = 703;
local PLATE_OF_INDI_POISON = 6074;
local MATRE_BELL          = 21460;
local MATRE_BELL_GIL      = 300000;
local MATRE_BELL_BAYLD    = 150000;

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
    if (player:getQuestStatus(ADOULIN,DANCES_WITH_LUOPANS) == QUEST_ACCEPTED
        and player:hasKeyItem(FISTFUL_OF_HOMELAND_SOIL)
        and not player:hasKeyItem(LUOPAN)
        and npcUtil.tradeHas(trade, PETRIFIED_LOG)) then
        player:startEvent(34, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    end
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    local status = player:getQuestStatus(ADOULIN,DANCES_WITH_LUOPANS);

    if (status == QUEST_AVAILABLE) then
        if (player:getMainLvl() >= ADVANCED_JOB_LEVEL) then
            if (player:getVar("DwL_Declined") == 1) then
                player:startEvent(32, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            else
                player:startEvent(31, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            end
        else
            player:startEvent(33, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        end
    elseif (status == QUEST_ACCEPTED) then
        if (player:getVar("DwL_Prog") == 1) then
            player:startEvent(36, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        elseif (player:hasKeyItem(LUOPAN)) then
            player:startEvent(35, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        else
            player:startEvent(33, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        end
    else
        if (player:getMainJob() == JOBS.GEO and not player:hasItem(MATRE_BELL)) then
            player:setLocalVar("MatreBellPayment", 0);
            player:startEvent(37, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        else
            player:startEvent(39, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        end
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    if (csid == 37 and (option == 1 or option == 2)) then
        local param = 0;
        player:setLocalVar("MatreBellPayment", 0);
        if (player:getFreeSlotsCount() < 1) then
            param = 2;
        elseif ((option == 1 and player:getGil() >= MATRE_BELL_GIL)
            or (option == 2 and player:getCurrency("bayld") >= MATRE_BELL_BAYLD)) then
            player:setLocalVar("MatreBellPayment", option);
            param = 1;
        end
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, param);
    end
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    if (csid == 31 or csid == 32) then
        if (option == 1) then
            player:setVar("DwL_Declined", 0);
            player:setVar("DwL_Prog", 0);
            player:addQuest(ADOULIN,DANCES_WITH_LUOPANS);
        elseif (csid == 31) then
            player:setVar("DwL_Declined", 1);
        end
    elseif (csid == 34) then
        player:tradeComplete();
        player:delKeyItem(FISTFUL_OF_HOMELAND_SOIL);
        npcUtil.giveKeyItem(player, LUOPAN);
    elseif (csid == 36) then
        if (npcUtil.giveItem(player, {PLATE_OF_INDI_POISON, MATRE_BELL})) then
            player:unlockJob(JOBS.GEO);
            player:messageSpecial(YOU_CAN_NOW_BECOME, 0);
            npcUtil.giveKeyItem(player, JOB_GESTURE_GEOMANCER);
            player:setVar("DwL_Prog", 0);
            player:completeQuest(ADOULIN,DANCES_WITH_LUOPANS);
        end
    elseif (csid == 37) then
        local pay = player:getLocalVar("MatreBellPayment");
        player:setLocalVar("MatreBellPayment", 0);
        if (pay ~= 0 and option == 1) then
            if (npcUtil.giveItem(player, MATRE_BELL)) then
                if (pay == 1) then
                    player:delGil(MATRE_BELL_GIL);
                else
                    player:delCurrency("bayld", MATRE_BELL_BAYLD);
                end
            end
        end
    end
end;
