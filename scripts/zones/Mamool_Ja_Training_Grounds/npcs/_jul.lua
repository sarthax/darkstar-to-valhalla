-----------------------------------
-- Area: Mamool Ja Training Grounds (Imperial Agent Rescue)
--  NPC: Pot Hatch, GATE_2 pen (real npc_list.sql name "_jul")
-----------------------------------
-- 2026-08-18: position-paired with GATE_2/_ju5 (both x~180, z~-560) -- see
-- instance_entities.sql, _pot_hatch_common.lua, and Assault_Fix_Log.md for the full writeup.
-----------------------------------
local common = require("scripts/zones/Mamool_Ja_Training_Grounds/npcs/_pot_hatch_common")
-----------------------------------
function onTrigger(player, npc)
    npc:lookAt(player:getPos())
    common.trySearchHatch(player, npc, 2)
end

