-----------------------------------
-- Area: Nyzul Isle
--  NPC: Vending Box
-- Notes: Lobby temp-item shop (npc_list 17093430), spends NYZUL_ISLE_ASSAULT_POINT tokens.
-- !pos -22.000 -4.000 -11.000
-----------------------------------
require("scripts/globals/nyzul/vending_box")
-----------------------------------
function onTrigger(player, npc)
    Nyzul.vendingBoxOnTrigger(player)
end

function onEventUpdate(player, csid, option)
    Nyzul.vendingBoxOnEventUpdate(player, csid, option)
end

-- 2026-09-23: removed an empty onEventFinish stub -- part of the systemic
-- instance-timeout black-screen fix (see documentation/Assault_Fix_Log.md, the
-- 2026-08-18 'SYSTEMIC' entry, and Nyzul_Isle/npcs/Rune_of_Transfer.lua's own header
-- comment). An empty-but-defined onEventFinish here permanently pins
-- PChar->m_event.Script to this file whenever it's the last NPC a player clicked
-- (the custom EVENTFIX patch preserves that pin across resets), so LoadEventScript
-- never falls through to Zone.lua's real csid==102 handler on instance
-- timeout/mission-failed -- the eject cutscene plays, the client acks it, and the
-- player is never actually removed from the failed instance: stuck at a black
-- screen forever. Deleting the stub (this file has no real per-csid logic to keep)
-- lets dispatch reach the working fallback.

