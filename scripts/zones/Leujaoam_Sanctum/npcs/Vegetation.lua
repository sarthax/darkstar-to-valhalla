-----------------------------------
-- Area: Leujaoam Sanctum (Shanarha Grass Conservation)
--  NPC: Vegetation
-----------------------------------
-- Shared script for all 29 Vegetation props (same npc_list name, matching the Mining_Point.lua/
-- Supplies_Crate.lua convention of one file for a repeated prop).
-- 2026-08-30: real 4-stage decay text (dat-extractor-confirmed, see IDs.lua) shown here on
-- examine, matching the real decayStage a Coney's grazing has advanced this specific patch to
-- (see mobs/Coney.lua). Stage 0 (untouched) has no distinct real MesNum captured -- the base
-- "There is some shanarha grass growing here." examine line, VEGETATION_UNTOUCHED, covers it.
-----------------------------------
local ID = Leujaoam
-----------------------------------
local DECAY_TEXT =
{
    [0] = ID.text.VEGETATION_UNTOUCHED,
    [1] = ID.text.VEGETATION_CHEWED,
    [2] = ID.text.VEGETATION_TORN,
    [3] = ID.text.VEGETATION_DESTROYED,
}

function onTrigger(player, npc)
    local stage = npc:getLocalVar("decayStage") or 0
    player:messageText(npc, DECAY_TEXT[stage] or ID.text.VEGETATION_UNTOUCHED)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

