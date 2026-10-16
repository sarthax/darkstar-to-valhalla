-----------------------------------
-- Area: Konschtat Highlands (108)
--  NPC: Ergon Locus
-- Dances with Luopans: Bastok citizens receive FISTFUL_OF_HOMELAND_SOIL (2278).
-- Npc id 17220210 matches the client.
-----------------------------------
package.loaded["scripts/zones/Konschtat_Highlands/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/quests");
require("scripts/globals/keyitems");
require("scripts/globals/npc_util");
require("scripts/zones/Konschtat_Highlands/TextIDs");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    if (player:getQuestStatus(ADOULIN,DANCES_WITH_LUOPANS) == QUEST_ACCEPTED
        and player:getNation() == NATION_BASTOK
        and not player:hasKeyItem(FISTFUL_OF_HOMELAND_SOIL)
        and not player:hasKeyItem(LUOPAN)) then
        npcUtil.giveKeyItem(player, FISTFUL_OF_HOMELAND_SOIL);
    end
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
