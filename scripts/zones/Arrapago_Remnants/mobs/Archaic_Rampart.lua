-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Archaic Rampart
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely. The floor-1 Archaic Rampart (id
-- 17080321, pos 340,-4.5,-326.5) has SQL name "Archaic_Rampart" with NO numeric suffix, but only
-- Archaic_Rampart_1/_2/_3.lua existed -- none of which match that exact name, so Topaz's real
-- per-mob name-driven script lookup (CacheLuaObjectFromFile uses the mob's exact SQL `name` field)
-- never found a script for it. Confirmed via user report: fought it to 15% HP with zero Sabotender
-- Maestro spawns, matching a totally unscripted mob (no onMobFight ever firing) rather than a
-- logic bug. Mirrors Archaic_Rampart_1.lua's single-pet variant, since floor 1 is the simplest
-- encounter (other Ramparts elsewhere use the _2/_3 multi-pet variants for their own real ids).
-- Also fixes a real id mismatch carried over from _1.lua: useMobAbility(2034) passed the mob-skill
-- FAMILY id, not an actual skill id (2290 "restoral" is commented out/inactive in mob_skills.sql;
-- 3243 "imperial_authority" is the only real active skill in that family) -- calling
-- useMobAbility(2034) silently no-ops in the C++ binding (GetMobSkill returns null), so the
-- Rampart never played its summon animation, though this didn't block the pet spawn itself.
-----------------------------------
mixins = {require("scripts/mixins/families/rampart")}
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    local popTime = mob:getLocalVar("lastPetPop")
    local POS = mob:getPos()
    local PET1 = GetMobByID((mob:getID() +1), instance)

    if os.time() - popTime > 15 then
        if not PET1:isSpawned() then
            PET1:setSpawn(POS.x, POS.y, POS.z, POS.rot)
            mob:useMobAbility(3243)
            mob:setLocalVar("lastPetPop", os.time())
            mob:timer(2500, function(m)
                SpawnMob((m:getID() +1), instance)
            end)
        end
    end
    if PET1:isSpawned() then
        PET1:updateEnmity(target)
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (161) in mob_groups pointing to a real mob_droplist entry, which the
-- native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter support).
-- The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of that --
-- reverted pending a full mob_droplist audit/correction instead (see chat).
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
end

