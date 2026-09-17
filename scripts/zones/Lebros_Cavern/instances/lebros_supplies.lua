-----------------------------------
-- Assault: Lebros Supplies
-- An advance unit sent into Lebros Cavern has met heavy resistance and is in need of
-- reprovisioning. Your mission is to deliver rations to each member of the advance unit.
-----------------------------------
-- Design notes:
--   No instance logic exists for this mission in LSB or upstream Topaz -- only the mob/npc IDs in
--   IDs.lua were known. This implementation is built from those IDs + the wiki objective text.
--   Progress comes from triggering each of the 12 Imperial_Stormer NPCs (see npcs/Imperial_Stormer.lua),
--   not from the 6 Crimson_Eruca obstacles.
-- Validated 2026-08-18 by a real Thris Nov 2025 capture, real WIN (1320 Assault points): all 12
-- Imperial Stormer triggers confirmed in the capture, mechanic exactly right. Real staging
-- coordinates for Rune of Release ((-330, -10, -262)) and Ancient Lockbox ((-330, -10, -265))
-- pulled from the same capture's NPCLogger -- no facing/rotation was captured (NPCLogger has no
-- dir column for static NPCs), left at 0. Entrance also fixed.
-- 2026-08-20: re-scanned the same capture's NPCLogger for every object position. Found 2 wall
-- props (_1rj/_1rq, sql/npc_list.sql 17035523/17035530) that were previously NOT_CAPTURED
-- placeholders and never registered to this instance at all -- real positions now filled in and
-- wired in below.
-- 2026-08-20: built the real food hand-out/turn-in mechanic (community wiki writeup + this
-- capture's dialogue/item ids) -- see npcs/Yazuhma.lua and npcs/Imperial_Stormer.lua. The 12
-- Stormers previously all shared one placeholder npc_list position (never actually scattered);
-- real per-unit positions (5 clusters matching the wiki's WSW-2/SSW-2/SE-3/NW-3/N-2 groups) come
-- from the same capture's NPCLogger and are set below. Each Stormer needs 6 or 7 points of food
-- (wiki: "either 6 or 7", not disambiguated further) -- randomized per instance per Stormer.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_22_START, 22)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Hardcoded mob groups for SpawnMob compatibility (see MOB_GROUP_21/23/24 pattern above)
local MOB_GROUP_22 = { 17035304, 17035305, 17035306, 17035307, 17035308, 17035309 } -- Crimson Eruca

function onInstanceCreated(instance)

    for _, v in ipairs(MOB_GROUP_22) do
        SpawnMob(v, instance)
    end

    -- Real per-unit positions from the Thris capture's NPCLogger (2026-08-20) -- previously all 12
    -- shared one placeholder npc_list position. Each also gets a real 6-or-7 point threshold and
    -- starts unfed (points 0, full 0) -- see npcs/Imperial_Stormer.lua for the feed mechanic.
    local STORMER_POS =
    {
        [ID.npc.IMPERIAL_STORMER1]  = { -473, -10, -360 },
        [ID.npc.IMPERIAL_STORMER2]  = { -471, -10, -365 },
        [ID.npc.IMPERIAL_STORMER3]  = { -396, -10, -397 },
        [ID.npc.IMPERIAL_STORMER4]  = { -391, -10, -396 },
        [ID.npc.IMPERIAL_STORMER5]  = { -168, -10, -361 },
        [ID.npc.IMPERIAL_STORMER6]  = { -163,  -9, -337 },
        [ID.npc.IMPERIAL_STORMER7]  = { -148,  -9, -357 },
        [ID.npc.IMPERIAL_STORMER8]  = { -559, -10,  -74 },
        [ID.npc.IMPERIAL_STORMER9]  = { -567, -10,  -72 },
        [ID.npc.IMPERIAL_STORMER10] = { -559, -10,  -79 },
        [ID.npc.IMPERIAL_STORMER11] = { -307, -10,  -55 },
        [ID.npc.IMPERIAL_STORMER12] = { -303, -10,  -52 },
    }

    for npcId, pos in pairs(STORMER_POS) do
        local stormer = instance:getEntity(bit.band(npcId, 0xFFF), TYPE_NPC)
        stormer:setPos(pos[1], pos[2], pos[3], 0)
        stormer:setStatus(STATUS_NORMAL)
        stormer:setLocalVar("threshold", math.random(6, 7))
        stormer:setLocalVar("points", 0)
        stormer:setLocalVar("full", 0)
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(-330, -10, -262, 0)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(-330, -10, -265, 0)

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    -- 2026-08-20: wall props, real positions from the same Thris capture's NPCLogger --
    -- previously NOT_CAPTURED placeholders, never registered to this instance at all.
    -- 2026-08-20 (later): diagnostic-hid the wall at 17035530 to test whether its own model was the
    -- real blocker for a user-reported impassable wall at its position -- user confirmed hiding it
    -- removed the entity from client-side tracking (e.g. minimap radar addons lost their dot for
    -- it) but the wall itself stayed completely solid, and Ashita's own F11 zone-geometry highlight
    -- still shows an object right there distinct from the surrounding terrain. Confirms this is
    -- static client-side zone geometry, not this (or any) entity's collision -- same conclusion
    -- already reached for Excavation Duty's Brittle Rock 4/5 (which later turned out wrong -- see
    -- below). Reverted back to NORMAL -- hiding it achieved nothing but breaking radar-addon
    -- visibility. See Assault_Fix_Log.md for the full writeup.
    -- 2026-08-25: user re-reported the same wall still blocking, live navdebug at
    -- -399,-13,-180 shows onMesh=true (navmesh confirms a path exists) and only this one entity
    -- (17035530) within 15 yalms. Found and fixed a real id-name bug this exact cluster shares with
    -- Evade and Escape's: this npcid was mislabeled `_1rq` in npc_list.sql/IDs.lua -- two
    -- independent real captures (this mission's own Thris capture + a Nov2025 Thris capture) both
    -- confirm it's really `_1rp`. `17035522`/`17035523` (`_1rj` in this same block) had the same
    -- drift -- real names `_1rh`/`_1ri`, one of them (`_1rh`) also had a completely wrong position
    -- (fixed to -500,-13.071,-40, confirmed by 2 independent captures). `17035530`'s own position
    -- was already correct even under the wrong name, so this rename alone does NOT explain the
    -- wall persisting -- the 2026-08-20 hide-test result (wall stays solid when entity is hidden)
    -- still stands and still points at baked client geometry for this specific wall. Not resolved;
    -- see Assault_Issue_Tracker.md's Lebros Supplies entry for next steps.
    instance:getEntity(bit.band(ID.npc._1ri, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc._1rp, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

    -- 2026-08-20: Yazuhma had a real npc_list row but was never registered to this instance at
    -- all -- confirmed present and talked to repeatedly in the same capture. See npcs/Yazuhma.lua.
    instance:getEntity(bit.band(ID.npc.YAZUHMA, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)

    if progress >= 12 then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        -- 2026-08-20: was RUNE_UNLOCKED with (22, 10) params, which is the ASSAULT_x_START
        -- template's param shape, not this message's (it takes none) -- same bug class already
        -- fixed on Excavation Duty. Real capture confirms this mission's grid position, H-8 (letter
        -- index confirmed 0-based -- A=0 -- via the same capture's own decoded text and Num1
        -- params: {7, 8, ...} rendered as "(H-8)").
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 7, 8) -- H-8
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

