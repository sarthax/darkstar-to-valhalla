-----------------------------------
-- Area: Bhaflau Remnants
--  NPC: Dormant Rampart
-----------------------------------
-- 2026-09-08: real fix -- moved here from mobs/Dormant_Rampart.lua. Live testing showed it as a
-- Mob entity spawned immediately, was attackable/one-hit-killable, and never actually triggered
-- the warp -- confirmed via LandSandBoat's own real reference that this is genuinely an NPC
-- (untargetable-for-combat, click-only prop), never a mob at all. sql/npc_list.sql now carries its
-- real position/look/status (status=2/DISAPPEAR by default -- hidden until Mad Bomber/Empathic
-- Flan reveals it via setStatus(NORMAL)), ported directly from LSB's own npc_list rows for these
-- same 4 real ids. sql/mob_spawn_points.sql/mob_groups.sql's own Dormant_Rampart rows are removed.
--
-- onTrigger/onEventFinish logic below is unchanged from the mob version -- real onTrigger-on-mob
-- support was confirmed via a direct capture (CS Event csid 3), and the engine's dispatch is
-- generic CBaseEntity*, so the same logic works identically for an NPC. Matches this entity's own
-- id against DORMANT_RAMPART to find its real array index, then reads REACTIONARY_RAMPART at that
-- same index -- IDs.lua's arrays are position-parallel per floor.
-----------------------------------
require("scripts/globals/status")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
local function findReactionaryId(dormantNpcId)
    for i, id in ipairs(Bhaflau.mobs.DORMANT_RAMPART) do
        if id == dormantNpcId then
            return Bhaflau.mobs.REACTIONARY_RAMPART[i]
        end
    end
    return nil
end

function onTrigger(player, npc)
    player:startEvent(3)
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-08: real fix -- was a bare setPos with no visual transition at all. The original
-- Foxmulder capture showed a real, separate self-triggered csid 5 firing on the player right after
-- this exact confirm (csid 3, option 1), same as region-based telepads elsewhere in this zone --
-- added the matching startEvent(5) so the warp actually plays something instead of an instant,
-- silent position jump.
--
-- 2026-09-08 (later): real fix -- decoded csid 5's actual real bytecode via
-- mission_toolkit/explore_event.py (Bhaflau_Remnants, entity 2147483632/self, csid 5) instead of
-- guessing further. Real sequence: player:setCancelData() -> fade-out task ("fdo1") -> wait 60
-- ticks (1.0s) -> fade-in task ("fdi1") -> wait 120 ticks (2.0s) -- confirmed NO baked position or
-- coordinate data anywhere in it; it is purely a screen fade, the server is fully responsible for
-- the actual position. The earlier version called setPos in the SAME tick as startEvent(5), before
-- the ~140-tick (2.3s) fade-out had even started -- the player saw an instant jump immediately,
-- then a seemingly unrelated fade play ~2.3s later, looking like two separate warps. Delaying
-- setPos (and the one-time-use hide) to roughly when the screen is actually black (~200 ticks /
-- 3300ms: the 140-tick fade-out plus the 60-tick transition wait) fixes this -- the player now sees
-- one continuous fade-to-black-then-reveal-at-new-location, not an instant jump plus a separate
-- animation.
--
-- 2026-09-08 (later still): real fix -- live-confirmed this was usable more than once: the Dormant
-- Rampart stayed visible/targetable after use, so clicking it again spawned a SECOND Reactionary
-- Rampart. BG Wiki's own mechanic is one real encounter per Mad Bomber/Empathic Flan trigger --
-- hides itself (back to its own real default DISAPPEAR status, same as npc_list's own row) the
-- moment it's actually used, matching the same reveal-once pattern used everywhere else in this
-- zone. Moved to fire at the same delayed moment as the position change, not instantly.
-- 2026-09-09: real fix -- npc:setStatus(DISAPPEAR)/untargetable(true) fired in the SAME tick as
-- startEvent(5), before the player had actually been relocated (the real setPos is delayed 3300ms
-- to match the fade, per the csid 5 decode above) -- user reported the Dormant Rampart vanishing
-- immediately on confirm instead of staying visible through the transition. Moved both calls inside
-- the same delayed callback as the real position change, so it only disappears once the player has
-- actually arrived at the Reactionary Rampart.
--
-- 2026-09-09 (also): real fix -- was only ever warping the triggering player, not the whole party,
-- unlike every other real telepad in this zone (region triggers use instances/
-- bhaflau_remnants.lua's own teleportGroup helper for exactly this reason). Ported the same
-- pattern here: every other character in the instance gets the same real csid 5 fade and is moved
-- to the same Reactionary Rampart position, not just the trigger.
function onEventFinish(player, csid, option, npc)
    if csid == 3 and option == 1 then
        local instance = npc:getInstance()
        if not instance then
            return
        end

        local reactionaryId = findReactionaryId(npc:getID())
        if not reactionaryId then
            return
        end

        local reactionary = SpawnMob(reactionaryId, instance)
        if reactionary then
            local pos = reactionary:getPos()

            local function warpChar(char, isTrigger)
                if not isTrigger then
                    char:startEvent(5)
                end
                char:timer(3300, function(c)
                    c:setPos(pos.x, pos.y, pos.z, pos.rot)
                end)
            end

            player:startEvent(5)
            warpChar(player, true)

            local chars = instance:getChars()
            for _, char in pairs(chars) do
                if char:getID() ~= player:getID() then
                    warpChar(char, false)
                end
            end

            player:timer(3300, function()
                npc:setStatus(STATUS_DISAPPEAR)
                npc:untargetable(true)
            end)
        end
    end
end

