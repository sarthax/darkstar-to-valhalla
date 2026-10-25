-----------------------------------
-- Area: Bastok Mines
--  NPC: Zopago
-- Type: VCS Chocobo Trainer
-- @zone 234
-- !pos 51.706 -0.126 -109.065
-----------------------------------

require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
    CHOCOBO_RAISING.onTrade(player,npc,trade);
end;

function onTrigger(player,npc)
    if (not CHOCOBO_RAISING.onTrigger(player,npc)) then
        -- Main menu is Phase 1b; keep the intro cutscene until it lands.
        player:startEvent(508);
    end
end;

function onEventUpdate(player,csid,option)
    CHOCOBO_RAISING.onEventUpdate(player,csid,option);
end;

function onEventFinish(player,csid,option)
    CHOCOBO_RAISING.onEventFinish(player,csid,option);
end;
