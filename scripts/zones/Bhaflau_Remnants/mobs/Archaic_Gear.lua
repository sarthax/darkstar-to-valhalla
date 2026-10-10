-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Archaic Gear
-----------------------------------
-- 2026-09-09: real mechanic, ported directly from LandSandBoat's own real, working
-- Archaic_Gear.lua, cross-checked against the user's own Floor 4 wiki text: "Warp away if they
-- aggro, link, or pulled with a damaging ability... Does not warp away if pulled with a
-- non-damaging spell/ability, or ranged attack... Will also warp away mid-fight if they aren't
-- killed in 60 seconds." Three real triggers, ported as three real hooks:
--   1) ATTACKED listener (melee only in DSP) (added on spawn, removed once real combat starts) -- any non-ranged
--      damage before real engagement is a "pull," despawns after a short delay.
--   2) onMobEngaged with getCE()==0 and getVE()==0 -- real aggro/link (no player-caused combat
--      enmity yet), despawns.
--   3) onMobFight -- battle time > 60s despawns once, guarded by a localVar so it only fires once.
-- LSB's own `independentAnimation` (a cosmetic warp-away flourish) has no equivalent binding in
-- this Topaz fork and no confirmed real animation id to substitute -- skipped rather than
-- fabricated; the mob still despawns correctly, just without the extra visual cue.
-- GetSystemTime() -> os.time() (same real semantic, already used identically elsewhere in this
-- zone's own Archaic_Gears.lua). optParams.isKiller -> Topaz's real 3-arg onMobDeath signature
-- (mob, player, isKiller), used identically by every other mob file in this zone.
--
-- 2026-09-09 (also): real fix -- this file is shared by the real "Archaic_Gear" name on BOTH
-- Floor 3 (chest-drop only, no warp-away/kill-count mechanic) and Floor 4 (this mechanic) -- see
-- IDs.lua's own ARCHAIC_GEAR/ARCHAIC_GEAR_F3 split writeup. Everything below is gated on
-- instance:getStage()==4, matching LSB's own real gating exactly and naturally preventing a
-- Floor 3 kill from ever reaching this logic.
--
-- 2026-09-09 (also): LSB's own real onMobDeath repositions DORMANT_RAMPART[4] to one of 8 fixed
-- room-specific spots (4 per side) before revealing it. Topaz has only ONE real confirmed
-- position for DORMANT_RAMPART[4] (npc_list.sql's own default row, -340,0,154) -- LSB's 8 raw
-- coordinates are that fork's own world-space values, not independently verified against Topaz's
-- real geometry (the same class of unconfirmed cross-project data this zone has been burned by
-- before -- Empathic Flan's room mapping, the Dormant Rampart rotation fix, etc). Reveals at its
-- own single real default position instead of guessing 7 more.
-----------------------------------
require("scripts/globals/salvage")
require("scripts/globals/status")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    if not (instance and instance:getStage() == 4) then
        return
    end

    -- DSP has no TAKE_DAMAGE listener event; ATTACKED fires on melee hits only, so magic and
    -- weaponskill pulls do NOT despawn the Gear here (ranged correctly does not).
    mob:addListener("ATTACKED", "GEAR_TAKE_DAMAGE", function(mobArg, attacker, action)
        mobArg:timer(4000, function(gearMob)
            if gearMob and gearMob:isAlive() then
                DespawnMob(gearMob:getID(), instance)
            end
        end)
    end)
end

function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    if not (instance and instance:getStage() == 4) then
        return
    end

    if mob:getCE(target) == 0 and mob:getVE(target) == 0 then
        mob:timer(4000, function(mobArg)
            if mobArg and mobArg:isAlive() then
                DespawnMob(mobArg:getID(), instance)
            end
        end)
    end

    mob:removeListener("GEAR_TAKE_DAMAGE")
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    if not (instance and instance:getStage() == 4) then
        return
    end

    if mob:getBattleTime() > 60 and mob:getLocalVar("teleport") == 0 then
        mob:setLocalVar("teleport", 1)
        mob:timer(4000, function(mobArg)
            if mobArg and mobArg:isAlive() then
                DespawnMob(mobArg:getID(), instance)
            end
        end)
    end
end

-- 2026-09-09: real fix -- BG Wiki (this session's own Floor 4 text): "Killing all 10 Archaic Gear
-- will weaken the effect of Homing Missile... Neither entering the Dormant Rampart nor defeating
-- the Reactionary Rampart are required at all to completely lower Homing Missile's effect; only
-- the 10 Archaic Gear are tied to it." Confirms the Rampart-reveal and the full Homing-Missile
-- weaken are the SAME real threshold (10 kills), not two independently-confirmed conditions --
-- kept as the existing ArchaicGearsKilled/DormantRampartPopped localVars (already read by
-- homing_missile.lua) rather than introducing a new, disconnected counter name.
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)

    local instance = mob:getInstance()
    if not (instance and instance:getStage() == 4) then
        return
    end

    local killed = instance:getLocalVar("ArchaicGearsKilled") + 1
    instance:setLocalVar("ArchaicGearsKilled", killed)

    if killed >= 10 then
        instance:setLocalVar("DormantRampartPopped", 1)

        local dormant = instance:getEntity(bit.band(Bhaflau.mobs.DORMANT_RAMPART[4], 0xFFF), TYPE_NPC)
        if dormant then
            dormant:setStatus(STATUS_NORMAL)
        end
    end
end

