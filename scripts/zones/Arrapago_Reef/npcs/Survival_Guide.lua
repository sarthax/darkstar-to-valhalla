-----------------------------------
-- Area: Arrapago Reef
--  NPC: Survival Guide
-----------------------------------
package.loaded["scripts/zones/Arrapago_Reef/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/survival_guide");
require("scripts/zones/Arrapago_Reef/TextIDs");

function onTrigger(player,npc)
    SURVIVAL_GUIDE.onTrigger(player, COMMON_SENSE_SURVIVAL);
end;

function onEventUpdate(player,csid,option)
    SURVIVAL_GUIDE.onEventUpdate(player, csid, option);
end;

function onEventFinish(player,csid,option)
    SURVIVAL_GUIDE.onEventFinish(player, csid, option);
end;
