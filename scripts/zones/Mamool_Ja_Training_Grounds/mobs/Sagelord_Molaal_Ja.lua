-----------------------------------
-- Area: Mamool Ja Training Grounds (Sagelord Elimination)
--  Mob: Sagelord Molaal Ja
-----------------------------------
-- 2026-08-20 REAL MECHANIC IMPLEMENTED (previous version assumed a plain kill-target fight --
-- wrong). User-clarified real retail mechanic: at every 20% HP lost (80/60/40%), he uses Warm-Up
-- then flees at 200% speed, and any Mamool Ja Trainee he runs past links against the player. At
-- 20% HP he casts Warp and escapes -- **that escape is the mission's actual win condition**, not
-- killing him to 0 HP.
--
-- Confirmed via a real Thris capture ("Mamool Ja Training Grounds SP - Sagelord Elimination.zip"):
-- - Warm-Up really is mob skill 1924 (animation 1268) -- "Sagelord Molaal Ja readies/uses
--   Warm-Up", observed twice in the capture, each followed by "gains the effect of Evasion Boost"
--   and the player briefly losing him ("is out of range" / "You lose sight of").
-- - He really does cast the actual player Warp spell (id 261) as his escape, not a mob skill:
--   "starts casting Warp" -> ~5s later -> "casts Warp. Sagelord Molaal Ja vanishes."
-- - The real Warp spell's own effect script (scripts/globals/spells/warp.lua) adds a
--   player-only TELEPORT status effect (home-point teleport) -- not something a mob entity can
--   meaningfully resolve. castSpell() below is used ONLY for the correct client-visible cast
--   animation/text, matching the capture exactly; the actual escape (despawn + mission completion)
--   is handled explicitly here instead of relying on the spell's own (player-only) effect.
--
-- 2026-08-20 (live-test history, most recent last):
-- 1. disengage() was called before pathTo()/castSpell() -- both depend on state disengage() tears
--    down (onMobFight only fires while engaged; castSpell() with no target falls back to the
--    mob's current battle target, which disengage() had just cleared). Fixed by never disengaging.
-- 2. pathTo() has no reachability/bounds check -- the flee clipped through the map boundary once
--    the away-from-target direction pointed off the compiled navmesh. Fixed with a
--    checkNavPosition() + checkNavPath() validated sweep before ever calling pathTo().
-- 3. checkNavPosition() alone still let him climb walls (it only confirms a polygon exists near
--    the point, not a real walkable route there) -- added the checkNavPath() check above.
--    Also: he always stopped to cast spells if the player stayed close while fleeing -- a real
--    engine-level gap (DoCombatTick tries spells/special skills/TP moves in C++ right after
--    onMobFight returns, independent of Lua). Fixed by applying Silence + zeroing
--    MOBMOD_SPECIAL_SKILL + emptying MOBMOD_SKILL_LIST for each flee's duration.
-- 4. **This fix**: the Warp escape check was gated behind `fleeStage == 3` -- only reachable once
--    all 3 Warm-Up/flee/Silence cycles (80/60/40%) had each individually run their full 30s. If a
--    player's burst damage dropped him under 20% HP while an EARLIER cycle's Silence was still
--    active, nothing ever re-checked the Warp condition once that Silence wore off -- he'd just
--    sit there, escape permanently skipped. Restructured so the HP<=20% check is now the highest
--    priority, evaluated every single tick regardless of stage, and retries continuously (still
--    evading if a flee happens to be in progress) until a tick finds him not busy and not
--    Silenced, at which point it fires immediately -- it no longer waits for the staged sequence
--    to formally complete first.
--
-- Numeric specifics NOT independently re-verified against the capture (kept as reasonable
-- estimates, flagged rather than presented as confirmed): flee distance, trainee link range. Flee
-- duration (30s) is set to match the real player Flee job ability's known duration, per user
-- direction -- the best available reference point, since no capture data pins down his own
-- duration specifically. The HP thresholds themselves (80/60/40/20) and the Warm-Up/Warp skill ids
-- are the real, capture-confirmed parts. Trainee-links-when-in-range is deterministic (always
-- links if in range when he flees past), confirmed correct with the user.
--
-- onMobDeath is kept as an alternate valid completion path (not part of the real mechanic, but a
-- reasonable fallback if a player's damage kills him outright before he successfully escapes at
-- the 20% threshold -- the capture shows he takes real damage throughout, including during his
-- casting windows, so an outright kill before he escapes is clearly possible).
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
-----------------------------------
-- 2026-08-24: damage immunity added for the Warm-Up->flee windows and the Warp cast itself, per
-- user report -- he was trivially killable while mid-Warm-Up or mid-Warp-cast, well before he
-- ever gets a chance to actually flee/escape (the mission's real win condition). Uses the same
-- real engine mechanism retail's own EFFECT_INVINCIBLE status effect is built on
-- (`scripts/globals/effects/invincible.lua`, already live in this codebase) -- `Mod::UDMGPHYS/
-- UDMGMAGIC/UDMGRANGE` (`src/map/modifier.h:200-203`, doc comment: "Uncapped Damage Multipliers...
-- used in sentinel, invincible, physical shield etc") are read directly in
-- `battleutils.cpp::PhysicalDmgTaken/MagicalDmgTaken/RangedDmgTaken` as
-- `resist = max(1 + mod/100, 0)`, so setting all three to -100 makes `resist == 0` -- damage taken
-- is forced to exactly 0 before the normal PDT/MDT caps ever apply (this mod is deliberately
-- uncapped, unlike `DMGPHYS`/`DMGMAGIC` which cap at -50%), not just a big reduction. This is a
-- real, true damage block, not an after-the-fact HP-floor patch. `setMod()` (absolute value) is
-- used instead of `addMod()`/`delMod()` (delta-based) so repeated calls can never stack/desync.
-- Deliberately NOT reusing EFFECT_INVINCIBLE itself, since that effect script only touches
-- DSP's checkDistance() only accepts an entity (Topaz also accepts {x,y,z}); passing a table hits
-- Lunar::check on non-userdata and crashes the map server (seen at 80% HP). Same 3D distance.
local function distToPos(mob, p)
    local dx, dy, dz = mob:getXPos() - p.x, mob:getYPos() - p.y, mob:getZPos() - p.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- UDMGPHYS -- this needs to also block magic/ranged damage, since any job could be fighting him.
local function setInvincible(mob, on)
    -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): logs every on/off transition request,
    -- regardless of whether it's a no-op re-call.
    --[[ DEBUG (disabled): print(string.format("[SAGELORD INVINCIBLE DEBUG] setInvincible(%s) hp=%d hpp=%d lock=%d",
        tostring(on), mob:getHP(), mob:getHPP(), mob:getLocalVar("invincibleHPLock"))) ]]

    local value = on and -100 or 0
    mob:setMod(MOD_UDMGPHYS, value)
    mob:setMod(MOD_UDMGMAGIC, value)
    mob:setMod(MOD_UDMGRANGE, value)

    -- 2026-09-12, user-reported live: he stayed invincible well past the first flee's actual end --
    -- root cause is that UDMGPHYS/MAGIC/RANGE only gate battleutils.cpp's
    -- PhysicalDmgTaken/MagicalDmgTaken/RangedDmgTaken paths -- a damage-over-time status effect
    -- (Poison/Bio/Bleed/etc.) applies its tick via a completely different path
    -- (status_effect_container.cpp:1679, a direct `addHP(regen)` with regen negative) that never
    -- checks those mods at all. A DoT already on him when a flee starts keeps ticking the ENTIRE
    -- 60s window, potentially dragging HP past the NEXT stage's threshold too by the time this
    -- flee ends -- onMobFight's fallthrough then immediately re-triggers a second flee with no real
    -- vulnerable window in between, which looks exactly like "invincibility never got removed."
    -- Real fix: pin HP at the exact value it was when invincibility engaged (only on the on->on
    -- transition, not every idempotent re-call -- see the guard below), and enforceInvincibleHP()
    -- (called every onMobFight tick, see there) restores it if anything drops it below that floor,
    -- closing the gap the mod-based approach can't reach regardless of the damage source.
    if on then
        if mob:getLocalVar("invincibleHPLock") == 0 then
            mob:setLocalVar("invincibleHPLock", 1)
            mob:setLocalVar("invincibleHP", mob:getHP())
        end
    else
        mob:setLocalVar("invincibleHPLock", 0)
    end
end

-- Called unconditionally at the top of every onMobFight tick -- restores HP to the locked value if
-- anything (a DoT tick, or any other damage path not covered by the UDMG mods above) has dragged
-- it below what it was the instant invincibility engaged. See setInvincible's header for the bug
-- this closes.
local function enforceInvincibleHP(mob)
    if mob:getLocalVar("invincibleHPLock") == 1 then
        local lockedHP = mob:getLocalVar("invincibleHP")
        if mob:getHP() < lockedHP then
            -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): only logs when it actually
            -- restores something (i.e. damage got through despite the lock being active).
            --[[ DEBUG (disabled): print(string.format("[SAGELORD INVINCIBLE DEBUG] enforceInvincibleHP restoring hp=%d -> %d",
                mob:getHP(), lockedHP)) ]]
            mob:setHP(lockedHP)
        end
    end
end

-- 2026-09-12, user-reported live: took him from 100% to 8% in a single spell, which skipped
-- straight past the 80/60/40% flee stages entirely and went directly to the 20% Warp-escape
-- branch -- the mission's staged Warm-Up/flee/reinforcement sequence never actually got to play
-- out. User-requested: "any damage that would exceed a threshold needs to be capped." Called
-- unconditionally at the very top of every onMobFight tick, before anything else reads hpp --
-- clamps his HP UP to whatever threshold his CURRENT fleeStage hasn't crossed yet (80/60/40/20,
-- the same 80-stage*20 formula the stage-transition check below already uses) any time a hit would
-- have dropped him past it. This makes every threshold a real, individual gate a single hit can
-- advance him through AT MOST ONE OF, regardless of how much raw damage lands -- the excess is
-- absorbed, not carried through. Runs BEFORE hpp is read below, so the critical/stage-transition
-- checks always see the clamped value, never the raw pre-clamp one.
-- 2026-09-12, user-reported live (root-caused via the debug log): clamping to EXACTLY floor%,
-- then comparing against hpp<=floor% in updateEscapeState, was a real, deterministic bug -- the
-- clamp targets exactly floor% via setHP(floor(maxHP*floor/100)), but getHPP()'s own read-back
-- rounding doesn't invert that exactly (observed live: clamping to 60% read back as 61%, every
-- single time), so the very next threshold check (hpp<=60) was permanently false, leaving him
-- stuck clamped-but-never-triggering for up to 2 real minutes until a raw hit happened to land on
-- the exact true percentage without going through the clamp's own rounding at all. Fixed by
-- clamping/comparing in RAW HP throughout (see getStageFloorHP below) instead of percentage --
-- eliminates the rounding gap entirely, since both the clamp target and the comparison now use the
-- exact same integer.
local function getStageFloorHP(mob, stage)
    local floorPct = math.max(20, 80 - stage * 20)
    return math.floor(mob:getMaxHP() * floorPct / 100)
end

local function clampToStageFloor(mob)
    local stage = mob:getLocalVar("fleeStage")
    local floorHP = getStageFloorHP(mob, stage)
    if mob:getHP() < floorHP then
        -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): only logs when it actually clamps
        -- something.
        --[[ DEBUG (disabled): print(string.format("[SAGELORD CLAMP DEBUG] stage=%d floorHP=%d hp=%d -> clamping up",
            stage, floorHP, mob:getHP())) ]]
        mob:setHP(floorHP)
    end
end

local WARM_UP_SKILL   = 1924
local WARP_SPELL      = 261
local WARP_CAST_MS    = 5000 -- matches the real capture's ~5s "starts casting" -> "casts Warp" gap
local WARP_VANISH_MS  = 4500 -- 2026-09-19: raised; spell cast (~4s) + Warp animation must finish before vanish (estimate, not capture-confirmed)
                              -- to let the vanish animation/effect actually finish playing before
                              -- the entity is removed (see header history #5)
local FLEE_DISTANCE   = 15   -- yalms, estimate -- how far ahead of himself he paths each tick
                              -- (fallback away-from-player sweep only, see findValidFleeTarget)
-- 2026-09-12, user-requested: 30 -> 60 seconds -- gives the new reinforcement-seeking behavior
-- below (see REINFORCEMENT_IDS/findNearestReinforcement) real room to path to and hand off enmity
-- to multiple Mamool Ja across a full flee cycle, not just one.
local FLEE_DURATION   = 60   -- seconds
-- 2026-09-12, user-reported live: full-flee-length invincibility (60s) was "too long and causing
-- issues" -- it only ever needed to cover the instant of the Warm-Up windup + enough of the initial
-- run that the player can't burst him down in the same global cooldown or two right after Warm-Up
-- plays. Shortened to a separate, shorter window that expires independently of the flee/run itself
-- continuing for its own full FLEE_DURATION -- see updateFleeInvincibility, called every tick.
-- (The critical <=20% Warp-escape invincibility is NOT affected by this -- that one only needs to
-- last through its own short ~8s cast+vanish sequence and already does.)
local FLEE_INVINCIBLE_DURATION = 15 -- seconds
-- 2026-09-12, user-reported live: hard timeout backstop for the fleePending latch (see
-- updateEscapeState) -- if a clean notBusy() window hasn't opened within this long after the
-- threshold was crossed, force Warm-Up through regardless of busy state rather than risk an
-- indefinite stuck-invincible deadlock.
local FLEE_PENDING_FORCE_TIMEOUT = 8 -- seconds
local LINK_RANGE       = 12  -- yalms, estimate -- not independently re-verified against a capture
local SPEED_MULT       = 2   -- 200%, per user
local REAL_SKILL_LIST  = 176 -- his real family/skill list (mob_pools poolid 3437) -- swapped to 0
                              -- (empty) during each flee, restored after
-- 2026-09-12, user-requested tuning pass: real mob_spawn_points coordinates put the 14 candidate
-- reinforcements 42-235 yalms from his own spawn (2 loose clusters -- a near one ~42-70 away, a
-- far one ~210-235 away, matching the user's "two main rooms" description), and this codebase has
-- no independently-confirmed yalms/second figure for his move speed to calculate an exact pickup
-- count from. Rather than guess a travel-time budget that could easily land on 1 or 2 in practice,
-- widened the arrival radius (4 -> 10) so distance alone doesn't stop him well short of the
-- requested "3-4 per flee" floor, and added an explicit hard CAP (below) as the real backstop for
-- the ceiling instead of relying on FLEE_DURATION running out first. Live-test and report back if
-- he's still landing outside the 3-4 range -- this radius is the first thing to retune.
local REINFORCEMENT_REACH = 10 -- yalms

-- 2026-09-12, user-requested: "put a cap on how many he will link" -- out of 14 real candidates
-- (9 trainees + 5 lizards), stop actively seeking new reinforcements once this many have been
-- handed enmity in the CURRENT flee cycle (reset per Warm-Up stage, see onMobFight's stage<3
-- branch) -- falls back to the plain away-from-player sweep for the rest of that flee once hit.
local REINFORCEMENT_CAP = 4

local TRAINEE_IDS =
{
    17047591, 17047594, 17047597,
    17047600, 17047602, 17047603,
    17047605, 17047606, 17047608,
}

-- 2026-09-12, user-requested: "there are multiple other Mamool Ja in the level... I want him to
-- target the nearest Mamool Ja and once he reaches it, transfer enmity to that Mamool Ja so it
-- will come after the player" -- a deliberate gameplay addition (not a real capture-confirmed
-- mechanic) meant to stop him from just running into corners with nowhere useful to go. Lizard
-- pets included per user follow-up ("lizard pets count also").
local REINFORCEMENT_IDS =
{
    17047591, 17047594, 17047597,
    17047600, 17047602, 17047603,
    17047605, 17047606, 17047608,
    17047593, 17047596, 17047604, 17047607, 17047609,
}

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return not (action == ACTION_MOBABILITY_START or action == ACTION_MOBABILITY_USING or
                action == ACTION_MOBABILITY_FINISH or action == ACTION_MAGIC_START or
                action == ACTION_MAGIC_CASTING)
end

-- 2026-09-12, user-requested: ends the FLEE-stage invincibility window (only) after
-- FLEE_INVINCIBLE_DURATION, independent of the flee/run itself continuing for its own full
-- FLEE_DURATION. `fleeInvincibleUntil` is only ever set by the stage-transition branch below, never
-- by the critical <=20% Warp branch, so this never touches that one's own (much shorter) window.
local function updateFleeInvincibility(mob)
    local until_ = mob:getLocalVar("fleeInvincibleUntil")
    if until_ > 0 and mob:getBattleTime() >= until_ then
        -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): the 15s flee-invincibility window
        -- expiring -- confirms exactly when this fires relative to the flee's own fleeUntil.
        --[[ DEBUG (disabled): print(string.format("[SAGELORD INVINCIBLE DEBUG] flee-invincible window expired at now=%d (was until=%d)",
            mob:getBattleTime(), until_)) ]]
        mob:setLocalVar("fleeInvincibleUntil", 0)
        setInvincible(mob, false)
    end
end

-- Links any Trainee within LINK_RANGE of the mob's current position against the player --
-- "Mamool Ja Trainees that he passes will link to you."
local function linkNearbyTrainees(mob, player, instance)
    for _, id in ipairs(TRAINEE_IDS) do
        local trainee = GetMobByID(id, instance)
        if trainee and trainee:isAlive() and mob:checkDistance(trainee) <= LINK_RANGE then
            trainee:setAggressive(true)
            trainee:engage(player:getShortID())
        end
    end
end

-- Sweeps outward from the direct away-from-target angle until a navmesh-validated point is found
-- (both checkNavPosition AND checkNavPath -- see header history #2/#3 for why both are needed).
-- Fallback only now -- see findNearestReinforcement/stepFlee below -- used when no living,
-- not-yet-engaged Mamool Ja remain to run to (this was the ONLY flee behavior before 2026-09-12,
-- and is why he'd sometimes run into a dead-end corner with nowhere useful to go).
local NAV_SWEEP_ANGLES_DEG = { 0, 20, -20, 40, -40, 60, -60, 90, -90, 120, -120, 150, -150, 180 }

local function findValidFleeTarget(zone, pos, dx, dz)
    for _, angleDeg in ipairs(NAV_SWEEP_ANGLES_DEG) do
        local rad = math.rad(angleDeg)
        local rdx = dx * math.cos(rad) - dz * math.sin(rad)
        local rdz = dx * math.sin(rad) + dz * math.cos(rad)
        local tx, tz = pos.x + rdx * FLEE_DISTANCE, pos.z + rdz * FLEE_DISTANCE
        if zone:checkNavPosition(tx, pos.y, tz) then
            local pathFound = zone:checkNavPath(pos.x, pos.y, pos.z, tx, pos.y, tz)
            if pathFound then
                return tx, tz
            end
        end
    end
    return nil, nil
end

-- 2026-09-12, user-reported live: he kept getting stuck trying to path to a west-side
-- reinforcement near a thin navmesh wall around LOGPOS,,66,-419.8948,-11.9303,172.4342 --
-- checkNavPath() reports a path exists (a real, known limitation already flagged in
-- findValidFleeTarget's own header -- it confirms a route exists, not that pathTo() will actually
-- navigate it cleanly around thin geometry). Per user direction: once he gets this close to that
-- spot, abandon the current side entirely, path all the way back to his own real spawn point
-- instead, then flip his east/west bias (see BIAS_EAST/BIAS_WEST below) rather than just excluding
-- the one bad side. HOME_POS is his own real, confirmed mob_spawn_points.sql position, not a guess.
local HOME_POS         = { x = -427.7, y = -3.561, z = 319.423 }
-- 2026-09-12, user-reported live: a SECOND trouble spot found on the opposite side of the same thin
-- wall (LOGPOS,,66,-422.9680,-9.0088,146.4499) -- same failure mode as WALL_TRAP_POS below (a
-- checkNavPath()-approved route pathTo() can't actually clear around this geometry). Checked as a
-- list so either side triggers the same home-then-flip-bias response.
local WALL_TRAP_POSITIONS =
{
    { x = -419.8948, y = -11.9303, z = 172.4342 },
    { x = -422.9680, y = -9.0088,  z = 146.4499 },
}
local WALL_TRAP_RADIUS = 15 -- yalms, estimate -- close enough to count as "reached the trap area"
local HOME_ARRIVED_RADIUS = 10 -- yalms, estimate -- close enough to count as "home", resumes normal seeking
-- East/west split for the reinforcement bias below -- not a confirmed real cardinal mapping for
-- this zone, just a reasonable split point west of the known "near" reinforcement cluster
-- (T3/T4/T6, x -442 to -362) and east of the wall-trap cluster (T1/L1/L3/L4/T7, x -370 to -412) --
-- retune if "east"/"west" turn out to be backwards in-game.
local EAST_X_THRESHOLD = -400
local BIAS_EAST = 1
local BIAS_WEST = -1

-- 2026-09-12, user-requested: finds the nearest living, not-already-engaged Mamool Ja (trainee or
-- lizard pet) with a real navmesh-validated path from his current position -- `isEngaged()` is
-- used as the "already a reinforcement" check instead of a separate tracked list, so this
-- naturally skips anyone he's already handed enmity to (or who's independently aggro'd/linked via
-- linkNearbyTrainees) without needing extra bookkeeping state. `bias` (BIAS_EAST/BIAS_WEST, set
-- randomly on spawn and flipped on hitting the wall trap -- see stepFlee) restricts consideration
-- to only that side of EAST_X_THRESHOLD, for the "picks one of two directions" randomness
-- requested.
local function findNearestReinforcement(mob, instance, bias)
    local zone = mob:getZone()
    local pos = mob:getPos()
    local best, bestDist = nil, nil

    for _, id in ipairs(REINFORCEMENT_IDS) do
        local candidate = GetMobByID(id, instance)
        if candidate and candidate:isAlive() and not candidate:isEngaged() then
            local cpos = candidate:getPos()
            local onBiasedSide = (bias == BIAS_EAST and cpos.x > EAST_X_THRESHOLD) or
                                  (bias == BIAS_WEST and cpos.x <= EAST_X_THRESHOLD)
            if onBiasedSide then
                local dist = mob:checkDistance(candidate)
                if (not bestDist or dist < bestDist) and zone:checkNavPath(pos.x, pos.y, pos.z, cpos.x, cpos.y, cpos.z) then
                    best, bestDist = candidate, dist
                end
            end
        end
    end

    return best
end

-- 2026-08-20 (fifth live test): user reported he still clips into walls, and that the flee itself
-- looks like "rubber banding or skipping around." Root cause: stepFlee() was called and issued a
-- brand new pathTo() EVERY single onMobFight tick -- if that fires faster than he can meaningfully
-- travel between ticks (DoCombatTick's real interval was never confirmed, but the skipping/
-- rubber-banding symptom strongly suggests it's frequent enough that each new pathTo() interrupts
-- him mid-step, before he's covered real ground toward the previous target), repeatedly retargeting
-- before any real progress is a plausible way to produce exactly this kind of janky, discontinuous
-- movement -- and a client/server desync during that kind of constant retargeting is a plausible
-- way for him to glitch through geometry a single continuous run wouldn't. Throttled to at most
-- once every FLEE_STEP_INTERVAL seconds -- frequent enough to keep tracking a moving player,
-- infrequent enough to let him actually complete each leg of the run smoothly in between.
local FLEE_STEP_INTERVAL = 2 -- seconds

-- 2026-08-20 (sixth live test): user reported he STILL clips through walls even with the
-- checkNavPosition()/checkNavPath() sweep above validating every flee target first. Root cause
-- found by reading pathTo()'s own C++ (src/map/lua/lua_baseentity.cpp): when called with no
-- explicit flags argument (as every call here was), it defaults to
-- `PATHFLAG_RUN | PATHFLAG_WALLHACK | PATHFLAG_SCRIPT` -- PATHFLAG_WALLHACK (0x02, "run through
-- walls if path is too long") was silently overriding collision on every single step, making the
-- navmesh validation above moot regardless of how correct it was. Neither PATHFLAG_RUN (0x01) nor
-- PATHFLAG_SCRIPT (0x08) are exposed as Lua globals/constants anywhere in this codebase (checked --
-- transport.lua's own `PATHFLAG_WALLHACK` reference is an undefined bare global, likely a
-- pre-existing unrelated bug, not something to copy), so passed as the raw flag value directly:
-- RUN | SCRIPT = 0x01 | 0x08 = 9. This is the real fix for the clipping -- the earlier
-- navmesh-sweep work was still worth keeping (it picks a real reachable point instead of an
-- arbitrary one), it just wasn't the actual mechanism letting him through geometry.
local PATH_FLAGS_NO_WALLHACK = 9 -- PATHFLAG_RUN (0x01) | PATHFLAG_SCRIPT (0x08)

-- Shared per-tick flee-steering, used both by a normal 80/60/40% flee cycle and by the "waiting
-- for a clean window to Warp" holding pattern below. Throttled -- see FLEE_STEP_INTERVAL above.
-- 2026-09-12, user-requested REWORK: previously always ran directly away from the player along a
-- swept vector, which had no notion of "useful" destinations and could easily dead-end him in a
-- corner with the player closing in and nothing to show for it. Now: while fleeing, he actively
-- seeks out the nearest living, not-yet-engaged Mamool Ja (trainee or lizard) and paths TO it
-- instead of away from the player; on arrival, enmity transfers to it (it engages the player as a
-- real reinforcement) and he immediately looks for the next one, repeating for the rest of the
-- flee's duration. Only once no reachable reinforcement remains does he fall back to the original
-- away-from-player sweep, so he's never stuck with nowhere to go. This is a deliberate gameplay
-- addition, not a real capture-confirmed mechanic (see this file's own header).
local function stepFlee(mob, target)
    local now = mob:getBattleTime()
    if now < mob:getLocalVar("nextFleeStep") then
        return
    end
    mob:setLocalVar("nextFleeStep", now + FLEE_STEP_INTERVAL)

    local instance = mob:getInstance()

    -- 2026-09-12, user-requested: hit the real wall-trap area (see WALL_TRAP_POS's own header) --
    -- give up on the CURRENT biased side, head home first, then flip the bias to the other
    -- direction, rather than keep retrying a route checkNavPath() approves but pathTo() can't
    -- actually clear.
    for _, trapPos in ipairs(WALL_TRAP_POSITIONS) do
        if distToPos(mob, trapPos) <= WALL_TRAP_RADIUS then
            local bias = mob:getLocalVar("reinforcementBias")
            mob:setLocalVar("reinforcementBias", bias == BIAS_EAST and BIAS_WEST or BIAS_EAST)
            mob:setLocalVar("headingHome", 1)
            break
        end
    end

    if mob:getLocalVar("headingHome") == 1 then
        if distToPos(mob, HOME_POS) <= HOME_ARRIVED_RADIUS then
            -- Home -- resume reinforcement-seeking with the now-flipped bias (see above).
            mob:setLocalVar("headingHome", 0)
        else
            mob:pathTo(HOME_POS.x, HOME_POS.y, HOME_POS.z, PATH_FLAGS_NO_WALLHACK)
            linkNearbyTrainees(mob, target, instance)
            return
        end
    end

    local underCap = mob:getLocalVar("reinforcementsThisFlee") < REINFORCEMENT_CAP
    local bias = mob:getLocalVar("reinforcementBias")
    local reinforcement = underCap and findNearestReinforcement(mob, instance, bias) or nil

    -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): confirms whether stepFlee finds a
    -- reinforcement and actually issues a pathTo() call, or falls into some other branch silently.
    --[[ DEBUG (disabled): print(string.format("[SAGELORD FLEE DEBUG] stepFlee underCap=%s bias=%d reinforcement=%s",
        tostring(underCap), bias, reinforcement and "found" or "NONE")) ]]

    if reinforcement then
        if mob:checkDistance(reinforcement) <= REINFORCEMENT_REACH then
            -- Arrived -- hand off enmity and immediately look for the next reinforcement on the
            -- very next tick instead of waiting out the rest of FLEE_STEP_INTERVAL idle.
            reinforcement:setAggressive(true)
            reinforcement:engage(target:getShortID())
            mob:setLocalVar("reinforcementsThisFlee", mob:getLocalVar("reinforcementsThisFlee") + 1)
            mob:setLocalVar("nextFleeStep", 0)
        else
            local rpos = reinforcement:getPos()
            --[[ DEBUG (disabled): print(string.format("[SAGELORD FLEE DEBUG] pathTo reinforcement (%.1f,%.1f,%.1f)", rpos.x, rpos.y, rpos.z)) ]]
            mob:pathTo(rpos.x, rpos.y, rpos.z, PATH_FLAGS_NO_WALLHACK)
        end
    else
        -- No living, unengaged Mamool Ja left to run to -- original away-from-player behavior.
        local pos, tpos = mob:getPos(), target:getPos()
        local dx, dz = pos.x - tpos.x, pos.z - tpos.z
        local mag = math.sqrt(dx * dx + dz * dz)
        if mag > 0 then
            dx, dz = dx / mag, dz / mag
        end
        local tx, tz = findValidFleeTarget(mob:getZone(), pos, dx, dz)
        --[[ DEBUG (disabled): print(string.format("[SAGELORD FLEE DEBUG] fallback sweep tx=%s", tostring(tx))) ]]
        if tx then
            mob:pathTo(tx, pos.y, tz, PATH_FLAGS_NO_WALLHACK)
        end
    end

    linkNearbyTrainees(mob, target, instance)
end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    -- 2026-09-12, user-requested: "impossible to gauge... he should be NM" -- real FFXI NM
    -- convention, same binding this codebase already uses for other NMs (e.g. Pandemonium_Warden.lua)
    -- -- sets FLAG_HIDE_HP so his health bar/percentage reads as unknown to players instead of an
    -- exact number, matching how retail NMs are presented.
    mob:hideHP(true)
    mob:setLocalVar("fleeStage", 0)
    mob:setLocalVar("fleeUntil", 0)
    mob:setLocalVar("escaping", 0)
    mob:setLocalVar("reinforcementsThisFlee", 0)
    mob:setLocalVar("nextFleeStep", 0)
    mob:setLocalVar("fleeInvincibleUntil", 0)
    mob:setLocalVar("fleePending", 0)
    mob:setLocalVar("fleePendingSince", 0)
    -- 2026-09-12, user-requested: random 50/50 east/west reinforcement bias for some real
    -- variation between encounters, instead of always exhausting the same side first -- flips to
    -- the other direction if he ever hits the real wall-trap area (see stepFlee/WALL_TRAP_POS).
    mob:setLocalVar("reinforcementBias", math.random(0, 1) == 0 and BIAS_EAST or BIAS_WEST)
    mob:setLocalVar("headingHome", 0)
    setInvincible(mob, false) -- hygiene reset on a fresh spawn/respawn
end

-- 2026-09-12, user-reported live (with the real mechanism confirmed by the user themselves): a
-- direct hit killed him outright despite the stage floor supposedly protecting him, because he had
-- silently DISENGAGED and fallen into the engine's roam state while fleeing (losing enmity/
-- detection on the player while running at 200% speed toward a reinforcement far across the map --
-- a real, plausible side effect of the wider flee radius this mission's own reinforcement-seeking
-- rework now covers). `onMobFight` -- where every protection above lives (clampToStageFloor/
-- enforceInvincibleHP/updateFleeInvincibility) -- is only ever called from DoCombatTick, which only
-- runs while PAI->IsEngaged() is true (mob_controller.cpp:54-56); once disengaged, the engine calls
-- DoRoamTick instead, a completely separate path that never touches onMobFight at all -- none of
-- our safety logic ran during that window, so HP regenerated freely and the next hit (a direct
-- re-aggro cast, since he was no longer engaged) landed with zero mitigation. `onMobRoam` is the
-- real per-tick hook DoRoamTick calls (luautils.cpp:2925, mob_controller.cpp:868) -- mirroring the
-- same protective calls here closes the gap regardless of engagement state. Takes no target
-- argument (he isn't engaged with anyone while this fires).
-- 2026-09-12, user-reported live: "Sagelord will not use warmup until player engages him in melee
-- attacks. Magic spell attacks seem to completely bypass some of the logic we have built or break
-- the sequence." Root cause: this entire threshold-check/Warm-Up-trigger function used to live
-- ONLY inside onMobFight, which the engine only calls while PAI->IsEngaged() is true
-- (mob_controller.cpp:54-56, DoCombatTick). A ranged/magic hit can damage him without ever causing
-- IsEngaged() to become true the way a melee hit naturally does (melee requires being in his face,
-- which typically claims/engages both ways) -- a player who only ever casts at him from range can
-- keep him permanently in the disengaged roam state while still fully damaging him, and
-- onMobRoam (the hook that DOES fire in that state) previously only ran the passive HP-protection
-- calls, never the actual Warm-Up-triggering logic. Extracted the whole threshold/escape sequence
-- into this shared, engagement-independent function so it works identically whether he's engaged
-- or roaming. `target` is optional (nil when called from onMobRoam, since he isn't engaged with
-- anyone there) -- only the movement-specific stepFlee() calls need it and are guarded accordingly;
-- everything else (invincibility, Silence, stage advancement, actually starting Warm-Up) works
-- with or without a target.
local function updateEscapeState(mob, target)
    if mob:getLocalVar("escaping") == 1 then
        return
    end

    -- Unconditional, every tick, regardless of stage -- see setInvincible/enforceInvincibleHP's own
    -- header for why this is needed on top of the UDMG mods (DoT ticks bypass them entirely).
    enforceInvincibleHP(mob)
    updateFleeInvincibility(mob)

    local hpp = mob:getHPP()

    -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): full per-tick state snapshot -- the
    -- single most useful line for correlating everything else against.
    --[[ DEBUG (disabled): print(string.format(
        "[SAGELORD STATE DEBUG] hasTarget=%s hpp=%d stage=%d fleeUntil=%d fleePending=%d fleeInvincibleUntil=%d invincibleLock=%d action=%d",
        tostring(target ~= nil), hpp, mob:getLocalVar("fleeStage"), mob:getLocalVar("fleeUntil"),
        mob:getLocalVar("fleePending"), mob:getLocalVar("fleeInvincibleUntil"),
        mob:getLocalVar("invincibleHPLock"), mob:getCurrentAction())) ]]

    -- Highest priority: try to Warp out any time HP is at/under 20%, regardless of which
    -- Warm-Up/flee stage he's currently on, and regardless of whether that stage's own Silence
    -- window is still active. Retries every tick until a clean (not busy) window actually lands
    -- the cast -- see header history #4.
    -- 2026-08-20 (fifth live test): user reported he still runs for a while before Warping instead
    -- of doing it instantly -- because he was waiting out the REMAINDER of whichever flee cycle's
    -- Silence was still active when HP first crossed 20%, up to the full 30s. He should escape the
    -- moment he's critical, not after finishing out an in-progress flee. Fixed by actively
    -- stripping Silence the instant HP is critical (delStatusEffect), rather than just waiting for
    -- it to expire naturally -- the only remaining gate is notBusy() (mid-animation), which
    -- resolves within a tick or two, not up to 30 seconds.
    -- 2026-09-12: compares raw HP against the same floor(20%) value clampToStageFloor uses, not
    -- the hpp percentage -- see clampToStageFloor's own header for the rounding-mismatch bug this
    -- avoids.
    if mob:getHP() <= getStageFloorHP(mob, 3) then
        -- Unconditional, not just set when a flee cycle starts him toward this threshold --
        -- covers the edge case of a single burst hit taking him from >80% straight past 20% in
        -- one server-side damage application, skipping the staged Warm-Up flow (and its own
        -- setInvincible(true) call below) entirely. setMod() is absolute-value/idempotent, so
        -- calling this every tick while critical is harmless.
        setInvincible(mob, true)

        if mob:hasStatusEffect(EFFECT_SILENCE) then
            mob:delStatusEffect(EFFECT_SILENCE)
        end

        if notBusy(mob) then
            mob:setLocalVar("escaping", 1)
            setInvincible(mob, true) -- covers the ~5s cast + vanish-buffer window below; no
                                      -- matching setInvincible(mob, false) needed since he's
                                      -- despawned for good at the end of this sequence either way
            mob:messageText(mob, SAGELORD_WARP_CAST) -- real dialogue, fires the same
                                                               -- instant as the real capture's cast
            mob:castSpell(WARP_SPELL, mob) -- explicit self-target, see header

            mob:timer(WARP_CAST_MS, function(mob)
                if not mob:isAlive() then
                    return
                end
                -- CRASH FIX 2026-09-19 (probable, unverified): setProgress() may complete the instance, and
                -- CInstance::Complete() -> ClearEntities() frees this mob. The vanish timer below
                -- used to be scheduled AFTER that call, so it fired on a freed entity and crashed the
                -- map server ("crashed after Sagelord warped out and the Rune spawned"). Vanish first,
                -- and only complete the mission (freeing him) as the very last step.
                mob:timer(WARP_VANISH_MS, function(mob)
                    if mob:isAlive() then
                        mob:setStatus(STATUS_DISAPPEAR)
                    end
                    local instance = mob:getInstance()
                    if instance then
                        instance:setProgress(instance:getProgress() + 1)
                    end
                end)
            end)
            return
        end

        -- Can't cast this tick (mid-animation) -- Silence is already stripped above, so this
        -- should resolve within a tick or two. Keep evading if a flee happens to already be in
        -- progress, but don't start a NEW Warm-Up/flee/Silence cycle from here on -- that would
        -- only delay the escape further.
        local fleeUntil = mob:getLocalVar("fleeUntil")
        if target and fleeUntil > 0 and mob:getBattleTime() < fleeUntil then
            stepFlee(mob, target)
        end
        return
    end

    local stage      = mob:getLocalVar("fleeStage")
    local now        = mob:getBattleTime()
    local fleeUntil  = mob:getLocalVar("fleeUntil")

    -- Actively fleeing: recompute a direction away from the target and path there fresh every
    -- tick (same pattern Selh'teus uses to stay in position -- pathTo() needs to be called
    -- repeatedly while engaged to have any lasting effect; a one-shot call gets overridden).
    if fleeUntil > 0 then
        if now < fleeUntil then
            -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): user-reported live that on
            -- the 2nd/3rd threshold he uses Warm-Up, goes invincible, but never actually flees --
            -- need real data on whether `target` is nil (disengaged/roaming, silently skipping
            -- stepFlee below) or present (meaning the stall is inside stepFlee/pathTo itself).
            --[[ DEBUG (disabled): print(string.format("[SAGELORD FLEE DEBUG] stage=%d now=%d fleeUntil=%d hasTarget=%s action=%d",
                stage, now, fleeUntil, tostring(target ~= nil), mob:getCurrentAction())) ]]
            if target then
                stepFlee(mob, target)
            end
            return
        else
            mob:setLocalVar("fleeUntil", 0)
            mob:speed(mob:speed() / SPEED_MULT)
            mob:setMobMod(MOBMOD_SKILL_LIST, REAL_SKILL_LIST)
            -- 2026-09-12, user-reported live: map-server log showed "CAIMobDummy::ActionSpawn
            -- Special skill was set but not found! (1)" -- this restore call was setting
            -- MOBMOD_SPECIAL_SKILL to a literal 1, but that mod holds a real mob-skill ID (thousands
            -- range, e.g. WARM_UP_SKILL=1924), not a boolean flag -- battleutils::GetMobSkill(1)
            -- finds nothing and TrySpecialSkill() logs this exact error every time it's next
            -- attempted (mob_controller.cpp:326-334). He has no real autonomous "special skill" to
            -- begin with -- Warm-Up is invoked explicitly via useMobAbility(), a separate mechanism
            -- -- so 0 ("no special skill", matches IsSpecialSkillReady()'s own early-out at value
            -- 0, mob_controller.cpp:1094) is the correct restore value, same as the suppress value
            -- used below, not a real behavior change, just removing the bogus id.
            mob:setMobMod(MOBMOD_SPECIAL_SKILL, 0)
            setInvincible(mob, false) -- flee cycle over, back to a normal vulnerable fight
        end
    end

    -- 2026-09-12, user-reported live: was trivially killable ("almost 0 health") while mid-cast on
    -- one of his own long native spells (e.g. Tornado) exactly when HP crossed an 80/60/40%
    -- threshold -- setInvincible(true) used to only fire INSIDE the notBusy(mob) guard below, as
    -- part of actually starting Warm-Up, so a long cast already in progress delayed invincibility
    -- for its entire remaining duration, same root cause the hpp<=20 branch above already had fixed
    -- (see header history #4) but this stage branch never received. Mirrors that same fix: the
    -- instant a threshold is crossed, invincibility engages unconditionally regardless of busy
    -- state -- only the actual Warm-Up/flee START still waits for a clean (notBusy) window, since
    -- useMobAbility() can't interrupt an active cast anyway.
    -- 2026-09-12, user-reported live: after the Silence deadlock fix above, he STILL got
    -- permanently stuck invincible+silenced with Warm-Up never firing -- HP was seen dropping to
    -- 80% then ticking back up to 81% (natural regen) and holding there indefinitely. Root cause:
    -- this whole block only runs while hpp<=threshold on THAT SPECIFIC tick -- the instant natural
    -- regen pushes hpp back above it, the block is skipped entirely, so notBusy() never even gets
    -- checked, and nothing here ever undoes the Invincible/Silence a PRIOR tick already applied
    -- (those are only cleared by a flee actually starting and running its course). If regen wins
    -- the race against notBusy() ever lining up with hpp<=threshold on the same tick, he's stuck
    -- forever with the threshold crossed but the flee never actually triggered. Fix: `fleePending`
    -- latches the instant the threshold is crossed and stays set (independent of hpp climbing back
    -- up from regen) until Warm-Up actually fires and clears it below -- so once he's flagged,
    -- he's committed to fleeing as soon as a real notBusy() window appears, not just on whichever
    -- single tick first crossed the line.
    -- 2026-09-12: compares raw HP against getStageFloorHP, not the hpp percentage -- see
    -- clampToStageFloor's own header for the rounding-mismatch bug this fixes (a clamp to exactly
    -- floor% was observed reading back as floor%+1 via getHPP(), permanently blocking this check).
    if stage < 3 and (mob:getHP() <= getStageFloorHP(mob, stage) or mob:getLocalVar("fleePending") == 1) then
        if mob:getLocalVar("fleePending") == 0 then
            mob:setLocalVar("fleePendingSince", now)
            -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): the exact instant a threshold
            -- is first crossed for this stage.
            --[[ DEBUG (disabled): print(string.format("[SAGELORD THRESHOLD DEBUG] threshold crossed: stage=%d hpp=%d now=%d",
                stage, hpp, now)) ]]
        end
        mob:setLocalVar("fleePending", 1)
        setInvincible(mob, true) -- covers the Warm-Up windup (a real cast-bar window he was
                                  -- trivially killable during, per user report) through the
                                  -- entire flee run -- removed above once fleeUntil expires

        -- 2026-09-12, user-reported live: he got permanently stuck invincible, Warm-Up/flee never
        -- firing at all. Root cause: MOBMOD_SKILL_LIST only gates mob-ability/TP-move skills
        -- (mob_controller.cpp's MobSkill()) -- it has NO effect on real spellcasting, which
        -- CanCastSpells() gates on PMob->SpellContainer->HasSpells() instead. SILENCE (the thing
        -- that actually blocks spells) used to only get applied INSIDE the notBusy(mob) guard below
        -- -- i.e. only once Warm-Up had already started. A caster mob like this one (seen live
        -- chain-casting Aspir back-to-back with no natural gap) never gave notBusy() a real opening
        -- to begin with, since nothing was silencing him yet -- a genuine chicken-and-egg deadlock,
        -- not just a rare timing gap. Fix: apply Silence (and the two MobMods, harmless either way)
        -- immediately and unconditionally the instant the threshold is crossed, same treatment as
        -- setInvincible() above -- this lets whatever cast is already in flight finish naturally
        -- without being followed by a new one, which is what actually opens a real notBusy() window
        -- shortly after. Re-applied again below once Warm-Up truly starts so the full FLEE_DURATION
        -- window is guaranteed from that instant, not whatever's left over from this early call.
        if not mob:hasStatusEffect(EFFECT_SILENCE) then
            mob:addStatusEffect(EFFECT_SILENCE, 0, 0, FLEE_DURATION)
        end
        mob:setMobMod(MOBMOD_SPECIAL_SKILL, 0)
        mob:setMobMod(MOBMOD_SKILL_LIST, 0)

        -- 2026-09-12, user-reported live (THIRD occurrence of this deadlock class): even with
        -- Silence/MobMods applied immediately above, he was still observed permanently stuck
        -- invincible with Warm-Up never firing -- notBusy() apparently never clears for some
        -- as-yet-unidentified reason specific to this mob (possibly an engine-level action-state
        -- edge case this Lua-only toolkit can't directly instrument further). Rather than keep
        -- chasing individual root causes one deadlock at a time, added a hard timeout backstop:
        -- if fleePending has been waiting more than FLEE_PENDING_FORCE_TIMEOUT seconds for a clean
        -- notBusy() window, force Warm-Up through regardless of busy state. useMobAbility() may be
        -- a no-op if genuinely still mid-cast (can't interrupt), but this guarantees the deadlock
        -- can never persist beyond one timeout window even if the underlying busy-state cause is
        -- never fully identified.
        -- 2026-09-12 TEMPORARY DIAGNOSTIC (remove once resolved): shows the decision on every tick
        -- fleePending is set, regardless of whether it actually fires this tick.
        --[[ DEBUG (disabled): print(string.format(
            "[SAGELORD THRESHOLD DEBUG] gate check: notBusy=%s action=%d elapsedSincePending=%d timeout=%d willFire=%s",
            tostring(notBusy(mob)), mob:getCurrentAction(), now - mob:getLocalVar("fleePendingSince"),
            FLEE_PENDING_FORCE_TIMEOUT,
            tostring(notBusy(mob) or (now - mob:getLocalVar("fleePendingSince")) >= FLEE_PENDING_FORCE_TIMEOUT))) ]]

        if notBusy(mob) or (now - mob:getLocalVar("fleePendingSince")) >= FLEE_PENDING_FORCE_TIMEOUT then
            --[[ DEBUG (disabled): print("[SAGELORD THRESHOLD DEBUG] >>> FIRING Warm-Up now <<<") ]]
            mob:setLocalVar("fleePending", 0)
            mob:setLocalVar("fleeStage", stage + 1)
            mob:useMobAbility(WARM_UP_SKILL)
            mob:speed(mob:speed() * SPEED_MULT)
            mob:setLocalVar("fleeUntil", now + FLEE_DURATION)
            -- Starts the shorter 15s countdown (see FLEE_INVINCIBLE_DURATION/
            -- updateFleeInvincibility) only from THIS instant -- Warm-Up actually starting -- not
            -- from whenever the threshold was first crossed, so a long busy-wait beforehand can't
            -- eat into it.
            mob:setLocalVar("fleeInvincibleUntil", now + FLEE_INVINCIBLE_DURATION)
            -- Reset the per-flee reinforcement cap (REINFORCEMENT_CAP) here -- each of the 3 flee
            -- stages (80/60/40%) gets its own fresh 3-4 pickups, not a lifetime total across all 3.
            mob:setLocalVar("reinforcementsThisFlee", 0)
            -- 2026-09-12, user-reported live: "clamp and flee engaged but invincible and warmup did
            -- not... warmup and invincible triggered but flee did not" -- root-caused via the debug
            -- log that getBattleTime()'s "now" is NOT a stable monotonic clock across an entire
            -- encounter (observed live resetting to a small value after a disengage/re-engage
            -- cycle). stepFlee()'s own internal throttle (`now < nextFleeStep`) compares against
            -- whatever `nextFleeStep` was left over from the PREVIOUS flee stage's "now" timeline --
            -- if that stale value (e.g. ~46, from a flee that ran "now" up past 70) is larger than
            -- the new stage's freshly-reset-low "now", stepFlee() returns before its body (and its
            -- own debug print) ever runs, EVERY tick, for the entire new flee -- exactly matching the
            -- observed "flee never happens" symptom despite fleeUntil/hasTarget being correct.
            -- Resetting nextFleeStep here, alongside the other fresh-flee-start resets, guarantees
            -- the very first stepFlee() call of a new stage always passes the throttle check
            -- regardless of what timeline the previous stage's "now" was on.
            mob:setLocalVar("nextFleeStep", 0)

            -- Refresh Silence to the full real duration now that the flee has actually started --
            -- see the early application above, which may have landed with less than FLEE_DURATION
            -- left by this point.
            mob:addStatusEffect(EFFECT_SILENCE, 0, 0, FLEE_DURATION)
        end
    end
end

function onMobRoam(mob)
    -- Unconditional, every tick, regardless of stage or escaping state -- must run BEFORE hpp is
    -- read inside updateEscapeState so the critical/stage-transition checks always see the
    -- clamped value, never a raw overshoot. See clampToStageFloor's own header.
    clampToStageFloor(mob)
    updateEscapeState(mob, nil)
end

function onMobFight(mob, target)
    -- Unconditional, every tick, regardless of stage or escaping state -- must run BEFORE hpp is
    -- read inside updateEscapeState so the critical/stage-transition checks always see the
    -- clamped value, never a raw overshoot. See clampToStageFloor's own header.
    clampToStageFloor(mob)
    updateEscapeState(mob, target)
end

function onMobDeath(mob, player, isKiller)
    if player and mob:getLocalVar("escaping") == 0 then
        local instance = mob:getInstance()
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
end

