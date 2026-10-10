
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
-- 2026-09-05: real fix -- this is the REAL second door leaf at this position cluster (real client
-- name "Gilded Gateway", confirmed via build_database.py --zones 74 ground-truth entity pull). The
-- logic here was previously (wrongly) placed on _22h.lua, before we had real name data to tell the
-- two apart -- _22h has no real descriptive name (its client name is the literal string "_22h"),
-- meaning it's the passive mechanism/hinge that animates alongside this real door, not a door
-- itself. Moved the real CS logic here; _22h.lua is now a no-op.
-- 2026-09-06: real fix -- >= instead of == 7, as a safety net matching this zone's own doors
-- elsewhere that already use >= for their stage gate (e.g. instances/arrapago_remnants.lua's
-- own progress checks). This door already locks itself (door:untargetable(true)) the moment
-- it's successfully used, so this doesn't allow re-triggering after a real completion -- it only
-- protects against the door wrongly reporting sealed if something else ever advances the
-- instance's stage past 7 before this specific door gets used.
function onTrigger(entity, npc)
    if (npc:getInstance():getStage() >= 7) then
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
        instance:setStage(8)
        instance:setProgress(0)
        door:setAnimation(8)
        door:untargetable(true)
        local mechanism = instance:getEntity(bit.band(Arrapago.npcs.GATEWAY_MECHANISM, 0xFFF), TYPE_NPC)
        mechanism:setAnimation(8)
        mechanism:untargetable(true)
    end
end

