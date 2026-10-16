-----------------------------------
-- Area: Ru'Lude Gardens
-- NPC:  Assai Nybaem (Voidwalker abyssite vendor / discard)
-- @zone 243
-- !pos -34 0 -77
-----------------------------------
package.loaded["scripts/zones/RuLude_Gardens/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/voidwalker");
require("scripts/zones/RuLude_Gardens/TextIDs");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    voidwalker.npcOnTrigger(player);
end;

function onEventUpdate(player,csid,option)
    voidwalker.npcOnEventUpdate(player, csid, option);
end;

function onEventFinish(player,csid,option)
    voidwalker.npcOnEventFinish(player, csid, option, KEYITEM_OBTAINED);
end;
