-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23a, LSB: DOOR_1_CENTER_2)
-----------------------------------
-- 2026-09-08: real fix -- was previously modeled as an "either door locks both, advances the
-- instance" pair with _239, based on LSB's own DOOR_1_CENTER_1/DOOR_1_CENTER_2 role labels. User
-- confirmed via a real video playthrough this is wrong: _239 and _23a are a straight SEQUENTIAL
-- pair (a continuous southward corridor, not a branch choice) -- BOTH must be opened to reach the
-- telepad, no other precondition observed. _239 is now a plain pass-through door with no stage
-- effect (see that file); this door (the real final gate, right before the telepad) keeps the
-- stage-advance/Floor 2 reveal, but its own sealed-check no longer depends on instance stage at
-- all (that was the actual bug: _239 advancing stage made THIS door read as sealed even though it
-- had never been opened) -- switched to the same self-tracked "opened" flag every other real
-- Bhaflau door uses.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
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

-- 2026-09-08: real fix -- matches LSB's own real _23a.lua exactly: this door only marks
-- stageComplete = 1 (the CURRENT stage, unchanged) -- it does NOT advance stage or reveal Floor 2
-- itself. That happens in the region-1/csid-200 telepad handler
-- (instances/bhaflau_remnants.lua), which is what stageComplete==getStage() actually gates (see
-- that file's own onRegionEnter). An earlier version of this fix incorrectly duplicated the
-- stage-advance/Floor 2 reveal here too, which would have raced/conflicted with the telepad's own
-- real logic.
function onEventFinish(player, csid, option, door)
    if csid == 300 and option == 1 then
        doorUtil.openSimple(door)
        local instance = door:getInstance()
        instance:setLocalVar("stageComplete", 1)
    end
end

