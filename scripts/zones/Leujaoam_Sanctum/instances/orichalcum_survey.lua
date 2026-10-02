-----------------------------------
-- Assault: Orichalcum Survey
-- There is a rumor that orichalcum ore has been discovered in Leujaoam Sanctum.
-- Find the ore vein before the beastmen do.
-----------------------------------
-- Built out 2026-08-18 using the Solo Assault Guide by Korvana, refined the same day with
-- confirmed retail specifics: pickaxe break chance is the same MINING_BREAK_CHANCE (33%) the
-- regular overworld HELM mining system uses (scripts/globals/helm.lua), worm hazard chance
-- matches the ore chance (20%), and Qiqirn Miners are passive until the ore is found, then
-- switch hostile and chase the carrier. Core loop: Mulwahah issues a Pickaxe, Mining Points (10
-- of them, scripted in npcs/Mining_Point.lua) roll for ore/worm/break, and reporting to Mulwahah
-- with the ore completes the instance directly (npcs/Mulwahah.lua) -- no progress-counter
-- mechanic here, so onInstanceProgressUpdate is unused. Not yet tested.
--
-- 2026-08-19: the 4 Qiqirn Miners were spawned via instance:insertAlly() (PET-type, confirmed
-- untargetable by the player) at a position offset from 4 Mining Points, with their live entity
-- ids tracked via instance localvars. Switched to real pre-registered SpawnMob()-based mobs at
-- their own real positions (found unwired in sql/mob_spawn_points.sql, see IDs.lua mob[2]) --
-- static ids known ahead of time, so the localvar tracking is no longer needed either. Per a
-- user-provided FFXIclopedia walkthrough, they roam and are passive/non-hostile until the ore is
-- found (Mining_Point.lua engages them explicitly at that point), so they spawn here, immediately,
-- same as before.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_02_START, 2)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

function onInstanceCreated(instance)

    -- 2026-08-20, user-reported: real Mining Points work "like normal [HELM] mining points" --
    -- not all visible at once, cycling as points get used up or hit a hazard (see
    -- npcs/Mining_Point.lua's cyclePoint() for the real hideNPC()-based mechanism, reusing HELM's
    -- own constants). Was showing all 10 simultaneously with no cycling at all. ACTIVE_POINT_COUNT
    -- (3) is an unconfirmed estimate -- no real data exists for how many are concurrently visible
    -- in retail, just that it isn't "all of them at once."
    local ACTIVE_POINT_COUNT = 3
    local order = {}
    for i = 1, 10 do
        order[i] = i
    end
    for i = 10, 2, -1 do
        local j = math.random(i)
        order[i], order[j] = order[j], order[i]
    end
    for i = 1, 10 do
        local status = (i <= ACTIVE_POINT_COUNT) and STATUS_NORMAL or STATUS_DISAPPEAR
        instance:getEntity(bit.band(ID.npc["MINING_POINT" .. order[i]], 0xFFF), TYPE_NPC):setStatus(status)
    end

    -- 2026-08-19: was 1-4, only spawning half the real Miners -- user-reported live ("There should
    -- be more qiqirn than this"), corrected to all 8 real spawn points (see IDs.lua).
    for i = 1, 8 do
        SpawnMob(ID.mob[2]["QIQIRN_MINER" .. i], instance)
    end
    -- Mineral Eater (the real mining hazard) is deliberately NOT spawned here -- it's a singular
    -- NM, triggered on demand by Mining_Point.lua's hazard roll, not present from the start.

    -- 2026-08-19, user-reported: Rune of Release/Ancient Lockbox not where they should be.
    -- Root cause: this instance never called setPos() for either -- they sat at npc_list.sql's
    -- generic zone-default position (476, 8.479, ~39-40), ~900 units off in X alone. Real
    -- widescan-confirmed positions from a real win capture, fixed below.
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(-432.000, -27.627, 169.000, 129)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(-432.000, -27.588, 167.000, 129)
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    -- 2026-08-20, user-reported: a rock/stalactite prop sat in a closed state blocking half the
    -- map. This whole investigation (2026-08-20 through 2026-08-22) chased `_1XO`'s animation
    -- state and ran a navmesh diagnostic -- both dead ends. **Real root cause, found 2026-08-22**:
    -- `_1XO` (17060143) is not actually this corridor's blocker at all -- its `npc_list` row had
    -- been sitting at this corridor's real position (`-460.054, -32.172, 120.370`) by data-mixup
    -- coincidence (that's actually `_1XP`'s real position; see npc_list.sql/Assault_Issue_Tracker.md
    -- for the full writeup). `_1XO`'s own real identity belongs to Leujaoam Cleansing (357, -7,
    -- 59), and its `npc_list` row has been corrected there. All `_1XO`-specific handling and the
    -- temp navmesh diagnostic removed from this file -- `_1XP` (already registered below, at its
    -- own correct real position) is the actual, sole blocker for this corridor.
    -- **User-confirmed live 2026-08-22: this corridor is now passable.**
    instance:getEntity(bit.band(ID.npc._1XE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1XE, 0xFFF), TYPE_NPC):setAnimation(9)
    instance:getEntity(bit.band(ID.npc._1XF, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1XF, 0xFFF), TYPE_NPC):setAnimation(9)
    instance:getEntity(bit.band(ID.npc._1XP, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1XP, 0xFFF), TYPE_NPC):setAnimation(8)

    -- 2026-08-29: ROCK_PROP_1XO (17060143) actually belongs here, not Leujaoam Cleansing -- a
    -- 2026-08-22 pass matched its raw capture id against current npc_list ids without applying
    -- this zone's -1 id-shift correction. Its own real capture position (-460,-32,120) already
    -- matches this row's current npc_list position exactly, so no position fix was needed, just
    -- the registration/wiring. See sql/instance_entities.sql for the corrected registration.
    instance:getEntity(bit.band(ID.npc.ROCK_PROP_1XO, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ROCK_PROP_1XO, 0xFFF), TYPE_NPC):setAnimation(8)

end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    -- Unused -- completion is triggered directly by Mulwahah.lua via instance:complete()
    -- when a player reports in with the ore, not a progress count.
end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        -- 2026-08-20, user-reported: showed "C-8" instead of the real "H-8" -- letter param was 2
        -- (0-indexed A=0, so C), should be 7 (H). Encoding confirmed 0-indexed this session via
        -- Lebros Supplies' own capture (Num1={7,8,...} rendered as "(H-8)").
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 7, 8) -- H-8
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

