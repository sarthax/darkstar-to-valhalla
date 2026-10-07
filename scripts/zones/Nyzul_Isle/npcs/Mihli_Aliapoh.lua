-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Mihli Aliapoh (npc_list 17093453 = capture 17093454). Dialogue-only, no item reward.
-- Dialog 7685 ("What a marvelous place I've found!...").
-- 2026-09-30 (user): dialog swapped with Naja Salaheem (17093464); previously 7683 ("From an age
-- long past I... But I should say no more..."), which is now Naja's.
-----------------------------------
function onTrigger(player, npc)
    player:messageText(npc, 7685, true)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

