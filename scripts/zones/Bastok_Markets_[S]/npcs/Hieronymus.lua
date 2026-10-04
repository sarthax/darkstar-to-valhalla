-----------------------------------
-- Area: Bastok Markets [S]
--  NPC: Hieronymus
-- Type: Campaign Ops Overseer
-- !pos -325.702 -12.601 -51.150 87
-----------------------------------
package.loaded["scripts/zones/Bastok_Markets_[S]/TextIDs"] = nil;
-----------------------------------

require("scripts/zones/Bastok_Markets_[S]/TextIDs");
require("scripts/globals/campaign");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    -- Event 320 (text only): not of this nation's allegiance. Verified by decode, no capture.
    if (player:getCampaignAllegiance() ~= 2) then
        player:startEvent(320, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    else
        opsOnTrigger(player, 316);
    end
end;

function onEventUpdate(player,csid,option)
    if (csid == 316) then
        opsOnEventUpdate(player, csid, option);
    end
end;

function onEventFinish(player,csid,option)
end;
