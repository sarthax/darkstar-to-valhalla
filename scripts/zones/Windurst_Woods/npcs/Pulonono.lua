-----------------------------------
-- Area: Windurst Woods
--  NPC: Pulonono
-- Type: VCS Chocobo Trainer
-- @zone 241
-- !pos 130.124 -6.35 -119.341
-----------------------------------

require("scripts/globals/chocobo_raising");

function onTrade(player,npc,trade)
    CHOCOBO_RAISING.onTrade(player,npc,trade);
end;

function onTrigger(player,npc)
    if (not CHOCOBO_RAISING.onTrigger(player,npc)) then
        -- Main menu is Phase 1b; keep the intro cutscene until it lands.
        player:startEvent(741);
    end
end;

function onEventUpdate(player,csid,option)
    CHOCOBO_RAISING.onEventUpdate(player,csid,option);
end;

function onEventFinish(player,csid,option)
    CHOCOBO_RAISING.onEventFinish(player,csid,option);
end;
