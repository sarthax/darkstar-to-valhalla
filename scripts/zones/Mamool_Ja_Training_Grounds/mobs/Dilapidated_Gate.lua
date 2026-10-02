require("scripts/globals/status")
-----------------------------------
-- Area: Mamool Ja Training Grounds (Imperial Agent Rescue)
--  Mob: Dilapidated Gate
-----------------------------------
-- Destructible obstacle, not a real combatant -- modeled on Brittle_Rock.lua (Excavation Duty).
-- On death, the paired door NPC is hidden to represent the gate having been broken through.
-- Door pairing (GATE_1/_ju3, GATE_2/_ju5, GATE_3/_ju7) confirmed 2026-08-18 by exact x/z position
-- match against real npc_list.sql/mob_spawn_points.sql data (each gate mob spawns at the same
-- x/z as its paired door prop). Each pen also has a Pot Hatch with a 1-in-3 chance of containing
-- Brujeel -- see npcs/_pot_hatch_common.lua and instances/imperial_agent_rescue.lua.
-----------------------------------

-----------------------------------
function onMobSpawn(mob)
    mob:addMod(MOD_DMG, -98)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:SetAutoAttackEnabled(false)
    mob:setMod(MOD_DEF, 1500)
    mob:setMod(MOD_MDEF, 900)
    -- 2026-08-27: real root cause found for "Firespit doesn't break the gate" -- a live diagnostic
    -- confirmed the gate genuinely recovered 866 HP (exactly maxHP*0.1 x2) between two Firespit
    -- hits 46s apart. Root cause: CMobEntity's idle-roam AI (mob_controller.cpp, "lets buff up or
    -- move around" branch) calls Rest(0.1) -- a real 10%-of-maxHP heal -- on its roam cooldown for
    -- any mob not gated by MOBMOD_NO_REST, whenever health.hp != health.maxhp. The gate is
    -- NO_MOVE + autoattack-disabled and never truly "in combat" (it can't fight back or be
    -- targeted), so it kept landing in this idle/resting branch between Warder skill casts,
    -- healing back a meaningful fraction of our fixed-percentage chip damage. This was never
    -- disabled since a "destructible prop" mob was never expected to rest at all.
    mob:setMobMod(MOBMOD_NO_REST, 1)
end

-- 2026-08-27: user-reported live -- gate visually disappears on death but stays impassable.
-- `setStatus(DISAPPEAR)` only ever controlled visibility/targetability; the actual physical
-- collision/passability is governed by the door prop's `animation` field (same finding already
-- established for this session's other door-prop fixes -- see topaz_1x_prop_blocker_diagnosis) --
-- this file never touched it at all, so the prop kept its SQL-default closed animation even
-- while invisible. Fixed with an explicit animation call, a real persisted state change (unlike
-- the engine's transient default click-toggle the user saw revert on its own during an earlier
-- bug-era test where the gate was briefly, incorrectly targetable).
-- 2026-08-27 CORRECTION, REVERTED: briefly tried animation 6 (a "destruction/shatter sequence"
-- value per a client-animation reference table the user provided) ahead of the disappear, to get
-- a real crumble visual instead of an instant hide. **This caused a real client crash** --
-- user-reported live: client crashed immediately after a Warder's Axe Throw killed a gate, right
-- when this code would have first fired `setAnimation(6)` on it (every earlier gate-kill test,
-- all using the plain `setAnimation(8)` version, never crashed).
-- 2026-08-27 (later), user direction: try animation 7 instead (same reference table's other
-- "destruction/shatter" value), falling back to the known-safe 8-only version if 7 also fails.
-- User was advised to test this first via `!animatenpc {door_npcid} 7` directly on a still-intact
-- gate prop (no kill required, instantly repeatable) before it fires again through the real
-- onMobDeath sequence below, to avoid risking another crash mid-mission-test. If 7 also crashes,
-- revert this same line back to just `door:setAnimation(8); door:setStatus(STATUS_DISAPPEAR)`
-- (no animation 6/7 call at all), matching the previous known-safe version.
local function openGateDoor(npcID, instance)
    local door = instance:getEntity(bit.band(npcID, 0xFFF), TYPE_NPC)
    door:setAnimation(7) -- destruction/shatter sequence -- TESTING, see header note above
    door:timer(3000, function(n)
        n:setAnimation(8) -- transition to the actual passable/hidden state once the shatter finishes
        n:setStatus(STATUS_DISAPPEAR)
    end)
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if mob:getID() == 17047567 then
        openGateDoor(17047898, instance)
    elseif mob:getID() == 17047568 then
        openGateDoor(17047900, instance)
    elseif mob:getID() == 17047569 then
        openGateDoor(17047902, instance)
    end
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    instance:setProgress(instance:getProgress() + 1)
end

