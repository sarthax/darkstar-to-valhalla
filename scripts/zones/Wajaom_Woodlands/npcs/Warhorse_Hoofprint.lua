-----------------------------------
-- Area: Wajaom Woodlands
--  NPC: Warhorse Hoofprint
-----------------------------------
-- 2026-09-13, real BG Wiki mechanic (Promotion: Superior Private / Promotion: Corporal). See
-- scripts/globals/besieged.lua's warhorseHoofprintTrigger() for the full real-vs-simplified design
-- note -- summary: real retail has exactly one hoofprint up server-wide on a day/night timer,
-- following one wide-roaming Dark Rider NM across 20+ zones; this implementation keeps all 3 of
-- this zone's real hoofprint spots always active instead, per explicit user decision to make the
-- trial actually findable. This zone's 3 real npc_list.sql rows are positioned via real
-- user-supplied !logpos captures (2026-09-13).
-----------------------------------
require("scripts/globals/besieged")
require("scripts/globals/keyitems")
package.loaded["scripts/zones/Wajaom_Woodlands/TextIDs"] = nil;
require("scripts/zones/Wajaom_Woodlands/TextIDs");
-----------------------------------
function onTrigger(player, npc)
    warhorseHoofprintTrigger(player, npc, HOOFPRINT_FOUND)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

