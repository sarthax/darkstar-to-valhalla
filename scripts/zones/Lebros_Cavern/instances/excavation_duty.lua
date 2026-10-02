-----------------------------------
-- Assault: Excavation Duty
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_21_START, 21)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-----------------------------------
-- Hardcoded mob groups for SpawnMob compatibility.
-- Mamool Ja instances use this pattern (hardcoded arrays), so Lebros follows the same.
-- Previously using ID.mob[21] iteration caused SpawnMob to fail because it expects
-- raw mob IDs, not table-key iterations. Converted to explicit ID arrays.
--
-- 2026-09-17 FIX: this list previously omitted the 5 Brittle Rock MOB ids (17035282,
-- 17035284, 17035286, 17035288, 17035290), based on a mistaken comment conflating them with
-- the separate rock-wall NPC PROPS (_1rx/_1ry/_1rz/_ir0/_ir1, real npc_list entries revealed
-- below via setStatus). The props are the visible/blocking wall geometry; the Brittle_Rock
-- mob (mob_pools poolid 534, Brittle_Rock.lua) is the actual killable entity a player attacks
-- to break through -- it still needs SpawnMob like every other mob in this instance, exactly
-- like Volcanic_Bomb/Qiqirn below and like MOB_GROUP_22/23/24 in the sibling missions. Without
-- it, the wall prop was visible but nothing existed behind it to interact with or destroy --
-- this was the actual bug, not a design choice. Live-confirmed missing/uninteractable rocks
-- reported by user, root-caused and fixed here.
-----------------------------------
local MOB_GROUP_21 = {
    17035265, 17035266, 17035267, 17035268, 17035269, 17035270, 17035271, 17035272,
    17035273, 17035274, 17035275, 17035276, 17035277, 17035278, 17035279, 17035280,
    17035281, -- Volcanic Bomb and Qiqirn Ceramist/Volcanist mobs
    17035282, 17035284, 17035286, 17035288, 17035290, -- Brittle Rock mobs 1-5
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
-- Assault: Excavation Duty (mission 21) - Brittle Rock wall breakers + Qiqirn Ceramist/Volcanist
-----------------------------------
function onInstanceCreated(instance)

    for _, v in ipairs(MOB_GROUP_21) do
        forceAggro(SpawnMob(v, instance))
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(49.999, -40.837, 96.999, 0)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(50.000, -40.070, 99.999, 0)

    -- Rock-wall props default to hidden (npc_list status=0) and nothing was revealing them, so
    -- the Brittle Rock mobs had no visible obstacle to be standing in front of. Show them now;
    -- Brittle_Rock.lua's onMobDeath clears each one back to hidden once its rock is destroyed.
    instance:getEntity(bit.band(ID.npc._1rx, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1ry, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1rz, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._ir0, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._ir1, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    -- 2026-09-19: force every wall prop to the closed/solid state (9). _1ry was seeded with
    -- animation 8 (open) in npc_list, so one rock started invisible and walk-through.
    for _, propId in ipairs({ID.npc._1rx, ID.npc._1ry, ID.npc._1rz, ID.npc._ir0, ID.npc._ir1}) do
        instance:getEntity(bit.band(propId, 0xFFF), TYPE_NPC):setAnimation(9)
    end
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

    -- 2026-08-25: reverted to 5 (real mission threshold per FFXIclopedia/Korvana guide, "break
    -- all 5 Brittle Rock walls"). 
    if progress >= 5 then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        -- 2026-08-20: letter index confirmed 0-based (A=0) via the Lebros Supplies capture's own
        -- decoded text ("H-8" rendered from Num1={7,8,...})
        v:messageSpecial(RUNE_UNLOCKED_POS, 5, 10) -- F-10
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

