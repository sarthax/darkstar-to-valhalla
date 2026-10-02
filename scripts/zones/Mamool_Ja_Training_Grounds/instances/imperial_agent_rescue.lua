-----------------------------------
-- Assault: Imperial Agent Rescue
-- An agent sent to spy on the secret training grounds of the Mamool Ja has been captured.
-- Rescue him before he is interrogated for Imperial secrets.
-----------------------------------
-- Design notes -- CORRECTED 2026-08-18, replacing an earlier misread of the capture data:
--   The real mechanic (confirmed live in-game by the user, and consistent with a fresh re-read of
--   the same Thris Nov 2025 capture) is a search-and-rescue, not "kill 3 gates to auto-complete":
--     1. 3 Dilapidated Gate obstacles each block a walled pen (mobs/Dilapidated_Gate.lua).
--     2. Breaking a gate hides its door prop, opening that pen.
--     3. Each pen has one Pot Hatch npc (npcs/_jun.lua, _jul.lua, _jum.lua, position-paired 1:1
--        with GATE_1/_ju3, GATE_2/_ju5, GATE_3/_ju7 respectively -- see instance_entities.sql).
--        Searching a hatch has a 1-in-3 chance of containing Brujeel -- which hatch is correct is
--        randomized once per instance below (brujeelHatch localvar), matching the "he can be in
--        any of the 3" behavior the user described.
--     4. Finding him plays his real reveal animation ("deru" CEntityAnimationPacket) and his real
--        6-line rescue dialogue (raw MesNum 7539-7544 from the capture, see IDs.lua), then
--        completes the mission automatically -- no separate "talk to Brujeel" step, confirmed by
--        the user both from the capture (no further player action before "Mission objective
--        completed") and from live testing.
--   The old theory ("exactly 3 gate-damage hits = progress trigger") didn't survive a recount --
--   the capture actually shows 7 "Dilapidated Gate takes N damage" lines, all incidental splash
--   damage from Mamool Ja Warder AoE skills (Firespit etc.), not deliberate gate-breaking hits.
--   Lockbox rewards (???_ring + hi-potion_+2 + hi-potion_tank, see npcs/Ancient_Lockbox.lua) and
--   this mission's 1210 Assault points (see npcs/Rune_of_Release.lua) remain confirmed exact.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------
-- Real Mamool Ja Warder guard + Dilapidated Gate ids (were ID.mob[2] under the old
-- LandSandBoat-targeted IDs.lua; that per-instance mob-group shape has no old-dsp-reference
-- equivalent -- see TextIDs.lua's own header -- so hardcoded directly here instead, same
-- convention as old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua).
local MOB_GROUP_2 = {
    17047553, 17047554, 17047556, 17047557, 17047559, 17047560,
    17047561, 17047563, 17047564, 17047565, 17047566,
    17047567, 17047568, 17047569, -- GATE_1, GATE_2, GATE_3
}
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_11_START, 11)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)

    for _, v in ipairs(MOB_GROUP_2) do
        forceAggro(SpawnMob(v, instance))
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setPos(220.000, 1.465, -504.999, 0)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setPos(220.000, 1.619, -502.999, 0)

    -- Brujeel stays hidden until the correct pot hatch is searched (npcs/_pot_hatch_common.lua).
    instance:getEntity(bit.band(17047810, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    -- Randomize which of the 3 pot hatches actually contains Brujeel -- 1=GATE_1 pen (_jun),
    -- 2=GATE_2 pen (_jul), 3=GATE_3 pen (_jum). See npcs/_pot_hatch_common.lua.
    instance:setLocalVar("brujeelHatch", math.random(1, 3))
    instance:setLocalVar("brujeelFound", 0)

    -- Force the 3 real gate door props closed and visible at spawn -- user reported them
    -- appearing open/passable by default. `status` (set previously) only controls visibility;
    -- the actual open/closed pose is the `animation` field (ANIMATION_OPEN_DOOR=8 /
    -- ANIMATION_CLOSE_DOOR=9, src/map/entities/baseentity.h) -- already 9 in npc_list.sql for
    -- all 3, but set it explicitly here too in case spawn doesn't pick up the DB default reliably.
    for _, npcID in ipairs({ 17047898, 17047900, 17047902 }) do
        local door = instance:getEntity(bit.band(npcID, 0xFFF), TYPE_NPC)
        door:setStatus(STATUS_NORMAL)
        door:setAnimation(9) -- ANIMATION_CLOSE_DOOR
    end

    -- _1u5 (120,0.461,-500.003, matches user-reported 121,2,-499) is NOT one of the 3 real
    -- objective gates -- it was registered under the same unverified "roughly in range" guess as
    -- _1u6 (already removed, see instance_entities.sql). Unlike _1u6 it does belong here
    -- (position matches a real reported passage), but should never block movement -- its DB
    -- default is already animation=8 (ANIMATION_OPEN_DOOR), forced explicitly here too since the
    -- 3 real gates needed the same explicit push to render correctly.
    instance:getEntity(bit.band(17047864, 0xFFF), TYPE_NPC):setAnimation(8) -- ANIMATION_OPEN_DOOR
    instance:getEntity(bit.band(17047864, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

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
    -- No-op: progress still ticks up per gate broken (mobs/Dilapidated_Gate.lua) for player
    -- feedback, but completion is now driven by finding Brujeel in the correct pot hatch
    -- (npcs/_pot_hatch_common.lua calls instance:complete() directly), not a gate count.
end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 9, 8) -- J-8 (capture Thris Nov2025; Topaz has 11,10)
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

