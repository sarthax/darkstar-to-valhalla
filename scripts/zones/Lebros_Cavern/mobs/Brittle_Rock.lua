-----------------------------------
-- Area: Lebros Cavern (Excavation Duty)
--  Mob: Brittle Rock
-----------------------------------
local ID = Lebros
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
    mob:addMod(MOD_DMG, -98)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:SetAutoAttackEnabled(false)
    -- Tuning pass 2026-08-18: live testing at DEF 1500/MDEF 900 showed melee 24-28, crits ~45,
    -- and a weapon skill at 587 -- target is a flat ~20 regardless of source. A true hard cap
    -- needs a C++ change (no Lua hook exists to intercept/clamp incoming damage); user opted to
    -- stay Lua-only for now, so this is a defense bump to bring melee/crit closer to target.
    -- KNOWN LIMITATION: this cannot meaningfully touch weapon skill damage -- 587 is already
    -- ~29x over target, and physical defense doesn't have the range to close a gap that size
    -- without effectively making the rock unhittable by anything smaller. WS will keep bypassing
    -- the intended "use a mine" pacing until this gets the real C++ fix. Values below are a
    -- first estimate, not calculated against this engine's exact damage formula -- needs
    -- your live-test numbers to dial in further.
    mob:setMod(MOD_DEF, 2200)
    mob:setMod(MOD_MDEF, 1300)
    -- 2026-08-27: same latent bug class found and root-caused on Imperial Agent Rescue's
    -- Dilapidated_Gate.lua (identical "destructible prop, never fights back" pattern) -- CMobEntity's
    -- idle-roam AI heals 10% of maxHP on its roam cooldown for any mob not gated by
    -- MOBMOD_NO_REST. Likely far less noticeable here since real player damage typically dwarfs a
    -- 10% heal, but a rock that's been left alone between hits could still regen meaningfully.
    -- Never disabled since a destructible prop was never expected to rest at all.
    mob:setMobMod(MOBMOD_NO_REST, 1)
end

-- 2026-08-20 REVERTED to the pre-"dup entity" design (see git history, commit 81d05b3a30, for
-- the full reopened investigation this undoes). The dup-entity theory was real, capture-confirmed
-- data, but live-testing showed it made rocks 1-3 unreliable (two fully identical overlapping
-- mobs at the same coordinate produced inconsistent collision/targeting -- walk-past-able while
-- alive, contrary to the correct, user-confirmed "before" behavior: solid and impassable until
-- killed, then plays a death animation and becomes passable) while never actually fixing rocks
-- 4/5 (still impassable both before and after death regardless). Round-2 navmesh diagnostics also
-- confirmed the navmesh itself allows walking around all 5 rocks -- the real blocker is each
-- rock's own client-rendered model collision, independent of both navmesh and any Lua-side
-- status/animation state. No server-side fix found for rocks 4/5 at their current coordinates;
-- user is relocating that objective instead of continuing to force it here. Back to the simpler,
-- known-good logic for rocks 1-3 (and left in place structurally for 4/5, though real gating
-- there was never confirmed working).
function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    local prop = nil

    if mob:getID() == ID.mob[21].BRITTLE_ROCK1 then
        prop = instance:getEntity(bit.band(ID.npc._1rx, 0xFFF), TYPE_NPC)
    elseif mob:getID() == ID.mob[21].BRITTLE_ROCK2 then
        prop = instance:getEntity(bit.band(ID.npc._1ry, 0xFFF), TYPE_NPC)
    elseif mob:getID() == ID.mob[21].BRITTLE_ROCK3 then
        prop = instance:getEntity(bit.band(ID.npc._1rz, 0xFFF), TYPE_NPC)
    elseif mob:getID() == ID.mob[21].BRITTLE_ROCK4 then
        prop = instance:getEntity(bit.band(ID.npc._ir0, 0xFFF), TYPE_NPC)
    elseif mob:getID() == ID.mob[21].BRITTLE_ROCK5 then
        prop = instance:getEntity(bit.band(ID.npc._ir1, 0xFFF), TYPE_NPC)
    end

    if prop then
        local pos = prop:getPos()

        -- Playing the animation alone left the rock-wall prop (and whatever collision it
        -- carries) sitting there indefinitely -- some players could walk through afterward,
        -- some couldn't, which is consistent with the animation not reliably clearing it.
        -- Explicitly hide the prop a few seconds after the animation starts so the obstacle
        -- is definitively gone rather than relying on the animation alone.
        -- 2026-08-18: extended 3000 -> 5000 -- user reported the animation/SFX were being cut
        -- off before finishing.
        prop:setAnimation(8)

        prop:timer(5000, function()
            prop:setStatus(STATUS_DISAPPEAR)
            prop:setPos(pos.x, -500.000, pos.z, 0)
        end)
    end
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    instance:setProgress(instance:getProgress() + 1)
end

