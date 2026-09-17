-----------------------------------
-- Assault: Evade and Escape
-----------------------------------
-- Built 2026-08-18 from data found sitting unwired in this repo's own SQL: 3 real Dahak,
-- comment-labeled "-- Evade and Escape" in sql/mob_spawn_points.sql. Modeled as kill-all-3,
-- "confirmed" by a real Thris Nov 2025 capture showing 3 Dahak kills immediately followed by
-- mission completion.
-- 2026-08-22: that "confirmed" read was incomplete. FFXIclopedia describes a real switch-hunting/
-- avoidance mechanic instead -- 3 switches (randomly placed among 7 possible small rooms), each
-- stays active 5 min once hit, all 3 active at once spawns Rune of Release; the Dahaks are
-- explicitly "not worth killing" and meant to be evaded, not farmed. User confirmed both are
-- real and independently valid: killing a Dahak and hitting a switch each satisfy one of the 3
-- needed -- not mutually exclusive.
-- 2026-08-29 REBUILT (user-confirmed wiki text): the real win condition needs all 3 SWITCHES
-- active AT THE SAME TIME (each stays active 5 real minutes once hit), not just 3 total hits
-- ever -- checked here every real second (this hook's own native rate) against each switch's
-- live `activeUntil` expiry timestamp (see npcs/Switch.lua) plus Dahak.lua's permanent
-- `dahakKills` credit, instead of the old flat instance:getProgress() threshold.
-- STILL OPEN, flagged rather than guessed: all 3 SWITCH1-3 npc_list rows are still at the
-- generic (0,0,0) placeholder -- genuinely no real captured position exists for any of them (the
-- 2026-08-22 header's "placed using a position-map image" claim was never actually applied to
-- SQL). The real mechanic also needs up to 7 candidate room positions to randomize 3 of them
-- into each run, matching "3 of 7 possible rooms" -- only 3 total SWITCH npc_list rows currently
-- exist at all, so right now all 3 always spawn in the same fixed (if any) spot rather than a
-- real random 3-of-7. Needs real LOGPOS coordinates for as many of the 7 candidate small rooms as
-- can be found, not fabricated.
-- 2026-09-02 RESOLVED: Dahak roam built from a user-supplied real LSB-format reference script
-- (see mobs/Dahak.lua's own header for the full backport writeup) -- 6 real endpoint positions,
-- bitwise-gated per Dahak (17035325=top group only, 17035326=bottom group only, 17035327=both).
-- The earlier "no ROAM_DISTANCE row so they can't move" concern turned out not to apply: confirmed
-- via mob_controller.cpp that onMobRoam() fires on its own fixed tick independent of the native
-- RoamAround()/GetRoamDistance() path, so this custom pathTo()-driven roam works without one.
-- 2026-09-02 (later): 2 real bugs fixed, user-reported live "no switches" -- (1) all 3 SWITCH
-- npc_list rows were still `(0,0,0)` (never actually applied despite being flagged above), (2)
-- `status=6` (CUTSCENE_ONLY) -- the exact same never-renders-client-side bug already found and
-- fixed for Periqia's Bridge Switch this session. Both fixed in npc_list.sql. Then user supplied
-- real `!logpos` coordinates for all 7 real candidate rooms (previously only 3 were ever
-- captured, since any single real playthrough only ever shows whichever 3 the game picked that
-- run) -- the real "3 randomly chosen of 7" mechanic is now built: CANDIDATE_ROOMS below holds all
-- 7 real positions, and onInstanceCreated repositions the 3 real Switch NPCs onto a random,
-- non-repeating subset of 3 each time the instance is created (same real-position-reuse pattern
-- already proven for Saving Private Ryaaf's 5-pattern room selection).
-- 2026-09-02 (later still): SWITCH_EXPIRING (real text, "The switch looks like it may cut out at
-- any moment...") wired in here at 60s remaining -- the capture confirms the line exists but not
-- its exact trigger threshold, so 60s of the real 300s window is an estimate, not a confirmed
-- retail timing. Fired once per active window (per-switch `expiryWarned` localvar, reset on
-- Switch.lua's onTrigger) to the whole party rather than just whoever's standing at that switch,
-- since this hook has no per-player proximity data.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_24_START, 24)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21/23 pattern above)
local MOB_GROUP_24 = { 17035325, 17035326, 17035327 } -- Dahak mobs

local SWITCH_IDS = { ID.npc.SWITCH1, ID.npc.SWITCH2, ID.npc.SWITCH3 }
local SWITCH_EXPIRY_WARNING_SECONDS = 60

-- Real, user-provided !logpos coordinates for all 7 candidate switch rooms (2026-09-02).
local CANDIDATE_ROOMS =
{
    { 264.6349, -29.8389,  133.8784 },
    { 461.8572, -49.7830,   66.7616 },
    {  92.7857, -39.7997,   23.0238 },
    { 106.2513, -39.8563,  -62.9841 },
    { 459.6055, -29.9729, -101.5024 },
    { 245.4687, -39.9758, -180.0733 },
    { 526.4518, -29.9128, -279.8645 },
}

-- Picks 3 distinct random indices out of CANDIDATE_ROOMS and repositions the 3 real Switch NPCs
-- onto them, one each -- real "3 of 7" mechanic, no fabricated positions.
local function placeSwitches(instance)
    local pool = {}
    for i = 1, #CANDIDATE_ROOMS do
        pool[i] = i
    end

    for _, switchId in ipairs(SWITCH_IDS) do
        local pick = math.random(#pool)
        local roomIndex = pool[pick]
        table.remove(pool, pick)

        local switch = instance:getEntity(bit.band(switchId, 0xFFF), TYPE_NPC)
        if switch then
            local room = CANDIDATE_ROOMS[roomIndex]
            switch:setPos(room[1], room[2], room[3], 0)
        end
    end
end

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_24) do
        SpawnMob(v, instance)
    end

    placeSwitches(instance)

    -- 2026-09-02, user-reported live: Rune of Release wasn't spawning at the right spot, reporting
    -- the shared npc_list default position ("I-8") instead of this mission's own real room. Real
    -- coordinates confirmed via this mission's own PathLog capture ("Lebros Cavern LC - Evade and
    -- Escape", Thris): Rune_of_Release at (301, -29.978, -62, dir 192), Ancient_Lockbox right next
    -- to it at (299, -30.01, -62, dir 192) -- same setPos-in-onInstanceCreated pattern already
    -- proven for Supplies Recovery's own mission-specific Rune/Lockbox position.
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(301, -29.978, -62, 192)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(299, -30.01, -62, 192)

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)

    if instance:completed() then
        return
    end

    local now = os.time()
    local activeCount = instance:getLocalVar("dahakKills") or 0
    for _, switchId in ipairs(SWITCH_IDS) do
        local switch = instance:getEntity(bit.band(switchId, 0xFFF), TYPE_NPC)
        local activeUntil = switch and switch:getLocalVar("activeUntil")
        if activeUntil and activeUntil > now then
            activeCount = activeCount + 1

            if activeUntil - now <= SWITCH_EXPIRY_WARNING_SECONDS and switch:getLocalVar("expiryWarned") == 0 then
                switch:setLocalVar("expiryWarned", 1)
                for _, p in pairs(instance:getChars()) do
                    p:messageText(switch, ID.text.SWITCH_EXPIRING)
                end
            end
        end
    end

    if activeCount >= 3 then
        instance:complete()
    end
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    -- Unused -- completion is driven by onInstanceTimeUpdate's real-time simultaneity check
    -- above, not instance:getProgress(). See header.
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    -- 2026-09-02, user-reported live: was showing the wrong grid ref. Real value is H-8, per this
    -- mission's own CapLog line ("Mission objective completed. Unlocking Rune of Release (H-8).").
    -- RUNE_UNLOCKED_POS's letter param is 0-indexed (H = 8th letter -> param 7, not 8) -- same
    -- convention already confirmed for this text id elsewhere (lebros_supplies.lua/
    -- stop_the_bloodshed.lua).
    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 7, 8)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

