require("scripts/globals/status")
-----------------------------------
-- Area: Ilrusi Atoll (Demolition Duty)
--  Mob: Wreckage
-----------------------------------
-- 2026-08-31, real mob (converted from an untargetable npc_list prop -- see sql/mob_pools.sql's
-- own note for the full reasoning). Passive destructible obstacle, same modeling convention as
-- Imperial Agent Rescue's Dilapidated_Gate.lua: never moves, never attacks, real HP (mob_groups
-- groupid 37) takes genuine damage from the Demolition Automaton's real native combat -- see
-- mobs/Demolition_Automaton.lua, which is now just `mob:engage(wreckage:getShortID())` and lets
-- the engine handle everything (damage numbers, TP, Slapstick) for real.
-- 2026-08-31 user-reported: no death message/crumbling animation, and no passage opened once
-- destroyed. Debug logging confirmed onMobDeath WAS firing correctly (destroyedCount incremented
-- right on cue) -- the real gap was architectural: per confirmed working precedent
-- (Brittle_Rock.lua/Dilapidated_Gate.lua), a mob's OWN animation/death state never controls
-- passability at all -- a SEPARATE paired door-prop NPC does, via its own `animation` field.
-- Converting Wreckage from an NPC prop to a mob removed that paired prop entirely.
-- First fix attempt fabricated 5 new npc_list rows/ids for this -- user correctly caught that
-- entity ids in this codebase are real, client-observed values, not server-invented numbers, and
-- it was reverted. Real fix: `_jj4`/`_jj6`/`_jj7`/`_jj8`/`_jj9` (IDs.lua) are already-registered
-- real props for this exact instance, distance-matched 1:1 to Wreckage1-5 (within ~0.2-8 yalms
-- each) -- the real paired door props, just never previously wired to control anything.
-----------------------------------

-----------------------------------
local DOOR_FOR_WRECKAGE =
{
    [17002546] = 17002746,
    [17002547] = 17002748,
    [17002548] = 17002749,
    [17002549] = 17002750,
    [17002550] = 17002751,
}

local CRUMBLE_ANIMATION_DELAY_MS = 5000 -- matches Brittle_Rock.lua's own real timing (extended from an initial 3000 -- user reported the animation/SFX being cut off before finishing there)

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1) -- same real leash-despawn gap already found on the automaton -- see that file's own note
    mob:SetAutoAttackEnabled(false) -- inanimate wreckage, never fights back
    mob:setLocalVar("destroyed", 0)
    -- 2026-08-31 user-reported: real mission objective is "the automaton attacks Wreckage, players
    -- should not be able to" -- a player was able to tab-target and (presumably) attack it. Root
    -- cause: Wreckage (allegiance MOB) and the automaton (allegiance PLAYER, set in
    -- Demolition_Automaton.lua so it reads as a real ally) end up in the EXACT SAME
    -- allegiance-mismatch relationship with Wreckage as any real player does -- there was no
    -- allegiance value that could let the automaton through while blocking players, since the
    -- engine can't tell "a scripted ally" and "a real player" apart at that level (both are
    -- ALLEGIANCE_TYPE::PLAYER). Required a small, scoped C++ addition -- see
    -- src/map/entities/battleentity.cpp's own note on CBattleEntity::ValidTarget() -- this localVar
    -- is what that new check reads. Needs an engine rebuild + restart to take effect (Lua alone
    -- can't add this).
    mob:setLocalVar("playerCannotAttack", 1)
    -- 2026-08-31 user-reported: dying too fast since becoming a real mob (mob_groups groupid 37
    -- gave it level 76-78 to roughly match the automaton, but that only set its HP -- its DEF/MDEF
    -- stayed at the family/level default, so the automaton's native damage was chewing through it
    -- in a couple hits). Real precedent: Brittle_Rock.lua/Dilapidated_Gate.lua both raise
    -- DEF/MDEF this same way for the same "inanimate destructible obstacle" role rather than
    -- touching level/HP -- matches Uzhahn's own dialogue that it's "not a combat model."
    -- 2026-08-31 user-reported live-tested average: 60 dmg/hit at DEF 2200 AND at DEF 3200 --
    -- raising DEF by 45% barely moved the number, meaning DEF isn't the effective lever here
    -- (automaton's own ATT is likely far enough above Wreckage's DEF that FFXI's cRatio/pDIF curve
    -- is sitting on its floor rather than scaling with it). Reverted DEF back down and switched the
    -- primary lever to reducing the AUTOMATON's own ATT% directly instead -- see
    -- mobs/Demolition_Automaton.lua's own onMobSpawn -- a direct, predictable knob rather than
    -- fighting an unresponsive DEF curve. Kept a modest DEF bump here too (real Brittle_Rock/
    -- Dilapidated_Gate precedent value) since it's harmless, just not sufficient alone.
    mob:setMod(MOD_DEF, 2200)
    mob:setMod(MOD_MDEF, 1300)
end

function onMobDeath(mob, player, isKiller)
    -- print(string.format("[DEMOLITION DEBUG] Wreckage %u destroyed (isKiller=%s)", mob:getID(), tostring(isKiller)))

    local instance = mob:getInstance()
    if not instance then
        -- print("[DEMOLITION DEBUG] Wreckage onMobDeath: no instance found, bailing")
        return
    end
    mob:setLocalVar("destroyed", 1)
    local destroyedCount = instance:getLocalVar("wreckageDestroyed") + 1
    instance:setLocalVar("wreckageDestroyed", destroyedCount)
    -- print(string.format("[DEMOLITION DEBUG] wreckageDestroyed now %d/5", destroyedCount))

    local doorId = DOOR_FOR_WRECKAGE[mob:getID()]
    local door = doorId and instance:getEntity(bit.band(doorId, 0xFFF), TYPE_NPC)
    if not door then
        -- print(string.format("[DEMOLITION DEBUG] Wreckage %u: no paired door prop found (id=%s)", mob:getID(), tostring(doorId)))
        return
    end

    local pos = door:getPos()
    door:setAnimation(8) -- real open/passable convention, matches Brittle_Rock.lua/Dilapidated_Gate.lua
    door:timer(CRUMBLE_ANIMATION_DELAY_MS, function()
        -- print(string.format("[DEMOLITION DEBUG] Wreckage %u: door prop %u fade timer fired, setting DISAPPEAR", mob:getID(), doorId))
        door:setStatus(STATUS_DISAPPEAR)
        -- Extra safety net, same as Brittle_Rock.lua -- animation+DISAPPEAR alone wasn't always
        -- reliable there for clearing client-rendered model collision.
        door:setPos(pos.x, -500.000, pos.z, 0)
    end)
end

