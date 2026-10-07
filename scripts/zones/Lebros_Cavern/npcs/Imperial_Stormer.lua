require("scripts/globals/status")
-----------------------------------
-- Area: Lebros Cavern (Lebros Supplies)
--  NPC: Imperial Stormer
-----------------------------------
-- One of the 12 advance-unit soldiers the player feeds to full. Real mechanic (2026-08-20, built
-- from a community wiki writeup plus this mission's own capture-confirmed dialogue ids): each
-- Stormer needs 6 or 7 points of food (randomized per instance, see instances/lebros_supplies.lua)
-- -- delivered by simply talking to them while holding a food item from Yazuhma (no item unwanted
-- yes/no prompt, matches the wiki's "exchange takes place automatically" note). A Temporary
-- Seafood Stewpot (added to retail 2015-05-14, per the user) instantly fills every "surrounding"
-- Stormer instead of adding points. Mission completes once all 12 are full (instances/
-- lebros_supplies.lua, onInstanceProgressUpdate already gates on progress >= 12 -- progress now
-- increments once per Stormer that transitions to full, not once per trigger).
-- 2026-08-20 (later): "surrounding" corrected to a real distance check (STEWPOT_RADIUS) against
-- every other Stormer's live position, replacing an earlier static 5-group table -- the wiki's
-- described 5 clusters (2 WSW/2 SSW/3 SE/3 NW/2 N) are still real position data (see
-- instances/lebros_supplies.lua's STORMER_POS), just no longer used to gate who the Stewpot can
-- reach. 30 yalms comfortably covers the widest real intra-cluster spread (~25 yalms, the SE
-- group) while staying well under the narrowest gap between two different clusters (~77 yalms,
-- WSW-SSW) -- confirmed against the real capture-derived positions, not guessed.
-- 2026-08-25, real mechanic added: user-reported that Stormers are meant to roam within their own
-- cluster -- each has a visually distinct shield (npc_list's look-blob `sub` slot already varies
-- for real, 3 real values across the 12 rows: 0x702A/0x702C/0x702D, confirmed real data, not
-- invented here), and if they stay put, the player can just memorize "this spot = this Stormer"
-- instead of actually reading the shield. Implemented per the user's own suggestion: periodically
-- shuffle which member of a cluster occupies which of that cluster's own real position slots (all
-- 3/2 positions are real capture-confirmed spots already -- no new coordinates invented, and no
-- navmesh pathing risk since this is a position swap, not a walked route). `SHUFFLE_INTERVAL` is
-- an unconfirmed judgment call (no real source gives an exact timing).
-----------------------------------
local ID = Lebros
-----------------------------------
local SHUFFLE_INTERVAL = 25000 -- ms -- unconfirmed judgment call, see header

-- Same real per-cluster positions as instances/lebros_supplies.lua's STORMER_POS -- duplicated
-- here (not required) since this file owns the shuffle behavior.
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

-- Real clusters per the wiki (WSW-2/SSW-2/SE-3/NW-3/N-2), confirmed by grouping the real
-- positions above -- the first id in each list is the one whose onNpcSpawn kicks off that
-- cluster's shuffle timer, so it only runs once per cluster, not once per member.
local CLUSTERS =
{
    { ID.npc.IMPERIAL_STORMER1,  ID.npc.IMPERIAL_STORMER2  },
    { ID.npc.IMPERIAL_STORMER3,  ID.npc.IMPERIAL_STORMER4  },
    { ID.npc.IMPERIAL_STORMER5,  ID.npc.IMPERIAL_STORMER6,  ID.npc.IMPERIAL_STORMER7  },
    { ID.npc.IMPERIAL_STORMER8,  ID.npc.IMPERIAL_STORMER9,  ID.npc.IMPERIAL_STORMER10 },
    { ID.npc.IMPERIAL_STORMER11, ID.npc.IMPERIAL_STORMER12 },
}

local function shuffleCluster(cluster, instance)
    local positions = {}
    for i, id in ipairs(cluster) do
        positions[i] = STORMER_POS[id]
    end

    -- Fisher-Yates.
    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end

    for i, id in ipairs(cluster) do
        local stormer = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if stormer then
            stormer:setPos(positions[i][1], positions[i][2], positions[i][3], 0)
        end
    end
end

-- Real item ids (sql/item_basic.sql) and point values, per the wiki writeup.
local FOOD_POINTS =
{
    [4356] = 1, -- loaf_of_white_bread
    [4416] = 2, -- bowl_of_pea_soup
    [5207] = 3, -- strip_of_bison_jerky
    [5166] = 4, -- coeurl_sub
    [5142] = 5, -- serving_of_bison_steak
}
local STEWPOT_ITEM   = 5238 -- seafood_stewpot
local STEWPOT_RADIUS = 30   -- yalms -- see header for how this was picked

local ALL_STORMER_IDS =
{
    ID.npc.IMPERIAL_STORMER1,  ID.npc.IMPERIAL_STORMER2,  ID.npc.IMPERIAL_STORMER3,
    ID.npc.IMPERIAL_STORMER4,  ID.npc.IMPERIAL_STORMER5,  ID.npc.IMPERIAL_STORMER6,
    ID.npc.IMPERIAL_STORMER7,  ID.npc.IMPERIAL_STORMER8,  ID.npc.IMPERIAL_STORMER9,
    ID.npc.IMPERIAL_STORMER10, ID.npc.IMPERIAL_STORMER11, ID.npc.IMPERIAL_STORMER12,
}

function onSpawn(npc)
    for _, cluster in ipairs(CLUSTERS) do
        if cluster[1] == npc:getID() then
            local instance = npc:getInstance()
            local function tick(n)
                shuffleCluster(cluster, instance)
                n:timer(SHUFFLE_INTERVAL, tick)
            end
            npc:timer(SHUFFLE_INTERVAL, tick)
            break
        end
    end
end

-- Marks one Stormer full and advances mission progress, if it wasn't full already. Shared by both
-- the direct-feed path and the Stewpot's group-wide fill.
local function feedToFull(stormer, instance)
    if stormer:getLocalVar("full") == 1 then
        return
    end
    stormer:setLocalVar("full", 1)
    instance:setProgress(instance:getProgress() + 1)
end

function onTrigger(player, npc)
    local instance = npc:getInstance()
    local isFull = npc:getLocalVar("full") == 1

    npc:lookAt(player:getPos())
    player:messageText(npc, isFull and ID.text.IMPERIAL_STORMER_MORE or ID.text.IMPERIAL_STORMER_THANKS)

    local heldItem = nil
    local isStewpot = false

    if player:hasItem(STEWPOT_ITEM) then
        heldItem = STEWPOT_ITEM
        isStewpot = true
    else
        for itemId in pairs(FOOD_POINTS) do
            if player:hasItem(itemId) then
                heldItem = itemId
                break
            end
        end
    end

    if not heldItem then
        local playerId = player:getID()
        npc:timer(2000, function(n)
            local p = nil
            for _, v in pairs(instance:getChars()) do
                if v:getID() == playerId then p = v end
            end
            if p then p:messageText(n, isFull and ID.text.IMPERIAL_STORMER_FULL_BELLY or ID.text.IMPERIAL_STORMER_PROVISIONS) end
        end)
        return
    end

    if isFull then
        -- Can't feed a Stormer who's already full -- keep the food, no exchange.
        return
    end

    -- 2026-08-20: delItem needs the TEMPITEMS container explicitly -- it defaults to main
    -- inventory (location 0), and the food granted by Yazuhma's addTempItem() lives in
    -- LOC_TEMPITEMS (3), not there. Without this, delItem silently no-ops (SearchItem finds
    -- nothing in inventory), the player never actually loses the food, and it could feed an
    -- unlimited number of Stormers off one grant while Yazuhma perpetually refuses a new one.
    player:delItem(heldItem, 1, LOC_TEMPITEMS)
    player:setLocalVar("lebrosSuppliesFood", 0)

    if isStewpot then
        for _, id in ipairs(ALL_STORMER_IDS) do
            local other = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if other and npc:checkDistance(other) <= STEWPOT_RADIUS then
                feedToFull(other, instance)
            end
        end
    else
        local points = (npc:getLocalVar("points") or 0) + FOOD_POINTS[heldItem]
        npc:setLocalVar("points", points)
        if points >= npc:getLocalVar("threshold") then
            feedToFull(npc, instance)
        end
    end
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-23: removed an empty onEventFinish stub -- part of the systemic
-- instance-timeout black-screen fix (see documentation/Assault_Fix_Log.md, the
-- 2026-08-18 'SYSTEMIC' entry, and Nyzul_Isle/npcs/Rune_of_Transfer.lua's own header
-- comment). An empty-but-defined onEventFinish here permanently pins
-- PChar->m_event.Script to this file whenever it's the last NPC a player clicked
-- (the custom EVENTFIX patch preserves that pin across resets), so LoadEventScript
-- never falls through to Zone.lua's real csid==102 handler on instance
-- timeout/mission-failed -- the eject cutscene plays, the client acks it, and the
-- player is never actually removed from the failed instance: stuck at a black
-- screen forever. Deleting the stub (this file has no real per-csid logic to keep)
-- lets dispatch reach the working fallback.

