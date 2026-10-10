-----------------------------------
-- Area: Zhayolm Remnants
-- Door: 7th Floor Door to Boss (_21i, LSB !pos -340 -6 520; opens its sibling _21h)
-----------------------------------
local util = require("scripts/zones/Zhayolm_Remnants/zhayolm_util")
-----------------------------------
function onTrigger(player, npc)
    util.openBossDoor(npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
end

