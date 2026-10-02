-----------------------------------
-- Assault: Escort Professor Chanoix
-----------------------------------
-- FULL REBUILD 2026-08-24, per user-provided real wiki walkthrough + the Thris Nov2025 win
-- capture already on file (1210 Assault points). Replaces the prior "clear all 16 threats" kill-
-- quota placeholder (which the same capture's own data already contradicted -- only 9 of 16 were
-- killed in a real win) with the real mechanic: Chanoix walks his own real captured path
-- completely autonomously (see mobs/Clavauert_B_Chanoix.lua for the path data, flavor dialogue,
-- and the real fail-on-death / complete-on-arrival logic); the 16 real Frozen Bones/Gelid Bhoot
-- threats are still spawned and aggro along his route exactly as in the real capture, but there
-- is no kill quota -- players just need to keep him alive to the end.
-- STILL OPEN: the wiki's Cure/Protect/Shell-only buff restriction on Chanoix isn't enforced (see
-- that file's own header) -- no existing per-mob spell-restriction hook in this codebase.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_03_START, 3)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- 2026-08-30 FIXED (round 2): the first setPos() fix only ever used DESTINATION 1's coordinates,
-- but Chanoix's own script (mobs/Clavauert_B_Chanoix.lua) rolls ONE of 2 real destinations per
-- run -- confirmed live, a real completed run using destination 2 still had the Rune sitting at
-- destination 1's spot (nowhere near where the player actually ended up). Real coordinates
-- mirrored from that file's own DESTINATIONS table -- kept in sync manually since it's a small,
-- fixed 2-entry table, not worth a shared-module require for.
-- 2026-09-14 REVERTED (live-reported, root cause found via git history, commit b492d69abb 2026-08-
-- 30): "round 3" changed destination 1 to (17.5632,-3.5,-219.4710) and then also collapsed
-- destination 2 onto that same value, believing both real destinations converged on one spot.
-- Live-tested tonight and confirmed WRONG -- that point is a plain hallway junction (next to J13)
-- BETWEEN the two real end rooms (one northeast, one southwest), not either actual destination.
-- Reverted both back to their own distinct pre-8/30 values, matching mobs/Clavauert_B_Chanoix.lua's
-- own (also-reverted) DESTINATIONS table. Provisional (best known real data) until re-verified live
-- at the actual NE/SW end rooms.
local DESTINATION_POS = {
    [1] = { x = 100.8230, y = -3.1525, z = -18.2932 },  -- capture-confirmed (pre-8/30 value, "Rune room, I-8")
    [2] = { x = -140.2350, y = -3.3098, z = -343.3171 }, -- reachable via J21 (leadsToDestination = 2)
}

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
    for i, v in pairs(ID.mob[3]) do
        forceAggro(SpawnMob(v, instance))
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)

    -- Chanoix's AI loop is driven from here (1s) instead of his own mob:timer() chain, so a
    -- Sleep/Stun that skips his AI tick can't stop it. Also acts as the external push.
    local chanoix = instance:getEntity(bit.band(ID.mob[3].CLAVAUERT_B_CHANOIX, 0xFFF), TYPE_MOB)
    -- DEBUG: report lookup problems every 10s (not every tick) so a silent miss is visible.
    if not chanoix or not chanoix:isAlive() or not ChanoixTick then
        -- if math.floor(elapsed / 1000) % 10 == 0 then
        --     print(string.format("[CHANOIX] instance tick: cannot drive AI -- entity=%s alive=%s ChanoixTick=%s (id %s, targid %s)",
        --         tostring(chanoix ~= nil), tostring(chanoix and chanoix:isAlive()), tostring(ChanoixTick ~= nil),
        --         tostring(ID.mob[3].CLAVAUERT_B_CHANOIX), tostring(bit.band(ID.mob[3].CLAVAUERT_B_CHANOIX, 0xFFF))))
        -- end
    else
        ChanoixTick(chanoix)
    end
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    -- No kill-quota completion -- Chanoix's own mob script (onMobSpawn's checkArrival tick)
    -- calls instance:complete() directly once he reaches the end of his real route.
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    -- 2026-08-30: position both the Rune and the Lockbox based on whichever destination this
    -- run's Chanoix actually rolled (see mobs/Clavauert_B_Chanoix.lua's chooseDestination()) --
    -- fixes them appearing at destination 1's spot even on a real destination-2 completion.
    local destIndex = instance:getLocalVar("chanoixDestIndex")
    local pos = DESTINATION_POS[destIndex] or DESTINATION_POS[1]

    for i, v in pairs(chars) do
        -- (8, 8)="I-8" is capture-confirmed for destination 1, and now applies to destination 2 as
        -- well since 2026-08-30's fix makes both destinations share the same real Rune location.
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 8, 8)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(pos.x, pos.y, pos.z, 0)
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    -- 2026-08-30: small fixed offset so it doesn't sit exactly on top of the Rune (no real
    -- per-entity capture position for the Lockbox at either destination) -- same convention as
    -- Imperial Treasure Retrieval's Rune/Lockbox pairing (a few yalms apart, not identical).
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(pos.x + 2, pos.y, pos.z + 3, 0)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

