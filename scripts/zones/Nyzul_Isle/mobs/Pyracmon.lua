-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Pyracmon (tier 5/Mumor-floor lamp trigger, paired with the 10 Wraith Bats in this room).
--  2026-09-29: user explicitly rejected an earlier random-key-pool implementation --
--  "Pyracmon.lua should be ALL bats AND Pyracmon to open the door. not separate random pools."
--  Real mechanic: "Kill Pyracmon and ALL Wraith Bats to activate the Runic Lamp to Mumor." All 11
--  mobs (Pyracmon + the 10 Wraith Bats, see Wraith_Bat.lua) share one groupKillGate counter --
--  the death that brings the count to 11 opens the Gilded Doors AND activates the tier-5 rune
--  together, as a single unified condition (not two separately-gated effects).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local GILDED_DOORS = 17093419
local ROOM_SIZE = 11 -- Pyracmon + 10 Wraith Bats
local DOOR_ANIM_OPEN = 8 -- 9 is closed (npc_list default) -- see sql/npc_list.sql's 2026-09-29 note

-- 2026-09-29 (user): "Door is openable before bats are killed. So it's in a closed state, but not
-- locked." Root cause: npc_list's entityFlags for 17093419 never included FLAG_UNTARGETABLE (0x800)
-- -- confirmed via Bhaflau_Remnants/door_util.lua's own established, live-tested pattern (M.onDoorOpen:
-- untargetable(true) at start, untargetable(false)+setAnimation(open) on real unlock) that the closed
-- animation alone doesn't block interaction, only untargetable() does. npc_list.sql's entityFlags for
-- 17093419 raised to 6147 (matches the one other correctly-locked Gilded* row, _24x/17089418) to start
-- locked; this untargetable(false) call is the actual runtime unlock, mirroring door_util.lua exactly.
function onMobDeath(mob, player, isKiller)
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

