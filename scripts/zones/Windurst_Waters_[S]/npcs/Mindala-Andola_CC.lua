-----------------------------------
-- Area: Windurst Waters [S]
--  NPC: Mindala-Andola, C.C.
-- Type: Sigil NPC
-- !pos -31.869 -6.009 226.793 94 (unverified)
-- Logic lives in scripts/globals/campaign.lua (sigilOn*)
-----------------------------------
package.loaded["scripts/zones/Windurst_Waters_[S]/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/campaign");
require("scripts/zones/Windurst_Waters_[S]/TextIDs");

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
