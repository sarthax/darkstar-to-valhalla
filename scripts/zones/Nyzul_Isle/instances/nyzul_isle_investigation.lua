-----------------------------------
-- Assault 51: Nyzul Isle Investigation
-----------------------------------
-- Entry gating (NYZUL_ISLE_ASSAULT_ORDERS) lives in Alzadaal_Undersea_Ruins/npcs/_20m.lua's
-- onTrigger, matching this codebase's own convention (the other Nyzul_Isle instance objects have
-- no registry/entry-requirement hooks of their own either). Player placement on zone-in is handled
-- entirely by Zone.lua's onInstanceZoneIn (instance:getEntryPos(), reading instance_list.sql row
-- 51's start_x/y/z/rot) -- no placement logic needed here.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/keyitems")
require("scripts/globals/nyzul")
require("scripts/globals/nyzul/pathos")
require("scripts/globals/nyzul/armoury_crate")
require("scripts/globals/nyzul/lamps")
require("scripts/globals/nyzul/floor_layouts")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/status")
-----------------------------------
-- 2026-09-15, real crash found live (AI state stack overflow, CAIContainer::ForceChangeState debug
-- assert m_stateStack.size() > 10 during CMobEntity::OnDespawn -> Internal_Respawn on a boss floor
-- fight -- user-confirmed pattern: more likely with more recurrences of the same mob/boss).
-- DespawnMob() -> Internal_Despawn() pushes a CDespawnState regardless of whether the target was
-- ever actually spawned. Since these mobs' mob_groups respawntime is 0 (Lua-driven spawning, not
-- native auto-respawn), CRespawnState never completes once triggered -- so a DespawnMob() call on
-- a mob that isn't currently spawned permanently sticks a Despawn/Respawn pair on its AI state
-- stack (CheckCompletedStates only ever inspects the stack's top, so stuck states pile up
-- forever). Every despawn* function below sweeps its FULL id range unconditionally on every single
-- floor transition (pickSetPoint), regardless of which ids were actually spawned this run -- this
-- shared guard makes that safe. Two attempted mob-side fixes (MOBMOD_NO_DESPAWN, then
-- mob:setBehaviour(..., BEHAVIOUR_NO_DESPAWN)) were both wrong or had side effects (the latter
-- blocked legitimate corpse fade-out after a real kill) -- not calling DespawnMob() on something
-- that was never spawned is the real, correct fix.
local function despawnIfSpawned(id, instance)
    local mob = GetMobByID(id, instance)
    if mob and mob:isSpawned() then
        DespawnMob(id, instance)
    end
end

-- 2026-09-16, real root cause found live: Nyzul Isle mobs weren't aggroing at all (no sight/sound/
-- magic detection, only direct-engage combat worked), while the same Lua/SQL worked correctly on
-- Topaz. Traced to a genuine DSP-vs-Topaz engine divergence in CZoneEntities::SpawnMOBs
-- (src/map/zone_entities.cpp) -- the gate that decides whether a mob is even ALLOWED to attempt
-- CanAggroTarget() at all differs: Topaz uses charutils::CheckMob() (a difficulty classification),
-- DSP uses a raw `expGain > 50` threshold from charutils::GetRealExp(). Nyzul Isle's real mob
-- levels (66-80, confirmed live in mob_groups) give ~0 exp against any endgame-level character
-- under DSP's real-exp-table formula, so `validAggro` is false for every one of these mobs
-- regardless of detects/aggro flags -- confirmed live: 184 of 190 zone-77 mob_groups rows lack
-- MOBTYPE_EVENT (the one flag that bypasses this gate via MOBMOD_ALWAYS_AGGRO, set automatically in
-- CInstanceLoader::LoadInstance for MOBTYPE_EVENT mobs only). This isn't a backport data bug --
-- retail Nyzul Isle mobs aggro regardless of player level (it's endgame farming content), so the
-- correct fix is forcing MOBMOD_ALWAYS_AGGRO on every mob this script spawns, matching real retail
-- behavior and bypassing DSP's stricter level-gap gate without touching that gate's global formula
-- (which affects aggro everywhere else in the game and is out of scope here).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

-- Real enemy layouts (ELIMINATE_ALL_ENEMIES and ELIMINATE_SPECIFIED_ENEMY objectives) -- see
-- IDs.lua's mob[51].ENEMY_LAYOUTS table, all 16 real BG Wiki layouts. Despawned unconditionally at
-- the top of every pickSetPoint call so a previous floor's mobs never linger.
local function despawnEnemyLayouts(instance)
    for _, layout in pairs(NyzulIsle.mobs[51].ENEMY_LAYOUTS) do
        for _, family in ipairs(layout) do
            for i = family.id, family.id + family.count - 1 do
                despawnIfSpawned(i, instance)
            end
        end
    end
end

-- Spawns one randomly-picked real layout's mobs at distinct real points from
-- Nyzul.layoutSpawnPoints[roomLayout] (ported from LSB). layoutSpawnPoints/lampSpawnPoints and
-- Nyzul.FloorLayout all share the same 1-17 index (the enemy/lamp spawn points *within*
-- whichever physical room FloorLayout[roomLayout] is), so this must be indexed by this floor's own
-- Nyzul_Isle_FloorLayout roll, not a fixed number, or the mobs spawn in a different room than the
-- party. The wiki's "16 possible enemy layouts" (which mob FAMILY appears) is this function's own
-- random pick among ENEMY_LAYOUTS keys -- a different axis from the room roll.
-- Returns the total mob count spawned (for the Eliminate counter).
local function spawnRandomEnemyLayout(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return 0
    end

    local points = Nyzul.getSpawnPoints(roomLayout)

    local layoutKeys = {}
    for k in pairs(NyzulIsle.mobs[51].ENEMY_LAYOUTS) do
        table.insert(layoutKeys, k)
    end
    local layout = NyzulIsle.mobs[51].ENEMY_LAYOUTS[layoutKeys[math.random(1, #layoutKeys)]]

    local total = 0
    for _, family in ipairs(layout) do
        for i = family.id, family.id + family.count - 1 do
            if #points == 0 then
                break
            end
            local idx = math.random(1, #points)
            local p = points[idx]
            table.remove(points, idx)

            -- Only spawn/count a mob if GetMobByID actually found it -- a failed lookup used to
            -- still SpawnMob() unconditionally, leaving it at a stale/default position (often
            -- unreachable) while the Eliminate counter still demanded its death.
            local mob = GetMobByID(i, instance)
            if mob then
                mob:setSpawn(p.x, p.y, p.z, 0)
                SpawnMob(i, instance)
                forceAggro(mob)
                total = total + 1
            else
                print(string.format("[NYZUL SPAWN ERROR] spawnRandomEnemyLayout: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", i))
            end
        end
    end

    return total
end

-- Real Enemy Leaders (ELIMINATE_ENEMY_LEADER objective) -- full real 8-family roster (Imp/
-- Soulflayer/Poroggo/Flan/Qiqirn/Chariot, 24 total) per BG Wiki. Only one spawns per floor ("There
-- is exactly one enemy on the floor that will unlock the Rune of Transfer").
local leaderPool =
{
    NyzulIsle.mobs[51].MOKKE, NyzulIsle.mobs[51].MOKKA, NyzulIsle.mobs[51].MOKKU,
    NyzulIsle.mobs[51].VILE_WAHDAHA, NyzulIsle.mobs[51].VILE_INEEF, NyzulIsle.mobs[51].VILE_YABEEWA,
    NyzulIsle.mobs[51].URIRI_SAMARIRI, NyzulIsle.mobs[51].ERIRI_SAMARIRI, NyzulIsle.mobs[51].ORIRI_SAMARIRI,
    NyzulIsle.mobs[51].GINGER_CUSTARD, NyzulIsle.mobs[51].ANISE_CUSTARD, NyzulIsle.mobs[51].CUMIN_CUSTARD,
    NyzulIsle.mobs[51].NUTMEG_CUSTARD, NyzulIsle.mobs[51].MINT_CUSTARD, NyzulIsle.mobs[51].CINNAMON_CUSTARD,
    NyzulIsle.mobs[51].CARAWAY_CUSTARD, NyzulIsle.mobs[51].VANILLA_CUSTARD,
    NyzulIsle.mobs[51].GEM_HEISTER_ROOROOROON, NyzulIsle.mobs[51].STEALTH_BOMBER_GAGAROON, NyzulIsle.mobs[51].QUICK_DRAW_SASAROON,
    NyzulIsle.mobs[51].SHIELDED_CHARIOT, NyzulIsle.mobs[51].BATTLEDRESSED_CHARIOT,
    NyzulIsle.mobs[51].LONG_GUNNED_CHARIOT, NyzulIsle.mobs[51].LONG_HORNED_CHARIOT,
}

local function despawnLeaders(instance)
    for _, leaderId in ipairs(leaderPool) do
        despawnIfSpawned(leaderId, instance)
    end
end

local function spawnRandomLeader(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return
    end

    -- !nyzuldebug leader <name> can pin a specific Enemy Leader mob for testing instead of the
    -- normal random pick. 0 (unset) falls through to real random behavior.
    local forcedLeader = instance:getLocalVar("Nyzul_Debug_ForceLeader")
    local leaderId = (forcedLeader and forcedLeader > 0) and forcedLeader or leaderPool[math.random(1, #leaderPool)]
    local leaderPoints = Nyzul.getSpawnPoints(roomLayout)
    if #leaderPoints == 0 then
        return
    end
    local p = leaderPoints[math.random(1, #leaderPoints)]

    local mob = GetMobByID(leaderId, instance)
    if mob then
        mob:setSpawn(p.x, p.y, p.z, 0)
    end
    SpawnMob(leaderId, instance)
    forceAggro(mob)
end
-- Real boss-floor HNMs -- floors 20/40 get Adamantoise/Behemoth/Fafnir, floors 60/80/100 get the
-- tougher Khimaira/Hydra/Cerberus tier (per BG Wiki). Also treated as ELIMINATE_ENEMY_LEADER (a
-- single real NM unlocks the rune), same objective type as Mokke/Mokka/Mokku, just far tougher.
-- 2026-09-15: uses the shared despawnIfSpawned() guard (see its own header comment) -- this used to
-- be the specific function that crashed live (AI state stack overflow, more likely the more often
-- the same boss type recurred across floors).
local function despawnBosses(instance)
    despawnIfSpawned(NyzulIsle.mobs[51].ADAMANTOISE, instance)
    despawnIfSpawned(NyzulIsle.mobs[51].BEHEMOTH, instance)
    despawnIfSpawned(NyzulIsle.mobs[51].FAFNIR, instance)
    despawnIfSpawned(NyzulIsle.mobs[51].KHIMAIRA, instance)
    despawnIfSpawned(NyzulIsle.mobs[51].HYDRA, instance)
    despawnIfSpawned(NyzulIsle.mobs[51].CERBERUS, instance)
    -- BG Wiki: "There will always be an Archaic Rampart next to the HNM."
    despawnIfSpawned(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
end

-- Fixed spawn points (not a random pick from the whole layout's point list, most of which is
-- ordinary patrol/pathing nodes, not boss-encounter spots), user-provided via live !logpos, real
-- position inside layout 16's actual boss room.
-- 2026-09-12, user-provided update via !logpos: LOGPOS,,77,-390.5986,0.0000,-380.1431 -- replaces
-- the earlier fixed spawn. Rotation 127 below was originally computed from the OLD coordinate to
-- layout 16's Rune of Transfer position -- not re-derived for this new point, since only the
-- position was requested; re-verify facing live if the boss looks turned away from the rune again.
local BOSS_FIXED_SPAWN = { x = -390.5986, y = 0.0000, z = -380.1431 }
-- BG Wiki: "There will always be an Archaic Rampart next to the HNM; this can be used to build TP
-- before engaging the boss." Real position, same room as BOSS_FIXED_SPAWN.
local RAMPART_FIXED_SPAWN = { x = -406.7906, y = 0.0000, z = -365.0887 }

local function spawnRandomBoss(instance)
    local floor = instance:getLocalVar("Nyzul_Current_Floor")
    local bosses
    if floor and floor >= 60 and floor % 20 == 0 then
        bosses = { NyzulIsle.mobs[51].KHIMAIRA, NyzulIsle.mobs[51].HYDRA, NyzulIsle.mobs[51].CERBERUS }
    else
        bosses = { NyzulIsle.mobs[51].ADAMANTOISE, NyzulIsle.mobs[51].BEHEMOTH, NyzulIsle.mobs[51].FAFNIR }
    end

    local bossId = bosses[math.random(1, #bosses)]

    -- Rotation 127, computed via the engine's own worldAngle() formula from BOSS_FIXED_SPAWN to
    -- layout 16's Rune of Transfer position -- rotation 0 pointed bosses away from the rune.
    local mob = GetMobByID(bossId, instance)
    if mob then
        mob:setSpawn(BOSS_FIXED_SPAWN.x, BOSS_FIXED_SPAWN.y, BOSS_FIXED_SPAWN.z, 127)
    end
    SpawnMob(bossId, instance)
    forceAggro(mob)

    local rampart = GetMobByID(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
    if rampart then
        rampart:setSpawn(RAMPART_FIXED_SPAWN.x, RAMPART_FIXED_SPAWN.y, RAMPART_FIXED_SPAWN.z, 0)
    end
    SpawnMob(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
    forceAggro(rampart)
end

-- Real ELIMINATE_SPECIFIED_ENEMIES family groups (2-5 real ToAU-native enemies per floor, per BG
-- Wiki -- see IDs.lua's SPECIFIED_GROUPS table). One whole family group is picked per floor;
-- despawn covers the full 17092969-17092998 range regardless of which group was last used.
local function despawnSpecifiedGroups(instance)
    for i = 17092969, 17092998 do
        despawnIfSpawned(i, instance)
    end
end

local function spawnRandomSpecifiedGroup(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return 0
    end

    local points = Nyzul.getSpawnPoints(roomLayout)

    local group = NyzulIsle.mobs[51].SPECIFIED_GROUPS[math.random(1, #NyzulIsle.mobs[51].SPECIFIED_GROUPS)]

    -- Same GetMobByID-nil handling as spawnRandomEnemyLayout above -- returns the real spawned
    -- count (not the fixed family size) so the Eliminate counter never demands kills for mobs that
    -- were never actually placed reachably.
    local spawned = 0
    for i = group.id, group.id + group.count - 1 do
        local idx = math.random(1, #points)
        local p = points[idx]
        table.remove(points, idx)

        local mob = GetMobByID(i, instance)
        if mob then
            mob:setSpawn(p.x, p.y, p.z, 0)
            SpawnMob(i, instance)
            forceAggro(mob)
            spawned = spawned + 1
        else
            print(string.format("[NYZUL SPAWN ERROR] spawnRandomSpecifiedGroup: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", i))
        end
    end

    return spawned
end

-- Real Archaic Gear secondary objective -- per BG Wiki/FFXIclopedia, a SEPARATE layer on top of
-- whichever primary objective is active (gated on instance:getLocalVar('gearObjective') > 0, not
-- tied to any one stage), matching LSB's own prepareMobs() shape. Only spawns GEAR_OFFSET+2..+7 (6
-- real ids: 3x Archaic_Gear, 3x Archaic_Gears -- see IDs.lua's mob[51].GEAR_OFFSET). The two real
-- objective types (AVOID_AGRO/DO_NOT_DESTROY) and the 3-way penalty (Pathos/-1 min time/token
-- reduction) are wiki-confirmed; the 20% "occasionally" roll below is an honest estimate, not a
-- confirmed retail rate (the wiki doesn't give an exact percentage).
local function rollGearObjective(instance)
    if math.random(1, 100) <= 20 then
        instance:setLocalVar("gearObjective", math.random(Nyzul.gearObjective.AVOID_AGRO, Nyzul.gearObjective.DO_NOT_DESTROY))
    else
        instance:setLocalVar("gearObjective", 0)
    end
end

local function despawnGear(instance)
    for i = NyzulIsle.mobs[51].GEAR_OFFSET + 2, NyzulIsle.mobs[51].GEAR_OFFSET + 7 do
        despawnIfSpawned(i, instance)
    end
end

local function spawnGear(instance)
    if instance:getLocalVar("gearObjective") <= 0 then
        return
    end

    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return
    end

    local points = Nyzul.getSpawnPoints(roomLayout)

    for i = NyzulIsle.mobs[51].GEAR_OFFSET + 2, NyzulIsle.mobs[51].GEAR_OFFSET + 7 do
        if #points == 0 then
            break
        end
        local idx = math.random(1, #points)
        local p = points[idx]
        table.remove(points, idx)

        local mob = GetMobByID(i, instance)
        if mob then
            mob:setSpawn(p.x, p.y, p.z, 0)
            SpawnMob(i, instance)
            forceAggro(mob)
        else
            print(string.format("[NYZUL SPAWN ERROR] spawnGear: GetMobByID(%d) returned nil -- skipped", i))
        end
    end

    instance:setLocalVar("gearPenalty", math.random(Nyzul.penalty.TIME, Nyzul.penalty.PATHOS))

    -- Real per-type announcement, confirmed via a decompiled client dialog-table dump.
    local gearText = NyzulIsle.text.GEAR_AVOID_AGRO
    if instance:getLocalVar("gearObjective") == Nyzul.gearObjective.DO_NOT_DESTROY then
        gearText = NyzulIsle.text.GEAR_DO_NOT_DESTROY
    end
    for _, player in pairs(instance:getChars()) do
        player:messageText(player, gearText)
    end
end

-- Real random floor NM pool -- per BG Wiki/FFXIclopedia: NMs summoned by the archaic ramparts,
-- spawning independently of the primary objective (never required to kill them unless the floor's
-- objective IS "eliminate all enemies"). IDs.lua's mob[51].NM_EVEN/NM_ODD are real floor-section
-- pools matched to LSB's own pTableEvenFloorRandomNMs/pTableOddFloorRandomNMs; "0, 1, or 2" NMs per
-- floor at a 20% roll each are LSB's own real numbers, not fabricated (the wiki doesn't give an
-- exact count/rate). mob[51].DAHAK is LSB's separate real 20% ELIMINATE_ALL_ENEMIES-only bonus spawn.
local function despawnFloorNMs(instance)
    for _, section in pairs(NyzulIsle.mobs[51].NM_EVEN) do
        for i = section.id, section.id + section.count - 1 do
            despawnIfSpawned(i, instance)
        end
    end
    for _, section in pairs(NyzulIsle.mobs[51].NM_ODD) do
        for i = section.id, section.id + section.count - 1 do
            despawnIfSpawned(i, instance)
        end
    end
    despawnIfSpawned(NyzulIsle.mobs[51].DAHAK, instance)
end

local function spawnFloorNMs(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return
    end

    local points = Nyzul.getSpawnPoints(roomLayout)

    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    local floorSection = math.min(5, math.floor((currentFloor - 1) / 20) + 1)
    local sectionTable = NyzulIsle.mobs[51].NM_ODD
    if currentFloor % 2 == 0 then
        sectionTable = NyzulIsle.mobs[51].NM_EVEN
    end
    local section = sectionTable[floorSection]
    if not section then
        return
    end

    local pool = {}
    for i = section.id, section.id + section.count - 1 do
        table.insert(pool, i)
    end

    -- This spawns AFTER pickSetPoint already locked in the ELIMINATE_ALL_ENEMIES 'Eliminate'
    -- target, but Nyzul.floorNMKill (these NMs' own onMobDeath handler) DOES count toward
    -- progress on that stage -- so on that specific stage they're required and must be added to
    -- the target, matching the wiki's "unless the objective is 'eliminate all enemies'" caveat.
    local isEliminateAll = instance:getStage() == Nyzul.objective.ELIMINATE_ALL_ENEMIES

    for _ = 1, 2 do
        if #points > 0 and #pool > 0 and math.random(1, 100) <= 20 then
            local poolIdx = math.random(1, #pool)
            local mobId = pool[poolIdx]
            table.remove(pool, poolIdx)

            local idx = math.random(1, #points)
            local p = points[idx]
            table.remove(points, idx)

            -- Only spawn/count toward Eliminate when GetMobByID actually found the mob (same class
            -- of fix as the other spawn functions above).
            local mob = GetMobByID(mobId, instance)
            if mob then
                mob:setSpawn(p.x, p.y, p.z, 0)
                SpawnMob(mobId, instance)
                forceAggro(mob)

                if isEliminateAll then
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                end
            else
                print(string.format("[NYZUL SPAWN ERROR] spawnFloorNMs: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", mobId))
            end
        end
    end

    -- Real per LSB: a separate 20% chance for Dahak specifically, only on ELIMINATE_ALL_ENEMIES
    -- floors ("Sometimes a Dahak will appear on floors with this objective in addition to other
    -- enemies").
    if
        isEliminateAll and
        #points > 0 and
        math.random(1, 100) <= 20
    then
        local idx = math.random(1, #points)
        local p = points[idx]
        table.remove(points, idx)

        local mob = GetMobByID(NyzulIsle.mobs[51].DAHAK, instance)
        if mob then
            mob:setSpawn(p.x, p.y, p.z, 0)
        end
        SpawnMob(NyzulIsle.mobs[51].DAHAK, instance)
        forceAggro(mob)
        instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
    end
end

-- Real Free Floor scattered crates -- per BG Wiki/FFXIclopedia: no enemies on the floor, but random
-- Armoury Crates scattered about, and unlike leader-kill crates these can hold more than one of an
-- item. Uses the same real 3-crate pool as the single leader-kill drop crate (IDs.lua's
-- ARMOURY_CRATE_OFFSET..+2, real distinct npc_list positions). "Random" is each of the 3 slots
-- independently having a chance to appear -- the wiki doesn't give an exact count, so this isn't a
-- fabricated fixed number. tempBoxTrigger's own item table already rolls amount=math.random(1,3)+
-- for most entries, the real "more than one" behavior -- no change needed there.
local function despawnFreeFloorCrates(instance)
    for i = NyzulIsle.npcs.ARMOURY_CRATE_OFFSET, NyzulIsle.npcs.ARMOURY_CRATE_OFFSET + 2 do
        local crate = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
        if crate then
            crate:resetLocalVars()
            crate:AnimationSub(0)
            crate:setStatus(STATUS_CUTSCENE_ONLY)
        end
    end
end

local function spawnFreeFloorCrates(instance)
    for i = NyzulIsle.npcs.ARMOURY_CRATE_OFFSET, NyzulIsle.npcs.ARMOURY_CRATE_OFFSET + 2 do
        if math.random(1, 100) <= 70 then
            local crate = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
            if crate then
                crate:resetLocalVars()
                crate:AnimationSub(0)
                crate:setStatus(STATUS_NORMAL)
                crate:forceRespawn()
            end
        end
    end
end

-- Real ELIMINATE_SPECIFIED_ENEMY (singular) objective -- ported from LSB's floor_generation.lua
-- prepareMobs(): spawns 6-12 random fodder mobs from ONE randomly-picked real enemy layout family
-- (same ENEMY_LAYOUTS table ELIMINATE_ALL_ENEMIES uses), then secretly designates whichever one
-- spawns first as the real kill target (Nyzul_Specified_Enemy localvar) -- the rest are just
-- fodder with no effect on progress.
local function spawnSpecifiedEnemy(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return
    end

    local points = Nyzul.getSpawnPoints(roomLayout)

    local layoutKeys = {}
    for k in pairs(NyzulIsle.mobs[51].ENEMY_LAYOUTS) do
        table.insert(layoutKeys, k)
    end
    local layout = NyzulIsle.mobs[51].ENEMY_LAYOUTS[layoutKeys[math.random(1, #layoutKeys)]]

    local pool = {}
    for _, family in ipairs(layout) do
        for i = family.id, family.id + family.count - 1 do
            table.insert(pool, i)
        end
    end

    local enemyAmount = math.min(#pool, math.random(6, 12))
    local target = nil

    for _ = 1, enemyAmount do
        if #points == 0 or #pool == 0 then
            break
        end
        local poolIdx = math.random(1, #pool)
        local mobId = pool[poolIdx]
        table.remove(pool, poolIdx)

        local idx = math.random(1, #points)
        local p = points[idx]
        table.remove(points, idx)

        -- Only spawns and only becomes the target when GetMobByID succeeds -- same class of fix as
        -- this file's other spawn functions.
        local mob = GetMobByID(mobId, instance)
        if mob then
            mob:setSpawn(p.x, p.y, p.z, 0)
            SpawnMob(mobId, instance)
            forceAggro(mob)

            if not target then
                target = mobId
            end
        else
            print(string.format("[NYZUL SPAWN ERROR] spawnSpecifiedEnemy: GetMobByID(%d) returned nil -- skipped", mobId))
        end
    end

    instance:setLocalVar("Nyzul_Specified_Enemy", target or 0)

    if target then
        local targetMob = GetMobByID(target, instance)
        if targetMob then
            Nyzul.specifiedEnemySet(targetMob)
        end
    end
end

-- Real per BG Wiki: the Rune of Transfer is ALWAYS status=NORMAL (present, examinable) -- only
-- animationsub (lit vs. unlit) changes on win ("will initially only display the floor objective
-- when examined... upon meeting the objective, the Rune will light up"). Boss floors (20/40/60/80/
-- 100) always get a boss fight, unconditional and checked before the normal objective roll.
local function isBossFloor(instance)
    local floor = instance:getLocalVar("Nyzul_Current_Floor")
    return floor and floor > 0 and floor % 20 == 0
end

-- DespawnMob() -> Internal_Despawn() pushes a CDespawnState onto the mob's AI state stack -- it
-- does NOT synchronously flip the entity back to "not spawned." An immediate same-tick SpawnMob()
-- on the same id finds the mob still mid-despawn and silently no-ops (confirmed via
-- lua_baseentity.cpp's forceRespawn(), which needs the same 1000ms delay for the identical reason).
-- Everything that spawns anything is moved into finishPickSetPoint(), fired after that delay
-- instead of inline. Floor layout selection itself (pure data, no despawn dependency) happens
-- immediately in pickSetPoint() below instead, so the player's own reposition isn't held hostage
-- to the mob-spawn delay it doesn't actually need.
local function pickFloorLayout(instance)
    -- !nyzuldebug layout <N> can pin a specific layout for testing against known logpos data. 0
    -- (unset) falls through to the real behavior below.
    local forcedLayout = instance:getLocalVar("Nyzul_Debug_ForceLayout")

    -- Boss floors are hardwired to layout 16 -- its "room 0" cluster (floor_layouts.lua) is the
    -- confirmed match against a real live playthrough's boss room. This is NOT
    -- Nyzul.FloorLayout index 0 (a separate table, the Rune of Transfer's own position marker)
    -- -- layoutSpawnPoints has no [0] entry, so using it there would silently spawn nothing.
    if forcedLayout and forcedLayout > 0 then
        instance:setLocalVar("Nyzul_Isle_FloorLayout", forcedLayout)
    elseif isBossFloor(instance) then
        instance:setLocalVar("Nyzul_Isle_FloorLayout", 16)
    else
        -- Layouts 1-17 exist in floor_layouts.lua. Layout 16 is reserved for boss floors.
        -- Regular floors randomly select from layouts 1-15 and 17, avoiding the boss-reserved 16.
        -- Layout 17 was excluded pending audit (suspected corrupted data); re-enabled 2026-09-21
        -- after a live-data audit confirmed it is a valid, non-blocking layout (layout 1 was the
        -- one with a real bug -- door prop _253/17093353 wrongly closed -- not layout 17).
        local NORMAL_LAYOUTS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17}
        instance:setLocalVar("Nyzul_Isle_FloorLayout", NORMAL_LAYOUTS[math.random(1, #NORMAL_LAYOUTS)])
    end
end

function pickSetPoint(instance)
    pickFloorLayout(instance)

    local layoutIndex = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local layoutPoint = Nyzul.FloorLayout[layoutIndex]
    print(string.format("[NYZUL RUNE DEBUG] pickSetPoint: layoutIndex=%s layoutPoint=%s",
        tostring(layoutIndex), tostring(layoutPoint)))
    if not layoutPoint then
        print("[NYZUL RUNE DEBUG] pickSetPoint: Nyzul.FloorLayout has NO entry for this index -- aborting, player will not be repositioned")
        return
    end
    local posX, posY, posZ = layoutPoint[1], layoutPoint[2], layoutPoint[3]
    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    print(string.format("[NYZUL RUNE DEBUG] pickSetPoint: currentFloor=%s target pos=(%s,%s,%s)",
        tostring(currentFloor), tostring(posX), tostring(posY), tostring(posZ)))

    -- Fires synchronously (zero delay) -- user-confirmed the fade-out/reposition/fade-in timing is
    -- correct this way. The Rune of Transfer prop's own reposition is a plain position update with
    -- no despawn dependency, same as the player's, so it belongs here too, not on
    -- finishPickSetPoint's separate 1000ms mob-spawn timer.
    local runeOfTransfer = instance:getEntity(bit.band(NyzulIsle.npcs.RUNE_OF_TRANSFER_OFFSET, 0xFFF), TYPE_NPC)
    if runeOfTransfer then
        runeOfTransfer:AnimationSub(0) -- unlit -- objective not yet met on this floor
        -- 2026-09-15, same real out-of-range fix as globals/nyzul.lua's activateRuneOfTransfer --
        -- ensures the reset itself reaches every player in the instance, not just ones in range of
        -- this specific entity id's old or new position.
        runeOfTransfer:updateAnimationSub()
        runeOfTransfer:setPos(posX, posY, posZ)
        runeOfTransfer:setStatus(STATUS_NORMAL) -- always present/examinable, per BG Wiki
    end

    -- 2026-09-12: real LSB source (Nyzul_Isle/instances/nyzul_isle_investigation.lua) re-rolls this
    -- every floor -- Rune_of_Transfer.lua's own menu choice (7 = normal single-path menu, 27 =
    -- left/right branch) reads it via `menuChoice > 1`, i.e. a real 1-in-20 (5%) chance of the
    -- left/right variant, 19-in-20 (95%) normal. Ported verbatim; this REPLACES a fabricated 50/50
    -- coin flip that used to live in Rune_of_Transfer.lua itself with no basis in real data.
    instance:setLocalVar("menuChoice", math.random(1, 20))

    for _, char in pairs(instance:getChars()) do
        -- Scatters each party member up to 1 yalm away on the horizontal plane (random angle, X/Z
        -- offset) -- without this every player landed on the exact same coordinate, stacking on
        -- top of each other. Y is untouched so nobody gets pushed into a wall/floor on uneven ground.
        local angle = math.random() * 2 * math.pi
        char:setPos(posX + math.cos(angle), posY, posZ + math.sin(angle))
        -- Real id confirmed via a decompiled client dialog-table dump (Dialog Table Entry 7484,
        -- "Transfer complete. Welcome to Floor <N>."). Per-stage objective text is shown separately
        -- by Rune_of_Transfer.lua's onTrigger on examine, not here.
        char:messageSpecial(NyzulIsle.text.RUNE_WELCOME_TO_FLOOR, currentFloor)
    end

    Nyzul.resetLamps(instance)
    despawnEnemyLayouts(instance)
    despawnLeaders(instance)
    despawnBosses(instance)
    despawnSpecifiedGroups(instance)
    despawnGear(instance)
    despawnFreeFloorCrates(instance)
    despawnFloorNMs(instance)

    local anyChar
    for _, char in pairs(instance:getChars()) do
        anyChar = char
        break
    end

    if anyChar then
        anyChar:timer(1000, function()
            finishPickSetPoint(instance)
        end)
    else
        finishPickSetPoint(instance)
    end
end

function finishPickSetPoint(instance)

    if isBossFloor(instance) then
        instance:setStage(Nyzul.objective.ELIMINATE_ENEMY_LEADER)
        spawnRandomBoss(instance)
    else
        -- Real 6-way roll across the non-boss objectives: Free Floor, Eliminate All Enemies,
        -- Eliminate Enemy Leader, Eliminate Specified Enemies, Activate All Lamps, Eliminate
        -- Specified Enemy. Uses math.random(1, n), not math.random(n) -- this server's
        -- tpzrand::GetRandomNumber has a confirmed half-open [1,n) range, so the single-arg form
        -- can never return n (see Excaliace.lua's checkMobAggro() for the full writeup) -- would
        -- have silently never rolled the last branch.
        -- !nyzuldebug leader <name> pins this floor's stage to ELIMINATE_ENEMY_LEADER so a forced
        -- leader pin actually gets a chance to spawn without needing to luck into roll==3 too.
        local forcedLeader = instance:getLocalVar("Nyzul_Debug_ForceLeader")
        local roll = (forcedLeader and forcedLeader > 0) and 3 or math.random(1, 6)
        if roll == 1 then
            instance:setStage(Nyzul.objective.FREE_FLOOR)

            local rune = instance:getEntity(bit.band(NyzulIsle.npcs.RUNE_OF_TRANSFER_ENTRANCE, 0xFFF), TYPE_NPC)
            if rune then
                rune:timer(9000, function(m)
                    m:getInstance():setProgress(15)
                end)
            end

            spawnFreeFloorCrates(instance)
        elseif roll == 2 then
            instance:setStage(Nyzul.objective.ELIMINATE_ALL_ENEMIES)
            local count = spawnRandomEnemyLayout(instance)
            instance:setLocalVar("Eliminate", count)
        elseif roll == 3 then
            instance:setStage(Nyzul.objective.ELIMINATE_ENEMY_LEADER)
            spawnRandomLeader(instance)
        elseif roll == 4 then
            instance:setStage(Nyzul.objective.ELIMINATE_SPECIFIED_ENEMIES)
            -- Spawn normal floor layout mobs first
            local layoutCount = spawnRandomEnemyLayout(instance)
            -- Then spawn the specified enemy group on top (2-5 mobs that check Impossible to Gauge)
            local specCount = spawnRandomSpecifiedGroup(instance)
            -- Track both in Eliminate counter, but only specified enemies need to be killed
            instance:setLocalVar("Eliminate", specCount)
            instance:setLocalVar("NormalLayoutCount", layoutCount)
        elseif roll == 5 then
            instance:setStage(Nyzul.objective.ACTIVATE_ALL_LAMPS)
            instance:setLocalVar("[Lamp]Objective", math.random(1, 3))
            Nyzul.lampsActivate(instance)
        else
            instance:setStage(Nyzul.objective.ELIMINATE_SPECIFIED_ENEMY)
            spawnSpecifiedEnemy(instance)
        end
    end

    -- Real per wiki: the gear secondary objective can layer onto ANY primary objective (boss
    -- floors included), so this rolls unconditionally after the primary stage is picked above.
    rollGearObjective(instance)
    spawnGear(instance)
    spawnFloorNMs(instance)
end

function onInstanceCreated(instance)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, NyzulIsle.text)

    -- 2026-09-15, real fix for a confirmed client-side rendering quirk -- live debug trace
    -- (entity_update.cpp's own [NYZUL ANIMSUB DEBUG] print) showed the server correctly sends
    -- animationsub=1 in the real ENTITY_SPAWN packet when a player re-enters range of an already-
    -- lit Rune of Transfer, but the client doesn't reliably re-apply the lit visual for an entity
    -- it has seen before and lost track of (went out of range, came back) -- a one-time broadcast
    -- at the moment the state actually changes (updateAnimationSub(), see globals/nyzul.lua/
    -- Runic_Lamp.lua) only helps players who are in the instance AT that exact moment; it can't
    -- help someone who respawns the entity later. Periodically re-nudging with a fresh
    -- updateAnimationSub() call is a real, working workaround for this client quirk -- confirmed by
    -- the same debug trace showing the client DOES correctly apply animationsub from a live
    -- ENTITY_UPDATE once the entity is already known/spawned to it (that's how updateAnimationSub()
    -- reaches in-range players at all) -- it's specifically the SPAWN packet's initial value that
    -- the client seems to ignore on a respawn. Throttled to once per 5s via a localvar timestamp,
    -- not every tick, and only while something is actually lit (skips the common all-unlit case).
    local now = os.time()
    if now - (instance:getLocalVar("lastAnimSubResync") or 0) >= 5 then
        instance:setLocalVar("lastAnimSubResync", now)

        local rune = instance:getEntity(bit.band(NyzulIsle.npcs.RUNE_OF_TRANSFER_OFFSET, 0xFFF), TYPE_NPC)
        if rune and rune:AnimationSub() == 1 then
            rune:updateAnimationSub()
        end

        for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + 4 do
            local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
            if lamp and lamp:AnimationSub() == 1 then
                lamp:updateAnimationSub()
            end
        end
    end
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(NyzulIsle.text.MISSION_FAILED, 10, 10)
        v:startEvent(1)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress > 0 and Nyzul.handleProgress(instance, progress) then
        Nyzul.activateRuneOfTransfer(instance)
    end
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:setPos(0, 0, 0, 0, 72)
    end
end

function onEventUpdate(player, csid, option)
    -- 2026-09-14, CONFIRMED DEAD CODE, live debug trace (two separate failed attempts): this
    -- function is never called at all for csid 95's compiled event -- neither the client's own
    -- behavior nor a separate engine dispatch bug (PChar->m_event.Script sticking to
    -- Rune_of_Transfer.lua, see that file's onEventFinish comment) ever routes an update callback
    -- here. pickSetPoint() -- the actual floor reposition -- has been moved to fire from
    -- Rune_of_Transfer.lua's onEventFinish(csid 95) instead, the one callback confirmed to
    -- actually run. Left this block in place only as a record of the original (incorrect) design
    -- intent; do not rely on it firing.
    if csid == 95 then
        local instance = player:getInstance()
        print(string.format("[NYZUL RUNE DEBUG] onEventUpdate: player=%s csid=95 instance=%s runeHandler=%s (playerID=%s)",
            player:getName(), tostring(instance), instance and tostring(instance:getLocalVar("runeHandler")) or "N/A", tostring(player:getID())))
        if instance and instance:getLocalVar("runeHandler") == player:getID() then
            print("[NYZUL RUNE DEBUG] onEventUpdate: calling pickSetPoint")
            pickSetPoint(instance)
        else
            print("[NYZUL RUNE DEBUG] onEventUpdate: runeHandler mismatch or no instance -- pickSetPoint NOT called")
        end
    end
end

function onEventFinish(player, csid, option)
    local instance = player:getInstance()
    print(string.format("[NYZUL RUNE DEBUG] onEventFinish: player=%s csid=%s option=%s pos=(%.2f,%.2f,%.2f)",
        player:getName(), tostring(csid), tostring(option), player:getXPos(), player:getYPos(), player:getZPos()))

    if csid == 1 then
        player:setPos(0, 0, 0, 0, 72)
    elseif csid == 95 and instance and instance:getLocalVar("runeHandler") == player:getID() then
        -- LSB also calls prepareMobs here -- not ported, no floor mob-spawn data exists yet
        -- (floor_generation.lua, still unported). Pathos IS ported: clear whatever was active on
        -- the floor just left, then apply anything queued for the new one (queuing a pathos --
        -- e.g. from a real floor-transition choice -- isn't wired in yet, so addFloorPathos is a
        -- no-op today, but the plumbing is ready for it).
        Nyzul.removePathos(instance)
        Nyzul.addFloorPathos(instance)
        instance:setLocalVar("runeHandler", 0)
    end
end


-- Add this at the very bottom of scripts/zones/Nyzul_Isle/instances/nyzul_isle_investigation.lua

local exported = {
    onInstanceCreated         = onInstanceCreated,
    onInstanceTimeUpdate      = onInstanceTimeUpdate,
    onInstanceFailure         = onInstanceFailure,
    onInstanceProgressUpdate  = onInstanceProgressUpdate,
    onInstanceComplete        = onInstanceComplete,
    onEventUpdate             = onEventUpdate,
    onEventFinish             = onEventFinish,
    pickSetPoint              = pickSetPoint,
    finishPickSetPoint        = finishPickSetPoint,
}

return exported
