-----------------------------------
-- Area: Zhayolm Remnants
-- Door: 1st Floor Beginning Door (_210, LSB door script, LSB !pos 400 -2 -560)
-----------------------------------
-- 2026-10-01: ported from LandSandBoat's Zhayolm door; ids are Topaz's own (IDs.lua), unSealed
-- localVar model shared with zhayolm_util.lua. Csid 300 is the shared door-open event.
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
local util = require("scripts/zones/Zhayolm_Remnants/zhayolm_util")
-----------------------------------
function onTrigger(player, npc)
    player:startEvent(300)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        local instance = npc:getInstance()
        if instance and util.onDoorOpen(npc) then
            instance:setLocalVar('allySize', #instance:getChars())
            util.unsealDoors(instance, { Zhayolm.npcs.DOOR._211, Zhayolm.npcs.DOOR._212, Zhayolm.npcs.DOOR._213, Zhayolm.npcs.DOOR._214 })
        else
            player:messageSpecial(Zhayolm.text.DOOR_IS_SEALED)
        end
    end
end

