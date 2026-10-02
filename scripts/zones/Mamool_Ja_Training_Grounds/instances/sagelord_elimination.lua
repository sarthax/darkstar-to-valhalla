-----------------------------------
-- Assault: Sagelord Elimination
-----------------------------------
-- Built 2026-08-18 from data found sitting unwired in this repo's own SQL, contiguous right after
-- the already-built Preemptive Strike block: Sagelord Molaal Ja (the boss) plus 9 Mamool Ja
-- Trainees and 5 Lizard pets (guard/ambient content). Retail objective is singular -- "Defeat
-- Sagelord Molaal Ja" -- so only his death is tracked; the trainees/lizards are optional trash,
-- same shape as Lamia No.13 (Ilrusi Atoll).
-- 2026-08-20: real mechanic implemented in mobs/Sagelord_Molaal_Ja.lua -- he escapes via a real
-- Warp cast at 20% HP (the actual win condition, per user clarification), not a plain kill. See
-- that file's header for the full writeup.
-- 2026-08-20: Rune of Release / Ancient Lockbox real positions found via the same real Thris
-- capture ("Mamool Ja Training Grounds SP - Sagelord Elimination.zip") that confirmed Warm-Up and
-- Warp above -- NPCLogger gives (-300,-3,284) and (-300,-3,287) respectively, replacing the
-- zone-wide npc_list default ((-55, 1.323, -103), wrong -- user-reported it should be near
-- (-300,-4,295), and this capture data confirms that report almost exactly).
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_13_START, 13)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- 2026-08-21: this mission's own door/wall prop family (_1um-_1up, 4 real props) had zero
-- instance_entities registrations and were never referenced here -- same gap class already found
-- and fixed on Preemptive Strike (see that mission's Assault_Fix_Log.md entry). CANDIDATE
-- contributor to the user-reported closed-door blocker, NOT a confirmed fix -- the user already
-- tried repositioning/animation-cycling a different door prop for this exact mission with no
-- effect, so this alone may not resolve it; the real blocker could still be static zone geometry
-- (same as the Brittle Rock precedent elsewhere in this codebase). Revealed with each prop's own
-- npc_list default animation, not overridden -- open-vs-closed semantics for this family aren't
-- independently confirmed.
-- 2026-08-27, user-reported live: door/wall missing entirely at LOGPOS -500.39,-12.03,241.88.
-- _1ul (17047880) sits almost exactly there -- confirmed via a zone-wide sweep that it had ZERO
-- instance_entities registration anywhere in this project's history and was never in this list.
-- Not a regression from a recent identity-shift fix (its own name/position were untouched by
-- that), just a genuine, long-standing gap. Registered to instance 13 in instance_entities.sql.
local DOOR_PROPS = { 17047880, 17047881, 17047882, 17047883, 17047884 }

-- 2026-08-29: corrected -- the raw capture UniqueNo for Pot Hatch is 17047920, but that's a raw
-- (pre-shift) id: this zone's confirmed -1 id-shift band (17047844-17047923) means it must be
-- shift-corrected to 17047919 (_juo) before comparing against current ids, not used directly.
-- 17047920 itself resolves to a DIFFERENT real npc_list row (name _jup, real position
-- (-97.025,-2.884,307.664)), which is not registered to this instance at all. _juo (17047919,
-- name _juo) IS already registered to instance 13 in instance_entities and its own npc_list
-- position, (-453.902,-11.703,97.472), already matches this mission's real capture almost
-- exactly -- confirmed via npclogger_all_rows_2026-08-22.csv raw row id 17047920 (Sagelord
-- Elimination, position -453,-11,97). Was previously wired to the wrong, unregistered constant
-- (_juq) and never actually spawned/moved.
local POT_HATCH_POS = { x = -453.000, y = -11.000, z = 97.000 }

-- Real Sagelord Molaal Ja (boss) + 9 Mamool Ja Trainee + 5 Lizard ids (were ID.mob[13] under the
-- old LandSandBoat-targeted IDs.lua; that per-instance mob-group shape has no old-dsp-reference
-- equivalent -- see TextIDs.lua's own header -- so hardcoded directly here instead, same
-- convention as old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua).
local MOB_GROUP_13 = {
    17047590, -- SAGELORD_MOLAAL_JA
    17047591, 17047593, 17047594, 17047596, 17047597, 17047600, 17047602,
    17047603, 17047604, 17047605, 17047606, 17047607, 17047608, 17047609,
}

-- BST Trainee master id -> its Lizard pet id (inferred pairing, see onInstanceCreated).
local BST_PETS = {
    [17047592] = 17047593, [17047594] = 17047596, [17047602] = 17047604,
    [17047606] = 17047607, [17047608] = 17047609,
}

local PET_PARK = {
    [17047593] = { -349.5, -5.278, 105.569 }, [17047596] = { -442.1, -3.469, 209.067 },
    [17047604] = { -361.9, -3.378, 240.764 }, [17047607] = { -469.4, -11.42, 220.632 },
    [17047609] = { -462.4, -10.81, 174.072 },
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
    for _, v in ipairs(MOB_GROUP_13) do
        forceAggro(SpawnMob(v, instance))
    end

    -- BST Trainee pets: every Lizard's DB spawn point is a (1,1) placeholder and instance_loader.cpp
    -- has no mob_pets attach ("//TODO: pets"), so each Lizard sat unlinked far from any master.
    -- Park each next to its BST master; the link/enmity follow is in mobs/Mamool_Ja_Trainee.lua.
    -- PAIRING IS INFERRED (5 BST masters <-> 5 Lizards, each Lizard is the next Lizard id after its
    -- BST in mob_spawn_points order); neither DSP nor Topaz has a mob_pets row for zone 66.
    -- Park from fixed master coordinates (mob_spawn_points): master 17047592 is not in MOB_GROUP_13, so
    -- reading its live position left its Lizard (17047593) at (1,1,1) -> CPathFind 'could not find path'
    -- whenever Sagelord's flee picked it. All pets are spawned above, so every candidate is pathable.
    for petId, p in pairs(PET_PARK) do
        local pet = instance:getEntity(bit.band(petId, 0xFFF), TYPE_MOB)
        if pet then
            pet:setPos(p[1], p[2], p[3], 0)
            pet:setSpawn(p[1], p[2], p[3], 0)
        end
    end


    for i, propId in ipairs(DOOR_PROPS) do
        local prop = instance:getEntity(bit.band(propId, 0xFFF), TYPE_NPC)
        if prop then
            prop:setStatus(STATUS_NORMAL)
        end
    end

    local potHatch = instance:getEntity(bit.band(17047919, 0xFFF), TYPE_NPC)
    if potHatch then
        potHatch:setPos(POT_HATCH_POS.x, POT_HATCH_POS.y, POT_HATCH_POS.z, 0)
        potHatch:setStatus(STATUS_NORMAL)
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setPos(-300, -3, 284, 0)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setPos(-300, -3, 287, 0)
    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
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
        -- 2026-08-20: was RUNE_UNLOCKED (7510, takes no params) with (8, 8) -- that's the
        -- RUNE_UNLOCKED_POS (7509) param shape. User-reported: rune text didn't include the grid
        -- position. Switched to RUNE_UNLOCKED_POS. Params also corrected from (8, 8) to (8, 7) --
        -- the same real capture's CapLog shows the actual decoded text "Unlocking Rune of Release
        -- (I-7)" (Num1: {8, 7, ...}), confirming letter index 8 = I (0-based) but number 7, not 8.
        v:messageSpecial(RUNE_UNLOCKED_POS, 8, 7)
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

