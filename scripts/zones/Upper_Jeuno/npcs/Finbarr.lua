-----------------------------------
-- Area: Upper Jeuno
-- NPC: Finbarr
-- VCS Honeymoon: chocobo breeding (scripts/globals/chocobo_raising_breeding.lua)
-----------------------------------

package.loaded["scripts/zones/Upper_Jeuno/TextIDs"] = nil;
require("scripts/zones/Upper_Jeuno/TextIDs");
require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
    CHOCOBO_RAISING.breedingTrade(player, npc, trade);
end;

function onTrigger(player,npc)
    CHOCOBO_RAISING.breedingTrigger(player, npc);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
    CHOCOBO_RAISING.breedingFinish(player, csid, option, GetNPCByID(17776821));
end;
