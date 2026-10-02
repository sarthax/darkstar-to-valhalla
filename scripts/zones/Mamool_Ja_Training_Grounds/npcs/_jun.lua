-----------------------------------
-- Area: Mamool Ja Training Grounds (Imperial Agent Rescue)
--  NPC: Pot Hatch, GATE_1 pen (real npc_list.sql name "_jun")
-----------------------------------
-- 2026-08-18: position-paired with GATE_1/_ju3 (both x~220, z~-440) -- see
-- instance_entities.sql, _pot_hatch_common.lua, and Assault_Fix_Log.md for the full writeup.
-----------------------------------
local common = require("scripts/zones/Mamool_Ja_Training_Grounds/npcs/_pot_hatch_common")
-----------------------------------
function onTrigger(player, npc)
    npc:lookAt(player:getPos())
    common.trySearchHatch(player, npc, 1)
end

