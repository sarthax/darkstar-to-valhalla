-----------------------------------
-- Heroines' Holdfast (Athena Orb login-campaign battlefield), instance_list id 80
-- Source: capture #237 (Siknawz 2025.05.01), scoping in documentation/research/Heroines_Holdfast_Scoping.md
--
-- ENTRY-FLOW SKELETON ONLY -- no tier objectives, heroine mobs or rewards are built yet.
--
-- Confirmed from the capture (events resolved with mission_toolkit/explore_event.py, Nyzul_Isle;
-- toolkit entity id = capture id - 1):
--   csid 301, Rune of Transfer #1-#5 (toolkit ids 17093431-17093435 = csid 301-305):
--       "Warp to Floor ${number: 0}? (Difficulty: ${choice: 1}[1-5 stars])", Yes/No.
--       capture params for #1: (1, 0, 2964, 144, 144, 0, 3, 4095)
--   csid 306-311, hidden "Rune of Transfer ???" (toolkit ids 17093436-17093441):
--       "Warp to the heroine's chamber?" Yes/No (dialog 7567, result2=1 on Yes).
--   csid 300, zone-level (entity 2147483632) warp cutscene. capture params seen:
--       (1, 566500, -540000, 0, 2048, 0, 1, 4095) and (6, 460000, -470000, 0, 3072, 0, 1, 4095)
--       -> believed (slot, x*1000, z*1000, ?, rot*16, ...); NOT verified, do not send until decoded.
--   Zone-in: real 0x00A places the player at (460, 0, -610) rot 59, with a 15 minute limit.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/titles")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(NyzulIsle.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

function onInstanceCreated(instance)
    -- 2026-09-27: real root cause of "no mobs spawn" -- instance_loader.cpp deliberately loads
    -- instanced mobs DORMANT (status = DISAPPEAR) and never auto-Spawn()s them; that's by design,
    -- not a bug (zone_entities.cpp's SpawnMOBs skips DISAPPEAR mobs, and CBaseEntity's default
    -- ctor sets it). Other instance content activates its mobs explicitly via the Lua SpawnMob()
    -- binding -- golden_salvage.lua is the proven precedent for this exact dormant-mob pattern.
    -- All 34 of this instance's mobs already have real capture-derived positions from
    -- mob_spawn_points (confirmed via check_join.py), so unlike Golden Salvage's randomized chest
    -- placement, nothing needs setSpawn() here -- just activate every mob instance_loader.cpp
    -- already loaded for instance 80, via getMobs() (returns m_mobList regardless of status).
    for _, mob in pairs(instance:getMobs()) do
        SpawnMob(mob:getID(), instance)
    end
    tpz.heroines.initLobbyRunes(instance)
end

function onInstanceTimeUpdate(instance, elapsed)
    tpz.heroines.updateTime(instance, elapsed - instance:getLocalVar("HH_BonusMs"), NyzulIsle.text)
    tpz.heroines.cheer(instance, elapsed)
    tpz.heroines.syncRune6(instance)
    -- 2026-09-29: delayed hub-return countdown (see tpz.heroines.tickReturnToHub) -- delta is
    -- computed against the last elapsed value seen, since onInstanceTimeUpdate only hands us the
    -- cumulative total, not a per-tick delta.
    local lastElapsed = instance:getLocalVar("HH_LastElapsedMs")
    if lastElapsed > 0 then
        tpz.heroines.tickReturnToHub(instance, elapsed - lastElapsed)
        -- 2026-09-29 (user): deferred zone-72 eject after the hub-warp cutscene (see
        -- tpz.heroines.tickPendingEject / Heroine_Rune_of_Transfer.lua's csid==300 handler) -- fixes
        -- the exit not firing until another rune of transfer was used.
        tpz.heroines.tickPendingEject(instance, elapsed - lastElapsed)
        tpz.heroines.tickPendingWarp(instance, elapsed - lastElapsed)
        -- 2026-09-29 (user): Floor 6 Mumor "fake death" revive sequence (see
        -- tpz.heroines.mumorFakeDeath/tickMumorRevive) -- timed here rather than off Mumor's own
        -- onMobFight because mob:stun() replaces her AI state with CInactiveState for the duration,
        -- which suppresses onMobFight entirely (confirmed via ai_container.cpp/inactive_state.cpp).
        tpz.heroines.tickMumorRevive(instance, elapsed - lastElapsed)
        tpz.heroines.tickMumorCalls(instance, elapsed - lastElapsed)
        tpz.heroines.tickTierCalls(instance, elapsed - lastElapsed)
        tpz.heroines.tickSixLink(instance)
        tpz.heroines.tickDeathEject(instance, elapsed - lastElapsed)
    end
    instance:setLocalVar("HH_LastElapsedMs", elapsed)
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    -- 2026-09-29 (user): dialog.yml 7565 ("All party members have fallen in battle. Exiting
    -- Heroines' Holdfast.") is the confirmed real wipe notice per docs/project-memory/19-heroines-
    -- holdfast-dialog-map.md -- MISSION_FAILED is a generic Nyzul id, not this instance's own text.
    for i, v in pairs(chars) do
        v:messageSpecial(7565)
        v:startEvent(1)
    end
end

function onInstanceProgressUpdate(instance, progress)
    -- progress = heroine tiers cleared (Lion, Prishe, Nashmeira, Lilisette, Mumor each bump once)
    -- +15 min per kill: tpz.heroines.returnToHub -> extendTime (bonus subtracted in onInstanceTimeUpdate)
    tpz.heroines.queueReturnToHub(instance)
    if progress >= 5 then
        for _, v in pairs(instance:getChars()) do
            v:addTitle(UNSUNG_HEROINE)
        end
    end
end

function onInstanceComplete(instance)
    -- 2026-09-29 (user): instance:complete() (CInstance::Complete(), src/map/instance.cpp) calls
    -- luautils::OnInstanceComplete SYNCHRONOUSLY, at the exact moment complete() is called (tier-5
    -- boss death, or the Floor 6 "all heroines" clear) -- confirmed by reading Complete()'s own
    -- body. This function's old setPos(0,0,0,0,72) body would have instantly ejected every player
    -- the instant the boss died, stomping the real capture-confirmed sequence (hub-warp cutscene
    -- csid 300 -> Option 0 -> eject csid 1), which only fires after tpz.heroines.queueReturnToHub's
    -- delayed hub-return AND the player's own "Yes" ack on the hub-warp prompt. The real eject is
    -- now handled entirely by Heroine_Rune_of_Transfer.lua's csid==300/csid==1 handlers (see that
    -- file's 2026-09-29 header note) via the HH_FullClear localvar this function's caller
    -- (globals/heroines_holdfast.lua's onHeroineDeath) sets right before calling complete() -- so
    -- this hook is intentionally a no-op now.
end

