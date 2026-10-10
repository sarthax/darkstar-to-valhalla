-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23y -- not in LSB, role unconfirmed)
-----------------------------------
-- 2026-09-07: real npc_list entity (name/position already correct in SQL, per this zone's own
-- IDs.lua header) -- real door-open csid (300) confirmed via a fresh eventview capture, same
-- shared event family as every other Gilded Doors entity here. Its real branch/group relationship
-- to the OTHER Floor 2-5 doors is NOT yet confirmed (unlike Floor 1's ENTRANCE/BRANCH/EXIT/CENTER
-- chain, see npcs/_230.lua-_23a.lua and IDs.lua's FLOOR1_GROUPS) -- wired standalone for now
-- (opens, self-locks) rather than guessing a group/stage relationship, same baseline behavior as
-- Arrapago Remnants' own simplest real door (npcs/_220.lua) before its own group chaining was
-- confirmed. Revisit once more capture/gameplay data maps this zone's Floor 2-5 structure.
-----------------------------------
-- 2026-09-08: real fix -- onTrigger now checks the door's own "opened" localVar (set by door_util.openSimple) before deciding whether to open or show "Door is sealed..." -- previously this door had no repeat-click check at all AND openSimple made it permanently unclickable via untargetable(), which is the wrong mechanism (see door_util.lua's own comment). A sealed door should stay targetable and respond with the message, not disappear.
require("scripts/zones/Bhaflau_Remnants/IDs")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    if npc:getLocalVar("opened") == 1 then
        player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
    else
        player:startEvent(300)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, door)
    if csid == 300 and option == 1 then
        doorUtil.openSimple(door)
    end
end

