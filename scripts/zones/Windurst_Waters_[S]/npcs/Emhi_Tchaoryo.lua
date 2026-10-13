-----------------------------------
--  Area: Windurst Waters (S)
--   NPC: Emhi Tchaoryo
--  Type: Campaign Ops Overseer
-- @zone 94
-- !pos 10.577 -2.478 32.680
--
-- Auto-Script: Requires Verification (Verified by Brawndo)
-----------------------------------
package.loaded["scripts/zones/Windurst_Waters_[S]/TextIDs"] = nil;
require("scripts/globals/campaign");
-----------------------------------

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    -- Event 311 (text only): serving another nation.
    if (player:getCampaignAllegiance() ~= 3) then
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

