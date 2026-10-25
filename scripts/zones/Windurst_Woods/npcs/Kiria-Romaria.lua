-----------------------------------
--  Area: Windurst Woods
--   NPC: Kiria-Romaria
--  Type: Chocobo Stable Clerk (Lost Chick review)
-----------------------------------

package.loaded["scripts/zones/Windurst_Woods/TextIDs"] = nil;

require("scripts/zones/Windurst_Woods/TextIDs");
require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    CHOCOBO_RAISING.startClerk(player, 3);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
