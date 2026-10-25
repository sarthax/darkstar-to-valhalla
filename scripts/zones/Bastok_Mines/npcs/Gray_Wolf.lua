-----------------------------------
-- Area: Bastok Mines
-- NPC: Gray Wolf
-- Standard Info NPC
-----------------------------------
package.loaded["scripts/zones/Bastok_Mines/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/chocobo_raising");
require("scripts/zones/Bastok_Mines/TextIDs");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;
-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    if (CHOCOBO_RAISING.ownerTrigger(player, 'Gray_Wolf')) then
        return;
    end
    player:startEvent(0x0013);
end; 
-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    CHOCOBO_RAISING.ownerUpdate(player, csid, option, 'Gray_Wolf');
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;
-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;