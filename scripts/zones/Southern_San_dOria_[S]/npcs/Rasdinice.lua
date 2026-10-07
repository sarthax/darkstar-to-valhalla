-----------------------------------
-- Area: Southern SandOria [S]
-- NPC: Rasdinice
-- @zone 80
-- !pos -8 1 35
-----------------------------------
package.loaded["scripts/zones/Southern_San_dOria_[S]/TextIDs"] = nil;
require("scripts/zones/Southern_San_dOria_[S]/TextIDs");
require("scripts/globals/campaign");
-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
-- Event 311 (text only): not of this nation's allegiance. Verified by decode, no capture.
    if (player:getCampaignAllegiance() ~= 1) then
        player:startEvent(311, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    else
        opsOnTrigger(player, 307);
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    if (csid == 307) then
        opsOnEventUpdate(player, csid, option);
    end
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;