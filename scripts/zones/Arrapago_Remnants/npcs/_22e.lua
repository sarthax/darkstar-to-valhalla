
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onTrigger(entity, npc)
    if (npc:getInstance():getStage() == 5) then
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
        instance:setStage(6)
        instance:setProgress(2)
        -- 2026-09-05: real fix -- same timer fix as _22d.lua's twin branch. See that file's comment.
        instance:getEntity(bit.band(Arrapago.npcs[6].DOOR, 0xFFF), TYPE_NPC):setLocalVar("start", os.time())
        door:setAnimation(8)
        SpawnMob(Arrapago.mobs[5][1].chariot, instance)
        SpawnMob(Arrapago.mobs[5][1].astrologer, instance)
        -- 2026-09-08: real fix -- removed the untargetable(true) lock loop on Arrapago.npcs[5][1] (this door's own branch-sibling group). untargetable() sets entityFlags 0x800, making the entity
        -- fully unclickable -- no onTrigger fires at all once set, so this door's own "Door is sealed" check above (getStage()) could never actually display through that path. User
        -- confirmed the real intended behavior: a sealed door stays targetable/clickable, you interact with it, and it responds with the message -- it does not disappear.
        -- 2026-09-04: real fix -- same missing-reveal bug as _220.lua's entrance door. Nothing
        -- ever revealed the next stage's door (_22f, Arrapago.npcs[6].DOOR) after advancing here.
        instance:getEntity(bit.band(Arrapago.npcs[6].DOOR, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    end
end

