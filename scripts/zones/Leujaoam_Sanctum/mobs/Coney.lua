require("scripts/globals/status")
-----------------------------------
-- Area: Leujaoam Sanctum (Shanarha Grass Conservation)
--  Mob: Coney
-----------------------------------
-- Kill-all pattern, same as Leujaoam_Worm.lua -- see instances/shanarha_grass_conservation.lua.
-- 2026-08-19: capture-confirmed kill-all-20 (exactly 20 "defeats the Coney" lines followed
-- immediately by mission completion, Leujaoam Sanctum LC capture) -- but progress was being
-- counted from onMobDespawn, which fires on ANY despawn (including a leash back to spawn), not
-- just a real kill. Moved to onMobDeath gated on a real killer, plus MOBMOD_NO_DESPAWN so a Coney
-- can't leash away uncounted -- same fix already applied to Sagelord_Molaal_Ja.lua/
-- Broken_Troll_Soldier.lua/Frozen_Bones.lua/Gelid_Bhoot.lua this session.
-- 2026-08-30, real AI behavior built per user-provided wiki walkthrough (previously modeled as a
-- static spawn + a blind per-tick dice-roll "eat" check with no actual movement at all):
--   "All of the Coneys spawn in the very first room. 9-11 of them run to the south first, and
--   9-11 of them run to the north first... they eat Vegetation spots on the map."
-- All 20 now spawn together at the real start room (258,-3,-239 -- same position
-- instances/shanarha_grass_conservation.lua uses for Rune of Release), split into 2 groups of 10
-- (first 10 real ids = south, last 10 = north -- which specific Coney go which way isn't
-- capture-confirmed, a reasonable even split per the wiki's "9-11" range), dash toward a general
-- hub in their assigned direction, then continuously seek and path to their nearest still-alive
-- Vegetation (their own hemisphere preferred, falls back to any remaining one once their side is
-- exhausted). North/south hub coordinates are DERIVED estimates -- midpoints of the real
-- Vegetation cluster on each side of the start room's Z, not a captured waypoint.
-- 2026-08-30, REVISED: user asked whether the Thris capture had real "vegetation eaten" warning
-- dialogue -- it did, just mislabeled by the capture tool's own +15 id drift for this zone
-- (confirmed via dat-extractor, see IDs.lua). Real text shows a genuine 4-stage decay per patch
-- (VEGETATION_UNTOUCHED/CHEWED/TORN/DESTROYED), confirmed monotonic by tracing one specific
-- Vegetation entity across a capture's full timeline -- not a single instant "eat" like the first
-- pass of this file modeled. Replaced the old single EAT_DURATION_MS channel-then-vanish with a
-- real multi-tick graze: reaching a patch starts a repeating GRAZE_TICK_MS timer that advances the
-- patch's own persisted decayStage by 1 each tick (shown to players who examine it via
-- npcs/Vegetation.lua) until it's fully consumed on stage 4. A player engaging the Coney
-- interrupts the graze (native disengage-and-heal combat behavior, matching the wiki); the decay
-- stage persists on the Vegetation itself, so a different Coney (or the same one, later) resumes
-- from wherever it was left, not from scratch. GRAZE_TICK_MS keeps the user's originally-suggested
-- 10s value, now reinterpreted as the interval between stage advances rather than a one-shot total
-- -- still not capture-confirmed exactly (the capture's real gaps ranged ~15s to ~7min, most
-- likely reflecting how often a Coney was actually nearby+idle rather than a fixed tick rate).
-----------------------------------
local ID = Leujaoam
-----------------------------------
local START_POS = { x = 258, y = -3, z = -239 } -- real captured start room (matches Rune of Release)

-- 2026-08-30 DERIVED, not capture-confirmed: general hub coordinates on each side of the start
-- room, computed as a rough midpoint of the real Vegetation cluster on that side (south = more
-- negative Z, north = more positive Z relative to the start room's Z=-239). Used only as an
-- initial dash target -- once a Coney arrives, it switches to real nearest-Vegetation seeking.
local SOUTH_HUB = { x = 150, y = -3, z = -400 }
local NORTH_HUB = { x = 220, y = -3, z = -100 }

-- 2026-08-30 arbitrary even split, not capture-confirmed which specific Coney go which way --
-- matches the wiki's "9-11 north / 9-11 south" with a clean 10/10 down the middle of the real id
-- range (17059891-900 = south, 17059901-910 = north).
local SOUTH_IDS =
{
    [17059891] = true, [17059892] = true, [17059893] = true, [17059894] = true, [17059895] = true,
    [17059896] = true, [17059897] = true, [17059898] = true, [17059899] = true, [17059900] = true,
}

local CONEY_IDS =
{
    17059891, 17059892, 17059893, 17059894, 17059895, 17059896, 17059897, 17059898, 17059899, 17059900,
    17059901, 17059902, 17059903, 17059904, 17059905, 17059906, 17059907, 17059908, 17059909, 17059910,
}

local VEGETATION_IDS =
{
    ID.npc.VEGETATION1,  ID.npc.VEGETATION2,  ID.npc.VEGETATION3,  ID.npc.VEGETATION4,
    ID.npc.VEGETATION5,  ID.npc.VEGETATION6,  ID.npc.VEGETATION7,  ID.npc.VEGETATION8,
    ID.npc.VEGETATION9,  ID.npc.VEGETATION10, ID.npc.VEGETATION11, ID.npc.VEGETATION12,
    ID.npc.VEGETATION13, ID.npc.VEGETATION14, ID.npc.VEGETATION15, ID.npc.VEGETATION16,
    ID.npc.VEGETATION17, ID.npc.VEGETATION18, ID.npc.VEGETATION19, ID.npc.VEGETATION20,
    ID.npc.VEGETATION21, ID.npc.VEGETATION22, ID.npc.VEGETATION23, ID.npc.VEGETATION24,
    ID.npc.VEGETATION25, ID.npc.VEGETATION26, ID.npc.VEGETATION27, ID.npc.VEGETATION28,
    ID.npc.VEGETATION29,
}

local AI_TICK_MS      = 3000  -- how often an idle Coney re-evaluates its target
local EAT_RANGE        = 6     -- close enough to actually be "at" a Vegetation spot
-- 2026-08-30 user-revised: was 10000 (a guess at "10 seconds", the user's original suggestion for
-- a single instant eat before the real multi-stage mechanic was found). User re-specified once the
-- real 4-stage decay was confirmed: "should take a few minutes total to consume one... 30 seconds
-- per stage". 4 stages * 30s = 2 minutes total per patch (uninterrupted) -- matches "a few minutes".
local GRAZE_TICK_MS    = 30000
local PATHFLAG_RUN_SCRIPT = 11 -- RUN|WALLHACK|SCRIPT, same convention as other Assault mob pathing
-- Real 4-stage decay text (VEGETATION_UNTOUCHED/CHEWED/TORN/DESTROYED, IDs.lua) is shown to
-- players who examine a patch, not broadcast automatically -- see npcs/Vegetation.lua's onTrigger,
-- which reads the same `decayStage` localVar this file advances.

-- Runtime state keyed by mob id -- NOT localVars (uint32-only, would corrupt the float
-- coordinates/veg-id bookkeeping here), same convention established for Clavauert_B_Chanoix.lua.
local runtime = {}

-- 2026-08-30 user-specified: each Coney should target a Vegetation patch no other Coney is
-- currently grazing, seeking out a free one instead of piling onto the same target. Module-level
-- (not per-Coney) claim table: claimed[vegId] = the mob id currently grazing it, cleared whenever
-- that Coney stops (engaged, wanders off, dies, or fully consumes the patch).
local claimed = {}

-- Forward-declared (not `local function grazeTick`) so aiTick's closure, defined textually
-- above it, captures this same local instead of an undeclared global -- same forward-reference
-- bug class already found and fixed in Clavauert_B_Chanoix.lua earlier this session.
local grazeTick

local function releaseClaim(mob, vegId)
    if vegId and claimed[vegId] == mob:getID() then
        claimed[vegId] = nil
    end
end

local function findNearestVegetation(mob, instance, preferSouth, preferNorth)
    local nearestVeg, nearestId, nearestDist
    local fallbackVeg, fallbackId, fallbackDist
    for _, vegId in ipairs(VEGETATION_IDS) do
        local veg = instance:getEntity(bit.band(vegId, 0xFFF), TYPE_NPC)
        if veg and veg:getStatus() ~= STATUS_DISAPPEAR and not claimed[vegId] then
            local dist = mob:checkDistance(veg)
            local isSouth = veg:getZPos() < -239
            local matchesSide = (preferSouth and isSouth) or (preferNorth and not isSouth)
            if matchesSide and (not nearestDist or dist < nearestDist) then
                nearestVeg, nearestId, nearestDist = veg, vegId, dist
            end
            if not fallbackDist or dist < fallbackDist then
                fallbackVeg, fallbackId, fallbackDist = veg, vegId, dist
            end
        end
    end
    -- Own hemisphere exhausted -- fall back to whatever's left anywhere.
    return nearestVeg or fallbackVeg, nearestId or fallbackId
end

-- 2026-08-30 user-reported real bug, more specific than the earlier spacing fix: 2 Coney standing
-- right next to the SAME Vegetation (well within native linking's 10-yalm range) -- one attacked,
-- one not -- and the second never linked, even after finishing its own approach and starting to
-- graze right next to the fight. The native TryLink()/CanLink() mechanism (mob_controller.cpp,
-- mobentity.cpp) is real, correctly configured (links=1, MOBMOD_LINK_RADIUS defaults to 10), and
-- untouched by this script directly -- but it only ADDS enmity to a linked party member
-- (PEnmityContainer->AddBaseEnmity), it does NOT force that member to engage
-- (PAI->Engage() only fires under ROAMFLAG_IGNORE, not set here) -- actually transitioning from
-- "has enmity" to "attacking" normally happens on the mob's own native roam-tick, which this
-- script's constant scripted pathTo()/graze calls every AI_TICK_MS may be preventing from ever
-- getting a chance to run cleanly. Rather than rely on that native transition firing correctly
-- alongside continuous Lua-driven movement, added an explicit, guaranteed link check here: an
-- unengaged Coney checks every OTHER alive Coney in the instance, and if one within LINK_RADIUS is
-- currently engaged, force-engages the same target immediately (same real engage() Lua binding
-- pattern already used elsewhere in this codebase, e.g. npcs/Cursed_Chest.lua).
local LINK_RADIUS = 10 -- matches the native MOBMOD_LINK_RADIUS default this pool never overrides

local function checkLink(mob, instance)
    for _, otherId in ipairs(CONEY_IDS) do
        if otherId ~= mob:getID() then
            local other = GetMobByID(otherId, instance)
            if other and other:isAlive() and other:isEngaged() and mob:checkDistance(other) <= LINK_RADIUS then
                local target = other:getTarget()
                if target then
                    mob:engage(target:getShortID())
                    return true
                end
            end
        end
    end
    return false
end

local function aiTick(mob)
    if not mob:isAlive() then
        return
    end
    local instance = mob:getInstance()
    if not instance or instance:completed() then
        return
    end

    local st = runtime[mob:getID()]
    if not mob:isEngaged() and checkLink(mob, instance) then
        -- Just force-engaged via the link check above -- treat this tick as if isEngaged() had
        -- already been true, same cleanup as the real engaged branch below.
        releaseClaim(mob, st.grazingVegId)
        st.grazingVegId = nil
        st.travelingVegId = nil
        mob:timer(AI_TICK_MS, aiTick)
        return
    end

    if mob:isEngaged() then
        -- In combat -- clear the in-progress graze (and release the claim so another Coney can
        -- pick this patch up) so a stale grazeTick() can't fire after the fight moves the Coney
        -- away from the patch it was grazing. The patch's own decayStage is untouched (persists
        -- on the Vegetation entity itself), so grazing resumes from where it left off once combat
        -- ends -- by this Coney or a different one.
        releaseClaim(mob, st.grazingVegId)
        st.grazingVegId = nil
        st.travelingVegId = nil
    elseif st.grazingVegId then
        -- Already grazing (grazeTick is scheduled) -- nothing to do here but wait.
    else
        -- 2026-08-30 user-reported real bug: re-picking the nearest free target every tick made a
        -- Coney oscillate between 2 patches whenever a closer one freed up mid-approach (or its
        -- current target got claimed by someone else while still traveling) -- it could flip-flop
        -- forever and never actually reach one. Fixed: commit to a travel target
        -- (st.travelingVegId) and keep pathing to that SAME one regardless of what frees up
        -- elsewhere. Only re-evaluate on arrival -- if it's been claimed by another Coney in the
        -- meantime, THEN switch to a different free one (per user's exact fix direction: "lock in,
        -- then once arrived, if it's occupied, switch to another free vegetation").
        local travelVeg = st.travelingVegId and instance:getEntity(bit.band(st.travelingVegId, 0xFFF), TYPE_NPC)
        if travelVeg and travelVeg:getStatus() == STATUS_DISAPPEAR then
            travelVeg = nil -- fully eaten by someone else while en route -- needs a new target
            st.travelingVegId = nil
        end

        if not travelVeg then
            -- No committed target yet -- pick the nearest free one and lock onto it.
            local veg, vegId = findNearestVegetation(mob, instance, SOUTH_IDS[mob:getID()], not SOUTH_IDS[mob:getID()])
            if veg then
                st.travelingVegId = vegId
                travelVeg = veg
            end
        end

        if travelVeg then
            if mob:checkDistance(travelVeg) <= EAT_RANGE then
                -- Arrived -- re-check occupancy now, not before. Only here does an occupied patch
                -- cause a switch.
                if claimed[st.travelingVegId] then
                    st.travelingVegId = nil -- occupied since we locked on -- try again next tick
                else
                    st.grazingVegId = st.travelingVegId
                    claimed[st.grazingVegId] = mob:getID()
                    local vegId = st.grazingVegId
                    st.travelingVegId = nil
                    mob:timer(GRAZE_TICK_MS, function(mob)
                        grazeTick(mob, vegId)
                    end)
                end
            else
                mob:pathTo(travelVeg:getXPos(), travelVeg:getYPos(), travelVeg:getZPos(), PATHFLAG_RUN_SCRIPT)
            end
        else
            -- 2026-08-30 user-flagged edge case: every real Vegetation gone (should never actually
            -- happen in play -- the mission fails at 8 remaining, well before 0 -- but closing the
            -- gap rather than leaving a dead-end). Instead of standing idle, keep roaming a random
            -- nearby point in the Coney's own hemisphere so it's always moving, matching the wiki's
            -- "run through the dungeon" description even with nothing left to pursue.
            local hub = SOUTH_IDS[mob:getID()] and SOUTH_HUB or NORTH_HUB
            mob:pathTo(hub.x + math.random(-40, 40), hub.y, hub.z + math.random(-40, 40), PATHFLAG_RUN_SCRIPT)
        end
    end

    mob:timer(AI_TICK_MS, aiTick)
end

grazeTick = function(mob, vegId)
    local st = runtime[mob:getID()]
    if not st or st.grazingVegId ~= vegId then
        return -- interrupted (engaged, or already moved onto a different target) -- no-op
    end

    if not mob:isAlive() or mob:isEngaged() then
        releaseClaim(mob, vegId)
        st.grazingVegId = nil
        return
    end

    local instance = mob:getInstance()
    if not instance or instance:completed() then
        releaseClaim(mob, vegId)
        st.grazingVegId = nil
        return
    end

    local veg = instance:getEntity(bit.band(vegId, 0xFFF), TYPE_NPC)
    if not veg or veg:getStatus() == STATUS_DISAPPEAR or mob:checkDistance(veg) > EAT_RANGE then
        releaseClaim(mob, vegId)
        st.grazingVegId = nil
        return -- already fully eaten by another Coney, or this one wandered off mid-graze
    end

    local stage = (veg:getLocalVar("decayStage") or 0) + 1
    veg:setLocalVar("decayStage", stage)

    if stage >= 4 then
        -- Fully consumed -- same completion bookkeeping as before.
        veg:setStatus(STATUS_DISAPPEAR)
        releaseClaim(mob, vegId)
        st.grazingVegId = nil
        local remaining = instance:getLocalVar("vegetation_remaining") - 1
        instance:setLocalVar("vegetation_remaining", remaining)

        -- 2026-08-30 user-specified: fail if MORE than 20 of the 29 real Vegetation are eaten
        -- (remaining <= 8), not the earlier unconfirmed FAIL_THRESHOLD=10 guess.
        if remaining <= 8 and instance:getLocalVar("vegetation_failed") == 0 then
            instance:setLocalVar("vegetation_failed", 1)
            instance:fail()
        end
    else
        -- Not fully consumed yet -- keep grazing this same patch.
        mob:timer(GRAZE_TICK_MS, function(mob)
            grazeTick(mob, vegId)
        end)
    end
end

-- 2026-08-30 user-reported: Coney seemed to ignore linking/aggro unless directly attacked.
-- Investigated the native engine directly -- linking itself is fully intact (mob_pools links=1
-- correct, every mob gets an automatic MOBMOD_LINK_RADIUS=10 yalm default at load,
-- CanLink()/TryLink() are pure C++ untouched by this script) -- the real cause is that the dash
-- scattered all 20 across the whole dungeon within ~0.5-2s of spawning, so by the time anyone gets
-- attacked the others are almost always well outside that 10-yalm range. Also undercut the wiki's
-- own "Sleepga is very important because they link and start out together" -- there was barely a
-- window to actually use it. User-directed fix: hold the whole group in the start room for a real
-- window before dashing, so Sleepga-the-pack is a genuine option like the wiki describes.
local DASH_DELAY_MS = 20000 -- user-directed, not capture-confirmed exact real value

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)

    -- 2026-08-30 real wiki mechanic: "Coney do not show up on Wide Scan" -- name and targetability
    -- must stay normal (players can see/attack them fine), only the widescan blip is hidden. No
    -- existing SQL/entityFlags bit does this split (every one that blocks isWideScannable() also
    -- hides the name or targetability) -- added a real, scoped C++ check
    -- (src/map/entities/baseentity.cpp's isWideScannable()) consulting this localVar instead.
    mob:setLocalVar("wideScanHidden", 1)

    -- Real mechanic: all 20 spawn together in the first room, not scattered at their own
    -- mid-fight capture snapshot positions (those are still real data, just not the true spawn
    -- point -- see the instance file's own header for that distinction).
    mob:setPos(START_POS.x, START_POS.y, START_POS.z, 0)

    runtime[mob:getID()] = {}

    local hub = SOUTH_IDS[mob:getID()] and SOUTH_HUB or NORTH_HUB
    mob:timer(DASH_DELAY_MS + math.random(500, 2000), function(mob) -- small stagger so 20 mobs don't path-request in the same instant
        if mob:isAlive() then
            mob:pathTo(hub.x, hub.y, hub.z, PATHFLAG_RUN_SCRIPT)
        end
    end)
    -- aiTick starts seeking/pathing toward Vegetation on the same delay as the dash -- otherwise
    -- it would start pulling a Coney toward a target well before the group's held-together window
    -- ends, defeating the point of the delay above.
    mob:timer(DASH_DELAY_MS, aiTick)
end

function onMobDeath(mob, player, isKiller)
    local st = runtime[mob:getID()]
    if st then
        releaseClaim(mob, st.grazingVegId)
    end
    runtime[mob:getID()] = nil
    if player then
        local instance = mob:getInstance()
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
    local st = runtime[mob:getID()]
    if st then
        releaseClaim(mob, st.grazingVegId)
    end
    runtime[mob:getID()] = nil
end

