-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Qiqirn Treasure Hunter
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/status")
require("scripts/globals/pathfind")
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
-- 2026-09-07: real fix -- "vanishes" partway along his patrol route was never scripted logic --
-- confirmed via source: CMobEntity::IsFarFromHome() (mobentity.cpp:339-341) despawns any mob more
-- than m_maxRoamDistance (default 50 yalms) from its own mob_spawn_points position once it
-- disengages, if PathTo(spawnPoint) fails (mob_controller.cpp:776-796 -- a straight PAI->Despawn()
-- call). His real spawn point (mob_spawn_points id 17080452, groupid 21) is (330.77,-4.079,
-- 416.506); his own route runs out to (219,-4,420), ~112 yalms away -- well past the leash. Same
-- fix already established elsewhere in this codebase for long-roaming mission mobs:
-- MOBMOD_NO_DESPAWN ("do not despawn when too far from spawn -- Gob Diggers have this.").
function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
end

-- 2026-09-07: real fix -- pathThrough() (lua_baseentity.cpp) always starts navigation at the
-- FIRST point of whatever table it's given -- it has no concept of "resume from here." Every
-- previous call passed the mob's full fixed patrol route unchanged, so any time the flee cycle
-- got interrupted and onMobRoamAction ran again mid-route, the mob re-targeted route point 1 and
-- beelined straight there regardless of its actual position -- user-confirmed live: normal
-- pathing otherwise, wallhacks specifically only right after a flee interrupt/resume, always
-- toward the route's first point. Finds the nearest waypoint to the mob's CURRENT position and
-- builds a resumed sub-route starting there instead, so it rejoins the patrol at the closest
-- point rather than backtracking through geometry to point 1.
--
-- 2026-09-07 (later): real fix -- a plain x/z nearest-point search picked a waypoint that's
-- geometrically close in the horizontal plane but on a completely different floor level (this
-- route's own data has one outlier: {339, 0, 460} sitting at y=0 while every other point in the
-- same loop is y=-4/-3 -- a room directly above/below, not reachable in a straight line without
-- cutting through the floor/wall between them). User-confirmed live: the mob wallhacked straight
-- to the route's last point specifically because it was horizontally closer despite being on a
-- different level. Weight y heavily (100x) so a same-level point always wins unless nothing
-- reasonably close exists on the mob's own level -- a few yalms of real vertical separation now
-- dominates the distance comparison instead of being an afterthought.
local function getResumedRoute(route, pos)
    local numPoints  = #route / 3
    local nearestIdx = 1
    local nearestDist = math.huge

    for i = 1, numPoints do
        local base = (i - 1) * 3
        local dx = route[base + 1] - pos.x
        local dy = route[base + 2] - pos.y
        local dz = route[base + 3] - pos.z
        local dist = dx * dx + (dy * dy * 100) + dz * dz
        if dist < nearestDist then
            nearestDist = dist
            nearestIdx = i
        end
    end

    local resumed = {}
    for i = nearestIdx, numPoints do
        local base = (i - 1) * 3
        table.insert(resumed, route[base + 1])
        table.insert(resumed, route[base + 2])
        table.insert(resumed, route[base + 3])
    end

    return resumed
end

function onMobRoamAction(mob)

    local instance = mob:getInstance()
    local stage = instance:getStage()
    local prog = instance:getProgress()

    -- 2026-09-05: TEMP DEBUG (treasure hunter roam investigation) -- remove once resolved.
    -- FIXED: previous version used C++'s ShowDebug(CL_CYAN "..." CL_RESET, ...) adjacent-string
    -- syntax, which is invalid in Lua (no implicit string concatenation) -- broke this whole file's
    -- caching (confirmed via log: "Load error: ... ')' expected near 'CL_RESET'"), silently undefing
    -- onMobRoamAction/onMobFight/onMobDeath for the entire test. Switched to the same plain
    -- print(string.format(...)) style already used by the real [TELEPAD DEBUG] Lua prints.
    local route = Arrapago.points[stage] and Arrapago.points[stage][prog] and Arrapago.points[stage][prog].route
    -- print(string.format("[TH ROAM DEBUG] onMobRoamAction: mob=%s stage=%d prog=%d isFollowingPath=%s route=%s",
          -- mob:getName(), stage, prog, tostring(mob:isFollowingPath()), tostring(route ~= nil)))

    if (mob:isFollowingPath() == false) then
        mob:speed(40)
        -- 2026-09-07: real fix -- getResumedRoute's nearest-point search must only apply when
        -- RESUMING a route already in progress (after a flee interrupt) -- user-confirmed live
        -- regression: on the very first roam call at spawn, straight-line distance from his real
        -- spawn point can be genuinely closer to a LATER route point across a wall/room boundary
        -- than to the route's actual first point (this route: spawn (330.77,416.5) is closer to
        -- index 4 (300,421) than index 1 (380,422)), sending him beelining/wallhacking there
        -- immediately instead of starting the patrol normally. Track whether he's actually
        -- started the route yet; only the FIRST call per spawn uses the full route from point 1.
        if mob:getLocalVar("hasStartedPatrol") == 0 then
            mob:setLocalVar("hasStartedPatrol", 1)
            mob:pathThrough(route, 9)
        else
            mob:pathThrough(getResumedRoute(route, mob:getPos()), 9)
        end
    end
end

function onMobEngaged(mob, target)

    local target = mob:getTarget()

    if (target:isPC() or target:isPet()) then
        mob:setLocalVar("runTime", os.time())
    end

end

function onMobFight(mob, target)

    local act = mob:getCurrentAction()
    local isBusy = false
    local instance = mob:getInstance()
    local stage = instance:getStage()
    local prog = instance:getProgress()
    local runTime = mob:getLocalVar("runTime")
    local popTime = mob:getLocalVar("popTime")
    local POS = mob:getPos()

    if act == ACTION_MOBABILITY_START or act == ACTION_MOBABILITY_USING or act == ACTION_MOBABILITY_FINISH or act == ACTION_MAGIC_START or act == ACTION_MAGIC_CASTING or act == ACTION_MAGIC_START then
        isBusy = true -- is set to true if mob is in any stage of using a mobskill or casting a spell
    end

    -- 2026-09-05: TEMP DEBUG (mine-drop investigation, post-roam-fix) -- remove once resolved
    -- print(string.format("[TH FIGHT DEBUG] mob=%s isFollowingPath=%s runTime_elapsed=%d popTime_elapsed=%d isBusy=%s",
          -- mob:getName(), tostring(mob:isFollowingPath()), os.time() - runTime, os.time() - popTime, tostring(isBusy)))

    if ((mob:isFollowingPath() == false) and (os.time() - runTime > 20)) then
        mob:setLocalVar("runTime", os.time())
        -- 2026-09-05: real fix -- this called a bare global `onMobRoamAction(mob)`, which doesn't
        -- exist (it's a field on the `entity` table, onMobRoamAction, not a global function).
        -- Would have thrown "attempt to call a nil value" every time this branch was reached (while
        -- engaged/fighting, 20s+ without a path). Found while adding debug instrumentation for the
        -- separate "does he roam at all" investigation -- fixed to call the real function directly.
        onMobRoamAction(mob)
    elseif (mob:isFollowingPath() == true) then
        if (os.time() - popTime > 7) then
            -- 2026-09-06: real fix -- REPLACED the SpawnMob()/DespawnMob() approach on a static
            -- pre-placed npc (mob_spawn_points 17080453/17080476) entirely. Root cause confirmed
            -- via debug: even with the correct Bomb family (poolid 6997) and allegiance=1, the
            -- mine's own isSpawned() read false on every single cycle -- something about reviving
            -- a static boot-time entity this way never stuck for this content, unlike the working
            -- Archaic Rampart pet-pop precedent (probably a different family/mechanism under the
            -- hood). Found the REAL, already-proven mechanism used for the only other working
            -- Qiqirn Mine in this codebase (scripts/zones/Lebros_Cavern/mobs/Qiqirn_Mine.lua +
            -- its companion scripts/globals/items/qiqirn_mine.lua): instance:insertAlly(groupid)
            -- dynamically constructs a brand-new CMobEntity straight from SQL (mobutils::
            -- InstantiateAlly), not resolving/reviving a pre-existing static entity at all --
            -- confirmed via C++ source this is a genuinely different code path. Reusing this
            -- zone's own existing mob_groups row (groupid 22, poolid 6997, zoneid 74) as the
            -- ally group -- no new SQL needed, insertAlly only requires mob_groups+mob_pools+
            -- mob_family_system, not a mob_spawn_points row.
            mob:setLocalVar("popTime", os.time())
            local mine = instance:insertAlly(22)
            -- 2026-09-07: TEMP DEBUG (mine-drop investigation, round 2) -- remove once resolved.
            -- The 2026-09-07 retiming fix alone made no observable difference (user report: mob
            -- engages, flee timer kicks in, resumes roam pathing, never drops anything) -- and
            -- there is currently ZERO visibility past this point: no print confirms insertAlly
            -- actually returned a real mine, nor that the ability timer ever fires. This closes
            -- that gap so the next test pinpoints exactly where the chain goes dark, instead of
            -- theorizing further with no new data.
            -- print(string.format("[MINE DEBUG] insertAlly(22) returned %s", tostring(mine ~= nil)))
            if mine then
                -- print(string.format("[MINE DEBUG] mine spawned: name=%s id=%d pos=(%.1f,%.1f,%.1f) target=%s",
                      -- mine:getName(), mine:getID(), POS.x, POS.y, POS.z, target and target:getName() or "nil"))
                mine:setSpawn(POS.x, POS.y, POS.z, POS.rot)
                mine:spawn()
                mine:updateEnmity(target)
                -- 2026-09-07: real fix -- BG Wiki: "Frequently drops Qiqirn Mines along its route
                -- which do 50 AoE damage (reduced by Shell) upon exploding." The shared
                -- mine_blast.lua formula (weapon-damage-scaled, tuned for Excavation Duty's
                -- Brittle Rock) hit ~7800 against a live player -- see mine_blast.lua's own
                -- localVar-gated override.
                mine:setLocalVar("fixedBlastDamage", 50)
                -- 2026-09-07: real fix -- skill 1838 (mine_blast)'s real mob_prepare_time is
                -- 5000ms (confirmed in sql/mob_skills.sql: (1838,253,'mine_blast',...,2000,5000,
                -- ...) -- anim_time, THEN prepare_time). useMobAbility() queues the skill through
                -- the normal TP-move flow, which waits out that full prepare time before the
                -- ability actually executes -- same real cadence already confirmed and documented
                -- in the working Lebros Cavern reference (Qiqirn_Mine.lua: "readies" fires
                -- immediately, "uses Mine Blast" only ~5s later). The previous 1000ms/4000ms
                -- timers called useMobAbility at t=1000 (so the real effect can't fire before
                -- t=6000) but then destroyed the mine via DISAPPEAR at t=4000 -- a full 2 seconds
                -- BEFORE the ability could ever execute. The mine was being deleted before Mine
                -- Blast ever went off, on every single cycle -- this is the actual "no mines
                -- dropping" bug, not a spawn failure (insertAlly itself was confirmed succeeding:
                -- no "group ID 22 not found" error in the real server log despite this branch
                -- firing repeatedly). Retimed to give the ability a real margin past its own
                -- prepare time before despawning, matching the Lebros reference's own buffer.
                mine:timer(1000, function(m)
                    -- print(string.format("[MINE DEBUG] ability timer fired: mine=%s alive=%s target=%s targetAlive=%s dist=%.1f",
                          -- m:getName(), tostring(m:isAlive()), target and target:getName() or "nil",
                          -- target and tostring(target:isAlive()) or "nil",
                          -- target and m:checkDistance(target) or -1))
                    m:useMobAbility(1838, target)
                end)
                mine:timer(7500, function(m)
                    -- print(string.format("[MINE DEBUG] despawning mine=%s alive=%s", m:getName(), tostring(m:isAlive())))
                    m:setStatus(STATUS_DISAPPEAR)
                end)
            end
        end
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (2060) in mob_groups pointing to a real mob_droplist entry (with
-- genuine TH-tiered rows already present), which the native C++ DropItems()/GetDropList() path
-- already rolls (with real Treasure Hunter support). The Lua addTreasure() calls were stacking a
-- second, TH-blind drop system on top of that -- reverted pending a full mob_droplist audit/
-- correction instead (see chat).
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    mob:setLocalVar("runTime", 0)
    mob:setLocalVar("hasStartedPatrol", 0)
end

