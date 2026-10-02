-----------------------------------
-- Area: Leujaoam Sanctum (Orichalcum Survey)
--  Mob: Qiqirn Miner
-----------------------------------
-- 2026-08-19, user-reported: some Miners that couldn't path to the ore carrier (e.g. spawned too
-- far away or blocked by terrain) despawned entirely and never came back. Real engine behavior --
-- CMobController checks IsFarFromHome() and despawns the mob unless MOBMOD_NO_DESPAWN is set
-- (mob_controller.cpp:792). Same precedent already used for Imperial Agent Rescue's Warders and
-- Sagelord Elimination's boss. These 4 Miners are load-bearing for the mining hazard mechanic in
-- Mining_Point.lua, so losing one to a pathing-triggered despawn would permanently reduce the
-- mob count for the rest of the instance.
-----------------------------------
-- 2026-09-10 REAL BUG FOUND AND FIXED, user-reported live during regression testing: once a Miner
-- disengages after chasing the ore carrier (mob:engage(), Mining_Point.lua) -- player escapes,
-- dies, or the mission completes -- the NATIVE engine's own roam-home pathing
-- (CMobController::DoRoamTick -> PMob->PAI->PathFind->PathTo(PMob->m_SpawnPoint),
-- mob_controller.cpp:779) calls PathTo() with NO flags at all -- no PATHFLAG_WALLHACK, unlike the
-- engage-chase path a few lines below it in the same file, which does use WALLHACK and is why the
-- chase itself can "beeline" through walls when FindPath() fails (that part is normal, intended
-- engine behavior, not a bug). A Miner dragged off-mesh during that WALLHACK chase can end up
-- somewhere its own plain, no-fallback roam-home FindPath() genuinely can't route from -- and
-- since these Miners are deliberately NO_DESPAWN (see this file's own 2026-08-19 comment below --
-- they're load-bearing for the whole mining-hazard mechanic), the engine's normal
-- despawn-when-stuck safety net never kicks in either. Confirmed live: repeated
-- "CPathFind::FindPath ... could not find path" spam, same start/end coordinates every tick, end
-- coordinate an exact match for that Miner's own real spawn point (mob:getSpawnPos()) -- a
-- genuine infinite retry loop, not a scripting bug on our side. Fixed with a Lua-side stall
-- watchdog: while disengaged and meaningfully far from its own real spawn point, track whether it
-- has actually moved; after a few consecutive stalled checks, hard-teleport it home via setPos()
-- instead of leaving it to the broken native retry.
-----------------------------------
local STALL_CHECK_MS = 5000
local STALL_HOME_DISTANCE = 15.0 -- yalms -- only intervenes once genuinely far from home, not
-- during a normal short roam-home hop that would succeed on its own
local STALL_TICKS_BEFORE_TELEPORT = 3 -- ~15s of confirmed zero movement before intervening

local stallTracking = {} -- keyed by mob id -- {x, z, ticks}

local function watchdogTick(mob)
    if mob:isSpawned() and mob:isAlive() then
        if not mob:isEngaged() then
            local spawn = mob:getSpawnPos()
            local dx, dz = mob:getXPos() - spawn.x, mob:getZPos() - spawn.z
            if (dx * dx + dz * dz) > (STALL_HOME_DISTANCE * STALL_HOME_DISTANCE) then
                local id = mob:getID()
                local last = stallTracking[id]
                local x, z = mob:getXPos(), mob:getZPos()
                if last and last.x == x and last.z == z then
                    last.ticks = last.ticks + 1
                    if last.ticks >= STALL_TICKS_BEFORE_TELEPORT then
                        mob:setPos(spawn.x, spawn.y, spawn.z, spawn.rot)
                        stallTracking[id] = nil
                    end
                else
                    stallTracking[id] = { x = x, z = z, ticks = 0 }
                end
            else
                stallTracking[mob:getID()] = nil
            end
        end
        mob:timer(STALL_CHECK_MS, watchdogTick)
    end
end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    stallTracking[mob:getID()] = nil -- clear any stale tracking from a prior instance run
    mob:timer(STALL_CHECK_MS, watchdogTick)
end

function onMobDeath(mob, player, isKiller)
    stallTracking[mob:getID()] = nil
end

