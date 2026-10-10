-----------------------------------
-- Area: Zhayolm Remnants
-- Door: 6th Floor Exit to Portal (_21f, LSB door script, LSB !pos -340 -2 160)
-----------------------------------
-- 2026-10-01: ported from LandSandBoat's Zhayolm door; ids are Topaz's own (IDs.lua), unSealed
-- localVar model shared with zhayolm_util.lua. Csid 300 is the shared door-open event.
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
local util = require("scripts/zones/Zhayolm_Remnants/zhayolm_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()

    if instance and instance:getLocalVar('6th Door') >= 13 then
        player:startEvent(300)
    else
        player:messageSpecial(Zhayolm.text.DOOR_IS_SEALED_MYSTERIOUS)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        npc:setAnimation(ANIMATION_OPEN_DOOR)
        npc:untargetable(true)
        npc:getInstance():setLocalVar('stageComplete', 6)
    end
end

