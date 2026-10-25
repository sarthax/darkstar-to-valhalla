-----------------------------------
--  Area: Southern San dOria
--   NPC: Arvilauge
--  Type: Chocobo Stable Clerk (Lost Chick review)
-----------------------------------

package.loaded["scripts/zones/Southern_San_dOria/TextIDs"] = nil;

require("scripts/zones/Southern_San_dOria/TextIDs");
require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    CHOCOBO_RAISING.startClerk(player, 1);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
