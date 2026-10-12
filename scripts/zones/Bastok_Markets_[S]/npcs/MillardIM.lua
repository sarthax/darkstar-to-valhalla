-----------------------------------
-- Area: Bastok Markets [S]
--  NPC: Millard, I.M.
-- Type: Sigil NPC
-- !pos (unverified - see npc_list)
-- Logic lives in scripts/globals/campaign.lua (sigilOn*)
-----------------------------------
package.loaded["scripts/zones/Bastok_Markets_[S]/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/campaign");
require("scripts/zones/Bastok_Markets_[S]/TextIDs");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    sigilOnTrigger(player, npc);
end;

function onEventUpdate(player,csid,option)
    sigilOnEventUpdate(player, csid, option);
end;

function onEventFinish(player,csid,option)
    sigilOnEventFinish(player, csid, option);
end;
