-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Zeid (npc_list 17093461 = capture 17093462). Opens door _257 (npc_list 17093359 = capture
-- 17093360) to grant access to the rest of floor 1. Line is CapLog 2025.05.01 23:26:13, dialog 7686
-- ("I'll open the door. Advance or retreat--it's up to you.").
-- 2026-09-29 (user report: "door is open by default and closes when you talk to him"): the original
-- comment here had the animation IDs backwards. Per baseentity.h's real ANIMATIONTYPE enum,
-- ANIMATION_OPEN_DOOR=8 and ANIMATION_CLOSE_DOOR=9 (also independently confirmed by the
-- Arrapago_Remnants/_220.lua precedent, which uses setAnimation(8) to OPEN a door on trigger). The
-- npc_list row for 17093359 spawns at animation=8 -- i.e. OPEN by default -- and onTrigger was
-- setting it to 9 (CLOSE), exactly matching the reported bug. Fixed by flipping npc_list's default to
-- 9 (closed) and onTrigger to setAnimation(8) (open).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local DOOR_257 = 17093359
local DOOR_256 = 17093358 -- 2026-09-30 (user): Zeid opens _256 too

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()
    player:messageText(npc, 7671, true)
    if instance then
        for _, id in ipairs({ DOOR_257, DOOR_256 }) do
            local door = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if door then
                door:setAnimation(8)
            end
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

