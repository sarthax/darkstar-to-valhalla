-----------------------------------
--  Area: Southern San d'Oria
--   NPC: Hantileon
--  Type: VCS Chocobo Trainer
-- @zone 230
-- !pos -2.675 -1.1 -105.287
-----------------------------------

package.loaded["scripts/zones/Southern_San_dOria/TextIDs"] = nil;

require("scripts/zones/Southern_San_dOria/TextIDs");
require("scripts/globals/quests");
require("scripts/globals/chocobo_raising");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
    CHOCOBO_RAISING.onTrade(player,npc,trade);
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)


    local chocoboOnTheLoose = player:getVar("ChocoboOnTheLoose");

    if (chocoboOnTheLoose == 3 or chocoboOnTheLoose == 4) then
        player:startEvent(0x0335);
    elseif (chocoboOnTheLoose == 5) then
        player:startEvent(0x0336);
    elseif (CHOCOBO_RAISING.whistleTrigger(player)) then
        return;
    elseif (not CHOCOBO_RAISING.onTrigger(player,npc)) then
        -- Main menu is Phase 1b; keep the intro cutscene until it lands.
        player:startEvent(0x0331);
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    CHOCOBO_RAISING.onEventUpdate(player,csid,option);
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    CHOCOBO_RAISING.onEventFinish(player,csid,option);
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);

    if (csid == 0x0335) then
        player:setVar("ChocoboOnTheLoose", 5);
    elseif (csid == 0x0336) then
        player:setVar("ChocoboOnTheLoose", 6);
    end
end;