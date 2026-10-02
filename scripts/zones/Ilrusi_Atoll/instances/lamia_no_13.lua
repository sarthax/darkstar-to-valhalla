-----------------------------------
-- Assault: Lamia No.13
-- Your mission is to hunt down Lamia No.13, a fearsome creature known to have performed vile
-- experiments on the countless corpses of her enemies.
-----------------------------------
-- Built out 2026-08-18 -- found her real spawn point (mob_spawn_points id 17002517,
-- mob_groups id 3, poolid 2340, zone 55) directly in this repo's SQL. Per the Solo Assault
-- Guide by Korvana this is a plain kill-target mission (locate via Wide Scan, no other
-- mechanics documented), so onInstanceCreated just spawns her and progress completes on death
-- (see mobs/Lamia_No13.lua), same pattern as the other simple kill-all missions.
-- 2026-08-19, user-reported: she doesn't spawn with any companions -- contradicts the "solo, no
-- other mechanics" assumption above. Real widescan data (NPCLogger, the real capture) confirms
-- 3 companion mobs clustered at her position -- not Fomor as originally guessed, but Fallen
-- Volunteer / Fallen Imperial Wizard / Fallen Imperial Trooper (real mob_spawn_points/mob_groups
-- rows already existed, groupids 4/5/6, zone 55 -- just never registered to this instance).
-- 2026-08-25, real mechanic corrected (user-supplied reference): the Fallen are NOT ambient
-- guards -- they start the encounter already charmed by Lamia (fighting on her side), and
-- dispelling that charm is the actual intended way to turn them against her. See
-- mobs/Lamia_No13.lua and mobskills/belly_dance.lua for the charm-targeting side of this.
-- 2026-08-25: real mechanic added -- "wandering on either of the two islands, requires the player
-- to hunt for her" (user-supplied reference + 3 real LOGPOS alternates). Randomly picks one of 4
-- known real sites (the original confirmed cluster + 3 new ones) per instance run. The 3 Fallen
-- are offset from Lamia's own position using the same relative deltas as the original
-- widescan-confirmed cluster -- those exact deltas aren't independently re-confirmed at the 3 new
-- sites, just carried over as a reasonable, documented assumption.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/status")
-----------------------------------
-- Lamia's own confirmed/reported real positions. Fallen offsets (below) are relative to whichever
-- of these gets picked.
local LAMIA_SPAWNS =
{
    { 24.381, -4.094, -209.261 }, -- original, widescan-confirmed 2026-08-18
    { 23.9906, -6.0649, -68.0578 }, -- alternate 1, corrected 2026-09-01 (was 18.0263,-3.7332,-58.6985) via user-provided LOGPOS from live testing (debug print confirmed this was "site 2/4")
    { 183.6340, -2.1086, -55.1841 }, -- alternate 2, user-supplied LOGPOS 2026-08-25
    { -56.6680, -5.8746, -187.8168 }, -- alternate 3, user-supplied LOGPOS 2026-08-25
}

-- Deltas from Lamia's original confirmed position to each Fallen's own confirmed position --
-- carried over unchanged to whichever spawn site gets picked (see header note).
local FALLEN_OFFSETS =
{
    [17002518]       = { -1.027, -0.149, 1.110 },
    [17002519] = { -1.184, -0.192, 2.362 },
    [17002520] = { -0.942, -0.170, 2.958 },
}

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)

    forceAggro(SpawnMob(17002517, instance))
    forceAggro(SpawnMob(17002518, instance))
    forceAggro(SpawnMob(17002519, instance))
    forceAggro(SpawnMob(17002520, instance))

    local lamia = GetMobByID(17002517, instance)
    local siteIndex = math.random(#LAMIA_SPAWNS)
    local site = LAMIA_SPAWNS[siteIndex]
    -- 2026-09-01, user-requested: which of the 4 real spawn sites got picked wasn't observable
    -- live -- confirming/ruling out "did she wander far from her actual spawn" required inferring
    -- it from distance after the fact instead of just knowing directly.
    -- print(string.format("[Lamia_No13 DEBUG] onInstanceCreated -- picked site %d/%d pos=(%.4f,%.4f,%.4f)",
        -- siteIndex, #LAMIA_SPAWNS, site[1], site[2], site[3]))
    lamia:setSpawn(site[1], site[2], site[3])
    instance:setLocalVar("lamiaSpawnX", math.floor(site[1] * 100))
    instance:setLocalVar("lamiaSpawnY", math.floor(site[2] * 100))
    instance:setLocalVar("lamiaSpawnZ", math.floor(site[3] * 100))
    lamia:setPos(site[1], site[2], site[3])

    for fallenId, offset in pairs(FALLEN_OFFSETS) do
        local fallen = GetMobByID(fallenId, instance)
        local fx, fy, fz = site[1] + offset[1], site[2] + offset[2], site[3] + offset[3]
        fallen:setSpawn(fx, fy, fz)
        fallen:setPos(fx, fy, fz)

        -- 2026-08-25: real mechanic -- the Fallen start already charmed by Lamia, for the entire
        -- length of the mission (30 min = 1800s) so they never lose charm on their own -- only a
        -- real Dispel should be able to free them. Guaranteed (bypasses the normal resist roll,
        -- unlike a live Belly Dance cast) since this is a scripted starting state, not a combat
        -- action. Subsequent recharges from a live Belly Dance cast use the normal roll/duration
        -- (see mobskills/belly_dance.lua).
        -- 2026-08-25 fix: `charm()`'s duration MUST be passed explicitly -- it previously wasn't
        -- exposed to Lua at all, silently defaulting to 0s. Harmless for a charmed player, but
        -- fatal for a charmed mob: CPetController::Tick() despawns any charmed pet once
        -- `tick > charmTime`, so the Fallen were being auto-despawned within a tick or two of
        -- spawning -- this is what looked like "Lamia's Fallen keep disappearing."
        fallen:addStatusEffect(EFFECT_CHARM_I, 0, 3, 1800)
        lamia:charm(fallen, 1800)
    end

    -- 2026-08-19, user-reported: Rune of Release/Ancient Lockbox message fired on completion but
    -- the NPCs weren't actually at the right spot -- this instance never called setPos() for
    -- either, so they sat wherever their generic zone-default position was. Real positions
    -- confirmed via widescan in the real capture (Rune 60,-3,-145 / Lockbox 63,-3,-144 -- close
    -- but not identical to each other or to the user's own in-game estimate of 66,-3,-145).
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setPos(60.000, -3.000, -145.000, 0)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setPos(63.000, -3.000, -144.000, 0)
    -- Rune of Release npc_list row defaults to status 0 (visible/clickable). Hide it (and the Lockbox) until
    -- the mission completes; onInstanceComplete sets both back to STATUS_NORMAL.
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    -- 2026-08-19, user-reported: Ancient Lockbox not targetable/usable. Removed the
    -- setStatus(DISAPPEAR)/(NORMAL) toggle -- this zone's own npc_list row for Ancient Lockbox
    -- (17002654) has FLAG_UNTARGETABLE baked into its default entityFlags (3715 = 0xE83, bit
    -- 0x800 set), and sibling Ilrusi Atoll missions that work correctly (e.g.
    -- instances/extermination.lua) never touch status on this shared npc at all -- just setPos.
    -- Matching that proven-working pattern instead of guessing further.

    -- 2026-08-19, user-reported: invisible wall at (70,-4,-143) blocking half the map (where
    -- Lamia spawns). Real door prop (_1jd, position-matched almost exactly) was never registered
    -- to this instance at all -- same missing-wiring pattern as Imperial Agent Rescue's doors.
    -- DB default animation is already 8 (open); forced explicitly too, same precedent as that
    -- fix. Not yet confirmed fixed live.
    instance:getEntity(bit.band(17002719, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002719, 0xFFF), TYPE_NPC):setAnimation(8) -- ANIMATION_OPEN_DOOR

    -- 2026-08-29 CORRECTED: earlier comments here (both _jj1 and _jj2) were written before
    -- consistently applying this zone's -1 id-shift correction to raw NPCLogger capture ids, and
    -- drew wrong conclusions as a result. Real picture, confirmed by re-deriving both from the
    -- pristine pre-session instance_entities.sql baseline (which already had BOTH doors
    -- registered here, just under old/pre-shift numbering) and shifting each -1:
    --   - raw capture id 17002744 (34,-6,-265) shifts to current id 17002743 (_jj1) -- already
    --     correctly positioned in npc_list.sql, no fix needed.
    --   - raw capture id 17002745 (79,-6,-104) shifts to current id 17002744 (_jj2) -- also
    --     already correctly positioned, no fix needed.
    -- Both are real, separate registered doors for this mission -- not a duplicate/collision.
    instance:getEntity(bit.band(17002744, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002744, 0xFFF), TYPE_NPC):setAnimation(8) -- ANIMATION_OPEN_DOOR

    instance:getEntity(bit.band(17002743, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002743, 0xFFF), TYPE_NPC):setAnimation(8) -- ANIMATION_OPEN_DOOR

    -- 2026-09-01, user-provided LOGPOS (55,11.4552,-3.7237,-19.5053 / 55,198.1810,-4.0563,-47.5690):
    -- _1jb/_1ji were defined in npc_list.sql but never registered to this instance at all -- same
    -- missing-wiring pattern as _1jd/_jj1/_jj2 above. Real positions are ~10 yalms from each real
    -- LOGPOS (consistent with standing in front of, not on top of, a closed door), not close
    -- enough to a mob_spawn_points prop or anything else nearby to be a different entity.
    -- 2026-09-01, user-provided LOGPOS (55,2.4059,-3.7101,-18.3788, ~1 yalm from _1jb's own
    -- registered position -- essentially standing on it, not just near it): live-tested open (8)
    -- and confirmed the pathway should be impassable instead -- corrected to 9.
    instance:getEntity(bit.band(17002717, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002717, 0xFFF), TYPE_NPC):setAnimation(9) -- impassable/closed

    -- 2026-09-01, user-provided LOGPOS (55,201.4867,-4.1871,-42.5818, ~4.5 yalms from _1ji's own
    -- registered position): live-tested open (8) and confirmed the pathway should be impassable
    -- instead -- corrected to 9.
    instance:getEntity(bit.band(17002724, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002724, 0xFFF), TYPE_NPC):setAnimation(9) -- impassable/closed

end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
    -- Leash: Lamia must not cross bridge _1jb (17002717 at 1.396,-3.499,-18.649) and wander off the
    -- island. Within BRIDGE_TURNAROUND_RANGE of it (and not fighting), walk her back to her spawn site.
    local lamia = GetMobByID(17002517, instance)
    if lamia and lamia:isAlive() and not lamia:isEngaged() then
        local dx = lamia:getXPos() - 1.396
        local dz = lamia:getZPos() + 18.649
        if dx * dx + dz * dz < 10 * 10 then
            local sx = instance:getLocalVar("lamiaSpawnX") / 100
            local sy = instance:getLocalVar("lamiaSpawnY") / 100
            local sz = instance:getLocalVar("lamiaSpawnZ") / 100
            lamia:pathTo(sx, sy, sz)
        end
    end
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress >= 1 then
        instance:complete()
    end
end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 8) -- H-8 (capture Thris Nov2025)
    end

    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):hideName(true)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

