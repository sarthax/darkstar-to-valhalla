-----------------------------------
-- Assault: Leujaoam Cleansing
-----------------------------------
-- Fully validated 2026-08-18 by a real Thris Nov 2025 capture, real WIN (1100 Assault points) --
-- entrance, kill-all-15 (Leujaoam Worm), and the Lockbox reward table (???_box -> remedy +
-- hi-potion +3) were all already exactly right. Assault points corrected from a 1000 guess to
-- the real 1100.
-- 2026-08-22: door-prop wiring (`_1xo`/`_1xw`/`_1xx`) originally claimed confirmed against 2 real
-- captures. STALE as of 2026-08-29: that check didn't apply the zone's -1 id-shift correction.
-- Re-verified with shift-corrected captures -- `_1xo` actually belongs to Orichalcum Survey
-- (mission 2, re-registered there) and `_1xx` actually belongs to Imperial Code (mission 8,
-- registered there in the live DB, matches shift-corrected capture position -360/-8/-378). Only
-- `_1xw` and `ROCK_PROP_1XN` (`_1xn`) are confirmed real Leujaoam Cleansing (mission 1) door
-- props. See onInstanceCreated's comment for the `_1xn` writeup.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_01_START, 1)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- 2026-09-17: applying the DSP aggro-gate fix confirmed live in Nyzul Isle (see
-- Nyzul_Isle/instances/nyzul_isle_investigation.lua's forceAggro/MOBMOD_ALWAYS_AGGRO writeup,
-- 2026-09-16). DSP's CZoneEntities::SpawnMOBs gates CanAggroTarget() on expGain > 50
-- (charutils::GetRealExp()); Assault-tier mobs give ~0 exp against endgame characters, so they
-- never validate to aggro at all (only direct-engage combat works) even though the same Lua/SQL
-- aggroes correctly on Topaz. Forcing MOBMOD_ALWAYS_AGGRO on every mob this instance spawns
-- restores real aggro behavior without touching DSP's global exp-gap formula.
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)

    for i, v in pairs(ID.mob[1]) do
        forceAggro(SpawnMob(v, instance))
    end

    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setPos(476, 8.479, 39, 49)
    box:setPos(476, 8.479, 40, 49)

    -- 2026-08-29 CORRECTED: the 2026-08-22 conclusion below was itself wrong -- it matched the
    -- raw capture id 17060143 directly against current npc_list ids without applying this zone's
    -- confirmed -1 id-shift correction. The real door for this mission's corridor (357,-7,59) is
    -- ROCK_PROP_1XN (17060142), not `_1xo` (17060143, which real capture data shows belongs to
    -- Orichalcum Survey instead -- re-registered there). This prop family needs no explicit
    -- setStatus/setAnimation override (same finding as its siblings in Shanarha Grass
    -- Conservation/Supplies Recovery) -- registration in sql/instance_entities.sql is the only
    -- thing that was missing, now added.
    --
    -- Original (wrong) 2026-08-22 note, kept for history: "removed all ROCK_PROP_1XN handling --
    -- 2 independent captures show it never appears in this mission." Those captures were real,
    -- but the id resolution used to check them wasn't shift-corrected.

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

    if (progress >= 15) then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 8, 8)
    end

    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setStatus(STATUS_NORMAL)
    box:setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

