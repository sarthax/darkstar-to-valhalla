-----------------------------------
-- Assault: Saving Private Ryaaf
-----------------------------------
-- Built from data found sitting unwired in this repo's own SQL: 3 real, individually positioned
-- NPCs (Ryaaf, Balarahb, Rhagmakah) sitting right after RUNE_OF_RELEASE in sql/npc_list.sql, never
-- referenced anywhere in Lua.
--
-- Real mechanic, from a community wiki writeup (ffxiclopedia "Saving Private Ryaaf") cross-checked
-- against a real capture ("Periqia SP - Saving Private Ryaaf.zip"). Real objective is "Find the
-- survivors" -- not a fixed layout:
--   - 5 rooms (North/West/South/East/Center), each with a "hunched-over figure" that resolves to
--     one of the 3 real survivors or an Experimental Undead (Fomor), plus 3 ambient Cursed Chigoe.
--   - Exactly 5 possible room-assignment patterns (wiki table), picked randomly per instance --
--     always 3 rooms get a real survivor, 2 rooms get a Fomor instead.
--   - The room's occupant faces a different direction depending on whether it's a real NPC or a
--     Fomor -- a visual tell, confirmed by the wiki table and (partially) by real capture rotation
--     data. East is the one exception -- both NPC and Fomor face East there, no tell.
--
-- Real room positions and the room-to-compass mapping below are NOT a guess -- verified by finding
-- TWO real, independent capture-derived NPC placements (the original static npc_list.sql data, and
-- the fresh "Periqia SP" capture) and confirming both match a real wiki pattern EXACTLY once laid
-- out this way (old capture = pattern 3, new capture = pattern 1) -- see the room table and
-- PATTERNS below. Real per-room facing bytes are only independently confirmed for 3 of 5 cases
-- (North+NPC=90, East+NPC=133 -- also used for East+Fomor and Fomor-anywhere per the wiki's "always
-- faces East" rule, Center+NPC=254, all read directly off the fresh capture's NPCLogger `dir` field
-- for pattern 1). South+NPC ("faces West" per the wiki's own quirk) and West+NPC have no real
-- sample yet -- left as reasonable placeholders, flagged below, not capture-confirmed.
--
-- Real bugs found and fixed during live testing:
--   - Ryaaf/Balarahb/Rhagmakah's npc_list rows carry FLAG_UNTARGETABLE (entityFlags 2075) as their
--     real, correct pre-reveal default (confirmed by real capture history data showing this exact
--     value at spawn, every time) -- the transition to targetable is handled explicitly at the
--     real proximity-reveal moment (see revealOccupant()/REVEAL_DISTANCE below), not as a permanent
--     static default.
--   - Fomor rooms position a real HUNCHED_FIGURE decoy (2 npc_list rows, 17006818/819, reusing
--     Ryaaf's own look for a consistent hunched-cloaked appearance) instead of spawning the
--     Experimental Undead directly -- see npcs/Hunched_Figure.lua for the reveal-on-trigger logic
--     (same shape as Golden Salvage's Cursed_Chest.lua).
--   - The 2 HUNCHED_FIGURE decoys initially never worked at all -- their npc_list `name` field
--     ('HunchedFigure1'/'2') didn't match this file's actual name, and this engine resolves
--     onTrigger scripts by exact name match ("No Valid Function for HunchedFigure1" in the
--     map-server log). This also explained why Fomors never spawned -- the decoy that's supposed to
--     spawn them never ran its trigger logic at all.
--   - Cursed Chigoe were untargetable in-game -- their mob_pools entityFlags (2689) also had
--     FLAG_UNTARGETABLE set. Fixed in sql/mob_pools.sql (2689 -> 641, matching a real working
--     sibling, plain Chigoe poolid 714, which already uses 641).
--   - The 3 real survivors still showed their real name and could be told apart by name alone --
--     this engine has no separate hide-name mechanism independent of the same `name` field that
--     drives script lookup, so the real fix was renaming ALL 5 rooms' npc_list rows to the
--     identical 'Hunched_Figure', consolidating what used to be 4 separate files
--     (Ryaaf.lua/Balarahb.lua/Rhagmakah.lua/Hunched_Figure.lua) into one, npcs/Hunched_Figure.lua,
--     which tells the 5 apart by numeric id internally.
--
-- Not modeled: the wiki's separate "roaming true-seeing Fomors in the tunnels move according to
-- which rooms have the NPCs" behavior -- explicitly described as fully avoidable ambient content,
-- not needed for mission correctness, and there's no real path data for it. The 3 unused
-- Experimental Undead spawn points are still wired in as plain ambient roamers (no room-hint AI).
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Periqia
-----------------------------------
-- Real room positions (the 3 with a real NPC sample use that NPC's own real capture coordinate;
-- West has no NPC sample and uses its Cursed Chigoe cluster center instead, y-adjusted to match
-- the ~4-unit-deeper pattern seen on the other 4 rooms).
-- Facing bytes: see header for which are real vs. placeholder.
local ROOMS =
{
    N = { x = -70,  y = -19.25, z = 587.5, npcFacing = 90,  fomor = ID.mob[33].EXP_UNDEAD_NORTH },
    E = { x = 109,  y = -19.25, z = 448,   npcFacing = 133, fomor = ID.mob[33].EXP_UNDEAD_EAST },
    S = { x = -47,  y = -16.25, z = 295,   npcFacing = 192, fomor = ID.mob[33].EXP_UNDEAD_SOUTH }, -- npcFacing = West per wiki quirk; NOT capture-confirmed, using the engine's West byte (192) as a placeholder
    W = { x = -210, y = -19,    z = 458,   npcFacing = 192, fomor = ID.mob[33].EXP_UNDEAD_WEST },   -- npcFacing = West; NOT capture-confirmed, using the engine's West byte (192) as a placeholder
    C = { x = -58,  y = -19,    z = 412,   npcFacing = 254, fomor = ID.mob[33].EXP_UNDEAD_CENTER },
}
local FOMOR_FACING = 133 -- "always faces East regardless of room" per the wiki -- real capture value

-- Real reveal mechanic, found by reading a real capture's full entity history (not just a single
-- snapshot) -- 2 independent captures both show the identical sequence for all 3 real survivors: no
-- click/trigger event precedes the change at all, ruling out a player-initiated interaction.
-- legacy_flags goes 2075 (untargetable+hidden) -> 27 (targetable) at the same moment
-- legacy_animation goes 33 (hunched) -> 0 (standing) and legacy_namevis goes 72 (hidden) -> 0
-- (visible), all within about 3 seconds of each other -- proximity-based, not click-based. User
-- explicitly confirmed they should be untargetable while hunched, targetable after reveal (matching
-- the capture exactly). REVEAL_DISTANCE is a user-adjusted estimate, not capture-confirmed -- the
-- capture only proves reveal happens on approach, not the exact trigger radius. User wants this
-- very close/tight, matching a "practically standing next to it" trigger rather than a room-wide
-- detection range.
local REVEAL_DISTANCE = 4

-- Renaming a survivor here via setName() breaks their dialogue entirely -- luautils::OnTrigger
-- (src/map/lua/luautils.cpp:1596-1602) resolves the onTrigger script from the entity's LIVE
-- GetName() at click time, not a load-time binding, so renaming "Hunched_Figure" -> "Ryaaf" before
-- the player could click made every subsequent click look for a nonexistent npcs/Ryaaf.lua ("No
-- Valid Function for Ryaaf" in the map-server log). setName() itself is fine and still used -- see
-- npcs/Hunched_Figure.lua's onTrigger, which renames AFTER the click already resolved
-- (m_event.Script is fixed for this interaction at that point), so the staggered dialogue lines
-- display the real name without touching trigger routing.
local function revealOccupant(npc, player)
    if npc:getLocalVar("revealed") == 1 then
        return
    end
    npc:setLocalVar("revealed", 1)

    -- hideName(false) used to fire unconditionally for BOTH real survivors and Fomor decoys -- for
    -- a decoy, that put a nameplate over its head for the whole stand -> disappear -> real-Undead-
    -- spawns transition, which reads oddly since the decoy has no real identity to show (the real
    -- Experimental Undead mob shows its own name normally once it takes over, same as every other
    -- Experimental Undead in this instance -- no separate fix needed there). Real survivors still
    -- need this call -- their nameplate becoming visible here is part of the intended reveal (the
    -- actual name-swap to Ryaaf/Balarahb/Rhagmakah happens later, on click, in
    -- npcs/Hunched_Figure.lua). fomorId check moved up so this can be skipped for decoys.
    local fomorId = npc:getLocalVar("fomorId")
    local isFomor = fomorId and fomorId ~= 0

    npc:untargetable(false)
    if not isFomor then
        npc:hideName(false)
    end
    npc:setAnimation(0)
    npc:lookAt(player:getPos())

    -- Fomor decoys must ambush automatically the moment they're revealed -- a hostile monster
    -- doesn't wait for the player to click it first. Real survivors still require a real click
    -- (see npcs/Hunched_Figure.lua's onTrigger) since that's the actual "rescue" interaction.
    -- The 1.5s delay before disappearing the decoy lets its stand animation actually finish playing
    -- (spawning the real mob + disappearing the decoy in the same tick as setAnimation(0) above cut
    -- the hunched -> standing transition off mid-render, so the nameplate visibly rendered at the
    -- decoy's feet mid-transition).
    if isFomor then
        local fomorFacing = npc:getLocalVar("fomorFacing")
        local pos          = npc:getPos()
        local instance      = npc:getInstance()
        local pid           = player:getID() -- timers must not capture player (stale-player crash)

        npc:setLocalVar("triggered", 1)

        npc:timer(1500, function()
            npc:setStatus(STATUS_DISAPPEAR)

            -- setStatus() only queues its status-change broadcast for the next natural tick, same
            -- as setName()'s own "doesn't force it out immediately" behavior (npcs/Hunched_Figure.lua)
            -- -- calling SpawnMob() in the SAME tick raced the decoy's own disappear packet against
            -- the new mob's spawn/appearance packet. Now that the decoy has a real visible model
            -- (npc_list.sql, was an invisible placeholder before), losing that race left it looking
            -- like it's still there standing and fighting with the hunched figure's own model
            -- instead of the real Experimental Undead taking over (the underlying combat was always
            -- against the real Undead -- just visually masked). This 500ms delay gives the disappear
            -- a moment to actually land before spawning the replacement.
            npc:timer(500, function()
                local fomor = SpawnMob(fomorId, instance)
                local target = GetPlayerByID(pid)
                if fomor then
                    fomor:setPos(pos.x, pos.y, pos.z, fomorFacing)
                    if target then
                        fomor:updateClaim(target)
                        fomor:engage(target:getShortID())
                    end
                end
            end)
        end)
    end
end

-- The wiki's 5 real patterns, keyed by room. Room keys not listed for a given pattern are Fomors.
local PATTERNS =
{
    { N = "BALARAHB",  E = "RHAGMAKAH", C = "RYAAF" },                    -- 1 (matches the fresh capture exactly)
    { N = "RHAGMAKAH", W = "RYAAF",     C = "BALARAHB" },                 -- 2
    { N = "RYAAF",     S = "RHAGMAKAH", E = "BALARAHB" },                 -- 3 (matches the original static npc_list.sql data exactly)
    { W = "BALARAHB",  S = "RYAAF",     C = "RHAGMAKAH" },                -- 4
    { W = "RHAGMAKAH", S = "BALARAHB", E = "RYAAF" },                     -- 5
}

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_33_START, 33)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
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
    -- _1k1 barrier prop: must be visible and closed (impassable). npc_list default is animation 8 (open).
    local barrier = instance:getEntity(bit.band(17006840, 0xFFF), TYPE_NPC)
    if barrier then
        barrier:setStatus(STATUS_NORMAL)
        barrier:setAnimation(9)
    end
    -- Real capture-confirmed position (Thris Nov2025, "Saving Private Ryaaf") -- this mission never
    -- called setPos() for these shared entities, unlike sibling missions (requiem.lua,
    -- shooting_down_the_baron.lua), so they sat at npc_list's generic default (-495,-9.9,-72 /
    -- -495,-9.695,-75), nowhere near the real completion room.
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setPos(18.000, -15.000, 547.000, 32)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setPos(16.000, -15.000, 544.000, 32)
    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    local pattern = PATTERNS[math.random(#PATTERNS)]

    -- Exactly 2 rooms are Fomor rooms in every pattern -- one decoy each, no need for more than 2.
    local decoys = { ID.npc.HUNCHED_FIGURE1, ID.npc.HUNCHED_FIGURE2 }
    local nextDecoy = 1

    for roomKey, room in pairs(ROOMS) do
        local npcKey = pattern[roomKey]
        if npcKey then
            local survivor = instance:getEntity(bit.band(ID.npc[npcKey], 0xFFF), TYPE_NPC)
            survivor:setPos(room.x, room.y, room.z, room.npcFacing)
            survivor:setStatus(STATUS_NORMAL)
            -- The static namevis default (72, already includes FLAG_HIDE_NAME) isn't enough on its
            -- own to keep the identity hidden -- calling the real runtime hideName()
            -- (CLuaBaseEntity::hideName -> CBaseEntity::HideName(),
            -- src/map/lua/lua_baseentity.cpp:4074) explicitly instead of relying on a static SQL
            -- default that may be getting reset at spawn.
            survivor:hideName(true)
            -- Same "don't trust the static default alone" reasoning -- force the real
            -- hunched/untargetable state explicitly at spawn. setAnimation(33) matches this
            -- entity's own real captured hunched pose; untargetable(true) matches the real
            -- pre-reveal legacy_flags (2075). See revealOccupant() above for the proximity-based
            -- transition to standing/targetable/named.
            survivor:setAnimation(33)
            survivor:untargetable(true)
            survivor:setLocalVar("revealed", 0)
        else
            -- Decoy itself faces FOMOR_FACING, not room.npcFacing -- the facing hint has to be
            -- visible BEFORE the trigger to mean anything (that's the whole point of the wiki's
            -- "check their facing before approaching" tip).
            local decoy = instance:getEntity(bit.band(decoys[nextDecoy], 0xFFF), TYPE_NPC)
            nextDecoy = nextDecoy + 1
            decoy:setPos(room.x, room.y, room.z, FOMOR_FACING)
            decoy:setStatus(STATUS_NORMAL)
            decoy:hideName(true)
            decoy:setAnimation(33)
            decoy:untargetable(true)
            decoy:setLocalVar("revealed", 0)
            decoy:setLocalVar("fomorId", room.fomor)
            decoy:setLocalVar("fomorFacing", FOMOR_FACING)
        end
    end

    for i, v in pairs(ID.mob[33]) do
        if i:find("CURSED_CHIGOE") or i:find("EXP_UNDEAD_ROAM") then
            forceAggro(SpawnMob(v, instance))
        end
    end
end

local ROOM_OCCUPANTS =
{
    ID.npc.RYAAF, ID.npc.BALARAHB, ID.npc.RHAGMAKAH,
    ID.npc.HUNCHED_FIGURE1, ID.npc.HUNCHED_FIGURE2,
}

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)

    -- Proximity-based reveal, fires every real second (this hook's own native rate -- see
    -- src/map/instance.cpp's CInstance::CheckTime, 1s throttle) -- see revealOccupant() above for
    -- the full writeup. Cheap: 5 occupants x current party size, once a second.
    for _, npcId in ipairs(ROOM_OCCUPANTS) do
        local npc = instance:getEntity(bit.band(npcId, 0xFFF), TYPE_NPC)
        if npc and npc:getLocalVar("revealed") == 0 then
            for _, player in pairs(instance:getChars()) do
                if npc:checkDistance(player) <= REVEAL_DISTANCE then
                    revealOccupant(npc, player)
                    break
                end
            end
        end
    end
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress >= 3 then
        instance:complete()
    end
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 8, 7) -- I-7, real capture-confirmed
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

