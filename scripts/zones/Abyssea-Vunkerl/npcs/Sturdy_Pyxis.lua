-----------------------------------
-- Area: Abyssea
-- NPC: Sturdy Pyxis
-- Logic: scripts/globals/abyssea_pyxis.lua
-----------------------------------

require("scripts/globals/abyssea_pyxis");

function onTrade(player,npc,trade)
    onPyxisTrade(player,npc,trade);
end;

function onTrigger(player,npc)
    onPyxisTrigger(player,npc);
end;

function onEventUpdate(player,csid,option)
    onPyxisEventUpdate(player,csid,option);
end;

function onEventFinish(player,csid,option)
    onPyxisEventFinish(player,csid,option);
end;
