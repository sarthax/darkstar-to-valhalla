-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Reactionary Rampart
-----------------------------------
-- 2026-09-07: real mechanic, confirmed via BG Wiki (https://www.bg-wiki.com/ffxi/Reactionary_Rampart):
-- "Will not attack or move. Once aggroed it will use Reinforcements every 12 seconds to summon a
-- monster. Summon types are based on the floor... Once the Rampart begins to summon, it will
-- slowly start to lose HP. The rate at which it loses HP is about 1% HP per summon. Up to 5
-- summons can be spawned at a time... Once defeated everyone will re-appear at the Dormant
-- Rampart." Real per-floor summon table: Floor1=Chigoe/Gate Widow(NM), Floor2=Hunting Wasp/
-- Skirmish Pephredo(NM), Floor3=Colibri/Zebra Zachary(NM), Floor4=Tragopan/Peryton(NM).
--
-- SCOPED, PARTIAL IMPLEMENTATION -- floors 1/2/3 are wired (IDs.lua has real, confirmed ids for
-- Chigoe, Hunting Wasp, and Colibri; Tragopan and all 4 NMs have no confirmed ids in this codebase
-- at all yet). Floor assignment for the 3 real REACTIONARY_RAMPART ids is NOT independently
-- confirmed beyond the first (17084692, position-confirmed West Floor 1) -- this file ASSUMES
-- IDs.lua's array order (REACTIONARY_RAMPART[1]=floor1, [2]=floor2, [3]=floor3) matches real floor
-- order, same convention used elsewhere in this codebase when no per-id floor data exists
-- otherwise. Floor 4 (no real Rampart id at all yet, needs Tragopan too) is deliberately left
-- unimplemented rather than guessed -- see IDs.lua's own "STILL OPEN" tracking for the remainder.
--
-- 2026-09-08: real fix -- Floor 1 (Chigoe) was previously left unwired over a stale concern:
-- Chigoe's real mob_spawn_points rows are all at placeholder (0,0,0), and the header used to claim
-- spawning there "would be visibly broken." That's moot -- the Reinforcements logic below already
-- repositions every summon to the Rampart's OWN live position (`local pos = m:getPos()`) before
-- spawning it, same as it already does for Floors 2/3, so Chigoe's placeholder SQL position is
-- never actually used. User confirmed via a real retail video playthrough that Floor 1's
-- Reactionary Rampart does summon Chigoe, matching BG Wiki.
--
-- The NM "rarely" summon variant is NOT implemented (no real ids for any of the 4 named NMs).
require("scripts/globals/salvage")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
-- 2026-09-08: real fix -- BG Wiki: "Will not attack or move." Nothing previously set this --
-- live-confirmed it was roaming. Same real mobMod fix already applied to Long-Bowed_Chariot.lua.
--
-- 2026-09-09: real fix -- ROAM_DISTANCE/ROAM_TURNS only suppress idle roaming (CMobEntity::
-- CanRoam/CanRoamHome, mobentity.cpp) -- live-confirmed the Rampart still moved once engaged,
-- since mob_controller.cpp's own combat movement ("attempt to teleport to target") is gated on a
-- SEPARATE flag, MOBMOD_NO_MOVE (mob_modifier.h:96, "Mob will not be able to move" -- checked at
-- mob_controller.cpp:625). This is the real, standard flag this codebase already uses for every
-- other stationary mob (Excaliace, Qiqirn_Mine, Test_Wall, etc.) -- added alongside the existing
-- roam suppression rather than replacing it.
function onMobInitialize(mob)
    mob:setMobMod(MOBMOD_ROAM_DISTANCE, 0)
    mob:setMobMod(MOBMOD_ROAM_TURNS, 0)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
end

-- Real per-floor summon pools -- only floors this codebase has confirmed ids for.
local SUMMON_POOLS = {
    [Bhaflau.mobs.REACTIONARY_RAMPART[1]] = Bhaflau.mobs.CHIGOE,        -- Floor 1
    [Bhaflau.mobs.REACTIONARY_RAMPART[2]] = Bhaflau.mobs.HUNTING_WASP,  -- assumed Floor 2 (see header)
    [Bhaflau.mobs.REACTIONARY_RAMPART[3]] = Bhaflau.mobs.COLIBRI,       -- assumed Floor 3 (see header)
}

-- 2026-09-08: real fix -- BG Wiki's "rarely" NM variant, wired for Floor 1 only (Gate Widow is the
-- only one of the 4 real NM ids the user has asked to wire so far -- Skirmish Pephredo/Zebra
-- Zachary/Peryton remain deliberately unimplemented, same as before). No real numeric rate is
-- documented anywhere -- BG Wiki only says "extremely rare" -- so the chance below (2%) is an
-- explicit, clearly-flagged placeholder, not a confirmed rate. Once it spawns, it won't be rolled
-- for again this fight (real NMs don't multi-pop within one Rampart's Reinforcements cycle).
-- 2026-09-09: real fix -- Floor 3's Reactionary Rampart confirmed by the user to also summon
-- Colibri/Zebra Zachary, matching BG Wiki exactly (SUMMON_POOLS already had Colibri wired --
-- ZEBRA_ZACHARY was the missing rare half).
local RARE_POOLS = {
    [Bhaflau.mobs.REACTIONARY_RAMPART[1]] = Bhaflau.mobs.GATE_WIDOW,     -- Floor 1
    [Bhaflau.mobs.REACTIONARY_RAMPART[3]] = Bhaflau.mobs.ZEBRA_ZACHARY,  -- Floor 3
}
local RARE_POP_CHANCE = 2 -- percent, unconfirmed placeholder -- see comment above

function onMobEngaged(mob, target)
    if mob:getLocalVar("reinforcing") == 1 then
        return
    end

    local pool = SUMMON_POOLS[mob:getID()]
    if not pool then
        -- Floor 4 Rampart (no confirmed summon pool yet) -- don't fire Reinforcements at all
        -- rather than summon nothing/guess a pool.
        return
    end

    local rareId = RARE_POOLS[mob:getID()]

    mob:setLocalVar("reinforcing", 1)
    mob:setLocalVar("activeSummons", 0)
    mob:setLocalVar("rareSpawned", 0)

    local function reinforcements(m)
        if not m:isAlive() then
            return
        end

        -- BG Wiki: "Up to 5 summons can be spawned at a time. The Rampart will continue to lose
        -- HP and use Reinforcements while all 5 summons are spawned, but no new monsters will be
        -- summoned when it uses Reinforcements."
        local active = m:getLocalVar("activeSummons")
        if active < 5 then
            local summonId = pool[math.random(1, #pool)]
            if rareId and m:getLocalVar("rareSpawned") == 0 and math.random(1, 100) <= RARE_POP_CHANCE then
                summonId = rareId
            end

            local summon = GetMobByID(summonId, m:getInstance())
            if summon and not summon:isSpawned() then
                local pos = m:getPos()
                summon:setSpawn(pos.x, pos.y, pos.z, pos.rot)
                summon:spawn()
                -- 2026-09-08: defensive fix -- target is the entity that first engaged the Rampart
                -- (onMobEngaged), captured once and reused every 12s from this closure. If it's
                -- since died/zoned/disengaged, calling updateEnmity on a stale reference could
                -- error and silently kill this entire recurring timer chain (Lua errors in a timer
                -- callback abort the function before it reschedules itself) -- which would present
                -- to a player as "the Rampart just stops spawning anything" with no visible cause.
                if target and target:isAlive() then
                    summon:updateEnmity(target)
                end
                m:setLocalVar("activeSummons", active + 1)
                if summonId == rareId then
                    m:setLocalVar("rareSpawned", 1)
                end
            end
        end

        -- BG Wiki: "it will slowly start to lose HP. The rate at which it loses HP is about 1%
        -- HP per summon" -- applies every Reinforcements use, even while capped at 5 summons.
        m:delHP(math.floor(m:getMaxHP() * 0.01))

        m:timer(12000, reinforcements)
    end

    mob:timer(12000, reinforcements)
end

-- 2026-09-08: real fix -- was hardcoded to DORMANT_RAMPART[1] (West, the only position-confirmed
-- one) regardless of which of the 3 real Reactionary Ramparts actually died, so an East-path (or
-- any non-[1]) run would return the party to the WRONG Dormant Rampart. Matches this mob's own id
-- against REACTIONARY_RAMPART to find its real array index, then reads DORMANT_RAMPART at that
-- same index -- IDs.lua's arrays are position-parallel per branch (same convention
-- Dormant_Rampart.lua's own onEventFinish now uses in the other direction).
local function findDormantId(reactionaryMobId)
    for i, id in ipairs(Bhaflau.mobs.REACTIONARY_RAMPART) do
        if id == reactionaryMobId then
            return Bhaflau.mobs.DORMANT_RAMPART[i]
        end
    end
    return nil
end

function onMobDeath(mob, player, isKiller)
    -- BG Wiki: "Once defeated everyone will re-appear at the Dormant Rampart."
    -- 2026-09-08: real fix -- was GetMobByID, but Dormant Rampart is a real NPC now (see
    -- npcs/Dormant_Rampart.lua's own conversion writeup), not a mob -- GetMobByID silently
    -- returned nil for it, so this whole teleport-back never actually ran.
    --
    -- 2026-09-08 (later): real fix -- was a silent setPos with no visual transition, inconsistent
    -- with the Dormant Rampart's own real warp (npcs/Dormant_Rampart.lua). Decoded csid 5's real
    -- bytecode via mission_toolkit/explore_event.py -- a pure fade-out/wait/fade-in sequence with
    -- no baked position data, confirmed safe to reuse here too. Delays setPos to when the screen
    -- is actually black (~3300ms, same real timing as the Dormant Rampart's own fix), same reason:
    -- an instant position change fired in the same tick as startEvent(5) looks like a second,
    -- unrelated warp once the fade plays ~2.3s later.
    local instance = mob:getInstance()
    local dormantId = instance and findDormantId(mob:getID())
    local dormant = dormantId and instance:getEntity(bit.band(dormantId, 0xFFF), TYPE_NPC)
    if dormant then
        local pos = dormant:getPos()
        local chars = instance:getChars()
        for _, char in pairs(chars) do
            char:startEvent(5)
            char:timer(3300, function(c)
                c:setPos(pos.x, pos.y, pos.z, pos.rot)
            end)
        end
    end
end

function onMobDespawn(mob)
    mob:setLocalVar("reinforcing", 0)
    mob:setLocalVar("activeSummons", 0)
    mob:setLocalVar("rareSpawned", 0)
end

