-----------------------------------
-- Area: Southern San d'Oria
-- NPC: Violitte
-- Map Seller NPC
-----------------------------------
package.loaded["scripts/zones/Southern_San_dOria/TextIDs"] = nil;

require("scripts/globals/chocobo_raising");
require("scripts/zones/Southern_San_dOria/TextIDs");
require("scripts/globals/magic_maps");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)

end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    if (CHOCOBO_RAISING.ownerTrigger(player, 'Violitte')) then
        return;
    end
    CheckMaps(player, npc, 0x0253);
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    CHOCOBO_RAISING.ownerUpdate(player, csid, option, 'Violitte');
    if (csid == 0x0253) then
        CheckMapsUpdate(player, option, NOT_HAVE_ENOUGH_GIL, KEYITEM_OBTAINED);
    end
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    
end;