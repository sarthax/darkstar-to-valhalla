-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Aldo (npc_list 17093460 = capture 17093461). Tier 1: after the 3 Unlucky Beaks die, he activates the rune.
-- Line is dialog.yml 7672 (capture 7687).
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/globals/heroines_holdfast")
-----------------------------------
function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()
    local beaksDead = instance and instance:getLocalVar("HH_BeaksDead")
    -- 2026-09-27: debug instrumentation -- user reports Aldo gives no dialog at all (neither the
    -- "activated" line nor the "objective not met" line), which would mean onTrigger isn't being
    -- dispatched to this file (same dispatch-miss class already seen on Runic_Lamp/Rune_of_Transfer).
    dbgPrint(string.format("[ALDO DEBUG] onTrigger npcid=%d instance=%s HH_BeaksDead=%s",
        npc:getID(), tostring(instance ~= nil), tostring(beaksDead)))
    if instance and beaksDead and beaksDead >= 3 then
        dbgPrint("[ALDO DEBUG] condition met -- activating rune 1, messageText 7672")
        tpz.heroines.activateRune(instance, 1)
        player:messageText(npc, 7672, true)
    else
        dbgPrint(string.format("[ALDO DEBUG] condition NOT met -- messageText TEXT_OBJ_ALDO=%s",
            tostring(tpz.heroines.TEXT_OBJ_ALDO)))
        player:messageText(npc, tpz.heroines.TEXT_OBJ_ALDO, true)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

