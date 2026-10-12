-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_239, LSB: DOOR_1_CENTER_1)
-----------------------------------
-- 2026-09-08: real fix -- was previously modeled as an "either door locks both, advances the
-- instance" pair with _23a, based on LSB's own DOOR_1_CENTER_1/DOOR_1_CENTER_2 role labels. User
-- confirmed via a real video playthrough this is wrong: _239 and _23a are a straight SEQUENTIAL
-- pair (a continuous southward corridor -- you physically pass _239 to reach _23a, not a branch
-- choice), and BOTH must be opened to reach the telepad, with no other precondition observed.
-- Live-confirmed real bug this caused: opening _239 first advanced the instance stage, which then
-- made _23a (the actual final gate, right before the telepad) permanently show "sealed" even
-- though it had never been used. Converted to a plain, standalone pass-through door -- no stage
-- change, no Floor 2 reveal here at all; that's _23a's own job now (see that file).
-----------------------------------
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

