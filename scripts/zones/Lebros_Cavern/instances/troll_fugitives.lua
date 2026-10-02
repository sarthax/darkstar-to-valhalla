-----------------------------------
-- Assault: Troll Fugitives
-----------------------------------
-- Validated 2026-08-18 by a real Thris Nov 2025 capture, real WIN (1100 Assault points) -- exact
-- 15 "Broken Troll Soldier" kills observed, kill-all-15 confirmed exactly right. Entrance was
-- already close to real (not the generic placeholder); Assault points corrected from a 1000
-- guess to the real 1100; Lockbox reward table validated, no changes needed.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_23_START, 23)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Hardcoded mob groups for SpawnMob compatibility.
-- Mamool Ja instances use this pattern (hardcoded arrays), so Lebros follows the same.
-- Previously using ID.mob[23] iteration caused SpawnMob to fail because it expects
-- raw mob IDs, not table-key iterations. Converted to explicit ID arrays.
-----------------------------------
local MOB_GROUP_23 = {
    17035310, 17035311, 17035312, 17035313, 17035314, 17035315, 17035316, 17035317,
    17035318, 17035319, 17035320, 17035321, 17035322, 17035323, 17035324,
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

-----------------------------------
-- Assault: Troll Fugitives (mission 23) - Troll Fugitive kills required for objective
-----------------------------------
function onInstanceCreated(instance)

    for _, v in ipairs(MOB_GROUP_23) do
        forceAggro(SpawnMob(v, instance))
    end

    -- Rune/lockbox positions copied from Topaz troll_fugitives.lua onInstanceCreated (source-validated)
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(-376.272, -9.893, 89.189, 0)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(-384.097, -10, 84.954, 49)

end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)

    if progress >= 15 then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 9) -- H-9 (capture Thris)
    end

    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setStatus(STATUS_NORMAL)
    box:setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

