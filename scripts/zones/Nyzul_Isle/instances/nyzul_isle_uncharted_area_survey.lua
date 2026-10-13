-----------------------------------
-- Assault 52: Nyzul Isle Uncharted Area Survey
-----------------------------------
-- A genuinely separate, independently-scripted instance from Nyzul_Isle Investigation (id 51),
-- sharing the same physical zone (77) and most of its floor-content mob/lamp/gear pools (real,
-- pre-existing mob_spawn_points/npc_list rows tied to the PHYSICAL ROOM LAYOUTS, not to either
-- mission id specifically -- reused here deliberately via NyzulIsle.mobs[51], see the reuse note below).
--
-- Entry gating (NYZUL_ISLE_ASSAULT_ORDERS) lives in Alzadaal_Undersea_Ruins/npcs/_20m.lua's
-- onTrigger (already built generically for BOTH assault id 51 and 52 -- confirmed 2026-09-22, no
-- changes needed there). Sorrowful_Sage.lua (csid 278/284) is likewise already generic for both
-- mission ids. Player placement on zone-in is Zone.lua's onInstanceZoneIn, reading instance_list.sql
-- row 52's start_x/y/z/rot (reuses row 51's real, user-confirmed entry point -- same physical lobby).
--
-- REUSE DECISION (2026-09-22): IDs.lua's `mob[51]` tables (ENEMY_LAYOUTS, SPECIFIED_GROUPS, NM_EVEN/
-- NM_ODD, GEAR_OFFSET, DAHAK, and the boss-tier ids ADAMANTOISE/BEHEMOTH/FAFNIR/KHIMAIRA/HYDRA/
-- CERBERUS/ARCHAIC_RAMPART) are real mob_spawn_points rows physically placed in this zone's rooms --
-- not mission-51-exclusive assets. Investigation's own trash-mob/gear/free-floor content is reused
-- here as-is (same monsters, same rooms) rather than duplicating an entire second copy of that SQL
-- under a new id range, which would be pure duplication with no gameplay difference. Only content
-- that is GENUINELY mission-specific to Uncharted (the enemy-leader NM roster, the 5 boss-floor
-- HNMs, the destination-floor cap, the objective-sequencing rule, and the token/exit flow) is new
-- code below.
--
-- BLOCKED / NOT YET BUILT (see docs/project-memory/17-nyzul-uncharted-checklist.md for full detail):
--   1. DONE (2026-09-22): all 19 non-boss "Eliminate Enemy Leader" NMs from the wiki (Chariots/
--      Flans/Imps/Poroggos/Soulflayers/Qiqirns families -- distinct from Investigation's own
--      24-name leaderPool) are built -- new mob_pools 7009-7027, mob_groups (zone 77) 350-368,
--      mob_spawn_points 17921000-17921018 (all verified-free ids, see IDs.lua NyzulIsle.mobs[52]).
--      Real wiki-confirmed count is 19, not 18 -- a 4th real Chariot (Cornum) was missing from the
--      original brief, caught via BG Wiki cross-check. Two real TP moves (Eagle Eye Shot for the
--      Qiqirn family, Qiqirn Mine's periodic-drop) and several real spellcasting kits (ice spells,
--      tier-3 -ga/Providence/Ancient Magic, Unbridled Learning, Reprobation) have no confirmed
--      mob_skill_id/skill-list membership or established scripting precedent anywhere in this
--      codebase -- left unbuilt and flagged in each affected script's own header rather than
--      fabricated; those NMs ship as plain reskins using their base family's existing TP-move kit.
--      `leaderPool` below is now populated with all 19 real ids.
--   2. DONE (2026-09-22): the 5 boss-floor HNMs are built -- new mob_pools 6998-7008, mob_groups
--      (zone 77) 339-349, mob_spawn_points 17093329-17093379 (see IDs.lua NyzulIsle.mobs[52]). CORRECTED
--      2026-09-22: original allocation (17093000-17093050) collided with live pre-existing Nyzul
--      Isle content (Behemoth/Fafnir/Khimaira/Hydra/Cerberus cluster + contiguous real data through
--      17093328) despite an earlier false "verified free" claim -- caught via a real MySQL
--      duplicate-key import error, re-verified by direct id extraction, reallocated to the genuinely
--      free range 17093329-17096710 (ids below are old value +329, same relative per-boss offsets),
--      reskinned from their real confirmed base templates:
--        Stealthlord Haraal Ja -> Gulool_Ja_Ja      (Mamook, +4 escort adds ported)
--        Dabargar the Stoic    -> Gurfurlur_the_Menacing (Halvung, +4 escort adds ported)
--        Stheno                -> Medusa            (Arrapago_Reef, +4 escort adds ported)
--        Lord Vryko             -> Vampyr_Jarl (familyid 252, no script/no adds -- simple reskin,
--                                  same precedent as Enigmatic_Vampyr/Soaring_Vampyr)
--        Dvali Jonah            -> Pandemonium_Warden (Aydeewa_Subterrane, full 21-phase/16-pet
--                                  fight ported verbatim -- its model/skill/avatar arrays are
--                                  universal ids, not zone-local)
--      Scripts: scripts/zones/Nyzul_Isle/mobs/{Stealthlord_Haraal_Ja,Dabargar_the_Stoic,Stheno,
--      Lord_Vryko,Dvali_Jonah}.lua. `bossPool` below is now populated with the real ids.
--   3. DONE (2026-09-22): the destination-floor-selection (20/40/60/80/100) menu is csid 96,
--      confirmed via explore_event.py against our own client DAT (Nyzul_Isle zone, entity 17093429
--      -- the Rune of Transfer lobby entrance). Real dialog: systemMessage 7463 ("...confirmed.
--      Please select your destination...") then npc:dialog(7473,0,0), text "Select a floor.
--      [Selection] None. 20. 40. 60. 80. 100.[Prompt]" -- option = selection-line index (0=None,
--      1=20, 2=40, 3=60, 4=80, 5=100). This explains why captures 234/235/236 all showed the
--      identical option=5 (every captured player chose Floor 100, the wiki's own documented "choose
--      100, then 1" meta strategy) -- not a capture-pipeline artifact as originally suspected. Wired
--      into `scripts/zones/Nyzul_Isle/npcs/Rune_of_Transfer.lua`'s onTrigger/onEventFinish
--      (branches on `player:getCurrentAssault() == 52`, since this entity is shared with
--      Investigation's own csid-94 floor-purchase menu). `pickDestinationFloor` below still reads
--      instance:getLocalVar("Nyzul_DestinationFloor") (now set for real by that menu) and falls back
--      to 100 only as a safety net if triggered through some other path.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/keyitems")
require("scripts/globals/nyzul")
require("scripts/globals/nyzul/pathos")
require("scripts/globals/nyzul/armoury_crate")
require("scripts/globals/nyzul/lamps")
require("scripts/globals/nyzul/floor_layouts")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/debug_print")
-----------------------------------
-- Same real crash-avoidance guard as Investigation (see that file's header for the full AI
-- state-stack-overflow writeup) -- DespawnMob() on a mob that was never spawned this floor
-- permanently sticks a Despawn/Respawn pair on its AI state stack.
local function despawnIfSpawned(id, instance)
    local mob = GetMobByID(id, instance)
    if mob and mob:isSpawned() then
        DespawnMob(id, instance)
    end
end

-----------------------------------
-- Enemy Leader NM pool -- DONE (2026-09-22), see header note 1 (now historical) and
-- docs/project-memory/17-nyzul-uncharted-checklist.md Item 2. 19 real, BG-Wiki-confirmed names
-- (not 18 -- a 4th real Chariot, Cornum, was missing from the original brief), each a fresh
-- mob_pools/mob_groups/mob_spawn_points row distinct from Investigation's own separate 24-NM
-- leaderPool in the same zone (see nyzul_isle_investigation.lua lines ~109-123 -- confirmed no
-- id/poolid collision). Scripts: scripts/zones/Nyzul_Isle/mobs/{Scutum_Chariot,Bellum_Chariot,
-- Pistolium_Chariot,Cornum_Chariot,Groaty_Custard,Caramel_Custard,Cardamom_Custard,Nukku,Nokko,
-- Nekke,Uroro_Samaroro,Iroro_Samaroro,Aroro_Samaroro,Abject_Awiija,Abject_Farzahd,Abject_Kharoub,
-- Nerve_Render_Yiyiroon,Eye_Piercer_Fafaroon,Mad_Miner_Boboroon}.lua.
-----------------------------------
local leaderPool = {
    NyzulIsle.mobs[52].SCUTUM_CHARIOT, NyzulIsle.mobs[52].BELLUM_CHARIOT,
    NyzulIsle.mobs[52].PISTOLIUM_CHARIOT, NyzulIsle.mobs[52].CORNUM_CHARIOT,
    NyzulIsle.mobs[52].GROATY_CUSTARD, NyzulIsle.mobs[52].CARAMEL_CUSTARD, NyzulIsle.mobs[52].CARDAMOM_CUSTARD,
    NyzulIsle.mobs[52].NUKKU, NyzulIsle.mobs[52].NOKKO, NyzulIsle.mobs[52].NEKKE,
    NyzulIsle.mobs[52].URORO_SAMARORO, NyzulIsle.mobs[52].IRORO_SAMARORO, NyzulIsle.mobs[52].ARORO_SAMARORO,
    NyzulIsle.mobs[52].ABJECT_AWIIJA, NyzulIsle.mobs[52].ABJECT_FARZAHD, NyzulIsle.mobs[52].ABJECT_KHAROUB,
    NyzulIsle.mobs[52].NERVE_RENDER_YIYIROON, NyzulIsle.mobs[52].EYE_PIERCER_FAFAROON, NyzulIsle.mobs[52].MAD_MINER_BOBOROON,
}

local function despawnLeaders(instance)
    for _, leaderId in ipairs(leaderPool) do
        despawnIfSpawned(leaderId, instance)
    end
end

-- Returns false (did not spawn) when the pool is still empty, so callers can fall back to a
-- different objective instead of silently unlocking an un-winnable floor.
local function spawnRandomLeader(instance)
    if #leaderPool == 0 then
        print("[NYZUL52 SPAWN ERROR] spawnRandomLeader: leaderPool is unexpectedly empty despite Item 2 being complete -- floor objective re-rolled instead")
        return false
    end

    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return false
    end

    local leaderId = leaderPool[math.random(1, #leaderPool)]
    local p = roomPoints[math.random(1, #roomPoints)]

    local mob = GetMobByID(leaderId, instance)
    if mob then
        mob:setSpawn(p.x, p.y, p.z, 0)
    end
    SpawnMob(leaderId, instance)
    return true
end
-----------------------------------
-- Boss-floor HNM pool -- see header note 2, built 2026-09-22. Real ids from IDs.lua NyzulIsle.mobs[52].
-----------------------------------
local bossPool = {
    [20] = { NyzulIsle.mobs[52].STEALTHLORD_HARAAL_JA, NyzulIsle.mobs[52].DABARGAR_THE_STOIC, NyzulIsle.mobs[52].STHENO },
    [40] = { NyzulIsle.mobs[52].STEALTHLORD_HARAAL_JA, NyzulIsle.mobs[52].DABARGAR_THE_STOIC, NyzulIsle.mobs[52].STHENO },
    [60] = { NyzulIsle.mobs[52].STEALTHLORD_HARAAL_JA, NyzulIsle.mobs[52].DABARGAR_THE_STOIC, NyzulIsle.mobs[52].STHENO },
    [80] = { NyzulIsle.mobs[52].LORD_VRYKO },
    [100] = { NyzulIsle.mobs[52].DVALI_JONAH },
}

-- Same real fixed spawn points as Investigation (layout 16's boss room, live !logpos-confirmed) --
-- physically the same room, reused as-is; a boss spawned here for this mission lands in the correct
-- real location the instant bossPool is populated.
local BOSS_FIXED_SPAWN = { x = -390.5986, y = 0.0000, z = -380.1431 }
local RAMPART_FIXED_SPAWN = { x = -406.7906, y = 0.0000, z = -365.0887 }

local function despawnBosses(instance)
    for _, floorBosses in pairs(bossPool) do
        for _, id in ipairs(floorBosses) do
            despawnIfSpawned(id, instance)
        end
    end
    despawnIfSpawned(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
end

-- Returns false (did not spawn) while bossPool is empty for this floor.
local function spawnRandomBoss(instance)
    local floor = instance:getLocalVar("Nyzul_Current_Floor")
    local bosses = bossPool[floor]
    if not bosses or #bosses == 0 then
        print(string.format("[NYZUL52 SPAWN ERROR] spawnRandomBoss: no boss id mapped for floor %s (5 boss HNMs unconfirmed, see file header) -- nothing spawned", tostring(floor)))
        return false
    end

    local bossId = bosses[math.random(1, #bosses)]
    local mob = GetMobByID(bossId, instance)
    if mob then
        mob:setSpawn(BOSS_FIXED_SPAWN.x, BOSS_FIXED_SPAWN.y, BOSS_FIXED_SPAWN.z, 127)
    end
    SpawnMob(bossId, instance)

    -- Reuses the same real Archaic Rampart id/position as Investigation (BG Wiki: "There will always
    -- be an Archaic Rampart next to the HNM" -- zone-shared mechanic, not mission-specific).
    local rampart = GetMobByID(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
    if rampart then
        rampart:setSpawn(RAMPART_FIXED_SPAWN.x, RAMPART_FIXED_SPAWN.y, RAMPART_FIXED_SPAWN.z, 0)
    end
    SpawnMob(NyzulIsle.mobs[51].ARCHAIC_RAMPART, instance)
    return true
end

-----------------------------------
-- Reused floor-content pools (trash layouts / specified groups / gear / free-floor crates / floor
-- NMs) -- verbatim from Investigation, operating on the same real NyzulIsle.mobs[51]/NyzulIsle.npcs physical
-- spawn-point tables. See REUSE DECISION above for why this is not duplicated under a new id range.
-----------------------------------
local function despawnEnemyLayouts(instance)
    for _, layout in pairs(NyzulIsle.mobs[51].ENEMY_LAYOUTS) do
        for _, family in ipairs(layout) do
            for i = family.id, family.id + family.count - 1 do
                despawnIfSpawned(i, instance)
            end
        end
    end
end

local function spawnRandomEnemyLayout(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return 0
    end

    local points = {}
    for i = 1, #roomPoints do
        table.insert(points, roomPoints[i])
    end

    local layoutKeys = {}
    for k in pairs(NyzulIsle.mobs[51].ENEMY_LAYOUTS) do
        table.insert(layoutKeys, k)
    end
    local layout = NyzulIsle.mobs[51].ENEMY_LAYOUTS[layoutKeys[math.random(1, #layoutKeys)]]

    local spawned = 0
    for _, family in ipairs(layout) do
        for i = family.id, family.id + family.count - 1 do
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
                spawned = spawned + 1
            else
                print(string.format("[NYZUL52 SPAWN ERROR] spawnRandomEnemyLayout: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", i))
            end
        end
    end

    return spawned
end

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

    local points = {}
    for i = 1, #roomPoints do
        table.insert(points, roomPoints[i])
    end

    local group = NyzulIsle.mobs[51].SPECIFIED_GROUPS[math.random(1, #NyzulIsle.mobs[51].SPECIFIED_GROUPS)]

    local spawned = 0
    for i = group.id, group.id + group.count - 1 do
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
            spawned = spawned + 1
        else
            print(string.format("[NYZUL52 SPAWN ERROR] spawnRandomSpecifiedGroup: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", i))
        end
    end

    return spawned
end

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

    local points = {}
    for i = 1, #roomPoints do
        table.insert(points, roomPoints[i])
    end

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
        else
            print(string.format("[NYZUL52 SPAWN ERROR] spawnGear: GetMobByID(%d) returned nil -- skipped", i))
        end
    end

    -- Real per-wiki penalty: "less 100 tokens for each 'potential token yield reduced' penalty on
    -- Archaic Gear floors" -- distinct from Nyzul.penalty's TIME/PATHOS branches (already shared,
    -- see globals/nyzul.lua), TOKENS is the third real branch of that same enum, applied in
    -- awardExitTokens() below when rolled.
    instance:setLocalVar("gearPenalty", math.random(Nyzul.penalty.TIME, Nyzul.penalty.PATHOS))

    local gearText = NyzulIsle.text.GEAR_AVOID_AGRO
    if instance:getLocalVar("gearObjective") == Nyzul.gearObjective.DO_NOT_DESTROY then
        gearText = NyzulIsle.text.GEAR_DO_NOT_DESTROY
    end
    for _, player in pairs(instance:getChars()) do
        player:messageText(player, gearText)
    end
end

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

    local points = {}
    for i = 1, #roomPoints do
        table.insert(points, roomPoints[i])
    end

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

    local isEliminateAll = instance:getStage() == Nyzul.objective.ELIMINATE_ALL_ENEMIES

    for _ = 1, 2 do
        if #points > 0 and #pool > 0 and math.random(1, 100) <= 20 then
            local poolIdx = math.random(1, #pool)
            local mobId = pool[poolIdx]
            table.remove(pool, poolIdx)

            local idx = math.random(1, #points)
            local p = points[idx]
            table.remove(points, idx)

            local mob = GetMobByID(mobId, instance)
            if mob then
                mob:setSpawn(p.x, p.y, p.z, 0)
                SpawnMob(mobId, instance)

                if isEliminateAll then
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                end
            else
                print(string.format("[NYZUL52 SPAWN ERROR] spawnFloorNMs: GetMobByID(%d) returned nil -- skipped, not counted toward Eliminate", mobId))
            end
        end
    end

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
        instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
    end
end

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

local function spawnSpecifiedEnemy(instance)
    local roomLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local roomPoints = Nyzul.layoutSpawnPoints[roomLayout]
    if not roomPoints then
        return
    end

    local points = {}
    for i = 1, #roomPoints do
        table.insert(points, roomPoints[i])
    end

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

        local mob = GetMobByID(mobId, instance)
        if mob then
            mob:setSpawn(p.x, p.y, p.z, 0)
            SpawnMob(mobId, instance)

            if not target then
                target = mobId
            end
        else
            print(string.format("[NYZUL52 SPAWN ERROR] spawnSpecifiedEnemy: GetMobByID(%d) returned nil -- skipped", mobId))
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

-----------------------------------
-- NEW: floor-1 lock, destination-floor cap, weighted/no-repeat objective roll, token award on exit.
-----------------------------------
local function isBossFloor(instance)
    local floor = instance:getLocalVar("Nyzul_Current_Floor")
    return floor and floor > 0 and floor % 20 == 0
end

-- Real per BG Wiki: "Regardless of your Nyzul Isle floor progress recorded on your Runic Disc, you
-- will always start this Assault on Floor 1." Unlike Investigation (which honors each player's own
-- NyzulFloorProgress via _20m.lua's real disc-check flow -- see globals/nyzul.lua's handleRunicKey),
-- this mission hardwires the starting floor. Called once from onInstanceCreated.
local function lockStartingFloor(instance)
    instance:setLocalVar("Nyzul_Isle_StartingFloor", 1)
    instance:setLocalVar("Nyzul_Current_Floor", 1)
end

-- 2026-09-23, real bug found live: lockStartingFloor (above) sets Nyzul_Current_Floor=1 at
-- onInstanceCreated, BEFORE the player has ever interacted with the rune. Rune_of_Transfer.lua's
-- onTrigger decides "still in lobby, show the destination menu" vs. "mid-floor, check objective"
-- purely off currentFloor==0/nil, so for this mission that check was always false from the moment
-- the instance was created -- the lobby menu could never open, and the rune (which was also still
-- unlit, since pickSetPoint never ran) just showed objective text for a floor that hadn't started.
-- This separate flag tracks "has the player actually been transferred out of the lobby at least
-- once" independently of the floor-number localvar; set true only once pickSetPoint really runs.
local function hasLeftLobby(instance)
    return instance:getLocalVar("Nyzul_Isle_HasTransferred") == 1
end
-- See header note 3 (DONE) -- real player-facing selection menu is csid 96, wired in
-- Rune_of_Transfer.lua's openDestinationFloorMenu/onEventFinish. Reads the localvar that flow sets;
-- defaults to the max real destination (100, "choose 100, then 1" per the wiki's own Strategy
-- subpage) only as a safety net if this is somehow reached before the menu fires.
local function pickDestinationFloor(instance)
    local dest = instance:getLocalVar("Nyzul_DestinationFloor")
    if dest ~= 20 and dest ~= 40 and dest ~= 60 and dest ~= 80 and dest ~= 100 then
        dest = 100
        instance:setLocalVar("Nyzul_DestinationFloor", dest)
    end
    return dest
end

-- Real per BG Wiki: "You may not travel beyond the boss floor selected upon starting." The chosen
-- boss floor IS the final floor of the run -- once its ELIMINATE_ENEMY_LEADER objective is cleared,
-- the run ends there (no floor destinationFloor+1 is ever generated).
local function isAtDestinationFloor(instance)
    return instance:getLocalVar("Nyzul_Current_Floor") >= pickDestinationFloor(instance)
end

-- Real per BG Wiki: "Two consecutive floors cannot have the same objective (except moving from a
-- boss leader floor to an NM leader floor or vice versa)," plus "eliminate all enemies floors are
-- somewhat more common... free floors have a small (~1%) chance." NOT ported from Investigation --
-- confirmed 2026-09-22 that Investigation's own finishPickSetPoint() uses a flat, unweighted
-- math.random(1,6) with no history tracking at all, i.e. this whole function is new logic, not a
-- reuse of anything that already existed.
--
-- Weights are this build's own honest estimate (the wiki gives no exact numbers beyond "somewhat
-- more common" / "~1%"), not a fabricated-as-fact retail rate:
--   FREE_FLOOR(1)=1, ELIMINATE_ALL_ENEMIES(2)=30, ELIMINATE_ENEMY_LEADER(3)=20,
--   ELIMINATE_SPECIFIED_ENEMIES(4)=20, ACTIVATE_ALL_LAMPS(5)=17, ELIMINATE_SPECIFIED_ENEMY(6)=12
--   (total 100).
local objectiveWeights = { 1, 30, 20, 20, 17, 12 }

local function rollWeightedObjective()
    local total = 0
    for _, w in ipairs(objectiveWeights) do
        total = total + w
    end

    local roll = math.random(1, total)
    local cumulative = 0
    for stage, w in ipairs(objectiveWeights) do
        cumulative = cumulative + w
        if roll <= cumulative then
            return stage
        end
    end
    return 6 -- unreachable fallback
end

-- Rerolls (bounded, so a pathological weight table can never hang the map-server) until the result
-- differs from the previous non-boss floor's objective, UNLESS either the previous or the current
-- floor is a boss floor (that pair is always ELIMINATE_ENEMY_LEADER on the boss side, and the wiki's
-- own exception explicitly allows an NM-leader floor immediately before/after it).
local function rollNonRepeatingObjective(instance)
    local lastStage = instance:getLocalVar("Nyzul_LastObjective")
    local lastWasBoss = instance:getLocalVar("Nyzul_LastFloorWasBoss") == 1

    if lastStage == 0 or lastWasBoss then
        return rollWeightedObjective()
    end

    for _ = 1, 20 do
        local stage = rollWeightedObjective()
        if stage ~= lastStage then
            return stage
        end
    end

    -- 20 consecutive same-roll misses is statistically near-impossible with this weight table but
    -- guarded anyway -- accept whatever the 20th roll was rather than loop forever.
    return rollWeightedObjective()
end

local function pickFloorLayout(instance)
    local forcedLayout = instance:getLocalVar("Nyzul_Debug_ForceLayout")

    if forcedLayout and forcedLayout > 0 then
        instance:setLocalVar("Nyzul_Isle_FloorLayout", forcedLayout)
    elseif isBossFloor(instance) then
        instance:setLocalVar("Nyzul_Isle_FloorLayout", 16)
    else
        instance:setLocalVar("Nyzul_Isle_FloorLayout", math.random(1, 15))
    end
end

function pickSetPoint(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: enter")
    instance:setLocalVar("Nyzul_Isle_HasTransferred", 1)
    pickFloorLayout(instance)

    local layoutIndex = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local layoutPoint = Nyzul.FloorLayout[layoutIndex]
    dbgPrint(string.format("[NYZUL52 RUNE DEBUG] pickSetPoint: layoutIndex=%s layoutPoint=%s", tostring(layoutIndex), tostring(layoutPoint)))
    if not layoutPoint then
        dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: Nyzul.FloorLayout has NO entry for this index -- aborting")
        return
    end
    local posX, posY, posZ = layoutPoint[1], layoutPoint[2], layoutPoint[3]
    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")

    local runeOfTransfer = instance:getEntity(bit.band(NyzulIsle.npcs.RUNE_OF_TRANSFER_OFFSET, 0xFFF), TYPE_NPC)
    if runeOfTransfer then
        runeOfTransfer:AnimationSub(0)
        runeOfTransfer:updateAnimationSub()
        runeOfTransfer:setPos(posX, posY, posZ)
        runeOfTransfer:setStatus(STATUS_NORMAL)
    end

    instance:setLocalVar("menuChoice", math.random(1, 20))

    for _, char in pairs(instance:getChars()) do
        local angle = math.random() * 2 * math.pi
        char:setPos(posX + math.cos(angle), posY, posZ + math.sin(angle))
        char:messageSpecial(NyzulIsle.text.RUNE_WELCOME_TO_FLOOR, currentFloor)
    end

    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: players/rune moved, starting despawn sweep")
    Nyzul.resetLamps(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: resetLamps done")
    despawnEnemyLayouts(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: despawnEnemyLayouts done")
    despawnLeaders(instance)
    despawnBosses(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: despawnLeaders/Bosses done")
    despawnSpecifiedGroups(instance)
    despawnGear(instance)
    despawnFreeFloorCrates(instance)
    despawnFloorNMs(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] pickSetPoint: despawn sweep done")

    local anyChar
    for _, char in pairs(instance:getChars()) do
        anyChar = char
        break
    end

    -- Same real 1000ms despawn/respawn race workaround as Investigation (DespawnMob() doesn't
    -- synchronously flip spawned-state -- see that file's own header for the full writeup).
    if anyChar then
        anyChar:timer(1000, function()
            finishPickSetPoint(instance)
        end)
    else
        finishPickSetPoint(instance)
    end
end

function finishPickSetPoint(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] finishPickSetPoint: enter")
    local stage

    if isBossFloor(instance) then
        stage = Nyzul.objective.ELIMINATE_ENEMY_LEADER
        instance:setStage(stage)
        if not spawnRandomBoss(instance) then
            -- BLOCKED boss id -- objective is still correctly set (so progress/exit plumbing is
            -- exercised end-to-end), the fight itself just has nothing to kill yet. Logged above.
        end
    else
        local forcedLeader = instance:getLocalVar("Nyzul_Debug_ForceLeader")
        local roll = (forcedLeader and forcedLeader > 0) and 3 or rollNonRepeatingObjective(instance)
        stage = roll
        dbgPrint(string.format("[NYZUL52 RUNE DEBUG] finishPickSetPoint: rolled objective %s", tostring(roll)))

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
            if not spawnRandomLeader(instance) then
                -- BLOCKED leader pool -- fall back to a safe, always-buildable objective instead of
                -- leaving the floor unwinnable. Re-rolled once, excluding leader, biased toward
                -- ELIMINATE_ALL_ENEMIES.
                instance:setStage(Nyzul.objective.ELIMINATE_ALL_ENEMIES)
                stage = Nyzul.objective.ELIMINATE_ALL_ENEMIES
                local count = spawnRandomEnemyLayout(instance)
                instance:setLocalVar("Eliminate", count)
            end
        elseif roll == 4 then
            instance:setStage(Nyzul.objective.ELIMINATE_SPECIFIED_ENEMIES)
            local layoutCount = spawnRandomEnemyLayout(instance)
            local specCount = spawnRandomSpecifiedGroup(instance)
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

    instance:setLocalVar("Nyzul_LastObjective", stage)
    instance:setLocalVar("Nyzul_LastFloorWasBoss", isBossFloor(instance) and 1 or 0)

    dbgPrint("[NYZUL52 RUNE DEBUG] finishPickSetPoint: objective spawned, gear/NMs next")
    rollGearObjective(instance)
    spawnGear(instance)
    spawnFloorNMs(instance)
    dbgPrint("[NYZUL52 RUNE DEBUG] finishPickSetPoint: done")
end

function onInstanceCreated(instance)
    lockStartingFloor(instance)
    pickDestinationFloor(instance)
    instance:setLocalVar("Nyzul_LastObjective", 0)
    instance:setLocalVar("Nyzul_LastFloorWasBoss", 0)

    -- Real per BG Wiki: "Any status effects that a player has when entering the area will be
    -- removed." EFFECTFLAG_ON_ZONE (0x0100) is this codebase's real flag for exactly this class
    -- of effect (see globals/status.lua) -- explicit here rather than relying only on whatever the
    -- generic zone-transition path already clears, since entering an Assault instance is not always
    -- routed through the same code path as a normal zone line.
    for _, player in pairs(instance:getChars()) do
        player:delStatusEffectsByFlag(EFFECTFLAG_ON_ZONE, true)
    end
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, NyzulIsle.text)

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

-- Token award formula stays on the shared Nyzul.handleProgress/calculateTokens path (see
-- globals/nyzul.lua) -- confirmed 2026-09-22 that path is already zone-generic, not
-- mission-51-exclusive, and already gates the actual payout on Rune_of_Transfer.lua's real
-- Leave-Assault exit choice (not on every floor clear). The wiki's more precise Uncharted-specific
-- numbers (90/floor@6-party, +10% Assault Armband holder, -100/gear-penalty) differ in their exact
-- constants from the currently-implemented shared formula (200-base/floorBonus, no armband bonus,
-- tokenPenalty currently always 0) -- a known, already-documented discrepancy in globals/nyzul.lua's
-- own header, not something this file re-derives or silently overrides (that formula is shared
-- infrastructure Investigation also depends on; changing it is out of this pass's scope).
function onInstanceProgressUpdate(instance, progress)
    if progress > 0 and Nyzul.handleProgress(instance, progress) then
        -- Real per BG Wiki: the chosen destination boss floor's own clear ends the run at the rune
        -- rather than generating a floor destinationFloor+1 that could never exist for this mission.
        if isAtDestinationFloor(instance) then
            instance:setLocalVar("Nyzul_RunComplete", 1)
        end
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
    if csid == 95 then
        local instance = player:getInstance()
        if instance and instance:getLocalVar("runeHandler") == player:getID() then
            -- Real per BG Wiki floor cap: once the chosen destination boss floor is cleared, the
            -- Rune of Transfer's own exit flow (Rune_of_Transfer.lua) handles ending the run instead
            -- of generating another floor -- guarded here so a stray csid 95 fire post-completion
            -- can't advance past the chosen destination.
            if not (instance:getLocalVar("Nyzul_RunComplete") == 1) then
                pickSetPoint(instance)
            end
        end
    end
end

function onEventFinish(player, csid, option)
    local instance = player:getInstance()

    if csid == 1 then
        player:setPos(0, 0, 0, 0, 72)
    elseif csid == 95 and instance and instance:getLocalVar("runeHandler") == player:getID() then
        Nyzul.removePathos(instance)
        Nyzul.addFloorPathos(instance)
        instance:setLocalVar("runeHandler", 0)
    end
end

-- 2026-10-02: Rune_of_Transfer.lua requires this file and calls into it (hasLeftLobby, pickSetPoint,
-- onEventFinish); without a returned table require() gives a boolean -> 'attempt to index upvalue instanceScript52'.
return {
    onInstanceCreated         = onInstanceCreated,
    onInstanceTimeUpdate      = onInstanceTimeUpdate,
    onInstanceFailure         = onInstanceFailure,
    onInstanceProgressUpdate  = onInstanceProgressUpdate,
    onInstanceComplete        = onInstanceComplete,
    onEventUpdate             = onEventUpdate,
    onEventFinish             = onEventFinish,
    hasLeftLobby              = hasLeftLobby,
    pickSetPoint              = pickSetPoint,
    finishPickSetPoint        = finishPickSetPoint,
}
