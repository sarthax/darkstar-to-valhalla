-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Fickblix (npc_list 17093459 = capture 17093460). Dialogue-only, no item reward.
-- Dialog 7682 ("If it's all the same to you, I'd rather be left alone...").
-----------------------------------
function onTrigger(player, npc)
    player:messageText(npc, 7682, true)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

