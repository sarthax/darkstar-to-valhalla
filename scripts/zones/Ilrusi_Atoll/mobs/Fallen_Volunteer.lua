-----------------------------------
-- Area: Ilrusi Atoll (Lamia No.13)
--  Mob: Fallen Volunteer
-----------------------------------
-- Ambient guard, spawns alongside Lamia No.13 (not a kill objective -- see
-- instances/lamia_no_13.lua). 2026-08-19: same static-location bug as Lamia herself --
-- MOBMOD_ROAM_DISTANCE was never set, defaults to 0 (zero roam radius). See Lamia_No13.lua's
-- header for the full root-cause writeup.
-- 2026-08-19 (later): user-reported the companions should stay with Lamia as she wanders, not
-- roam independently. There's no engine mechanism for one wild mob to follow another's movement
-- -- PMaster/pet-following (src/map/ai/controllers/mob_controller.cpp) is player-pet-only, and
-- SUBLINK/LINK_RADIUS only link aggro, not movement. Dropped their own roam radius to a small one
-- (kept below as a fallback) so they'd at least stay near their own spawn point instead of
-- wandering independently -- but that only anchors them to their SPAWN point, not to Lamia's
-- CURRENT one. Since her own roam radius is much larger (5000 = 500 yalms, needed for her own
-- "doesn't wander like a real NM" fix), she drifts far from that shared spawn point over time
-- while they stay tethered near it -- confirmed by user-reported observation the gap grows to
-- 50+ yalms, well past what "stay with Lamia" means.
-- 2026-08-20: real fix -- an active follow loop using pathTo() (the same non-PC walk-toward-a-point
-- primitive used by Selh'Teus in the CoP final fight, "makes a non-PC move toward a target without
-- changing action") on a self-rescheduling timer, checking distance to Lamia's CURRENT position
-- (not spawn) every few seconds and walking closer if too far. Skipped while engaged so it doesn't
-- interfere with actual combat positioning.
-- 2026-08-25: real mechanic -- Fallen start charmed by Lamia (instances/lamia_no_13.lua), fighting
-- on her side. User-reported live: after fixing the crash in the underlying charm system, they
-- spawned correctly but were completely unresponsive, even when directly attacked. Root cause,
-- confirmed in engine source (mob_controller.cpp's aggro-check function): ANY mob with a non-null
-- `PMaster` is unconditionally excluded from the native aggro/engage AI -- that whole path assumes
-- a real player is issuing pet commands, which Lamia (a mob) obviously can't do. So once charmed,
-- a mob genuinely never autonomously engages anyone again, including in self-defense, unless
-- something explicitly forces it. Reusing this same follow-timer to also mirror Lamia's own
-- combat: whenever she's engaged with a target, force the Fallen to engage that same target too --
-- matches "fights on her side," not "attacks anyone nearby regardless of what Lamia's doing."
-----------------------------------

-----------------------------------
local FOLLOW_INTERVAL_MS = 3000
local FOLLOW_TRIGGER_DISTANCE = 10 -- yalms -- start closing the gap past this

local function followLamia(mob)
    if not mob:isAlive() then
        return
    end

    local instance = mob:getInstance()
    local lamia = instance and GetMobByID(17002517, instance)

    if lamia and lamia:isAlive() then
        local lamiaTarget = lamia:getTarget()
        if lamiaTarget and not mob:isEngaged() then
            mob:engage(lamiaTarget:getShortID())
        end

        if not mob:isEngaged() and mob:checkDistance(lamia) > FOLLOW_TRIGGER_DISTANCE then
            mob:pathTo(lamia:getXPos(), lamia:getYPos(), lamia:getZPos())
        end
    end

    mob:timer(FOLLOW_INTERVAL_MS, followLamia)
end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_ROAM_DISTANCE, 100) -- 10 yalms, fallback if the follow loop is ever off
    mob:timer(FOLLOW_INTERVAL_MS, followLamia)
end

-- Ambient companion, not a kill objective (see header) -- Lamia_No13.lua's own onMobDeath is what
-- advances mission progress. This still needs to exist though: the engine calls onMobDeath
-- unconditionally on every mob death and logs "undefined procedure" if it's missing.
function onMobDeath(mob, player, isKiller)
end

