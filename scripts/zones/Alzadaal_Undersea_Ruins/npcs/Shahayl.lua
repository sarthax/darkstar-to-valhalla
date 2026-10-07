-----------------------------------
-- Area: Alzadaal Undersea Ruins
--  NPC: Shahayl
-- Type: Assault (Nyzul Isle Staging Point)
-----------------------------------
-- 2026-09-09: real fix -- this NPC had a real npc_list.sql row (17072276, position matching the
-- real capture/LSB exactly) but NO Lua script at all -- not in Topaz, and not in LSB either (LSB's
-- own data/zones/alzadaal_undersea_ruins/npcs.yaml declares `script: Shahayl` but never actually
-- shipped that file, confirmed by checking LSB's own npcs/ folder directly). Built fresh from
-- real captured event data (FFXI-EventsDump, csid 412/413, text ids 7462-7481) rather than
-- guessed -- user confirmed via BG Wiki: "Sells Key Item Assault armband for 50 Imperial
-- Standing," matching this exact mechanic exactly as already implemented (and working) for 5
-- sibling NPCs at the other Assault staging zones: Meyaada (Arrapago Reef), Nahshib (Caedarva
-- Mire), Waudeen (Mount Zhayolm), Daswil (Bhaflau Thickets), Nareema (Caedarva Mire). Mirrors
-- Daswil.lua's real, already-working structure exactly, using Shahayl's own real csids/text ids
-- in place of Daswil's.
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/status")
require("scripts/globals/besieged")
require("scripts/globals/nyzul")
require("scripts/zones/Alzadaal_Undersea_Ruins/TextIDs")
-----------------------------------
-- 2026-09-09: real fix -- user reported Shahayl (and Sorrowful Sage) always show "0 floors
-- completed" on the Runic Disc regardless of real progress. Root cause confirmed: the real per-
-- floor tracker is NOT a char_points column at all -- it's the generic charvar
-- "NyzulFloorProgress" (see scripts/globals/nyzul.lua's own real comment: "each player's OWN
-- personally-saved disc floor... saved here, every real floor clear"). Neither NPC referenced
-- it; both only ever touched nyzul_isle_assault_point (tokens), a different value entirely.
-- Event 412's real disassembly (mission_toolkit/explore_event.py + raw opcode dump) confirms the
-- "I want to ask you some questions" -> "Nyzul Isle Uncharted Region" branch prints two real,
-- captured text lines (7502/7504) that each embed a token count and a floor number -- but the
-- exact internal register/slot wiring for those numeric substitutions could NOT be conclusively
-- resolved from the compiled bytecode (the PRINT_EVENT_MESSAGE operands don't fully decode with
-- available tooling) -- flagged rather than guessed. All 4 values below are real and correctly
-- sourced (flat cost, current standing, real token count, real floor progress); only their exact
-- order/slot could be wrong if the client expects a different arrangement -- needs a live test to
-- confirm the displayed numbers land in the right spots.
function onTrigger(player, npc)
    -- 2026-09-12, user-reported live: Shahayl never offered the armband purchase menu, only the
    -- flavor-only dialogue. Root cause for that specific report was the player already holding
    -- ASSAULT_ARMBAND (correctly skips the purchase menu -- nothing left to sell). While
    -- confirming that, found a real gap versus the sibling staging-point NPCs (e.g. Daswil.lua,
    -- Bhaflau Thickets, the confirmed-working real pattern): those also require the player to
    -- already hold that zone's own Assault Orders key item before ever offering the purchase menu
    -- -- Shahayl was missing that precondition entirely, so it would offer to sell an armband to a
    -- player who hasn't even picked an assault yet. Added to match.
    if player:hasKeyItem(NYZUL_ISLE_ASSAULT_ORDERS) and not player:hasKeyItem(ASSAULT_ARMBAND) then
        local IPpoint = player:getCurrency("imperial_standing")
        local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
        -- 2026-09-22: NyzulFloorProgress is now mission-scoped (Nyzul.floorProgressVar) --
        -- read via the player's real current assault id (51 Investigation or 52 Uncharted) rather
        -- than the old flat shared charvar, so this staging point shows that mission's own progress.
        local floorProgress = player:getVar(Nyzul.floorProgressVar(player:getCurrentAssault()))
        player:startEvent(412, 50, IPpoint, tokens, floorProgress)
    else
        -- Real flavor-only dialogue (csid 413, text 7505): "This is the Nyzul Isle staging
        -- point. If you have no official business here, it's time for you to leave."
        player:startEvent(413)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 412 and option == 1 then
        player:delCurrency("imperial_standing", 50)
        player:addKeyItem(ASSAULT_ARMBAND)
        player:messageSpecial(KEYITEM_OBTAINED, ASSAULT_ARMBAND)
    end
end

