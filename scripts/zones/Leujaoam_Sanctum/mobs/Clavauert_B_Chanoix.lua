-----------------------------------
-- Area: Leujaoam Sanctum (Escort Professor Chanoix)
--  Mob: Clavauert B Chanoix
-----------------------------------
-- Built from a real wiki walkthrough + a real Thris Nov2025 capture (win, 1210 Assault points).
--
-- Real mechanic: he cannot be controlled, wanders a maze of junctions "erratically" and "may
-- backtrack often" (per the wiki), and has TWO possible final destinations picked once at instance
-- start and fixed for that run (not re-rolled per junction).
--
-- Engine design:
--   - JUNCTIONS: real decision points (id, x,y,z, edges = neighbor ids directly walkable from
--     here). Movement between two adjacent junctions is one pathTo() call -- FindPath() does real
--     navmesh routing internally per call.
--   - No WALLHACK by default (flag 9 = RUN|SCRIPT only) -- WALLHACK-style movement caused a real
--     crash on Seagull Grounded (Periqia, mission 31). A small set of confirmed real navmesh gaps
--     get a narrow, per-leg WALLHACK exception instead (see WALLHACK_LEGS).
--   - State machine per instance (ADVANCING / PAUSED / BACKTRACKING): at each junction he can
--     pause (dwell + maybe speak), backtrack, or advance to a new neighbor. All state lives in a
--     module-level table keyed by instance:getID() (setLocalVar() is numeric-only).
--   - Dialogue fires on arrival at a junction (not a blind timer) -- see speakOnArrival() call
--     sites throughout tick().
-----------------------------------
require("scripts/globals/pathfind")
require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------
-- The engine's only passive mob-aggro scan (CZoneEntities::SpawnMOBs) is hard-typed to real
-- players -- it never runs for another mob, so the dungeon's undead would never autonomously
-- notice/attack a real CMobEntity like Chanoix regardless of allegiance. Driven explicitly here via
-- mob:updateEnmity() instead (see aggroNearbyThreats(), called from tick()).
-- DSP-PORT (2026-09-13, corrected): old-dsp-reference has no isAggroable/setIsAggroable binding of
-- any kind (confirmed absent from src/map/lua/lua_baseentity.cpp), so this manual workaround is
-- restored rather than removed -- it is the only way to make hostile mobs engage him on this target.
-----------------------------------
local THREAT_IDS =
{
    ID.mob[3].FROZEN_BONES1, ID.mob[3].FROZEN_BONES2, ID.mob[3].FROZEN_BONES3,
    ID.mob[3].FROZEN_BONES4, ID.mob[3].FROZEN_BONES5, ID.mob[3].FROZEN_BONES6,
    ID.mob[3].FROZEN_BONES7, ID.mob[3].FROZEN_BONES8, ID.mob[3].FROZEN_BONES9,
    ID.mob[3].GELID_BHOOT1, ID.mob[3].GELID_BHOOT2, ID.mob[3].GELID_BHOOT3,
    ID.mob[3].GELID_BHOOT4, ID.mob[3].GELID_BHOOT5, ID.mob[3].GELID_BHOOT6,
    ID.mob[3].GELID_BHOOT7,
}
local AGGRO_SCAN_RANGE = 15.0 -- not capture-confirmed -- a plausible sight/sound range

local function aggroNearbyThreats(mob, instance)
    for _, threatId in ipairs(THREAT_IDS) do
        local threat = threatId and instance:getEntity(bit.band(threatId, 0xFFF), TYPE_MOB)
        if threat and threat:isAlive() and not threat:isEngaged() and mob:checkDistance(threat) <= AGGRO_SCAN_RANGE then
            threat:updateEnmity(mob) -- real binding: threat aggros mob, unclaimed until it actually engages
        end
    end
end
-----------------------------------
-- Default: RUN|SCRIPT, deliberately WITHOUT WALLHACK -- see header for the crash this avoids.
local PATHFLAG_RUN_SCRIPT = 9
local PATHFLAG_RUN_WALLHACK_SCRIPT = 11 -- RUN|WALLHACK|SCRIPT

-- Scoped per-leg WALLHACK exceptions (both directions), each a real confirmed navmesh gap via
-- !checknav/live FindPath errors -- not a blanket re-enable. FindClosestPath() still tries real
-- navmesh routing first; wallhack only kicks in as a fallback if that genuinely fails, same safe
-- pattern as Excaliace.lua. Nested integer-keyed tables (not string-concat keys -- a float-valued
-- id formats differently and silently never matches).
-- IMPORTANT: each junction id must appear as a table key EXACTLY ONCE below -- a second `[n]={...}`
-- literal silently overwrites the first with no error. Merge into the existing entry instead.
local WALLHACK_LEGS = {
    [0] = { [1] = true }, -- spawn<->J1, ice-cave entrance
    [1] = { [0] = true, [4] = true },
    [4] = { [8] = true, [1] = true }, -- J4<->J8 doorway; J4<->J1 stuck point, confirmed no
    -- alternate doorway that direction (straight blocked corridor)
    [8] = { [4] = true },
    [3] = { [5] = true }, -- doorway near (-80.67,-5.52,-179.78)
    [5] = { [3] = true },
    [23] = { [13] = true }, -- open/clear spot, same short-local signature as the others
    [13] = { [23] = true },
    -- A J3<->J22 stuck point was almost wallhacked here too, but there's a real nearby doorway not
    -- on the direct line -- needs a real connector junction at the doorway (see J22), not a
    -- wallhack exception.
}

local function pathFlagsFor(fromId, toId)
    if fromId and WALLHACK_LEGS[fromId] and WALLHACK_LEGS[fromId][toId] then
        return PATHFLAG_RUN_WALLHACK_SCRIPT
    end
    return PATHFLAG_RUN_SCRIPT
end

local TICK_MS = 1000
local ARRIVE_RADIUS = 3.0 -- final destination arrival tolerance (tight, matches the real capture)
-- Ordinary junction arrival tolerance -- wider than ARRIVE_RADIUS since pathTo() doesn't settle as
-- precisely mid-route; too tight here caused a false "not there yet" stutter-retry on every leg.
local JUNCTION_ARRIVE_RADIUS = 10.0

-- Stall watchdog: FindClosestPath()'s wallhack fallback is a raw straight line with no further
-- routing, so a wallhack leg can drive him into a wall corner he physically wedges against --
-- isFollowingPath() then stays true forever and nothing else ever re-examines that leg. This
-- watches wall-clock time since a leg was issued, independent of isFollowingPath(), and escalates
-- to a direct short setPos hop after a couple of failed retries (safe -- a single known-good-
-- coordinate hop, not a long traversal).
local STALL_TIMEOUT_S = 20
local STALL_HARD_HOP_AFTER = 2

-----------------------------------
-- TUNING -- all timing/probability knobs for his junction behavior, grouped here. Real observed
-- values except where noted as a starting guess.
-----------------------------------
local JUNCTION_PAUSE_MS  = 10000 -- normal "deciding" pause at a junction
local LONG_PAUSE_MS      = 60000 -- rarer, longer pause -- plausibly deliberate room to heal/buff
local DWELL_PAUSE_DEFAULT_S = 12 -- fallback only, if a dwell node doesn't specify its own dwellSeconds

-- J20/J21 are real combat encounters, not simple pauses -- the final fights before the last
-- stretch. He's genuinely vulnerable (mission fails if he dies -- see onMobDeath) and roams during
-- the fight rather than standing still, per a real video (no capture path data exists for the
-- exact roam pattern -- approximate).
local COMBAT_DWELL_S = 60
local COMBAT_ROAM_RADIUS = 8.0   -- approximate, not capture-verified
local COMBAT_ROAM_STEP_MS = 15000
local SKIP_PAUSE_CHANCE  = 0.6   -- chance he skips the pause and runs straight through a junction
local LONG_PAUSE_CHANCE  = 0.12  -- of the pauses that DO happen, chance one is the long (60s) kind
local BACKTRACK_CHANCE   = 0.15  -- starting guess, not yet confirmed against real behavior
local ARRIVAL_LINE_GAP_MS = 4000 -- staggered dialogue between arrival lines
local FADE_DELAY_MS = 3000 -- pause after the last arrival line before he fades out

-- Safety valve against the random walk wandering forever. Real playthroughs average ~10 minutes;
-- the ramp starts well before the hard cutoff so bias builds up smoothly rather than a sudden
-- behavior change.
local GRADUAL_BIAS_RAMP_S = 240  -- forward-bias ramps linearly from 0 at spawn to MAX_FORWARD_BIAS
-- at this many seconds elapsed -- he gradually starts favoring real progress over pure randomness.
local MAX_FORWARD_BIAS = 12      -- weight bonus for the "closer to destination" neighbor once fully ramped
local FORCE_BEELINE_AFTER_S = 600 -- hard cutoff (10 min) -- skip all randomness, always take the
-- neighbor closest to the destination, guaranteeing completion.

-- Real, user-confirmed final destinations -- picked once per instance at spawn, fixed for the run.
-- 2026-09-14 REVERTED (live-reported, root cause found via git history): commit b492d69abb
-- (2026-08-30, "3 real rounds" of correction) had changed destination 1 to (17.5632,-3.5,-219.4710)
-- and forced destination 2 to share that same value, believing both real destinations converged on
-- one point near J13. Live-tested tonight and confirmed WRONG -- (17.5632,-3.5,-219.4710) is a
-- plain hallway junction (right next to J13) BETWEEN the two real end rooms, one to the northeast
-- and one to the southwest -- Chanoix was never supposed to stop there. Reverted destination 1 back
-- to the original pre-8/30 value (Thris/Tacocat/Siknawz captures' shared real ending, "~97,-4,-30"),
-- and destination 2 back to its own distinct value instead of mirroring destination 1. Neither of
-- these has a fresh, session-confirmed LOGPOS as of tonight -- treat as provisional (best known real
-- data) until re-verified live at the actual NE/SW end rooms.
local DESTINATIONS = {
    { x = 100.8230, y = -3.1525, z = -18.2932 },  -- capture-confirmed (pre-8/30 value, "Rune room, I-8")
    { x = -140.2350, y = -3.3098, z = -343.3171 }, -- reachable via J21 (leadsToDestination = 2)
}

-- Real decision points (!checknav-quality LOGPOS). `edges` inferred from shared x/z (grid-aligned
-- corridors -- junctions sharing an x form a north-south corridor, sharing a z form east-west).
-- Dead ends not fully mapped -- this graph is main-junctions-only, edges grow as more come in.
local JUNCTIONS = {
    [0]  = { x = -189.0000, y = -4.1630, z = -130.0000, edges = { 1 } }, -- spawn/entrance.
    -- The start room is one-way -- once past J1, spawn is never a valid destination again (no
    -- edge points back at it after the first leg).
    [1]  = { x = -139.7814, y = -3.5000, z = -142.0617, edges = { 2, 4 } }, -- entering the maze
    [2]  = { x = -98.9127,  y = -3.5000, z = -140.7664, edges = { 1, 3 } },
    [3]  = { x = -99.5290,  y = -3.5424, z = -180.1882, edges = { 2, 4, 5, 22 } }, -- 4-way
    [4]  = { x = -138.9678, y = -3.5000, z = -179.9897, edges = { 1, 3, 8, 15 } },
    [5]  = { x = -59.5701,  y = -3.5000, z = -181.3041, edges = { 3, 7, 11 } },
    [6]  = { x = -22.1865,  y = 0.5000,  z = -99.4314,  edges = { 7, 18 } }, -- elevated spur off J7
    [7]  = { x = -59.8754,  y = 0.5000,  z = -100.4051, edges = { 5, 6, 17 } },
    [8]  = { x = -141.4323, y = -3.5000, z = -219.6565, edges = { 4, 9, 11 } }, -- 3-way
    [9]  = { x = -178.1392, y = -3.5000, z = -219.5852, edges = { 8 } },
    [10] = { x = -100.7638, y = -3.5000, z = -258.1263, edges = { 22, 14, 16 } },
    [11] = { x = -58.8184,  y = -3.5000, z = -218.2750, edges = { 5, 8, 12, 21 } },
    -- Final junction through the main maze. The only way to reach destination 1 is through J20's
    -- leadsToDestination handoff after its fight (a direct edge to [100] here was removed -- it let
    -- ordinary movement skip J20's mandatory combat encounter entirely).
    [12] = { x = -19.4191,  y = -3.5000, z = -221.0690, edges = { 11, 23 } },
    [13] = { x = 19.0442,   y = -3.5000, z = -220.6158, edges = { 23, 20 } }, -- same z-row as J8/J9/J11/J12
    -- 2026-09-14 REVERTED to pre-8/30 value -- see DESTINATIONS comment above. (17.5632,-3.5,
    -- -219.4710) was J13's own neighboring hallway junction, not a real destination room.
    [100] = { x = 100.8230, y = -3.1525, z = -18.2932, edges = { 13 }, isDestination = 1 },
    -- Destination 2 has no terminal node of its own -- reached directly from J21 via its post-fight
    -- tunnel (leadsToDestination = 2), not through an intermediate node like [100].

    -- Dead ends: single-edge spurs off their nearest junction. No special handling needed --
    -- nextJunctionFrom() already always routes back the way he came from a single-edge node.
    [14] = { x = -195.4618, y = 3.1355,  z = -259.9342, edges = { 10 } },
    [15] = { x = -213.6438, y = 0.4720,  z = -180.0115, edges = { 4 } },
    [16] = { x = -133.8459, y = -3.5268, z = -260.2150, edges = { 10 } },
    [17] = { x = -60.0502,  y = 0.4528,  z = -66.6096,  edges = { 7 } },
    [18] = { x = -20.0798,  y = 0.4229,  z = -67.0367,  edges = { 6 } },
    [19] = { x = 19.7157,   y = -3.5459, z = -46.7108,  edges = { 20 } },

    -- Stop/dwell points -- unlike ordinary junctions (random pause chance), arriving here forces a
    -- pause (see tick()'s isDwellPoint check). dwellSeconds is a fixed event duration, not a random
    -- range. After the fight, a twisty one-way tunnel with no further junctions leads onward -- J20
    -- to destination 1, J21 to destination 2 (leadsToDestination, only taken if it matches the
    -- run's actual chosen destination).
    [20] = { x = 40.6589,   y = -3.5467, z = -75.3846,  edges = { 13, 19 }, isDwellPoint = true, isCombatDwell = true, dwellSeconds = COMBAT_DWELL_S, leadsToDestination = 1 },
    [21] = { x = -59.6459,  y = -3.0000, z = -318.2675, edges = { 11 }, isDwellPoint = true, isCombatDwell = true, dwellSeconds = COMBAT_DWELL_S, leadsToDestination = 2 },

    -- J3<->J10 was originally one long straight-line edge, but the real corridor bends partway --
    -- split into two short, actually-walkable hops via this real corner point instead.
    [22] = { x = -100.2503, y = -3.5605, z = -225.0034, edges = { 3, 10 } },

    -- Same long-straight-edge-cuts-a-corner fix as J22, for J12<->J13.
    [23] = { x = 7.0687,    y = -3.6084, z = -218.0717, edges = { 12, 13 } },
}

local SPAWN_JUNCTION = 0

local STATE_ADVANCING    = 1
local STATE_PAUSED       = 2
local STATE_BACKTRACKING = 3

-- Per-instance runtime state, keyed by instance:getID() -- can't live in setLocalVar (numeric
-- only). { destIndex, currentJunction, targetJunction, history = {visited junction ids, most
-- recent last}, state, pauseUntil }
-- MUST be a global: DSP re-executes this whole file on every mob hook call, so a plain
-- `local runtime = {}` is a brand-new empty table per load. The 20s start timer (loaded at spawn)
-- and ChanoixTick (the newest load) would then each see a DIFFERENT runtime table -- confirmed via
-- debug trace: startMoving set runtime[3].started but tick saw runtime[3] == nil.
CHANOIX_RUNTIME = CHANOIX_RUNTIME or {}
local runtime = CHANOIX_RUNTIME

-----------------------------------
-- DEBUG TRACING -- set CHANOIX_DEBUG = false to silence. Every line is prefixed [CHANOIX], so
-- grep the map-server console for it.
-----------------------------------
-- Debug output is DISABLED: the print() below is commented out. To debug again, uncomment it (and
-- the matching block in instances/escort_professor_chanoix.lua's onInstanceTimeUpdate) and set
-- CHANOIX_DEBUG = true.
CHANOIX_DEBUG = false
CHANOIX_DBG_GATE = CHANOIX_DBG_GATE or {}
local dbgLastGate = CHANOIX_DBG_GATE
local function dbg(fmt, ...)
    if CHANOIX_DEBUG then
        local ok, msg = pcall(string.format, fmt, ...)
        -- print("[CHANOIX] " .. (ok and msg or ("fmt-error: " .. tostring(fmt))))
    end
end

-- Logs a gate/early-return reason only when it CHANGES for that instance, so a tick that bails
-- every second doesn't spam, but you still see exactly which gate is blocking and when.
local function dbgGate(instId, reason)
    if dbgLastGate[instId] ~= reason then
        dbgLastGate[instId] = reason
        dbg("tick gate [inst %s]: %s", tostring(instId), reason)
    end
end

local function dbgPos(mob)
    return string.format("(%.1f,%.1f,%.1f)", mob:getXPos(), mob:getYPos(), mob:getZPos())
end

-- Every pathTo() in this file goes through here so the engine's return value (did FindPath accept
-- the leg?) and the flags used are always logged.
local function tracedPath(mob, x, y, z, flags)
    local ok = mob:pathTo(x, y, z, flags)
    dbg("pathTo target=(%.1f,%.1f,%.1f) flags=%s from=%s -> returned %s, isFollowingPath now=%s",
        x, y, z, tostring(flags), dbgPos(mob), tostring(ok), tostring(mob:isFollowingPath()))
    return ok
end

local function pickWeighted(options)
    -- options: { {value=..., weight=...}, ... }
    local total = 0
    for _, o in ipairs(options) do
        total = total + o.weight
    end
    local roll = math.random() * total
    for _, o in ipairs(options) do
        if roll < o.weight then
            return o.value
        end
        roll = roll - o.weight
    end
    return options[#options].value
end

-- Dedicated dialogue triggers -- every real "lost professor" line has a specific home, no generic
-- ambient pool. Arrival is silent -- no confirmed "found it" line exists.
local PAUSE_START_LINE     = ID.text.CHANOIX_LINE5  -- I'm quite out of breath... rest for a spell...
local PAUSE_END_LINE       = ID.text.CHANOIX_LINE6  -- Time to move, lazy bones. Plays when a pause ends.
local DEAD_END_ARRIVE_LINE = ID.text.CHANOIX_LINE9  -- Right, then. Shall we have a poke around? Plays on reaching a dead end.
local DEAD_END_LEAVE_LINE  = ID.text.CHANOIX_LINE10 -- Hmmm... I guess this isn't the place... Plays on leaving a dead end.

-- 2-line paired exchange -- usable at a dead-end arrival OR a pause-start, as an occasional
-- alternative to the single dedicated line above (adds variety, not both at once).
local EXCHANGE_CHANCE = 0.35
local EXCHANGE_LINE_GAP_MS = 3000
local EXCHANGE_LINES = {
    ID.text.CHANOIX_LINE7,  -- Does anyone happen to know the way from here?
    ID.text.CHANOIX_LINE14, -- I guess not... Well, come on then. Don't fall behind.
}

-- 3-line "wandering" moment -- a ONE-TIME event somewhere in the middle of the maze (not tied to
-- any specific junction type). Gated by elapsed time so it can't fire right at spawn, and by
-- st.wanderEventPlayed so it only ever fires once per run.
local WANDER_EVENT_CHANCE = 0.06 -- rolled per ordinary advance, until it fires once
local WANDER_EVENT_MIN_ELAPSED_S = 90
local WANDER_LINE_GAP_MS = 3500
local WANDER_LINES = {
    ID.text.CHANOIX_LINE8,  -- Hmmm... Maybe we should have taken a left back at the...
    ID.text.CHANOIX_LINE15, -- No, this is definitely the right way.
    ID.text.CHANOIX_LINE16, -- All right now, who was it? Who said this was the right way?
}

local LOST_LINES = {
    ID.text.CHANOIX_LINE1,  -- Oh dear... There was no such branching of passages on the map I was given...
    ID.text.CHANOIX_LINE2,  -- Atelloune was right. The map is barely fit for starting a fire...
    ID.text.CHANOIX_LINE3,  -- I seem to have taken a wrong turning somewhere...
    ID.text.CHANOIX_LINE4,  -- The map says it's this way, but...
    ID.text.CHANOIX_LINE12, -- Oh dear... (short)
    ID.text.CHANOIX_LINE13, -- I was certain I was on the right track...
}

local function speakLost(mob, reason)
    mob:messageText(mob, LOST_LINES[math.random(#LOST_LINES)])
end

-- 2026-09-14, live-reported (Chanoix stops responding entirely mid-maze): every mob:timer() below
-- used to capture `mob` from the outer scope and check mob:isAlive() as a "safety" guard -- but
-- that call itself requires mob to be a valid pointer, so it doesn't protect against genuine
-- use-after-free (same false confidence as the original Mulwahah crash). Now uses mob:timer()'s
-- own fresh callback argument instead (same proven mechanism as mob:timer(ms, tick) elsewhere in
-- this file), and bails cleanly if he's gone.
local function speakStaggered(mob, lines, gapMs)
    for i, lineId in ipairs(lines) do
        mob:timer((i - 1) * gapMs, function(mob)
            if mob then
                mob:messageText(mob, lineId)
            end
        end)
    end
end

local function speakExchange(mob, reason)
    speakStaggered(mob, EXCHANGE_LINES, EXCHANGE_LINE_GAP_MS)
end

local function speakWanderEvent(mob)
    speakStaggered(mob, WANDER_LINES, WANDER_LINE_GAP_MS)
end

local ARRIVAL_LINES = {
    ID.text.CHANOIX_ARRIVAL1, -- Hello!? Something huge...beneath the ice...
    ID.text.CHANOIX_ARRIVAL2, -- This is it! This is what I've been searching for!
    ID.text.CHANOIX_ARRIVAL3, -- And look at the state of preservation...
    ID.text.CHANOIX_ARRIVAL4, -- I must take a sample back to my laboratory at once.
}

-- Real sequence: reaching the destination plays this 4-line staggered dialogue chain, then he
-- fades out and disappears, THEN the Rune of Release unlocks (instance:complete() -- see
-- instances/escort_professor_chanoix.lua).
local function playArrivalSequence(mob, instance)
    for i, lineId in ipairs(ARRIVAL_LINES) do
        mob:timer((i - 1) * ARRIVAL_LINE_GAP_MS, function(mob)
            if mob then
                mob:messageText(mob, lineId)
            end
        end)
    end

    -- Fires the "kesu" client-side fade-out animation first, then setStatus(DISAPPEAR) after a
    -- short buffer so the clip has room to play out -- firing both in the same instant cuts the
    -- animation short (same real, user-tuned mechanic as _pot_hatch_common.lua's Brujeel reveal).
    local totalDialogueMs = (#ARRIVAL_LINES - 1) * ARRIVAL_LINE_GAP_MS
    local KESU_FADE_MS = 2000
    mob:timer(totalDialogueMs + FADE_DELAY_MS, function(mob)
        if mob then
            mob:entityAnimationPacket("kesu")
        end
    end)
    mob:timer(totalDialogueMs + FADE_DELAY_MS + KESU_FADE_MS, function(mob)
        if mob then
            mob:setStatus(STATUS_DISAPPEAR)
        end
        if instance then
            instance:complete()
        end
    end)
end

local function chooseDestination(mob, instance)
    local st = runtime[instance:getID()]
    local destIndex = math.random(1, #DESTINATIONS)
    -- Checks both isDestination (a real terminal node, like [100]) and leadsToDestination (a
    -- junction whose onward tunnel leads there, like J20/J21) so this fallback doesn't wrongly
    -- trigger for a destination that does have a real route.
    local reachable = false
    for _, j in pairs(JUNCTIONS) do
        if j.isDestination == destIndex or j.leadsToDestination == destIndex then
            reachable = true
            break
        end
    end
    if not reachable then
        destIndex = 1
    end
    st.destIndex = destIndex
    -- The instance script needs to know which destination was rolled so it can put the Rune of
    -- Release/Ancient Lockbox in the right spot on completion (a single static npc_list entity,
    -- not automatically tied to wherever he ends up) -- mirrored onto a real instance localVar so
    -- instances/escort_professor_chanoix.lua can read it back.
    instance:setLocalVar("chanoixDestIndex", destIndex)
end

local function dist2(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z
    return dx * dx + dz * dz
end

-- forwardBias: 0 = pure random walk (original behavior). >0 adds that much weight to whichever
-- neighbor is closer to `dest` than the current node -- see GRADUAL_BIAS_RAMP_S/MAX_FORWARD_BIAS.
local function nextJunctionFrom(current, cameFrom, forwardBias, dest)
    local node = JUNCTIONS[current]
    if not node or not node.edges or #node.edges == 0 then
        return nil
    end
    if #node.edges == 1 then
        return node.edges[1]
    end
    -- Never immediately double back the way we just came -- real backtracking still happens via
    -- the explicit BACKTRACK_CHANCE roll below, which skips back further than one hop.
    local currentDist = forwardBias > 0 and dist2(node, dest) or nil
    local options = {}
    for _, neighbor in ipairs(node.edges) do
        if neighbor ~= cameFrom then
            local weight = 4
            -- Dead-end (single-edge) neighbors never receive the forward-bias bonus -- entering
            -- one always costs a forced round trip, and a dead end can still look closer on a
            -- straight line than the real through-route, which caused endless oscillation into
            -- dead ends instead of ever trying the real path. They keep their normal base weight
            -- so they're still occasionally visited ("wanders erratically" per the wiki).
            -- isDwellPoint nodes (J20/J21) are real required waypoints, not dead ends, even though
            -- they're also single-edge -- excluded from this dead-end check or they'd become
            -- permanently unreachable once forward bias engages.
            local neighborNode = JUNCTIONS[neighbor]
            local neighborIsDeadEnd = neighborNode and neighborNode.edges and #neighborNode.edges == 1
                and not neighborNode.isDwellPoint
            if forwardBias > 0 and not neighborIsDeadEnd and dist2(neighborNode, dest) < currentDist then
                weight = weight + forwardBias
            end
            table.insert(options, { value = neighbor, weight = weight })
        end
    end
    if #options == 0 then
        -- Only real edge is the one we came from (shouldn't normally happen for a >1-edge node,
        -- defensive fallback) -- allow it rather than getting stuck.
        return cameFrom
    end
    return pickWeighted(options)
end

-- Hard-cutoff mode (FORCE_BEELINE_AFTER_S elapsed): no randomness at all, always the neighbor
-- that's actually closest to the destination. Excludes cameFrom and dead ends (same reasoning as
-- nextJunctionFrom() above -- without this a dead-end spur that looks closer in a straight line
-- than the real onward route could trap him in an infinite back-and-forth), falling back to
-- considering them only if every other neighbor is cameFrom.
local function beelineNext(current, cameFrom, dest)
    local node = JUNCTIONS[current]
    if not node or not node.edges or #node.edges == 0 then
        return nil
    end
    local best, bestDist = nil, math.huge
    for _, neighbor in ipairs(node.edges) do
        local neighborNode = JUNCTIONS[neighbor]
        local neighborIsDeadEnd = neighborNode and neighborNode.edges and #neighborNode.edges == 1
            and not neighborNode.isDwellPoint
        if neighbor ~= cameFrom and not neighborIsDeadEnd then
            local d = dist2(neighborNode, dest)
            if d < bestDist then
                best, bestDist = neighbor, d
            end
        end
    end
    if not best then
        for _, neighbor in ipairs(node.edges) do
            if neighbor ~= cameFrom then
                local d = dist2(JUNCTIONS[neighbor], dest)
                if d < bestDist then
                    best, bestDist = neighbor, d
                end
            end
        end
    end
    if not best then
        -- Only edge is the one we came from -- a real dead end, forced to return.
        return cameFrom
    end
    return best
end

-- Forward-declared so startMoving() (below) can reference it -- `local function NAME()` sugar
-- creates the local AFTER the function body runs, so a plain forward declaration is needed here to
-- avoid startMoving() silently capturing an unrelated global.
local tick

-- J20/J21 are real fights, and he roams during them rather than standing still (per a real video --
-- no capture path data exists for the exact pattern, this is an approximation). Self-reschedules
-- until the fight's pause window ends.
local function combatRoamStep(mob, instance, homeX, homeY, homeZ)
    if not instance or instance:completed() or not mob:isAlive() then
        return
    end
    local st = runtime[instance:getID()]
    if not st or st.state ~= STATE_PAUSED then
        return -- fight's over, stop roaming
    end
    local angle = math.random() * 2 * math.pi
    local rx = homeX + math.cos(angle) * COMBAT_ROAM_RADIUS
    local rz = homeZ + math.sin(angle) * COMBAT_ROAM_RADIUS
    tracedPath(mob, rx, homeY, rz, PATHFLAG_RUN_SCRIPT)
    mob:timer(COMBAT_ROAM_STEP_MS, function(mob)
        if mob then
            combatRoamStep(mob, instance, homeX, homeY, homeZ)
        end
    end)
end

-- Fixed-delay start (not a proximity poll -- that caused a real regression where he'd sometimes
-- never start at all). Reasonable estimate for "past the zone-in window", not capture-confirmed to
-- an exact value.
local START_DELAY_MS = 20000

local function startMoving(mob)
    dbg("startMoving: called")
    local instance = mob:getInstance()
    if not instance or instance:completed() then
        dbg("startMoving: ABORT instance=%s", tostring(instance))
        return
    end
    if not mob:isAlive() then
        dbg("startMoving: ABORT mob not alive")
        return
    end

    local st = runtime[instance:getID()]
    if not st then
        dbg("startMoving: runtime[%s] is NIL -- onMobSpawn state was cleared or never set", tostring(instance:getID()))
        return
    end
    st.startTime = os.time() -- clock starts when he actually begins, not at raw spawn
    chooseDestination(mob, instance)
    dbg("startMoving: OK inst=%s dest=%s pos=%s mobId=%s -- st.started=true, waiting for instance tick",
        tostring(instance:getID()), tostring(st.destIndex), dbgPos(mob), tostring(mob:getID()))
    st.started = true -- instance onInstanceTimeUpdate now calls ChanoixTick() every second
end

-- Incapacitating effects that stop the mob AI / freeze pathing. Stripped every tick as a
-- belt-and-braces backup to the "immuneToIncapacitate" localVar (which needs the C++ side).
local INCAPACITATE_EFFECTS =
{
    EFFECT_SLEEP_I, EFFECT_SLEEP_II, EFFECT_LULLABY, EFFECT_STUN, EFFECT_PETRIFICATION,
    EFFECT_TERROR, EFFECT_PENALTY, EFFECT_BIND, EFFECT_PARALYSIS, EFFECT_CHARM_I, EFFECT_CHARM_II,
}

tick = function(mob)
    local instance = mob:getInstance()
    if not instance then
        dbg("tick gate: mob:getInstance() is nil")
        return
    end
    local instId = instance:getID()
    if instance:completed() then
        dbgGate(instId, "instance completed")
        return
    end
    if not mob:isAlive() then
        dbgGate(instId, "mob not alive")
        return
    end

    local st = runtime[instId]
    if not st then
        dbgGate(instId, "runtime[inst] is nil (onMobSpawn never ran for this instance id, or cleared)")
        return
    end
    if not st.started then
        dbgGate(instId, "st.started is false -- the 20s START_DELAY timer has not fired startMoving yet (or never fired)")
        return
    end
    dbgGate(instId, "PASSED all entry gates")

    -- Per-tick heartbeat: everything needed to see why he isn't moving.
    dbg("tick: pos=%s state=%s curJ=%s dest=%s following=%s legIssuedAt=%s pausedHere=%s pauseUntil=%s hist=%d action=%s",
        dbgPos(mob), tostring(st.state), tostring(st.currentJunction), tostring(st.destIndex),
        tostring(mob:isFollowingPath()), tostring(st.legIssuedAt), tostring(st.pausedHere),
        tostring(st.pauseUntil), #st.history, tostring(mob:getCurrentAction()))

    for _, eff in ipairs(INCAPACITATE_EFFECTS) do
        if eff and mob:hasStatusEffect(eff) then
            dbg("tick: stripping incapacitating effect id %s", tostring(eff))
            mob:delStatusEffect(eff)
        end
    end

    aggroNearbyThreats(mob, instance)

    local dest = DESTINATIONS[st.destIndex]
    local elapsed = os.time() - (st.startTime or os.time())
    local beelining = elapsed >= FORCE_BEELINE_AFTER_S
    local forwardBias = beelining and 0 or (MAX_FORWARD_BIAS * math.min(1, elapsed / GRADUAL_BIAS_RAMP_S))

    local dx = mob:getXPos() - dest.x
    local dz = mob:getZPos() - dest.z
    if (dx * dx + dz * dz) <= (ARRIVE_RADIUS * ARRIVE_RADIUS) then
        if not st.arrivedSequenceStarted then
            st.arrivedSequenceStarted = true
            playArrivalSequence(mob, instance)
        end
        return
    end

    -- Stall watchdog -- runs BEFORE the isFollowingPath() branch below since a wedged mob has
    -- isFollowingPath() == true forever; this is the only code that can ever notice that case.
    -- Only meaningful mid-leg (currentJunction ~= -1, i.e. not the final direct-to-destination
    -- stretch, and legIssuedAt set).
    if st.state ~= STATE_PAUSED and st.legIssuedAt and st.currentJunction ~= -1
        and (os.time() - st.legIssuedAt) > STALL_TIMEOUT_S then
        local claimedNode = JUNCTIONS[st.currentJunction]
        if claimedNode then
            st.stallRetries = (st.stallRetries or 0) + 1
            dbg("STALL WATCHDOG fired: leg to J%s issued %ss ago, retry #%d", tostring(st.currentJunction),
                tostring(os.time() - st.legIssuedAt), st.stallRetries)
            if st.stallRetries > STALL_HARD_HOP_AFTER then
                -- Given up trying to path this leg -- place him directly at the junction.
                mob:setPos(claimedNode.x, claimedNode.y, claimedNode.z, 0)
                st.stallRetries = 0
                st.legIssuedAt = nil
            else
                tracedPath(mob, claimedNode.x, claimedNode.y, claimedNode.z, st.currentLegFlags or PATHFLAG_RUN_SCRIPT)
                st.legIssuedAt = os.time()
            end
        end
        -- (next tick driven by instance onInstanceTimeUpdate)
        return
    end

    if st.state == STATE_PAUSED then
        dbg("tick: PAUSED kind=%s remaining=%ss", tostring(st.pauseKind), tostring(st.pauseUntil - os.time()))
        if os.time() >= st.pauseUntil then
            dbg("tick: pause ENDED (kind=%s) -> ADVANCING", tostring(st.pauseKind))
            st.state = STATE_ADVANCING
            if st.pauseKind == "ordinary" then
                -- Plays specifically when an ordinary junction pause ENDS, not the dwell/combat
                -- kind (those have their own bespoke end-of-fight line, see isCombatDwell below).
                mob:messageText(mob, PAUSE_END_LINE)
            end
            st.pauseKind = nil
        end
        -- (next tick driven by instance onInstanceTimeUpdate)
        return
    end

    if not mob:isFollowingPath() then
        dbg("tick: not following a path -> decision branch at curJ=%s", tostring(st.currentJunction))
        -- st.currentJunction is set to the TARGET the moment a leg is ISSUED, not when it's
        -- actually confirmed complete. If a leg doesn't finish cleanly, isFollowingPath() can go
        -- false while he's still physically partway there -- verify real proximity before trusting
        -- "arrived", or everything below computes his next move from the wrong (claimed) position.
        if st.currentJunction ~= -1 and st.currentJunction ~= SPAWN_JUNCTION then
            local claimedNode = JUNCTIONS[st.currentJunction]
            if claimedNode then
                local ddx = mob:getXPos() - claimedNode.x
                local ddz = mob:getZPos() - claimedNode.z
                if (ddx * ddx + ddz * ddz) > (JUNCTION_ARRIVE_RADIUS * JUNCTION_ARRIVE_RADIUS) then
                    dbg("tick: leg to J%s not complete (dist=%.1f > %.1f) -> re-issuing same leg",
                        tostring(st.currentJunction), math.sqrt(ddx * ddx + ddz * ddz), JUNCTION_ARRIVE_RADIUS)
                    -- Not actually there yet -- retry the SAME leg from his real current position.
                    -- Reuses whatever flags that leg was originally issued with (st.currentLegFlags)
                    -- -- a wallhack leg that needs a retry must stay wallhack, or it fails outright
                    -- and loops forever on the wrong flag. Does NOT reset st.legIssuedAt here -- this
                    -- branch can re-fire every tick when strict FindPath() fails outright, and
                    -- resetting the clock on every retry would hide that from the stall watchdog
                    -- above (a leg failing immediately forever needs to escalate past this loop).
                    tracedPath(mob, claimedNode.x, claimedNode.y, claimedNode.z, st.currentLegFlags or PATHFLAG_RUN_SCRIPT)
                    -- (next tick driven by instance onInstanceTimeUpdate)
                    return
                end
            end
        end

        local node = JUNCTIONS[st.currentJunction]
        if node and node.isDestination == st.destIndex then
            -- Reached the last known junction toward the chosen destination; hand off to a direct
            -- pathTo() for the final stretch (still strict, no wallhack).
            tracedPath(mob, dest.x, dest.y, dest.z, PATHFLAG_RUN_SCRIPT)
            st.currentJunction = -1 -- sentinel: "heading to destination directly"
            st.legIssuedAt = nil -- stall watchdog only watches mid-leg (currentJunction ~= -1)
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        if st.currentJunction == -1 then
            -- Already issued the final pathTo() toward the destination; just wait for arrival
            -- (checked above).
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        -- Arrived at st.currentJunction (or just spawned). Decide what to do.
        local arrivedNode = JUNCTIONS[st.currentJunction]
        dbg("tick: ARRIVED/decide at J%s (node found=%s, edges=%s)", tostring(st.currentJunction),
            tostring(arrivedNode ~= nil), arrivedNode and arrivedNode.edges and table.concat(arrivedNode.edges, ",") or "none")

        -- 2026-09-14, user-reported: J17/J18 (the northern dead-end spur off J6/J7, e.g. LOGPOS
        -- confirmed at J18: -19.4427,0.4220,-67.6332) were almost never actually visited across
        -- real playthroughs -- reaching them needs a lucky weighted roll at J7 among 3 equal-weight
        -- options, so over a run he overwhelmingly ends up in the west-side dead ends instead.
        if st.currentJunction == 18 then
            st.visitedNorthSpur = true
        end

        -- A plain dead end (single edge, NOT a dwell/combat point like J20/J21) plays a dedicated
        -- line on ARRIVAL, once per visit. Spawn (J0) also has exactly 1 edge (leads to J1), which
        -- would otherwise misfire this as a dead end on his very first tick -- excluded explicitly.
        local isPlainDeadEnd = st.currentJunction ~= SPAWN_JUNCTION and arrivedNode and arrivedNode.edges
            and #arrivedNode.edges == 1 and not arrivedNode.isDwellPoint
        if isPlainDeadEnd and not st.deadEndAnnounced then
            st.deadEndAnnounced = true
            -- The 2-line exchange can also play here instead of the single dedicated line, as an
            -- occasional alternative.
            if math.random() < EXCHANGE_CHANCE then
                speakExchange(mob, "dead-end arrive @ J" .. tostring(st.currentJunction))
            else
                mob:messageText(mob, DEAD_END_ARRIVE_LINE)
            end
        end

        -- J20 leads onward to destination 1, J21 to destination 2, via a twisty one-way tunnel --
        -- but ONLY when that's the destination actually chosen for this run. If he ends up at the
        -- "wrong" one, fall through to normal graph movement instead (his other edge, back the way
        -- he came). st.pausedHere gates this on "we already did the fight here", so this only fires
        -- on the second arrival-tick at this node, after combat.
        if st.pausedHere and arrivedNode and arrivedNode.leadsToDestination == st.destIndex then
            tracedPath(mob, dest.x, dest.y, dest.z, PATHFLAG_RUN_SCRIPT)
            st.currentJunction = -1 -- sentinel: heading to destination directly, same as J13->100
            st.legIssuedAt = nil -- stall watchdog only watches mid-leg (currentJunction ~= -1)
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        -- Force at least one visit to the J6/J18 northern spur per run: the first time he arrives
        -- at the gate junction (J7) without having visited J18 yet, send him down that leg
        -- unconditionally instead of rolling normally, since the ordinary weighted roll made this
        -- branch rare enough to effectively never happen in practice. Runs before the beelining
        -- check further down so it isn't skipped by the hard cutoff, same as the mandatory J20/J21
        -- dwell points below -- just without the combat/dwell payload, it's a plain detour+return.
        if st.currentJunction == 7 and not st.visitedNorthSpur and st.history[#st.history] ~= 6 then
            local target = 6
            table.insert(st.history, st.currentJunction)
            local tj = JUNCTIONS[target]
            local legFlags = pathFlagsFor(st.currentJunction, target)
            tracedPath(mob, tj.x, tj.y, tj.z, legFlags)
            st.currentJunction = target
            st.currentLegFlags = legFlags
            st.legIssuedAt = os.time()
            st.stallRetries = 0
            st.pausedHere = false
            st.deadEndAnnounced = false
            st.state = STATE_ADVANCING
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        -- Dwell/fight handling must always run regardless of beelining -- J20/J21 are single-edge
        -- nodes, so beelineNext() would otherwise have no other option and just bounce straight
        -- back out, meaning destination 2 could never be reached once beelining engages. Only the
        -- ordinary random-junction-pause skip below is meant to be beelining-exempt.
        if arrivedNode and arrivedNode.isDwellPoint and not st.pausedHere then
            -- Dwell points are a FIXED event, not a random-range pause -- each node carries its own
            -- dwellSeconds. st.pausedHere gates this to once per visit, same as an ordinary pause.
            st.state = STATE_PAUSED
            st.pauseKind = "dwell"
            st.pausedHere = true
            local duration = arrivedNode.dwellSeconds or DWELL_PAUSE_DEFAULT_S
            st.pauseUntil = os.time() + duration
            if arrivedNode.isCombatDwell then
                -- Real fight (J20/J21): roam instead of standing still, and speak near the end of
                -- it rather than the start, matching "he roams, then plays dialogue and leaves"
                -- from the real video. Mission fails if he dies here (see onMobDeath) -- the undead
                -- are already spawned zone-wide by the instance script, nothing extra to trigger.
                combatRoamStep(mob, instance, mob:getXPos(), mob:getYPos(), mob:getZPos())
                mob:timer(math.max(0, duration - 5) * 1000, function(mob)
                    if mob then
                        speakExchange(mob, "combat dwell end @ J" .. tostring(st.currentJunction))
                    end
                end)
            else
                speakExchange(mob, "dwell @ J" .. tostring(st.currentJunction))
            end
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        -- Normally pauses ~10s at a junction to "decide" (real observed timing), but not always --
        -- he sometimes runs straight through with no pause at all. A smaller fraction of pauses run
        -- ~60s instead, plausibly room for the party to heal/buff. st.pausedHere gates this to once
        -- per visit. None of this applies once beelining -- past FORCE_BEELINE_AFTER_S he stops
        -- pausing/second-guessing entirely.
        if not beelining and not st.pausedHere and math.random() >= SKIP_PAUSE_CHANCE then
            local isLongPause = math.random() < LONG_PAUSE_CHANCE
            st.state = STATE_PAUSED
            st.pauseKind = "ordinary"
            st.pauseUntil = os.time() + ((isLongPause and LONG_PAUSE_MS or JUNCTION_PAUSE_MS) / 1000)
            st.pausedHere = true
            -- PAUSE_START_LINE plays at the start of an ordinary pause; PAUSE_END_LINE plays when
            -- it ends (see the STATE_PAUSED-expiry block above). The 2-line exchange can also play
            -- here instead, as an occasional alternative.
            if math.random() < EXCHANGE_CHANCE then
                speakExchange(mob, "ordinary pause start @ J" .. tostring(st.currentJunction))
            else
                mob:messageText(mob, PAUSE_START_LINE)
            end
            -- (next tick driven by instance onInstanceTimeUpdate)
            return
        end

        local target
        local backtracking = false
        if beelining then
            -- Hard cutoff engaged: ignore backtrack/random entirely, always the neighbor closest
            -- to the destination. Still uses real navmesh routing per leg, just no more wandering.
            target = beelineNext(st.currentJunction, st.history[#st.history], dest)
            st.state = STATE_ADVANCING
            if target then
                table.insert(st.history, st.currentJunction)
            end
        elseif math.random() < BACKTRACK_CHANCE and #st.history > 1 and st.history[#st.history - 1] ~= SPAWN_JUNCTION then
            -- Backtrack further than one hop -- the immediately-previous junction is already
            -- excluded as "never double back" in nextJunctionFrom above, so a real backtrack here
            -- skips past it to the one before that instead.
            target = st.history[#st.history - 1]
            table.remove(st.history)
            table.remove(st.history)
            st.state = STATE_BACKTRACKING
            backtracking = true
        else
            local cameFrom = st.history[#st.history]
            target = nextJunctionFrom(st.currentJunction, cameFrom, forwardBias, dest)
            st.state = STATE_ADVANCING
            if target then
                table.insert(st.history, st.currentJunction)
                -- A dead end (single edge) or an unlucky weighted roll can send him right back the
                -- way he came even through this "normal advance" branch -- still a real double-back,
                -- gets the lost-themed line too, not just the explicit backtrack-roll path above.
                if target == cameFrom then
                    backtracking = true
                end
            end
        end

        dbg("tick: decision -> target=%s backtracking=%s beelining=%s forwardBias=%.1f elapsed=%ss",
            tostring(target), tostring(backtracking), tostring(beelining), forwardBias, tostring(elapsed))
        if target then
            if isPlainDeadEnd then
                -- Dedicated line for LEAVING a dead end, distinct from the generic lost-pool
                -- backtrack line used everywhere else.
                mob:messageText(mob, DEAD_END_LEAVE_LINE)
            elseif backtracking then
                speakLost(mob, string.format("backtrack J%s -> J%s", tostring(st.currentJunction), tostring(target)))
            elseif not st.wanderEventPlayed and elapsed >= WANDER_EVENT_MIN_ELAPSED_S
                and math.random() < WANDER_EVENT_CHANCE then
                -- One-time 3-line "wandering" moment, not tied to any specific junction type --
                -- just needs to land somewhere mid-maze, not at spawn.
                st.wanderEventPlayed = true
                speakWanderEvent(mob)
            end
            -- else: an ordinary forward advance with nothing special going on is silent -- every
            -- real line has a dedicated home, there's no leftover ambient pool to fall back on.
            local tj = JUNCTIONS[target]
            local legFlags = pathFlagsFor(st.currentJunction, target)
            tracedPath(mob, tj.x, tj.y, tj.z, legFlags)
            st.currentJunction = target
            -- Remembered so a retry (above) reuses the SAME flags, not a hardcoded default -- a
            -- wallhack leg that needs another attempt must stay wallhack.
            st.currentLegFlags = legFlags
            st.legIssuedAt = os.time() -- stall watchdog: freshly-issued leg, start the clock over
            st.stallRetries = 0
            st.pausedHere = false -- fresh arrival, can pause again next time
            st.deadEndAnnounced = false
        end
        if not target then
            dbg("tick: NO TARGET chosen at J%s -- standing still", tostring(st.currentJunction))
        end
        -- else: no target chosen this tick -- he'll stand still until the next tick re-evaluates.
        -- If this happens repeatedly at the same junction, that junction's edges/nextJunctionFrom
        -- logic is the real bug to check.
    end

    -- (next tick driven by instance onInstanceTimeUpdate)
end

-- Driven from instances/escort_professor_chanoix.lua's onInstanceTimeUpdate (1s, independent of
-- the mob's own AI tick, so Sleep/Stun can't stall it). Global so the instance script can call it
-- while the `runtime` table stays in this chunk.
CHANOIX_TICK_COUNT = CHANOIX_TICK_COUNT or 0
function ChanoixTick(mob)
    CHANOIX_TICK_COUNT = CHANOIX_TICK_COUNT + 1
    if CHANOIX_TICK_COUNT == 1 or CHANOIX_TICK_COUNT % 30 == 0 then
        dbg("ChanoixTick invoked from instance (call #%d)", CHANOIX_TICK_COUNT)
    end
    local ok, err = pcall(tick, mob)
    if not ok then
        dbg("!!! tick() THREW A LUA ERROR: %s", tostring(err))
    end
end

function onMobSpawn(mob)
    dbg("onMobSpawn: fired for mobId=%s pos=%s", tostring(mob:getID()), dbgPos(mob))
    mob:SetAutoAttackEnabled(false)
    -- He wanders the whole maze by design and can end up far from his own spawn point, so he's
    -- exempt from the engine's default leash-despawn (a real live regression was a leash despawn
    -- near a junction with nearby monsters, not a death -- deaths correctly instance:fail()
    -- instead, see onMobDeath).
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    -- Opts him out of the movement-freezing CInactiveState a hostile mob's Stun (and the same
    -- incapacitating-effect family -- Sleep/Petrify/Terror/Lullaby/Penalty) would otherwise push --
    -- see status_effect_container.cpp's SetEffectParams(). Same convention as the
    -- "playerCannotAttack" mechanism in battleentity.cpp's ValidTarget() (see below).
    mob:setLocalVar("immuneToIncapacitate", 1)
    -- He's a real CMobEntity, so by default players could attack/kill him by accident (mission-
    -- ending). ALLEGIANCE_TYPE.PLAYER makes the engine treat him as a friendly TARGET_PLAYER entity
    -- for any player sharing that allegiance, blocking the standard hostile-mob Attack action.
    mob:setAllegiance(1)
    local instance = mob:getInstance()
    if not instance then
        dbg("onMobSpawn: mob:getInstance() is NIL -- runtime never created, AI can never start")
        return
    end
    dbg("onMobSpawn: creating runtime[%s], scheduling startMoving in %dms", tostring(instance:getID()), START_DELAY_MS)
    runtime[instance:getID()] = {
        destIndex = 1,
        currentJunction = SPAWN_JUNCTION,
        history = {},
        state = STATE_ADVANCING,
        pauseUntil = 0,
        startTime = os.time(),
        visitedNorthSpur = false,
    }
    -- 2026-09-14, live-reported (Chanoix never starts pathing): mob was captured by this closure
    -- and reused 20s later with no liveness check -- same bug class as the Mining_Point/Mulwahah
    -- crashes. Use mob:timer()'s own fresh callback argument instead of the stale outer-scope
    -- capture, and bail cleanly if he's gone.
    mob:timer(START_DELAY_MS, function(mob)
        dbg("START_DELAY timer fired (mob arg present=%s)", tostring(mob ~= nil))
        if mob then
            local ok, err = pcall(startMoving, mob)
            if not ok then
                dbg("!!! startMoving THREW A LUA ERROR: %s", tostring(err))
            end
        end
    end)
end

function onMobDeath(mob, player, isKiller)
    dbg("onMobDeath: fired -- instance will FAIL")
    local instance = mob:getInstance()
    if instance and not instance:completed() then
        instance:fail()
    end
    if instance then
        runtime[instance:getID()] = nil
    end
end

function onMobDespawn(mob)
    dbg("onMobDespawn: fired -- runtime cleared")
    local instance = mob:getInstance()
    if instance then
        runtime[instance:getID()] = nil
    end
end

