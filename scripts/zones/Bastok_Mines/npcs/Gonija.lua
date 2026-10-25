-----------------------------------
--  Area: Bastok Mines
--   NPC: Gonija
--  Type: Chocobo Stable Clerk (Lost Chick review)
-----------------------------------

package.loaded["scripts/zones/Bastok_Mines/TextIDs"] = nil;

require("scripts/zones/Bastok_Mines/TextIDs");
require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    CHOCOBO_RAISING.startClerk(player, 2);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
