
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
function onTrigger(entity, npc)
    if (npc:getInstance():getStage() == 7) then
        entity:startEvent(300)
    else
        entity:messageSpecial(Arrapago.text.DOOR_IS_SEALED)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result, door)
    if (eventid == 300 and result == 1) then
        -- 2026-09-06: real fix -- REVISED again. User confirmed by direct playthrough: _22g is a
        -- MANDATORY passage gate you must open to physically reach _22i's location (Gilded
        -- Gateway) -- there is no way around it, unlike floor 1's genuine parallel-branch doors
        -- (_221-_224, which really are alternates and each independently sets the next stage).
        -- This door was wrongly copying that alternate-door pattern and completing the stage
        -- transition (setStage(8)) on its own -- since _22g is a sequential prerequisite, not an
        -- alternate to _22i, that meant simply walking through it already sealed the real exit
        -- (_22i) before the player could ever use it. Real fix: _22g now behaves like this zone's
        -- other plain pass-through corridor doors (e.g. _220) -- it just opens/animates itself;
        -- only _22i (the actual Gilded Gateway exit) performs the real stage 7->8 transition.
        door:setAnimation(8)
        door:untargetable(true)
    end
end

