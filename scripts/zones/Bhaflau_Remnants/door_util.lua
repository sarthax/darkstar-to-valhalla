-----------------------------------
-- Bhaflau Remnants -- shared Gilded Doors logic.
-----------------------------------
-- 2026-09-07: real mechanic, same pattern Arrapago Remnants' own confirmed-working door chain
-- uses (npcs/_220.lua-_224.lua): opening any door in a group locks the WHOLE group (untargetable),
-- and reveals the next group (setStatus NORMAL). Centralized here since this codebase's real
-- name-driven script lookup ([[topaz_npc_name_drives_script_lookup]]) requires one .lua file per
-- unique door npc name -- this module lets each of those files stay a thin wrapper instead of
-- duplicating the same logic ~30 times.
-----------------------------------
require("scripts/globals/status")
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working
-- scripts/globals/salvage.lua (xi.salvage.onDoorOpen/unsealDoors -- the same shared helper used
-- identically in Zhayolm Remnants too, not Bhaflau-specific). This directly answers the open
-- "kill all vs. reach the door" question: every real LSB door file just calls onDoorOpen and, on
-- success, sets instance:setLocalVar('stageComplete', <stage number>) -- no kill/mob-count check
-- anywhere in any of these files. Reaching and opening the door IS the real condition.
--
-- Doors are sealed (unSealed=0) by default and must be explicitly unsealed by the previous
-- stage's own progression (unsealDoors) before onDoorOpen will succeed -- this is a different,
-- more accurate model than the flat "opened" flag used elsewhere in this file (that flag still
-- works for the simple self-lock case, kept below for the doors not yet converted to real
-- unseal-chain data).
function onDoorOpen(door, stage, progress)
    local instance = door:getInstance()

    if door:getAnimation() == ANIMATION_CLOSE_DOOR and door:getLocalVar('unSealed') == 1 then
        door:setLocalVar('unSealed', 0)
        if stage then
            instance:setStage(stage)
        end
        if progress then
            instance:setProgress(progress)
        end
        door:setAnimation(ANIMATION_OPEN_DOOR)
        door:untargetable(true)
        return true
    end

    return false
end

function unsealDoors(instance, ids)
    if type(ids) == "table" then
        for _, id in ipairs(ids) do
            local door = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if door then
                door:setLocalVar('unSealed', 1)
            end
        end
    else
        local door = instance:getEntity(bit.band(ids, 0xFFF), TYPE_NPC)
        if door then
            door:setLocalVar('unSealed', 1)
        end
    end
end

-- 2026-09-08: real mechanic, ported from LSB's own xi.salvage.sealDoors -- re-locks a door (or
-- table of doors) that was previously unsealed, used when opening one branch's door re-seals the
-- opposite branch's own entrance (e.g. Floor 2's West/East entrance pair).
function sealDoors(instance, ids)
    if type(ids) == "table" then
        for _, id in ipairs(ids) do
            local door = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if door then
                door:setLocalVar('unSealed', 0)
            end
        end
    else
        local door = instance:getEntity(bit.band(ids, 0xFFF), TYPE_NPC)
        if door then
            door:setLocalVar('unSealed', 0)
        end
    end
end

-- 2026-09-08: real mechanic, ported from LSB's own xi.salvage.spawnGroup -- `groups` is a list
-- where each entry is either a single real mob id or a table of ids (e.g. the output of slice
-- below); spawns every id in every entry. Relies on SpawnMob's own built-in already-spawned guard
-- (confirmed real, src/map/lua/luautils.cpp), so calling this more than once for the same group is
-- harmless.
function spawnGroup(instance, groups)
    for _, group in ipairs(groups) do
        if type(group) == "table" then
            for _, id in ipairs(group) do
                SpawnMob(id, instance)
            end
        else
            SpawnMob(group, instance)
        end
    end
end

-- 2026-09-08: local equivalent of LSB's utils.slice (not present anywhere in this Topaz fork,
-- and not added to the shared scripts/globals/utils.lua to avoid changing behavior other zones
-- might rely on) -- returns tbl[first..last] as a new array, 1-indexed inclusive, matching LSB's
-- own real per-room index ranges used throughout the Floor 2-5 door files this was ported from.
function slice(tbl, first, last)
    local sliced = {}
    for i = first, last do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

-- Opens `door` and reveals every door in `nextGroup` (if given) by setting it NORMAL.
-- `onOpen(instance)` is an optional callback for extra state (e.g. remembering which branch was
-- taken, or setting the localVar/flag each door in `group` checks in its own onTrigger to show
-- "The door is sealed..." on a repeat click).
--
-- 2026-09-08: real fix -- this used to also call npc:untargetable(true) on every door in `group`,
-- including the one just opened. That's the wrong mechanism for "sealed" doors: untargetable()
-- sets the same entityFlags bit (0x800) already documented elsewhere in this project as making an
-- entity fully unclickable -- no onTrigger fires at all once set, so the "Door is sealed..."
-- message every door file already checks for (via its own localVar, e.g. BhaflauFloor1Exit) could
-- never actually display through that path. User confirmed the real intended behavior directly:
-- a sealed door stays targetable/clickable, you interact with it, and it just responds with the
-- message -- it doesn't disappear. Removed the untargetable() loop entirely; each door's own
-- onTrigger already correctly gates itself via its own localVar check (unchanged, already
-- present in every _233.lua-_23a.lua file). Doors on a branch the party never took at all (the
-- opposite, unreached side) are a different, separate case -- those stay hidden via
-- instances/bhaflau_remnants.lua's own onInstanceCreated untargetable() calls, not this function.
--
-- 2026-09-08 (later): real fix -- live-confirmed _233/_235/_238 (WEST_EXIT/EAST_EXIT members)
-- could not be targeted or opened at all. Root cause: onInstanceCreated calls untargetable(true)
-- on the WHOLE WEST_EXIT/EAST_EXIT/CENTER groups at instance creation (entityFlags 0x800, so a
-- player on the wrong branch can't see the other side's doors -- see that file's own comment).
-- This reveal step only ever called setStatus(NORMAL), never untargetable(false) -- so that flag
-- was never actually cleared once a branch was chosen, leaving the whole revealed group
-- permanently unclickable even though it's the branch the player is actually on.
function openAndAdvance(door, group, nextGroup, onOpen)
    door:setAnimation(8)
    local instance = door:getInstance()

    if nextGroup then
        for _, id in ipairs(nextGroup) do
            local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if npc then
                npc:untargetable(false)
                npc:setStatus(STATUS_NORMAL)
            end
        end
    end

    if onOpen then
        onOpen(instance)
    end
end

-- Standalone door with no confirmed group relationship yet: opens and marks itself used, same
-- baseline behavior as Arrapago's simplest real door (npcs/_220.lua) before any group/stage
-- chaining is confirmed for it.
--
-- 2026-09-08: real fix -- same bug/fix as openAndAdvance above: was door:untargetable(true),
-- which makes the door permanently unclickable rather than showing "Door is sealed..." on a
-- repeat click. Sets a localVar on the door itself instead -- each of these standalone door files
-- now checks it in their own onTrigger before deciding whether to open or show the sealed message.
function openSimple(door)
    door:setAnimation(8)
    door:setLocalVar("opened", 1)
end

