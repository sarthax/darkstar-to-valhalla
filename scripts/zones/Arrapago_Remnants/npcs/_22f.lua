
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onTrigger(entity, npc)
    if (npc:getInstance():getStage() == 6) and (npc:getInstance():getProgress() >= 11) then
        entity:startEvent(300)
    else
        entity:messageSpecial(Arrapago.text.DOOR_IS_SEALED)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result, door)
    if (eventid == 300 and result == 1) then
        local instance = door:getInstance()
        instance:setStage(7)
        instance:setProgress(0)
        -- 2026-09-05: real fix -- rampart3 (west room) and rampart4 (east room) no longer spawn
        -- here. Per confirmed real mechanic (ffxiclopedia): the west rampart pops once the main
        -- room is cleared (now handled in onInstanceProgressUpdate at progress==11, independent of
        -- whether the player has actually walked up and used this door yet), and the east rampart
        -- only pops after the west rampart is defeated (now handled in Archaic_Rampart_3.lua's
        -- onMobDeath). Spawning both here at once was wrong on two counts: it required the player
        -- to trigger this specific door first, and it spawned both simultaneously instead of
        -- sequentially.
        door:setAnimation(8)
        door:untargetable(true)
        -- 2026-09-04: real fix -- same missing-reveal bug as _220.lua's entrance door. Nothing
        -- ever revealed the next stage's door (_22g/_22h, Arrapago.npcs[7]) after advancing here.
        for i, v in pairs(Arrapago.npcs[7]) do
            local npc = instance:getEntity(bit.band(v, 0xFFF), TYPE_NPC)
            npc:setStatus(STATUS_NORMAL)
        end
    end
end

