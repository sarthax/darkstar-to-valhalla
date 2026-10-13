require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onTrigger(entity, npc)
    entity:startEvent(300)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result, door)
    if (eventid == 300 and result == 1) then
        door:setAnimation(8)
        local instance = door:getInstance()
        -- spawn mobs, etc
        for i, v in pairs(Arrapago.npcs[1][2]) do
            local npc = instance:getEntity(bit.band(v, 0xFFF), TYPE_NPC)
            npc:setStatus(STATUS_NORMAL)
        end
        -- 2026-09-04: real fix -- nothing ever revealed the 4-way branch doors (Arrapago.npcs[1][3],
        -- _221-_224) after the entrance door opened. Their own scripts already correctly lock the
        -- other 3 once one is opened (untargetable(true) on all of Arrapago.npcs[1][3]) -- confirmed real,
        -- matching the user's own understanding of the mechanic -- but they were left permanently
        -- untargetable from instance creation onward since no code ever set them to NORMAL first.
        for i, v in pairs(Arrapago.npcs[1][3]) do
            local npc = instance:getEntity(bit.band(v, 0xFFF), TYPE_NPC)
            npc:setStatus(STATUS_NORMAL)
        end
        for id = Arrapago.mobs[1][2].mobs_start, Arrapago.mobs[1][2].mobs_end do
            SpawnMob(id, instance)
        end
        door:untargetable(true)
    end
end

