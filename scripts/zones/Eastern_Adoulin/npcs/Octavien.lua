-----------------------------------
-- Area: Eastern Adoulin (257)
--  NPC: Octavien
-- Starts and ends Children of the Rune (Rune Fencer unlock)
-- csids 23-29 and TextID 7009 verified against client event/dialog data.
-- Key items: YAHSE_WILDFLOWER_PETAL 2279, JOB_GESTURE_RUNE_FENCER 2964 (client ROM/175/35.DAT).
-- Item: SOWILO_CLAYMORE 20781.
-- Char var RUN_COTR: 1 = declined, 2 = rune enhancement, 3 = reward pending.
-- NOTE: npc_list row (2.444,-11.442,-16.595) differs from LSB's !pos (100.58,-40.15,-63.83);
-- left as captured, unverified.
-----------------------------------
package.loaded["scripts/zones/Eastern_Adoulin/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/settings");
require("scripts/globals/quests");
require("scripts/globals/keyitems");
require("scripts/globals/npc_util");
require("scripts/zones/Eastern_Adoulin/TextIDs");

local SOWILO_CLAYMORE = 20781;

local TRIGGERED        = 1;
local RUNE_ENHANCEMENT = 2;
local REWARD_PENDING   = 3;

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    local status = player:getQuestStatus(ADOULIN,CHILDREN_OF_THE_RUNE);
    local state = player:getVar("RUN_COTR");

    if (status == QUEST_COMPLETED) then
        player:startEvent(28, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (state == REWARD_PENDING) then
        player:startEvent(29, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (state == RUNE_ENHANCEMENT) then
        player:startEvent(26, 1, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (status == QUEST_ACCEPTED and player:hasKeyItem(YAHSE_WILDFLOWER_PETAL)) then
        player:startEvent(26, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (status == QUEST_ACCEPTED) then
        player:startEvent(25, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (state == TRIGGERED) then
        player:startEvent(24, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    elseif (status == QUEST_AVAILABLE and player:getMainLvl() >= ADVANCED_JOB_LEVEL) then
        player:startEvent(23, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    else
        player:startEvent(27, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    if (csid == 26 and option == 1) then
        -- halve HP/MP, but never to death
        local hp = player:getHP();
        if (hp > 5) then
            player:setHP(math.ceil(hp / 2));
        end
        local mp = player:getMP();
        if (mp > 5) then
            player:setMP(math.ceil(mp / 2));
        end
    end
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    if (csid == 23 or csid == 24) then
        if (option == 0) then
            player:setVar("RUN_COTR", TRIGGERED);
        elseif (option == 1) then
            player:addQuest(ADOULIN,CHILDREN_OF_THE_RUNE);
        end
    elseif (csid == 26) then
        if (option == 0) then
            player:setVar("RUN_COTR", RUNE_ENHANCEMENT);
        elseif (option == 1) then
            player:setVar("RUN_COTR", REWARD_PENDING);
        end
    end

    if (player:getVar("RUN_COTR") == REWARD_PENDING) then
        if (npcUtil.giveItem(player, SOWILO_CLAYMORE)) then
            player:unlockJob(JOBS.RUN);
            player:messageSpecial(YOU_CAN_NOW_BECOME, 1);
            npcUtil.giveKeyItem(player, JOB_GESTURE_RUNE_FENCER);
            player:setVar("RUN_COTR", 0);
            player:delKeyItem(YAHSE_WILDFLOWER_PETAL);
            player:completeQuest(ADOULIN,CHILDREN_OF_THE_RUNE);
        end
    end
end;
