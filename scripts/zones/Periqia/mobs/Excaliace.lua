-----------------------------------
-- Area: Periqia
--  NPC: Excaliace
-----------------------------------
-- Escort mechanic (confirmed via a real capture's CapLog + client dialog table, see IDs.lua's
-- EXCALIACE_* block):
--   Excaliace cannot be controlled; he starts moving at 50% speed once a player comes within 10'.
--   His route has ~30 invisible checkpoints. At each one: if no player is within 10', he tries to
--   escape (75% speed, back toward the entrance, "Now's my chance!") -- reaching the entrance
--   fails the mission. Being within 5' of him at a checkpoint stops him ("Someone's been eating
--   too much garlic...") until you back off past 5'. Catching an escaping Excaliace (within 10'
--   at his next checkpoint) stops the escape ("Damn...").
--   NOT YET IMPLEMENTED: the paired-room investigation (first half) and aggro-triggered fleeing
--   (second half) -- both need real room/path position data this repo doesn't have. See the TODO
--   block near the bottom for the full real mechanic writeup.
--
-- Route data: FULL_PATH below is built from a real capture's PathLog (Excaliace/17006593.csv),
-- cleaned up in several passes (spacing filter, pruning real in-capture backtracking, then
-- !checknav-verified point by point) into an authoritative walkable route. Checkpoint positions
-- (CHECKPOINTS) are a fixed-spacing sampling of that route, snapped to 9 REAL checkpoints found by
-- correlating garlic-message timestamps against the capture's position history (REAL_CHECKPOINTS)
-- -- the rest are still approximate, not individually confirmed.
-----------------------------------
require("scripts/globals/pathfind")
local ID = Periqia

-- DSP's checkDistance() only accepts an entity (Topaz also accepts {x,y,z}); a table crashes the
-- server in Lunar::check. Accept either here.
local function distTo(npc, t)
    if type(t) == "table" and t.x then
        local dx, dy, dz = npc:getXPos() - t.x, npc:getYPos() - t.y, npc:getZPos() - t.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    return npc:checkDistance(t)
end
-----------------------------------
local START_POS = { -322, -16.5, 380 }

-- Real captured route (!checknav-verified), used both for normal patrol and as the basis for
-- flee retraces. Crab-room/branch detours are NOT baked in here -- handled at runtime via
-- BRANCH_POINTS + STATE_BRANCHING instead.
local FULL_PATH = {
    -322.000000, -16.499000, 380.000000,
    -312.504000, -16.191000, 380.337000,
    -305.193000, -16.281000, 372.289000,
    -299.329000, -16.259000, 358.581000,
    -298.445000, -16.132000, 343.298000,
    -308.826000, -16.273000, 340.942000,
    -323.885000, -16.174000, 340.264000,
    -332.988000, -16.263000, 345.247000,
    -339.240200, -15.703600, 348.873100,
    -343.908700, -14.920300, 341.371900,
    -339.580000, -16.352000, 328.622000,
    -339.000000, -16.140000, 313.294000,
    -340.513000, -15.763000, 300.072000,
    -344.975000, -16.273000, 300.931000,
    -338.642000, -16.062000, 279.923000,
    -337.826000, -16.270000, 265.960000,
    -345.365000, -16.192000, 260.855000,
    -339.026000, -16.159000, 249.500000,
    -338.701000, -16.135000, 234.993000,
    -338.680000, -16.361000, 222.708000,
    -338.035000, -16.360000, 221.059000,
    -339.034000, -16.177000, 207.290000,
    -341.768000, -16.182000, 194.631000,
    -347.355000, -16.239000, 185.865000,
    -360.184000, -16.137000, 180.378000,
    -374.878000, -16.187000, 178.631000,
    -378.608000, -16.140000, 167.342000,
    -379.151000, -16.212000, 154.558000,
    -386.583000, -16.107000, 142.770000,
    -382.335000, -15.998000, 130.447000,
    -378.988000, -16.038000, 119.358000,
    -376.994000, -16.405000, 107.263000,
    -380.394000, -15.627000, 99.311000,
    -378.627000, -16.094000, 88.508000,
    -379.104000, -16.208000, 77.460000,
    -375.880000, -15.752000, 63.263000,
    -377.972000, -15.988000, 52.768000,
    -385.936000, -16.043000, 55.625000,
    -398.721000, -16.037000, 59.878000,
    -422.173000, -15.547000, 60.631000,
    -419.253000, -16.186000, 45.186000,
    -419.305000, -16.161000, 33.861000,
    -413.000200, -15.768000, 26.080900,
    -394.482100, -15.836000, 19.896400,
    -408.808500, -15.818600, 17.199900,
    -419.447900, -15.610500, 5.641500,
    -419.291000, -16.120000, -0.014000,
    -416.462000, -16.218000, -14.108000,
    -419.839000, -16.061000, -27.166000,
    -431.634000, -16.189000, -21.802000,
    -443.597000, -16.187000, -20.400000,
    -449.014000, -16.004700, -14.120100,
    -465.345200, -9.711300, -27.616800,
    -458.487000, -8.393000, -38.497000,
    -457.724000, -9.612000, -51.576000,
    -462.835000, -10.114000, -62.034000,
    -474.215000, -10.137000, -63.246000,
    -478.890000, -10.118000, -66.853000,
    -474.719400, -9.458400, -79.019900,
    -472.672300, -9.693800, -88.233100,
}

-----------------------------------
-- Movement is navmesh-aware: every leg below is walked ONE point at a time via pathTo() (which
-- calls FindPath()/FindClosestPath() through the real navmesh), advancing once isFollowingPath()
-- goes false, rather than handing a whole array to pathThrough() (which never calls FindPath() at
-- all -- just straight lines between points, which wallhacks on anything but dense/verified data).
-- PATHFLAG_RUN_SCRIPT keeps WALLHACK as a fallback: FindClosestPath() still tries real FindPath()
-- routing first, but always appends the raw target as a guaranteed tail instead of failing outright
-- on the route's occasional real navmesh gaps. SCRIPT prevents other AI logic from overwriting the
-- path mid-leg.
-----------------------------------
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
local PATHFLAG_RUN_SCRIPT = 11 -- PATHFLAG_RUN (1) | PATHFLAG_WALLHACK (2) | PATHFLAG_SCRIPT (8, not exposed in tpz.path.flag)
local PATHFLAG_RUN_SCRIPT_NO_WALLHACK = 9 -- RUN (1) | SCRIPT (8), no WALLHACK -- pure FindPath(), no straight-line fallback

-- As a real CMobEntity he has native roam behavior (MOBMOD_ROAM_DISTANCE/ROAM_COOL/etc.) that
-- kicks in whenever nothing is actively pathing him -- i.e. every deliberate pause. MOBMOD_NO_MOVE
-- suppresses it; toggled on/off at every stationary/moving state transition below.
local function setStationary(npc, stationary)
    npc:setMobMod(MOBMOD_NO_MOVE, stationary and 1 or 0)
end

-- Diagnostic switches, left in place (both false) in case navmesh/flee issues resurface and need
-- isolating again: TEMP_DEBUG_SIMPLE_NAVMESH_FLEE bypasses the whole flee-route system for one
-- plain wallhack-free pathTo() to START_POS (tests raw navmesh connectivity); TEMP_DEBUG_DISABLE_FLEE
-- disables every flee trigger so ordinary forward patrol can be tested in isolation.
local TEMP_DEBUG_SIMPLE_NAVMESH_FLEE = false
local TEMP_DEBUG_DISABLE_FLEE = false

-- Always resumes from his ACTUAL nearest FULL_PATH point (not a fixed chunk boundary) so returning
-- from a branch/fork detour doesn't send him in a straight line back to some earlier fixed index.
local function startFromPathPoint(npc, startIndex)
    local total = #FULL_PATH / 3
    if startIndex > total then
        startIndex = total
    end
    local base = (startIndex - 1) * 3 + 1
    npc:setLocalVar("routeIndex", startIndex + 1)
    npc:pathTo(FULL_PATH[base], FULL_PATH[base + 1], FULL_PATH[base + 2], PATHFLAG_RUN_SCRIPT)
end

-- B4's east side diverges onto this separate route instead of a there-and-back detour like B1-3 --
-- real !logpos coordinates. Once the last point is reached, normal patrol resumes from his actual
-- current position (nearestPathIndex()), same "resume from nearest real point" pattern used
-- everywhere else in this file. Mob-aggro flee applies here same as the main route.
local EAST_FORK_PATH = {
    -290.0088, -15.6571, 144.0965,
    -350.5642, -15.2787, 145.4693,
    -294.5370, -15.2559,  96.0331,
    -372.0467, -16.0728,  97.1072,
}

-----------------------------------
-- Checkpoint approximation -- samples FULL_PATH at a fixed spacing, then snaps to the 9 real
-- confirmed positions below.
-----------------------------------
local CHECKPOINT_SPACING = 18.0 -- yalms; ~30 checkpoints over retail's full route length

local function buildCheckpoints(flatPath, spacing)
    local checkpoints = {}
    local lastX, lastY, lastZ
    local distSinceLast = 0

    for i = 1, #flatPath, 3 do
        local x, y, z = flatPath[i], flatPath[i + 1], flatPath[i + 2]
        if lastX then
            local dx, dy, dz = x - lastX, y - lastY, z - lastZ
            distSinceLast = distSinceLast + math.sqrt(dx * dx + dy * dy + dz * dz)
        end
        if not lastX or distSinceLast >= spacing then
            table.insert(checkpoints, { x = x, y = y, z = z })
            distSinceLast = 0
        end
        lastX, lastY, lastZ = x, y, z
    end

    -- Always include the final point as a checkpoint even if it falls short of a full spacing
    -- interval, so the last stretch still gets checked.
    local last = { x = flatPath[#flatPath - 2], y = flatPath[#flatPath - 1], z = flatPath[#flatPath] }
    local final = checkpoints[#checkpoints]
    if not final or final.x ~= last.x or final.z ~= last.z then
        table.insert(checkpoints, last)
    end

    return checkpoints
end

-- 9 REAL checkpoint positions, found by correlating "Someone's been eating too much garlic..."
-- CapLog timestamps against Excaliace's own per-tick position history in the same capture. Listed
-- in real route order. Only 9 of the real "about 30" are known; the rest of CHECKPOINTS still comes
-- from fixed-spacing sampling above.
local REAL_CHECKPOINTS =
{
    { x = -340.071, y = -16.391, z = 333.029 },
    { x = -344.975, y = -16.273, z = 300.931 },
    { x = -362.198, y = -16.179, z = 260.716 },
    { x = -338.680, y = -16.113, z = 240.563 },
    { x = -379.382, y = -16.149, z = 161.380 },
    { x = -419.393, y = -16.240, z =  47.218 },
    { x = -419.115, y = -16.151, z =  43.030 },
    { x = -443.373, y = -16.170, z = -20.014 },
    { x = -485.000, y =  -9.811, z = -75.000 },
}

-- Real mission-failure target (not a checkpoint) -- if a fleeing Excaliace actually reaches this
-- position (north of START_POS), the mission fails outright. He only turns back toward the real
-- win condition (D3, ID.mob[31].DEBAUCHER3 -- the Debaucher itself, not the Rune of Release NPC)
-- once caught first.
local FLEE_FAIL_POS = { x = -235.7802, y = -15.8877, z = 419.9426 }

-- Real win-condition position (!logpos-confirmed) -- a PROXIMITY TRIGGER near the Debaucher in the
-- center of the cave. Approaching it starts flee-until-killed behavior; it is NOT where the Rune of
-- Release/Ancient Lockbox actually spawn (those sit against the cave wall, see
-- seagull_grounded.lua's onInstanceCreated -- do not sync these two positions).
local WIN_CONDITION_POS = { x = -475.4015, y = -9.6938, z = -88.0954 }
local WIN_ARRIVE_RADIUS = 8.0 -- yalms; wider than CHECKPOINT_ARRIVE_RADIUS, this only needs to fire once

-- Snaps the nearest approximate checkpoint to each real one (within SNAP_RADIUS) instead of
-- inserting a duplicate nearby point -- upgrades fidelity in place without disturbing route order.
local SNAP_RADIUS = 15.0

local function snapToRealCheckpoints(checkpoints, realCheckpoints, radius)
    for _, real in ipairs(realCheckpoints) do
        local nearestIndex, nearestDist
        for i, cp in ipairs(checkpoints) do
            local dx, dz = cp.x - real.x, cp.z - real.z
            local dist = math.sqrt(dx * dx + dz * dz)
            if not nearestDist or dist < nearestDist then
                nearestIndex, nearestDist = i, dist
            end
        end

        if nearestIndex and nearestDist <= radius then
            checkpoints[nearestIndex] = real
        else
            table.insert(checkpoints, real)
        end
    end

    return checkpoints
end

local CHECKPOINTS = snapToRealCheckpoints(buildCheckpoints(FULL_PATH, CHECKPOINT_SPACING), REAL_CHECKPOINTS, SNAP_RADIUS)

-----------------------------------
-- Speed tiers (real, from the mechanic writeup) -- base speed matches this zone's other walking
-- NPCs (40 = normal human walk), scaled by the stated percentages.
-----------------------------------
-- DSP-PORT: GetSpeedMod() has no DSP equivalent anywhere in src/map (confirmed absent from both
-- lua_base_entity.cpp and luautils.cpp) -- genuine engine gap, not a naming mismatch. Per project
-- decision (2026-09-13 addendum), hardcoded to this DSP checkout's real configured base speed:
-- 40 (original walking base) + 50 (xi.settings.map.BASE_SPEED, landsandboat-reference/settings/
-- default/map.lua:110). Retune if the target server's own map.lua differs.
local BASE_SPEED = 40 + 50
-- Tuned down from the walkthrough's literal 0.75 -- this server's speed_mod inflates BASE_SPEED
-- enough that 0.75 felt too fast live. Retune this one multiplier if speed_mod changes.
local ESCORT_SPEED_RATIO = 0.55
-- Deliberately distinct from ESCORT_SPEED_RATIO -- this tier is SUPPOSED to be faster than normal
-- escort pace ("runs at faster than normal movement speed" per the real walkthrough).
local ESCAPE_SPEED_RATIO = 0.75
local SPEED_NORMAL = math.floor(BASE_SPEED * ESCORT_SPEED_RATIO) -- while being escorted normally
local SPEED_ESCAPE = math.floor(BASE_SPEED * ESCAPE_SPEED_RATIO) -- while attempting to escape
local SPEED_FLEE   = BASE_SPEED                                  -- 100% while fleeing an aggro'd mob

local CHECKPOINT_ARRIVE_RADIUS = 6.0 -- yalms; how close counts as "reached this checkpoint"
local GARLIC_RANGE = 5.0
local ESCORT_RANGE = 10.0 -- too-far-behind escape trigger; matches the real walkthrough's "more than 10' away"
-- Recapture range during any flee/tired/to-fail phase -- kept separate from ESCORT_RANGE (which is
-- tied to the walkthrough's own "more than 10' for about 10 seconds" trigger and shouldn't move).
local CATCH_RANGE = 5.0
local TICK_MS = 300

-- Catching him requires CATCH_RANGE proximity sustained for several consecutive ticks, not a
-- single-tick pass-by -- otherwise his own retrace walking back through a spot the player merely
-- happened to be standing on would register as a "catch."
local CATCH_SUSTAIN_MS = 1000
local CATCH_SUSTAIN_TICKS = math.ceil(CATCH_SUSTAIN_MS / TICK_MS)

-- Too-far-behind requires ESCORT_RANGE to be sustained for TOO_FAR_GRACE_MS before he actually
-- flees, matching the real walkthrough ("more than 10' away for about 10 seconds") and avoiding a
-- flee/catch bounce loop from a player briefly lagging right at the boundary.
local TOO_FAR_GRACE_MS = 10000
local TOO_FAR_GRACE_TICKS = math.ceil(TOO_FAR_GRACE_MS / TICK_MS)

-- Escape fatigue: flees at 100% until he's traveled ~2 map squares, then gets tired and pauses
-- before resuming at 75% -- balances "can't just outrun him if you're far" against "you get a
-- window to catch up after his pause."
local ESCAPE_FATIGUE_DISTANCE = 50.0 -- yalms to travel before getting tired
local ESCAPE_TIRED_WAIT_TICKS = math.ceil(40000 / TICK_MS) -- ~40 seconds

-- Minimum time after any flee trigger before the "player caught up" check can fire -- gives him a
-- real head start instead of instantly re-catching a player who was already close when it triggered.
local CATCH_GRACE_MS = 3000
local CATCH_GRACE_TICKS = math.ceil(CATCH_GRACE_MS / TICK_MS)

-----------------------------------
-- Per-instance flee-retrace state (this module is loaded once and shared by every concurrent
-- instance of the mission, so all of the tables below are keyed by instance ID).
-----------------------------------
-- FULL_PATH index he was nearest to at the moment he entered the east fork -- lets a
-- fork-triggered flee's retrace splice EAST_FORK_PATH's walked portion back onto the correct point
-- of the main corridor (see buildForkLeg()).
local forkEntryPathIndex = {}

-- Same idea, for a flee triggered mid-branch-detour (STATE_BRANCHING) -- detour points aren't in
-- FULL_PATH at all, so nearestPathIndex() run from off-corridor would find the wrong (often far)
-- checkpoint. Recorded while he's still ON FULL_PATH, right before detouring (see buildBranchLeg()).
local branchEntryPathIndex = {}

-- The built flee route (buildFleePath()'s output) for each instance's current escape, walked one
-- point at a time via pathTo() -- see startEscape()/STATE_ESCAPING. setLocalVar() is uint32-only,
-- so the route itself can't live in a localvar, only the walk-cursor index does.
local escapeRoutes = {}

-- Escape-fatigue tracking position. Kept in a real Lua table, NOT setLocalVar() -- this zone's
-- entire map sits at negative X, and setLocalVar()'s uint32 param truncates a negative float into
-- a huge garbage value, which previously caused instant false fatigue on every flee.
local escapeStartPositions = {}

-- Real per-instance target point for a branch-point side detour (STATE_BRANCHING, branchStep 2).
local branchTargetPositions = {}

-- Stall watchdog for branchStep 2 (walking to a crab room's intermediate point): pathTo() can
-- leave isFollowingPath() reporting true indefinitely with zero actual movement (a real engine
-- pathing stall, not the ordinary "false right after a failed call too" case). Tracks real
-- position independent of isFollowingPath() so a stall can be detected and retried.
local branchStallCheck = {}
local STALL_TICKS = math.ceil(15000 / TICK_MS) -- ~15 real seconds of zero movement before retrying
local STALL_MAX_RETRIES = 3 -- give up on the leg after this many identical stalls (bad/unreachable target)

-- Dense entrance-tunnel tail appended to every flee route, guaranteeing any retrace actually
-- terminates inside the entrance/FLEE_FAIL_POS area rather than wherever the last breadcrumb
-- landed. Real !checknav-verified points.
local ENTRANCE_LEG_COUNT = 8

local function buildEntrancePath()
    -- Reversed order (room -> start) -- this is only ever used as the tail of a flee path.
    local pts = {}
    for i = ENTRANCE_LEG_COUNT, 1, -1 do
        local base = (i - 1) * 3 + 1
        table.insert(pts, FULL_PATH[base])
        table.insert(pts, FULL_PATH[base + 1])
        table.insert(pts, FULL_PATH[base + 2])
    end
    return pts
end
local ENTRANCE_PATH = buildEntrancePath()

local function reverseFlat(flat)
    local out = {}
    for i = #flat / 3, 1, -1 do
        local base = (i - 1) * 3 + 1
        table.insert(out, flat[base])
        table.insert(out, flat[base + 1])
        table.insert(out, flat[base + 2])
    end
    return out
end

-- Builds the actual flee route: the given main leg (see buildWalkedPathFallback()/buildForkLeg()/
-- buildBranchLeg()) reversed, then the guaranteed ENTRANCE_PATH appended as the final leg. Walked
-- one point at a time via pathTo(), so there's no MAX_PATH_POINTS cap to respect here -- a soft
-- length cap is still applied, trimmed from the front (farthest from the entrance), since the
-- entrance leg must never be the part that gets cut.
local MAX_FLEE_ROUTE_POINTS = 150
local function buildFleePath(mainLeg)
    local combined = reverseFlat(mainLeg)
    for _, v in ipairs(ENTRANCE_PATH) do
        table.insert(combined, v)
    end
    local maxLen = MAX_FLEE_ROUTE_POINTS * 3
    if #combined > maxLen then
        for _ = 1, #combined - maxLen do
            table.remove(combined, 1)
        end
    end
    return combined
end

-----------------------------------
-- Branch / intermediate-point framework. Real model: 4 hallway-center decision points along the
-- route, each offering 2 candidate side-rooms. Getting from a branch point to its picked side isn't
-- a straight line, so each side has its own ordered intermediate waypoint(s). On approach to a
-- branch point he peels off to a randomly-picked side, then (branches 1-3) returns to the branch's
-- center and resumes the main route, or (branch 4) continues onward via the separate east fork
-- instead of returning. Sides are labeled west/east (real cardinal direction via X) rather than
-- left/right to avoid facing ambiguity.
-----------------------------------
-- Real order, all via live !logpos capture:
--   1. Crab room 1
--   2. Crab room 2
--   3. Crab room 3
--   4. Doors to Debauchers or Pugils -- west leads to the Pugil fork, east leads to the Debaucher
--      (confirmed by proximity to their real spawn positions).
local BRANCH_POINTS =
{
    { label = "Crab room 1", pos = { x = -340.3118, y = -15.7142, z = 296.9288 },
      west = { { x = -389.1999, y = -15.2696, z = 296.2123 } },
      east = { { x = -293.0699, y = -15.2839, z = 300.0408 } } },
    { label = "Crab room 2", pos = { x = -339.5851, y = -15.9228, z = 259.6459 },
      west = { { x = -389.1134, y = -15.2893, z = 256.6495 } },
      east = { { x = -290.1050, y = -15.2687, z = 255.5301 } } },
    { label = "Crab room 3", pos = { x = -340.6840, y = -15.6871, z = 218.6750 },
      west = { { x = -391.0412, y = -15.2330, z = 219.8630 } },
      east = { { x = -290.4445, y = -15.2799, z = 219.4002 } } },
    -- triggerRadius override: real measured minimum distance from this pos to the route is 9.75
    -- yalms, past the standard 6-yalm BRANCH_TRIGGER_RADIUS -- widened just for this branch point.
    { label = "Doors to Debauchers/Pugils", pos = { x = -342.9736, y = -15.7158, z = 177.1519 },
      triggerRadius = 11.0,
      west = { { x = -380.6727, y = -15.6844, z = 120.2881 } },
      east = { { x = -300.9829, y = -15.8654, z = 134.9449 } } },
}

-- B4's west-continue/east-fork decision is pinned to its actual fixed index (not "last entry in
-- BRANCH_POINTS") so appending further branch points later can't silently break it.
local FORK_DECISION_BRANCH_INDEX = 4

local function getBranchSide(branchIndex, side)
    local branch = BRANCH_POINTS[branchIndex]
    return branch and branch[side]
end

-- How close he needs to get to a branch point's central position before peeling off. Kept tight --
-- these sit right on the central route line.
local BRANCH_TRIGGER_RADIUS = 6.0

-- Real dwell time at every branch point AND intermediate point (twice per branch visit). Counted
-- in tick()-poll units rather than a separate npc:timer() so it can't race the main tick chain.
local PAUSE_DURATION_MS = 7333 -- calibrated against real observed timing, not the nominal TICK_MS math
local PAUSE_TICKS = math.ceil(PAUSE_DURATION_MS / TICK_MS)

-- Mob-aggro flee: when a nearby real mob is engaged/in range, he calls out ("Over to you.") and
-- flees the same way as the too-far-behind escape.
local AGGRO_CHECK_RADIUS = 5.0
local CRAB_AGGRO_TEXT = { ID.text.EXCALIACE_CRAB1, ID.text.EXCALIACE_CRAB2, ID.text.EXCALIACE_CRAB3 }
local DEBAUCHER_AGGRO_TEXT = { ID.text.EXCALIACE_DEBAUCHER1, ID.text.EXCALIACE_DEBAUCHER2 }

-- Per-instance "last aggro mob category" latch -- once a mob of a category (see below) has scared
-- him, other mobs of that SAME category are ignored until nothing of it remains in range, so
-- getting caught and put right back next to the same crab room doesn't loop flee/catch forever.
local lastAggroMob = {}

-- Returns the dialogue text ID to use, or nil if nothing nearby qualifies. Checks every real mob in
-- this mission (crabs, debauchers, pugils), not just the ones near BRANCH_POINTS -- he can
-- encounter any of them on the main route or a branch side-trip.
--
-- NOTE on math.random(n): the engine's single-arg math.random(n) is bound to a HALF-OPEN [1,n)
-- range (tpzrand::GetRandomNumber, confirmed by reading the C++) -- it can NEVER return n. The
-- two-arg form math.random(1, n) is correctly compensated and is used everywhere in this file for
-- that reason -- several "second option" outcomes (east forks, alternate dialogue lines) were
-- silently unreachable before this was found and fixed throughout.
local function checkMobAggro(npc, instance)
    local instanceId = instance and instance:getID()
    -- Debounce is keyed on CATEGORY (crab/pugil/debaucher), not exact mob id -- a crab room holds
    -- multiple crabs, and per-id debounce re-triggered once per crab instead of once for the room.
    local ignoreCategory = instanceId and lastAggroMob[instanceId]
    local anyInRange = false

    for name, id in pairs(ID.mob[31]) do
        if name ~= "EXCALIACE" then
            local mob = GetMobByID(id, instance)
            if mob and mob:isSpawned() and mob:isAlive() and distTo(npc, mob) <= AGGRO_CHECK_RADIUS then
                anyInRange = true
                -- DSP-PORT (2026-09-13, corrected): old-dsp-reference has no isAggroable/
                -- setIsAggroable Lua binding at all (confirmed absent from
                -- src/map/lua/lua_baseentity.cpp), so the native mob-vs-mob aggro path this
                -- comment previously assumed does not exist on this target. Restored the
                -- original Topaz manual-aggro workaround (mob:updateEnmity(npc), confirmed
                -- real binding: LUNAR_DECLARE_METHOD(CLuaBaseEntity,updateEnmity) in
                -- lua_baseentity.cpp) -- makes him a real, damageable/engageable target since
                -- CZoneEntities::SpawnMOBs only ever evaluates real players, never other mobs.
                if not mob:isEngaged() then
                    mob:updateEnmity(npc)
                end
                local category
                if name:find("CRAB") then
                    category = "CRAB"
                elseif name:find("PUGIL") then
                    category = "PUGIL"
                else
                    category = "DEBAUCHER"
                end
                if category ~= ignoreCategory then
                    if instanceId then
                        lastAggroMob[instanceId] = category
                    end
                    if category == "CRAB" then
                        return CRAB_AGGRO_TEXT[math.random(1, #CRAB_AGGRO_TEXT)]
                    else
                        return DEBAUCHER_AGGRO_TEXT[math.random(1, #DEBAUCHER_AGGRO_TEXT)]
                    end
                end
            end
        end
    end

    -- Nothing at all in range this tick -- he's genuinely moved past whatever last scared him, so
    -- clear the latch (otherwise the same mob would stay permanently immune even after a real gap).
    if instanceId and not anyInRange then
        lastAggroMob[instanceId] = nil
    end

    return nil
end

-- Finds the FULL_PATH point index nearest to the npc's current position -- used to resume patrol
-- from the right spot after a branch/fork detour, rather than a fixed chunk boundary.
local function nearestPathIndex(npc)
    local x, y, z = npc:getXPos(), npc:getYPos(), npc:getZPos()
    local bestIndex, bestDist = 1, nil
    for i = 1, #FULL_PATH, 3 do
        local dx, dy, dz = FULL_PATH[i] - x, FULL_PATH[i + 1] - y, FULL_PATH[i + 2] - z
        local dist = dx * dx + dy * dy + dz * dz
        if not bestDist or dist < bestDist then
            bestDist = dist
            bestIndex = (i - 1) / 3 + 1
        end
    end
    return bestIndex
end

-- Builds a flee-retrace leg from FULL_PATH index 1 through his current nearest point (not the
-- whole array -- reversing the whole route would put the southernmost point first, sending him the
-- wrong way), with his own live position appended last so it becomes the FIRST point after
-- buildFleePath()'s reversal. Index-based against the real fixed FULL_PATH array -- can never
-- duplicate or loop the way an earlier recorded-breadcrumb-log approach could.
local function buildWalkedPathFallback(npc)
    local idx = nearestPathIndex(npc)
    local flat = {}
    for i = 1, idx do
        local base = (i - 1) * 3 + 1
        table.insert(flat, FULL_PATH[base])
        table.insert(flat, FULL_PATH[base + 1])
        table.insert(flat, FULL_PATH[base + 2])
    end
    table.insert(flat, npc:getXPos())
    table.insert(flat, npc:getYPos())
    table.insert(flat, npc:getZPos())
    return flat
end

-- Same idea, for a flee triggered while on the east fork (STATE_FORKING) -- splices the main
-- corridor's walked-so-far portion (via forkEntryPathIndex, since the fork diverges away from
-- FULL_PATH and nearestPathIndex() would find the wrong spot) together with EAST_FORK_PATH's own
-- walked-so-far portion, in forward order.
local function buildForkLeg(npc, instance)
    local entryIdx = instance and forkEntryPathIndex[instance:getID()] or nearestPathIndex(npc)
    local flat = {}
    for i = 1, entryIdx do
        local base = (i - 1) * 3 + 1
        table.insert(flat, FULL_PATH[base])
        table.insert(flat, FULL_PATH[base + 1])
        table.insert(flat, FULL_PATH[base + 2])
    end

    -- forkIndex points PAST the leg he's actually mid-flight on when its pathTo() is issued --
    -- forkIndex-1 is the last EAST_FORK_PATH point he's actually reached.
    local forkIdx = npc:getLocalVar("forkIndex")
    if forkIdx == 0 then
        forkIdx = 1
    end
    local walkedForkIdx = math.min(forkIdx - 1, #EAST_FORK_PATH / 3)
    for i = 1, walkedForkIdx do
        local base = (i - 1) * 3 + 1
        table.insert(flat, EAST_FORK_PATH[base])
        table.insert(flat, EAST_FORK_PATH[base + 1])
        table.insert(flat, EAST_FORK_PATH[base + 2])
    end
    table.insert(flat, npc:getXPos())
    table.insert(flat, npc:getYPos())
    table.insert(flat, npc:getZPos())
    return flat
end

-- Same idea, for a flee triggered mid-branch-detour (STATE_BRANCHING). Detour points aren't in
-- FULL_PATH at all, so this routes him through the branch's own known center point (branchEntryPathIndex)
-- first, then the corridor from where he actually entered the detour, then his live position.
local function buildBranchLeg(npc, instance)
    local entryIdx = instance and branchEntryPathIndex[instance:getID()] or nearestPathIndex(npc)
    local flat = {}
    for i = 1, entryIdx do
        local base = (i - 1) * 3 + 1
        table.insert(flat, FULL_PATH[base])
        table.insert(flat, FULL_PATH[base + 1])
        table.insert(flat, FULL_PATH[base + 2])
    end

    local branchIndex = npc:getLocalVar("branchIndex")
    local branch = BRANCH_POINTS[branchIndex]
    if branch then
        table.insert(flat, branch.pos.x)
        table.insert(flat, branch.pos.y)
        table.insert(flat, branch.pos.z)
    end

    table.insert(flat, npc:getXPos())
    table.insert(flat, npc:getYPos())
    table.insert(flat, npc:getZPos())
    return flat
end

-----------------------------------
-- States
-----------------------------------
-- setLocalVar/getLocalVar are numeric-only (uint32) -- states are plain numbers, not strings.
-- Starts at 1 (not 0) since an unset localvar reads back as 0.
local STATE_WAITING   = 1 -- hasn't started moving yet, waiting for a player within 10'
local STATE_MOVING    = 2 -- normal escort movement, 50% speed
local STATE_STOPPED   = 3 -- garlic-stopped, paused until player backs off past 5'
local STATE_ESCAPING  = 4 -- heading back toward the entrance at 75%
local STATE_BRANCHING = 5 -- detoured off the main route to a branch point's side-room
local STATE_FORKING   = 6 -- on B4's separate east-fork route, not a there-and-back detour
local STATE_ESCAPING_TIRED = 7 -- paused during escape, catching breath before resuming at 75%
-- After the tired pause, he heads specifically toward FLEE_FAIL_POS at 75% (SPEED_ESCAPE) -- a
-- single fixed destination, not a route -- giving one more real chance to catch him.
local STATE_ESCAPING_TO_FAIL = 8

local function nearestPlayerDistance(npc, chars)
    local nearest = nil
    for _, player in pairs(chars) do
        local d = distTo(npc, player)
        if not nearest or d < nearest then
            nearest = d
        end
    end
    return nearest or 9999
end

-- Shared sustained-catch check used by all three flee states, so a real catch requires several real
-- seconds of sustained proximity everywhere, not just a single-tick pass-by.
local function checkCaught(npc, chars)
    if nearestPlayerDistance(npc, chars) <= CATCH_RANGE then
        local ticks = (npc:getLocalVar("catchSustainTicks") or 0) + 1
        npc:setLocalVar("catchSustainTicks", ticks)
        return ticks >= CATCH_SUSTAIN_TICKS
    end
    npc:setLocalVar("catchSustainTicks", 0)
    return false
end

-- textId/speed let this be reused for both the mob-aggro flee (EXCALIACE_CRAB*/DEBAUCHER* +
-- SPEED_FLEE) and the original too-far-behind escape (EXCALIACE_RUN + SPEED_ESCAPE default).
local function startEscape(npc, instance, textId, speed)
    if TEMP_DEBUG_DISABLE_FLEE then
        return
    end
    -- Records which state he was actually in before fleeing (unless already mid-flee) so
    -- resumeEscort() can put him back into the same branch/fork detour instead of always
    -- defaulting to the main route.
    local previousState = npc:getLocalVar("state")
    if previousState ~= STATE_ESCAPING and previousState ~= STATE_ESCAPING_TIRED
        and previousState ~= STATE_ESCAPING_TO_FAIL then
        npc:setLocalVar("preEscapeState", previousState)
    end
    npc:setLocalVar("state", STATE_ESCAPING)
    setStationary(npc, false)
    npc:setLocalVar("pauseNPCPathing", 0)
    -- Grace window before the catch check can register -- a mob-aggro flee often fires while the
    -- player is already at normal escort range, and without this he'd flee and get caught in the
    -- same instant, repeatedly, without ever visibly running.
    npc:setLocalVar("catchGraceTicks", CATCH_GRACE_TICKS)
    npc:messageText(npc, textId or ID.text.EXCALIACE_RUN)
    -- Escape starts at 100% (SPEED_FLEE). Record the start position (real table, not setLocalVar --
    -- see escapeStartPositions' own comment) to track fatigue distance.
    npc:speed(speed or SPEED_FLEE)
    if instance then
        escapeStartPositions[instance:getID()] = { x = npc:getXPos(), z = npc:getZPos() }
    end
    npc:setLocalVar("escapeTiredWaitTicks", 0)
    -- The tired pause only happens ONCE per flee episode -- reset fresh at the start of every new
    -- flee (see hasBeenTired's use in STATE_ESCAPING below).
    npc:setLocalVar("hasBeenTired", 0)

    if TEMP_DEBUG_SIMPLE_NAVMESH_FLEE then
        local route = { START_POS[1], START_POS[2], START_POS[3] }
        if instance then
            escapeRoutes[instance:getID()] = route
        end
        npc:clearPath()
        npc:pathTo(route[1], route[2], route[3], PATHFLAG_RUN_SCRIPT_NO_WALLHACK)
        npc:setLocalVar("escapeRouteIndex", 2)
        return
    end

    -- previousState (captured above) tells us which real route he was actually on when the flee
    -- started, so the retrace can splice back onto the right one.
    local mainLeg
    if previousState == STATE_FORKING then
        mainLeg = buildForkLeg(npc, instance)
    elseif previousState == STATE_BRANCHING then
        mainLeg = buildBranchLeg(npc, instance)
    else
        mainLeg = buildWalkedPathFallback(npc)
    end

    -- Reversed manually (not via PATHFLAG_REVERSE) so the guaranteed entrance-tunnel leg can be
    -- appended afterward in the right order. Stored as a route + walk-cursor so each leg gets real
    -- navmesh routing via its own pathTo() call (see STATE_ESCAPING in tick()).
    local route = buildFleePath(mainLeg)
    if instance then
        escapeRoutes[instance:getID()] = route
    end
    if #route >= 3 then
        -- clearPath() before issuing this backward-direction path -- without it, a leg interrupted
        -- mid-flight by the flee trigger could layer its leftover movement onto the new path,
        -- producing a visible snap for the first leg or two.
        npc:clearPath()
        npc:pathTo(route[1], route[2], route[3], PATHFLAG_RUN_SCRIPT)
        npc:setLocalVar("escapeRouteIndex", 2)
    end
end

-- Companion to startEscape()'s preEscapeState capture -- puts him back into the exact branch
-- sub-step he was in when a flee interrupted the detour, instead of defaulting to the main route
-- and silently skipping the crab room. branchIndex/branchStep/branchTargetPositions are untouched
-- by the escape logic, so they're still exactly as they were when the flee started.
local function resumeBranch(npc, instance)
    local branchIndex = npc:getLocalVar("branchIndex")
    local branchStep = npc:getLocalVar("branchStep")
    local branch = BRANCH_POINTS[branchIndex]
    if not branch then
        return false
    end

    npc:setLocalVar("state", STATE_BRANCHING)
    npc:speed(SPEED_NORMAL)

    if branchStep == 1 or branchStep == 3 then
        -- Was paused (branch center or intermediate point) -- just resume the pause.
        -- pauseTicksLeft is untouched by the escape, so the countdown continues where it left off.
        setStationary(npc, true)
    elseif branchStep == 2 then
        setStationary(npc, false)
        local target = instance and branchTargetPositions[instance:getID()]
        if target then
            npc:pathTo(target.x, target.y, target.z, PATHFLAG_RUN_SCRIPT)
        else
            -- No stored target (shouldn't normally happen) -- fall back to heading back to the
            -- branch center same as a failed leg would.
            npc:setLocalVar("branchStep", 4)
            npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
        end
    elseif branchStep == 4 then
        setStationary(npc, false)
        npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
    else
        return false
    end
    return true
end

-- Same as resumeBranch() but for B4's east fork -- without this, a flee starting on STATE_FORKING
-- would fall through to the generic default and silently switch him onto the west route instead.
-- forkIndex was already advanced to point PAST the leg he was actually mid-flight on, so resume the
-- leg he was ACTUALLY on (forkIndex-1), not the one after it.
local function resumeFork(npc)
    local forkIndex = npc:getLocalVar("forkIndex")
    if forkIndex == 0 then
        forkIndex = 1
    end
    local resumeIndex = math.max(1, forkIndex - 1)
    if resumeIndex > #EAST_FORK_PATH / 3 then
        return false
    end

    npc:setLocalVar("state", STATE_FORKING)
    npc:speed(SPEED_NORMAL)
    local base = (resumeIndex - 1) * 3 + 1
    npc:pathTo(EAST_FORK_PATH[base], EAST_FORK_PATH[base + 1], EAST_FORK_PATH[base + 2], PATHFLAG_RUN_SCRIPT)
    npc:setLocalVar("forkIndex", resumeIndex + 1)
    return true
end

local function resumeEscort(npc, fromEscape)
    setStationary(npc, false)
    npc:setLocalVar("pauseNPCPathing", 0)
    if fromEscape then
        npc:messageText(npc, ID.text.EXCALIACE_CAUGHT)
    end
    npc:speed(SPEED_NORMAL)
    npc:setLocalVar("tooFarTicks", 0)

    local instance = npc:getInstance()
    if fromEscape and npc:getLocalVar("preEscapeState") == STATE_BRANCHING and resumeBranch(npc, instance) then
        return
    end
    if fromEscape and npc:getLocalVar("preEscapeState") == STATE_FORKING and resumeFork(npc) then
        return
    end

    npc:setLocalVar("state", STATE_MOVING)
    startFromPathPoint(npc, nearestPathIndex(npc))
end

-- Recurring tick -- pathThrough()/onPath only fire once per full path completion, so per-checkpoint
-- proximity logic needs its own poll loop rather than relying on that callback.
local function tick(npc)
    local instance = npc:getInstance()
    if not instance then
        return
    end

    local chars = instance:getChars()
    local state = npc:getLocalVar("state")
    local checkpointIndex = npc:getLocalVar("checkpointIndex")
    if checkpointIndex == 0 then
        checkpointIndex = 1
    end

    if state == STATE_WAITING then
        local nearest = nearestPlayerDistance(npc, chars)
        if nearest < ESCORT_RANGE then
            npc:setLocalVar("state", STATE_MOVING)
            setStationary(npc, false)
            npc:messageText(npc, ID.text.EXCALIACE_START)
            npc:speed(SPEED_NORMAL)
            startFromPathPoint(npc, 1)
        end
    elseif state == STATE_STOPPED then
        if nearestPlayerDistance(npc, chars) > GARLIC_RANGE then
            resumeEscort(npc, false)
        end
    elseif state == STATE_BRANCHING then
        -- branchStep sequence (all branch points, including B4):
        --   1 = pausing at the branch's central position (just arrived)
        --   2 = walking to the picked side's intermediate point (B1-3 only, B4-west skips straight
        --       to STATE_MOVING and B4-east goes to STATE_FORKING -- see below)
        --   3 = pausing at the intermediate point
        --   4 = walking back to the branch's central position (B1-3 only)
        local branchIndex = npc:getLocalVar("branchIndex")
        local branchStep = npc:getLocalVar("branchStep")
        local branch = BRANCH_POINTS[branchIndex]

        -- Checked first, before any branchStep-specific handling, so a fight breaking out at ANY
        -- point during the detour interrupts it the same way it would during normal escort.
        local branchAggroText = checkMobAggro(npc, instance)
        if branchAggroText then
            startEscape(npc, instance, branchAggroText, SPEED_FLEE)
            npc:timer(TICK_MS, tick)
            return
        end

        local isFinalBranch = (branchIndex == FORK_DECISION_BRANCH_INDEX)

        if branchStep == 1 then
            local ticksLeft = npc:getLocalVar("pauseTicksLeft") - 1
            if ticksLeft > 0 then
                npc:setLocalVar("pauseTicksLeft", ticksLeft)
            elseif isFinalBranch then
                -- B4, pause finished -- decide west/east now (west continues the standard route
                -- untouched, east diverges onto the separate east fork).
                local goEast = (math.random(1, 2) == 2) and #EAST_FORK_PATH > 0
                setStationary(npc, false)
                if goEast then
                    npc:setLocalVar("state", STATE_FORKING)
                    npc:setLocalVar("forkIndex", 2)
                    if instance then
                        forkEntryPathIndex[instance:getID()] = nearestPathIndex(npc)
                    end
                    npc:pathTo(EAST_FORK_PATH[1], EAST_FORK_PATH[2], EAST_FORK_PATH[3], PATHFLAG_RUN_SCRIPT)
                else
                    npc:setLocalVar("state", STATE_MOVING)
                    startFromPathPoint(npc, nearestPathIndex(npc))
                end
            else
                -- B1-3, pause finished -- head to the picked side's intermediate point.
                setStationary(npc, false)
                local side = (math.random(1, 2) == 1) and branch.west or branch.east
                local p = side[1]
                npc:setLocalVar("branchStep", 2)
                if instance then
                    branchTargetPositions[instance:getID()] = p
                end
                npc:pathTo(p.x, p.y, p.z, PATHFLAG_RUN_SCRIPT)
            end
        elseif branchStep == 2 then
            -- isFollowingPath()==false is ambiguous between "arrived" and "pathTo() failed
            -- instantly" -- verify real proximity to the actual target before trusting "arrived".
            local target = instance and branchTargetPositions[instance:getID()]

            -- Stall watchdog (see branchStallCheck's own comment) -- runs every tick, independent
            -- of isFollowingPath(), since a genuine stall never reports false.
            local stallKey = instance and instance:getID()
            local sx, sy, sz = npc:getXPos(), npc:getYPos(), npc:getZPos()
            local stall = stallKey and branchStallCheck[stallKey]
            if not stall or math.sqrt((sx - stall.x) ^ 2 + (sz - stall.z) ^ 2) > 1.0 then
                if stallKey then
                    branchStallCheck[stallKey] = { x = sx, z = sz, ticks = 0 }
                end
            else
                stall.ticks = stall.ticks + 1
                if stall.ticks >= STALL_TICKS then
                    local retries = (stall.retries or 0) + 1
                    npc:clearPath()
                    if retries >= STALL_MAX_RETRIES then
                        -- Give up on this leg -- head back to the branch center instead of hanging.
                        branchStallCheck[stallKey] = nil
                        npc:setLocalVar("branchStep", 4)
                        setStationary(npc, false)
                        npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
                    else
                        branchStallCheck[stallKey] = { x = sx, z = sz, ticks = 0, retries = retries }
                        if target then
                            npc:pathTo(target.x, target.y, target.z, PATHFLAG_RUN_SCRIPT)
                        else
                            npc:setLocalVar("branchStep", 4)
                            setStationary(npc, false)
                            npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
                        end
                    end
                    npc:timer(TICK_MS, tick)
                    return
                end
            end

            if not npc:isFollowingPath() then
                local reached = target and distTo(npc, target) <= CHECKPOINT_ARRIVE_RADIUS
                if reached then
                    -- Reached the intermediate point -- pause here too before heading back.
                    npc:setLocalVar("branchStep", 3)
                    setStationary(npc, true)
                    npc:setLocalVar("pauseTicksLeft", PAUSE_TICKS)
                    if stallKey then
                        branchStallCheck[stallKey] = nil
                    end
                else
                    -- pathTo() failed outright (or target data missing) -- don't fake the detour,
                    -- just head back to the branch's central position and resume normally.
                    npc:setLocalVar("branchStep", 4)
                    setStationary(npc, false)
                    npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
                    if stallKey then
                        branchStallCheck[stallKey] = nil
                    end
                end
            end
        elseif branchStep == 3 then
            local ticksLeft = npc:getLocalVar("pauseTicksLeft") - 1
            if ticksLeft > 0 then
                npc:setLocalVar("pauseTicksLeft", ticksLeft)
            else
                npc:setLocalVar("branchStep", 4)
                setStationary(npc, false)
                npc:pathTo(branch.pos.x, branch.pos.y, branch.pos.z, PATHFLAG_RUN_SCRIPT)
            end
        elseif branchStep == 4 then
            if not npc:isFollowingPath() then
                -- Back at the branch's central position -- resume the main route from his actual
                -- current position. No second pause -- he already paused here in step 1.
                npc:setLocalVar("state", STATE_MOVING)
                setStationary(npc, false)
                startFromPathPoint(npc, nearestPathIndex(npc))
            end
        end
    else
        if state == STATE_MOVING then
            -- Sustained too-far-behind check, runs every tick -- requires TOO_FAR_GRACE_TICKS of
            -- CONSECUTIVE too-far ticks before actually fleeing (see TOO_FAR_GRACE_MS).
            if nearestPlayerDistance(npc, chars) > ESCORT_RANGE then
                local tooFarTicks = (npc:getLocalVar("tooFarTicks") or 0) + 1
                npc:setLocalVar("tooFarTicks", tooFarTicks)
                if tooFarTicks >= TOO_FAR_GRACE_TICKS then
                    npc:setLocalVar("tooFarTicks", 0)
                    startEscape(npc, instance)
                    npc:timer(TICK_MS, tick)
                    return
                end
            else
                npc:setLocalVar("tooFarTicks", 0)
            end

            -- Win-condition proximity check: a TRIGGER point, not an instant-complete point --
            -- while D3 (the Debaucher) is still alive, getting this close scares him into fleeing
            -- exactly like the mob-aggro check below. Only once D3 is dead does reaching this same
            -- spot complete the mission.
            local d3 = GetMobByID(ID.mob[31].DEBAUCHER3, instance)
            if distTo(npc, WIN_CONDITION_POS) <= WIN_ARRIVE_RADIUS then
                if d3 and d3:isSpawned() and d3:isAlive() then
                    startEscape(npc, instance, DEBAUCHER_AGGRO_TEXT[math.random(1, #DEBAUCHER_AGGRO_TEXT)], SPEED_FLEE)
                    npc:timer(TICK_MS, tick)
                else
                    -- D3 defeated -- mission complete. Random selection between END1/END2.
                    npc:messageText(npc, math.random(1, 2) == 1 and ID.text.EXCALIACE_END1 or ID.text.EXCALIACE_END2)
                    instance:setProgress(1)
                end
                return
            end

            -- Mob-aggro flee: a nearby real mob scares him off, same mechanic as the too-far-behind
            -- escape, just triggered by combat instead of player distance.
            local aggroText = checkMobAggro(npc, instance)
            if aggroText then
                startEscape(npc, instance, aggroText, SPEED_FLEE)
                npc:timer(TICK_MS, tick)
                return
            end

            -- Branch-point check: peel off once he gets close to the next branch point's central
            -- position. Branches trigger strictly in route order (nextBranch).
            local nextBranch = npc:getLocalVar("nextBranch")
            if nextBranch == 0 then
                nextBranch = 1
            end
            local branch = BRANCH_POINTS[nextBranch]
            local triggerRadius = (branch and branch.triggerRadius) or BRANCH_TRIGGER_RADIUS
            if branch and distTo(npc, branch.pos) <= triggerRadius then
                -- Enter the pause-at-branch-point step (branchStep 1) uniformly for B1-4 -- what
                -- happens after the pause is decided in the STATE_BRANCHING case above.
                npc:setLocalVar("nextBranch", nextBranch + 1)
                npc:setLocalVar("branchIndex", nextBranch)
                npc:setLocalVar("branchStep", 1)
                npc:setLocalVar("pauseTicksLeft", PAUSE_TICKS)
                npc:setLocalVar("state", STATE_BRANCHING)
                setStationary(npc, true)
                -- Record while he's still ON FULL_PATH, right before detouring (see
                -- branchEntryPathIndex's own comment).
                if instance then
                    branchEntryPathIndex[instance:getID()] = nearestPathIndex(npc)
                end
                npc:timer(TICK_MS, tick)
                return
            end

            -- Advance to the next FULL_PATH waypoint once the current pathTo() leg completes --
            -- routeIndex holds the next point to walk to (set to startIndex+1 by
            -- startFromPathPoint() after issuing the pathTo() for startIndex itself).
            if not npc:isFollowingPath() then
                local routeIndex = npc:getLocalVar("routeIndex")
                if routeIndex == 0 then
                    routeIndex = 1
                end
                if routeIndex <= #FULL_PATH / 3 then
                    local base = (routeIndex - 1) * 3 + 1
                    npc:pathTo(FULL_PATH[base], FULL_PATH[base + 1], FULL_PATH[base + 2], PATHFLAG_RUN_SCRIPT)
                    npc:setLocalVar("routeIndex", routeIndex + 1)
                end
            end
        elseif state == STATE_FORKING then
            -- On B4's separate east-fork route. A mid-fork flee correctly retraces the actual fork
            -- via buildForkLeg()/forkEntryPathIndex in startEscape().
            local aggroText = checkMobAggro(npc, instance)
            if aggroText then
                startEscape(npc, instance, aggroText, SPEED_FLEE)
                npc:timer(TICK_MS, tick)
                return
            end

            if not npc:isFollowingPath() then
                local forkIndex = npc:getLocalVar("forkIndex")
                if forkIndex == 0 then
                    forkIndex = 1
                end
                if forkIndex <= #EAST_FORK_PATH / 3 then
                    local base = (forkIndex - 1) * 3 + 1
                    npc:pathTo(EAST_FORK_PATH[base], EAST_FORK_PATH[base + 1], EAST_FORK_PATH[base + 2], PATHFLAG_RUN_SCRIPT)
                    npc:setLocalVar("forkIndex", forkIndex + 1)
                else
                    -- Reached the end of the east fork -- reconverges with the standard route.
                    -- Resume normal patrol from his actual current position.
                    npc:setLocalVar("state", STATE_MOVING)
                    setStationary(npc, false)
                    startFromPathPoint(npc, nearestPathIndex(npc))
                end
            end
        elseif state == STATE_ESCAPING then
            -- Runs every tick, independent of checkpoint proximity -- escaping moves BACKWARD
            -- along the route, so forward-checkpoint-gated logic would stop re-evaluating almost
            -- immediately once a flee starts.
            local nearest = nearestPlayerDistance(npc, chars)

            -- Suppresses the catch check for a short grace window right after the flee starts (see
            -- startEscape()) so an already-close player doesn't instantly resume it in the same tick.
            local catchGraceTicks = npc:getLocalVar("catchGraceTicks") or 0
            if catchGraceTicks > 0 then
                npc:setLocalVar("catchGraceTicks", catchGraceTicks - 1)
            end

            local startPos = instance and escapeStartPositions[instance:getID()]
            local escapeStartX = startPos and startPos.x or npc:getXPos()
            local escapeStartZ = startPos and startPos.z or npc:getZPos()
            local distanceTraveled = math.sqrt(
                (npc:getXPos() - escapeStartX) ^ 2 + (npc:getZPos() - escapeStartZ) ^ 2
            )
            -- Reaching the end of the retrace route here just means he's made it back to the start
            -- without being caught yet -- treated the same as the fatigue-distance trigger (get
            -- tired and pause), not an instant fail. The real fail check is STATE_ESCAPING_TO_FAIL.
            local route = instance and escapeRoutes[instance:getID()]
            local routeIndex = npc:getLocalVar("escapeRouteIndex")
            if routeIndex == 0 then
                routeIndex = 1
            end
            -- routeIndex is advanced to point PAST the last leg the moment that leg's pathTo() is
            -- issued, not once he's actually finished walking it -- the isFollowingPath() guard
            -- here prevents "routeExhausted" from reading true for the entire duration of his final
            -- leg, which would let the tired-trigger below cut him off mid-stride.
            local routeExhausted = not npc:isFollowingPath() and not (route and routeIndex <= #route / 3)

            -- The fatigue pause only fires ONCE per flee episode -- "he runs at 75% and never stops
            -- again" until caught or actually failing. Also gates routeExhausted: if he's already
            -- had his one pause and NOW reaches the entrance, that must not be a second pause.
            local hasBeenTired = npc:getLocalVar("hasBeenTired") == 1
            if not hasBeenTired and (distanceTraveled >= ESCAPE_FATIGUE_DISTANCE or routeExhausted) then
                -- He's traveled far enough (or run out of retrace route) -- time to get tired and
                -- pause. clearPath() actually halts him where he stands -- without it, a leg
                -- already in flight keeps physically walking him regardless of the state change.
                npc:clearPath()
                setStationary(npc, true)
                npc:messageText(npc, ID.text.EXCALIACE_TIRED)
                npc:setLocalVar("state", STATE_ESCAPING_TIRED)
                npc:setLocalVar("escapeTiredWaitTicks", ESCAPE_TIRED_WAIT_TICKS)
                npc:setLocalVar("hasBeenTired", 1)
                -- Records WHY this pause triggered so the resume can tell the two cases apart:
                -- routeExhausted (really reached the entrance) should proceed to the short final
                -- FLEE_FAIL_POS leg; a mere fatigue pause should resume the in-progress retrace.
                npc:setLocalVar("tiredRouteExhausted", routeExhausted and 1 or 0)
            elseif routeExhausted then
                -- Already had the one pause this episode -- go straight to the real final leg with
                -- no second stop.
                npc:speed(SPEED_ESCAPE)
                setStationary(npc, false)
                npc:setLocalVar("state", STATE_ESCAPING_TO_FAIL)
                npc:pathTo(FLEE_FAIL_POS.x, FLEE_FAIL_POS.y, FLEE_FAIL_POS.z, PATHFLAG_RUN_SCRIPT)
            elseif catchGraceTicks <= 0 and checkCaught(npc, chars) then
                resumeEscort(npc, true)
            elseif not npc:isFollowingPath() then
                -- Each leg finishing here just means "advance to the next point in the route," not
                -- "he's done fleeing."
                local base = (routeIndex - 1) * 3 + 1
                npc:pathTo(route[base], route[base + 1], route[base + 2], PATHFLAG_RUN_SCRIPT)
                npc:setLocalVar("escapeRouteIndex", routeIndex + 1)
            end
        elseif state == STATE_ESCAPING_TIRED then
            -- Pause during escape fatigue. Countdown the wait ticks; catch during the pause resumes
            -- escort.
            if checkCaught(npc, chars) then
                resumeEscort(npc, true)
            else
                local pauseTicksLeft = tonumber(npc:getLocalVar("escapeTiredWaitTicks")) or 0
                if pauseTicksLeft <= 0 then
                    npc:speed(SPEED_ESCAPE)
                    setStationary(npc, false)
                    if npc:getLocalVar("tiredRouteExhausted") == 1 then
                        -- Really reached the entrance -- proceed to the real final leg.
                        npc:setLocalVar("state", STATE_ESCAPING_TO_FAIL)
                        npc:pathTo(FLEE_FAIL_POS.x, FLEE_FAIL_POS.y, FLEE_FAIL_POS.z, PATHFLAG_RUN_SCRIPT)
                    else
                        -- Just a fatigue pause mid-retrace -- resume the SAME in-progress route
                        -- instead of skipping to FLEE_FAIL_POS. A fresh fatigue window starts now;
                        -- no explicit pathTo() needed -- the next STATE_ESCAPING tick's own
                        -- "not isFollowingPath()" branch issues the next leg automatically.
                        npc:setLocalVar("state", STATE_ESCAPING)
                        if instance then
                            escapeStartPositions[instance:getID()] = { x = npc:getXPos(), z = npc:getZPos() }
                        end
                    end
                else
                    npc:setLocalVar("escapeTiredWaitTicks", pauseTicksLeft - 1)
                end
            end
        elseif state == STATE_ESCAPING_TO_FAIL then
            -- The real final leg -- walking at 75% straight for FLEE_FAIL_POS after the tired
            -- pause. Catching him here resumes escort back down the main path; actually reaching
            -- FLEE_FAIL_POS fails the mission for real.
            if checkCaught(npc, chars) then
                resumeEscort(npc, true)
            elseif distTo(npc, FLEE_FAIL_POS) <= CHECKPOINT_ARRIVE_RADIUS then
                npc:messageText(npc, ID.text.EXCALIACE_ESCAPE)
                instance:fail()
                return
            elseif not npc:isFollowingPath() then
                -- pathTo() finished (arrived, or failed outright) without landing inside the
                -- arrival radius -- re-issue rather than leave him frozen either way.
                npc:pathTo(FLEE_FAIL_POS.x, FLEE_FAIL_POS.y, FLEE_FAIL_POS.z, PATHFLAG_RUN_SCRIPT)
            end
        end

        -- STATE_MOVING only: check proximity to the next checkpoint (garlic-stop / completion /
        -- too-far escape trigger). STATE_ESCAPING/STATE_ESCAPING_TIRED handle their own checks
        -- above, independent of checkpointIndex.
        if state == STATE_MOVING then
            local cp = CHECKPOINTS[checkpointIndex]
            if cp and distTo(npc, cp) <= CHECKPOINT_ARRIVE_RADIUS then
                checkpointIndex = checkpointIndex + 1
                npc:setLocalVar("checkpointIndex", checkpointIndex)

                local nearest = nearestPlayerDistance(npc, chars)
                if checkpointIndex > #CHECKPOINTS then
                    -- PLACEHOLDER completion: reached the end of whatever FULL_PATH currently
                    -- contains without escaping. Real completion should happen at the real
                    -- (F-11)/(G-12) endpoint (see TODO) -- self-corrects as more real path segments
                    -- get appended to FULL_PATH.
                    instance:setProgress(1)
                    return
                elseif nearest <= GARLIC_RANGE then
                    npc:setLocalVar("state", STATE_STOPPED)
                    setStationary(npc, true)
                    npc:setLocalVar("pauseNPCPathing", 1)
                    npc:messageText(npc, ID.text.EXCALIACE_TOO_CLOSE)
                end
            end
        end
    end

    npc:timer(TICK_MS, tick)
end

-- Real CMobEntity (converted from npc_list/TYPE_NPC -- native pathTo() movement doesn't render
-- client-side for a plain NPC-type entity; every other roaming entity in this codebase, including
-- the directly analogous Clavauert_B_Chanoix, is a real mob). See sql/mob_pools.sql poolid 6995 for
-- the SQL side. Uses onMobSpawn (not onSpawn) accordingly; "npc" is kept as the local
-- variable name throughout for consistency with the rest of this file.
function onMobSpawn(npc)
    npc:SetAutoAttackEnabled(false) -- he must never fight back, only flee (matches his real design)
    npc:setAllegiance(1) -- ALLEGIANCE_TYPE.PLAYER: without this, players can attack/kill him by accident
    -- DSP-PORT (2026-09-13, corrected): setIsAggroable removed -- old-dsp-reference has no
    -- isAggroable/setIsAggroable binding of any kind; the manual mob:updateEnmity(npc) workaround
    -- in checkMobAggro() above is what actually makes hostile mobs engage him on this target.
    npc:setMobMod(MOBMOD_NO_DESPAWN, 1) -- CRITICAL: his route covers ~500+ yalms from spawn --
    -- without this, the engine's default too-far-from-spawn leash despawn kills the mission.
    -- Opts him out of the movement-freezing CInactiveState a hostile mob's Stun (and the same
    -- incapacitating-effect family -- Sleep/Petrify/Terror/Lullaby/Penalty) would otherwise push --
    -- see status_effect_container.cpp's SetEffectParams(). He's damageable but must keep moving,
    -- not a real combatant. Same convention as the "playerCannotAttack" mechanism in
    -- battleentity.cpp's ValidTarget().
    npc:setLocalVar("immuneToIncapacitate", 1)
    npc:setLocalVar("state", STATE_WAITING)
    setStationary(npc, true)
    npc:setLocalVar("checkpointIndex", 1)
    npc:setLocalVar("routeIndex", 1)
    npc:setLocalVar("forkIndex", 1)
    npc:setLocalVar("escapeRouteIndex", 1)
    npc:setLocalVar("nextBranch", 1)
    npc:setLocalVar("tooFarTicks", 0)
    npc:setLocalVar("preEscapeState", 0)
    npc:setLocalVar("catchGraceTicks", 0)
    npc:setLocalVar("tiredRouteExhausted", 0)
    npc:setLocalVar("hasBeenTired", 0)
    npc:setLocalVar("catchSustainTicks", 0)
    npc:setPos(START_POS[1], START_POS[2], START_POS[3], 0)

    local instance = npc:getInstance()
    if instance then
        escapeRoutes[instance:getID()] = nil
        lastAggroMob[instance:getID()] = nil
        branchStallCheck[instance:getID()] = nil
        forkEntryPathIndex[instance:getID()] = nil
        branchEntryPathIndex[instance:getID()] = nil
    end

    npc:timer(TICK_MS, tick)
end

-- TODO (needs real room/path position data not yet available):
--  - Paired-room investigation (first half): 3 room pairs in H/I-7/8, Excaliace enters one of each
--    pair (random). Empty room -> stops, waits ~20s, resumes. Occupied room -> 3 Arrapago Crabs
--    (EXCALIACE_CRAB1/2/3, 9 total across the 3 possible occupied rooms) -> "Over to you." and
--    attempts to escape at 75% until the room is cleared. At the room's far wall: 5'-10' away ->
--    pauses and turns around on his own; closer than 5' -> stops and complains (needs re-starting,
--    same as a garlic-stop).
--  - After all 3 pairs: heads to the SE crossroads (H-8), then randomly West or East to the T in
--    SW (H-9) -- past 2 Periqia Pugil (west) or 3 (east), plus a Debaucher that can spawn at the
--    SW (H-9) crossroads, the NE (H-9) room (east path only), or the (G-8) tunnel. Real 20s pause
--    at the SW (H-9) crossroads, then continues south.
--  - Aggro-triggered fleeing (from here on): any mob that sights/hears him causes a 100%-speed
--    flee for "about two map squares," then a real ~40s rest before resuming -- if not reached by
--    then, he attempts to escape at 75% (not stoppable while fleeing itself). 2 more Debauchers
--    exist further south: one in (G-10), one in the final room.
--  - Win condition: NW corner of the southernmost room in F-11 (not G-12) -- Rune of Release +
--    Ancient Lockbox spawn there on arrival.
--
-- Reference (horizonffxi.wiki/Seagull_Grounded -- community wiki, consistent with everything
-- already confirmed here): Route is Periqia Map 8, starts at H-6. Room pairs: H-7/I-7 (first
-- choice), then two more randomized selections within H-8/I-8. H-9 is a lower fork (east/west).
-- G-10 is the final corridor. F-11 is the actual destination. Enemies: Arrapago Crab (lv72-74, 9
-- total), Periqia Pugil (lv75-77, 5, H-9 area), Debaucher (lv77-79, 3, H-9/G-10/F-11). Points: wiki
-- cites 1100 solo base -- a real capture's CapLog showed 2198 (Rune_of_Release.lua uses the capture
-- value; the discrepancy may be first-clear/leader bonuses the wiki's base doesn't include).

-- He's a real mob now, so a hostile mob could land a killing blow (even with auto-attack disabled,
-- he can still take damage -- see onTakeDamage below). Dying fails the mission, matching
-- Clavauert_B_Chanoix's identical handling. Also cleans up this instance's per-instance state
-- tables so a future instance reusing the same id doesn't inherit stale state from a dead run.
function onMobDeath(npc, player, isKiller)
    local instance = npc:getInstance()
    if instance and not instance:completed() then
        instance:fail()
    end
    if instance then
        local id = instance:getID()
        escapeRoutes[id] = nil
        escapeStartPositions[id] = nil
        branchTargetPositions[id] = nil
        lastAggroMob[id] = nil
        branchStallCheck[id] = nil
        forkEntryPathIndex[id] = nil
    end
end

function onMobDespawn(npc)
    local instance = npc:getInstance()
    if instance then
        local id = instance:getID()
        escapeRoutes[id] = nil
        escapeStartPositions[id] = nil
        branchTargetPositions[id] = nil
        lastAggroMob[id] = nil
        branchStallCheck[id] = nil
        forkEntryPathIndex[id] = nil
    end
end

function onTakeDamage(npc, attacker, damage)
    -- Random pain reaction when damaged. Only while actually escorting/fleeing (not during
    -- pause/branch states).
    local state = npc:getLocalVar("state")
    if state == STATE_MOVING or state == STATE_ESCAPING or state == STATE_ESCAPING_TO_FAIL then
        local painTexts = {
            ID.text.EXCALIACE_PAIN1,
            ID.text.EXCALIACE_PAIN2,
            ID.text.EXCALIACE_PAIN3,
            ID.text.EXCALIACE_PAIN4,
            ID.text.EXCALIACE_PAIN5,
        }
        npc:messageText(npc, painTexts[math.random(1, #painTexts)])
    end
end

-- onTrade/onTrigger/onEventUpdate/onEventFinish are NPC-only callbacks -- dead code after the
-- conversion to a real mob (never invoked, harmless to leave).
function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    npc:lookAt(player:getPos())
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
end

