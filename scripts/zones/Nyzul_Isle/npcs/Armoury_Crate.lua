-----------------------------------
-- Area: Nyzul Isle
--  NPC: Armoury Crate
-- Notes: temp-item crate. This is the shared script for the whole pool (17092609+) -- one is
--        positioned/revealed per Free Floor by instances/nyzul_isle_investigation.lua.
-----------------------------------
require("scripts/globals/nyzul/armoury_crate")
-----------------------------------
function onTrigger(player, npc)
    Nyzul.tempBoxTrigger(player, npc)
end

function onEventFinish(player, csid, option, npc)
    Nyzul.tempBoxFinish(player, csid, option, npc)
end

