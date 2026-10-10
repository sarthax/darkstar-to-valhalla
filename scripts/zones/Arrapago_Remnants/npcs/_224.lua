
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onTrigger(entity, npc)
    if (npc:getInstance():getStage() == 1) then
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
        instance:setStage(2)
        instance:setProgress(0)
        door:setAnimation(8)
        -- 2026-09-08: real fix -- removed the untargetable(true) lock loop on Arrapago.npcs[1][3] (this door's own branch-sibling group). untargetable() sets entityFlags 0x800, making the entity
        -- fully unclickable -- no onTrigger fires at all once set, so this door's own "Door is sealed" check above (getStage()) could never actually display through that path. User
        -- confirmed the real intended behavior: a sealed door stays targetable/clickable, you interact with it, and it responds with the message -- it does not disappear.
        -- 2026-09-04: real fix -- same missing-reveal bug as _220.lua's entrance door. Nothing
        -- ever revealed the next stage's 4-way door group (npc[2][1]) after advancing here.
        for i, v in pairs(Arrapago.npcs[2][1]) do
            local npc = instance:getEntity(bit.band(v, 0xFFF), TYPE_NPC)
            npc:setStatus(STATUS_NORMAL)
        end
    end
end

