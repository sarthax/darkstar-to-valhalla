-----------------------------------
-- Area: Yahse Hunting Grounds (260)
--  NPC: Yahse Wildflower
-- Involved in Children of the Rune. Gives YAHSE_WILDFLOWER_PETAL (2279) while the quest is active.
-- Npc id 17842699 matches the client; pos 370.7 0.7 153.3.
-----------------------------------
package.loaded["scripts/zones/Yahse_Hunting_Grounds/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/quests");
require("scripts/globals/keyitems");
require("scripts/globals/npc_util");
require("scripts/zones/Yahse_Hunting_Grounds/TextIDs");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    if (player:getQuestStatus(ADOULIN,CHILDREN_OF_THE_RUNE) == QUEST_ACCEPTED
        and not player:hasKeyItem(YAHSE_WILDFLOWER_PETAL)) then
        npcUtil.giveKeyItem(player, YAHSE_WILDFLOWER_PETAL);
    end
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
