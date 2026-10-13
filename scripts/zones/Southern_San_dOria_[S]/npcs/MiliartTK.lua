-----------------------------------
-- Area: Southern SandOria [S]
--  NPC: Miliart, T.K.
-- Type: Sigil NPC
-- !pos 107 1 -31 80
-- Logic lives in scripts/globals/campaign.lua (sigilOn*)
-----------------------------------
package.loaded["scripts/zones/Southern_San_dOria_[S]/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/campaign");
require("scripts/zones/Southern_San_dOria_[S]/TextIDs");

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
