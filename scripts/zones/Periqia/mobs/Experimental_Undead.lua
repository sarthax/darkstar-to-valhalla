require("scripts/globals/status")
-----------------------------------
-- Area: Periqia (Saving Private Ryaaf)
--  Mob: Experimental Undead
-----------------------------------
-- The real Fomor -- either a room's revealed decoy (see npcs/Hunched_Figure.lua) or one of the 3
-- ambient roaming variants. This file exists to satisfy the engine's onMobDeath hook lookup (was
-- previously missing entirely, logging "undefined procedure onMobDeath" on every kill).
-- 2026-08-23 DISABLED, left commented out below for a future pass -- do not re-enable without
-- addressing both real bugs found live-testing this:
--   1. Wrong engine hook used. `onMobRoam` is NOT gated by ROAMFLAG_EVENT/the normal roam-
--      cooldown state machine at all -- that's a real, separate hook, `onMobRoamAction`
--      (luautils::OnMobRoamAction, mob_controller.cpp's ROAMFLAG_EVENT branch). What actually ran
--      was `luautils::OnMobRoam` (luautils.cpp:2914), an unconditional "every 3 real seconds,
--      regardless of roam flags or whether the mob is still mid-path" general roam-script hook.
--      Every 3s, the code below re-issued a fresh pathTo(), constantly interrupting/restarting
--      whatever path was already in progress -- this is what made movement look "way too fast"/
--      erratic live. A real fix needs either a self-throttle localvar (same pattern
--      Apollyon/Adamantshell.lua uses on this exact hook) or switching to the real
--      `onMobRoamAction` name so the engine's own cooldown gating applies instead.
--   2. Reaching a room's doorway triggered an immediate, permanent despawn with no respawn --
--      confirmed live, separate from bug 1. Not yet root-caused -- possibly an IsFarFromHome()/
--      despawn-on-arrival interaction, possibly the same navmesh-connectivity gaps already tracked
--      for this zone. No MOBMOD_NO_DESPAWN is set on this pool, so any despawn here is permanent.
-- mob_pools poolid 1274's roamflag reverted 256 (ROAMFLAG_EVENT) -> 0 to match -- see that row's
-- comment in mob_pools.sql. MOBMOD_ROAM_COOL below is kept at a slower-than-default pace (10s)
-- for the plain default wander these 3 fall back to now.
-----------------------------------
-- local ID = Periqia
-----------------------------------
-- local ROOM_OCCUPANTS =
-- {
--     ID.npc.RYAAF, ID.npc.BALARAHB, ID.npc.RHAGMAKAH,
--     ID.npc.HUNCHED_FIGURE1, ID.npc.HUNCHED_FIGURE2,
-- }

-- local function pickRandomActiveOccupant(instance)
--     local active = {}
--
--     for _, npcId in ipairs(ROOM_OCCUPANTS) do
--         local occupant = instance:getEntity(bit.band(npcId, 0xFFF), TYPE_NPC)
--         if occupant and occupant:getLocalVar("revealed") == 0 then
--             active[#active + 1] = occupant
--         end
--     end
--
--     if #active > 0 then
--         return active[math.random(#active)]
--     end
--
--     -- All 5 found -- converge on the Rune of Release room instead of going idle. Its own
--     -- "revealed" localvar is never set (not a ROOM_OCCUPANTS member), so callers must not apply
--     -- the same relock-on-revealed check to this fallback -- it's always a valid, permanent target.
--     return instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
-- end

-- onMobRoam = function(mob)
--     local instance = mob:getInstance()
--     local targetId = mob:getLocalVar("targetOccupant")
--     local target = (targetId ~= 0) and instance:getEntity(bit.band(targetId, 0xFFF), TYPE_NPC) or nil
--
--     -- relock immediately once the current target is found (or if there never was one). The Rune
--     -- of Release fallback (targetId == ID.npc.RUNE_OF_RELEASE) has no "revealed" localvar so it
--     -- reads as 0/unrevealed forever -- deliberately treated as always-valid, only replaced if an
--     -- occupant somehow becomes active again (can't happen once all 5 are found).
--     if not target or (targetId ~= ID.npc.RUNE_OF_RELEASE and target:getLocalVar("revealed") ~= 0) then
--         target = pickRandomActiveOccupant(instance)
--         mob:setLocalVar("targetOccupant", target and target:getID() or 0)
--     end
--
--     if target and mob:checkDistance(target) > 2 then
--         local tp = target:getPos()
--         mob:pathTo(tp.x, tp.y, tp.z, 9)
--     end
-- end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_ROAM_COOL, 10)
end

function onMobDeath(mob, player, isKiller)
end

