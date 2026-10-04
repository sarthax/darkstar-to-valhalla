-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Wraith Bat (tier 5/Mumor-floor lamp trigger, 10 real spawns in Pyracmon's room,
--  mob_spawn_points 17093289-17093298). Paired with Pyracmon -- see Pyracmon.lua's header for
--  the full groupKillGate mechanic ("Kill Pyracmon and ALL Wraith Bats to activate the Runic
--  Lamp to Mumor" -- a single all-11-must-die condition, not a random-key pool).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local GILDED_DOORS = 17093419
local ROOM_SIZE = 11 -- Pyracmon + 10 Wraith Bats
local DOOR_ANIM_OPEN = 8 -- 9 is closed (npc_list default) -- see sql/npc_list.sql's 2026-09-29 note

-- 2026-09-29 (user): same fix as Pyracmon.lua -- see its header comment for the full root-cause
-- writeup (npc_list entityFlags/FLAG_UNTARGETABLE, door_util.lua's confirmed pattern).
function onMobDeath(mob, player, isKiller)
    tpz.heroines.trashDrop(mob, player)
    if tpz.heroines.groupKillGate(mob, "Mumor_Room", ROOM_SIZE) then
        local instance = mob:getInstance()
        if instance then
            tpz.heroines.activateRune(instance, 5)
            local door = instance:getEntity(bit.band(GILDED_DOORS, 0xFFF), TYPE_NPC)
            if door then
                door:untargetable(false)
                door:setAnimation(DOOR_ANIM_OPEN)
            end
        end
    end
end

