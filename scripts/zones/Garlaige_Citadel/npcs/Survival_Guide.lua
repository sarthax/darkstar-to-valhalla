-----------------------------------
-- Area: Garlaige Citadel
--  NPC: Survival Guide
-----------------------------------
package.loaded["scripts/zones/Garlaige_Citadel/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/survival_guide");
require("scripts/zones/Garlaige_Citadel/TextIDs");

function onTrigger(player,npc)
    SURVIVAL_GUIDE.onTrigger(player, COMMON_SENSE_SURVIVAL);
end;

function onEventUpdate(player,csid,option)
    SURVIVAL_GUIDE.onEventUpdate(player, csid, option);
end;

function onEventFinish(player,csid,option)
    SURVIVAL_GUIDE.onEventFinish(player, csid, option);
end;
