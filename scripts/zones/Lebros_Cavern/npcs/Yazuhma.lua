-----------------------------------
-- Area: Lebros Cavern (Lebros Supplies)
--  NPC: Yazuhma
-----------------------------------
-- Mission-giver NPC, staged next to Rune of Release/Ancient Lockbox. Had a real npc_list row but
-- was never registered to this instance at all (see instances/lebros_supplies.lua) -- confirmed
-- present and talked to repeatedly in the "Lebros Cavern PFC - Lebros Supplies (Thris)" capture
-- (2026-08-20).
-- 2026-08-20: full mechanic built from a community wiki writeup (BG Wiki-style walkthrough) plus
-- this mission's own capture-confirmed dialogue/item ids. Hands out one of 5 point-valued food
-- items (or a Seafood Stewpot that fills a whole Imperial Stormer group -- see
-- npcs/Imperial_Stormer.lua) whenever the player isn't already holding one. Which food is granted
-- is "sticky" per player until actually delivered (dropping it or eating it + Antacid still gets
-- the same item back next time), per the wiki -- modeled with a player localvar rather than pure
-- per-trigger RNG.
-----------------------------------
local ID = Lebros
-----------------------------------
-- Real item ids (sql/item_basic.sql) and point values, per the wiki writeup.
local FOOD_POINTS =
{
    [4356] = 1, -- loaf_of_white_bread
    [4416] = 2, -- bowl_of_pea_soup
    [5207] = 3, -- strip_of_bison_jerky
    [5166] = 4, -- coeurl_sub
    [5142] = 5, -- serving_of_bison_steak
}
local STEWPOT_ITEM = 5238 -- seafood_stewpot -- feeds every Stormer in one group to full
local ALL_FOOD_ITEMS = { 4356, 4416, 5207, 5166, 5142, STEWPOT_ITEM }


-- timer callbacks must not trust a captured player (stale-pointer crash): re-resolve by id
local function liveChar(instance, id)
    if instance then
        for _, v in pairs(instance:getChars()) do
            if v:getID() == id then
                return v
            end
        end
    end
    return nil
end

function onTrigger(player, npc)
    npc:lookAt(player:getPos())
    local instance = npc:getInstance()
    local playerId = player:getID()

    -- "Only the food items will feed the soldiers" -- and the wiki confirms re-asking Yazuhma while
    -- still holding one (even after dropping/Antacid-ing it, tracked via the localvar below) just
    -- repeats this line instead of granting a second item.
    for _, itemId in ipairs(ALL_FOOD_ITEMS) do
        if player:hasItem(itemId) then
            player:messageText(npc, ID.text.YAZUHMA_ALREADY_HAVE_RATION)
            return
        end
    end

    local itemId = player:getLocalVar("lebrosSuppliesFood")
    if itemId == 0 or (FOOD_POINTS[itemId] == nil and itemId ~= STEWPOT_ITEM) then
        itemId = ALL_FOOD_ITEMS[math.random(#ALL_FOOD_ITEMS)]
        player:setLocalVar("lebrosSuppliesFood", itemId)
    end

    player:addTempItem(itemId)

    player:messageText(npc, ID.text.YAZUHMA_GRANT_1)
    npc:timer(2000, function(n)
        local player = liveChar(instance, playerId)
        if player then player:messageText(n, ID.text.YAZUHMA_GRANT_2) end
    end)
    npc:timer(4000, function(n)
        local player = liveChar(instance, playerId)
        if not player then return end
        player:messageSpecial(ID.text.YAZUHMA_TEMP_ITEM_OBTAINED, itemId, 0, 0, 0, true)
    end)

    npc:timer(7000, function(npc)
        local player = liveChar(instance, playerId)
        if not player then return end
        local remaining = 12 - instance:getProgress()
        if remaining >= 7 then
            player:messageText(npc, ID.text.YAZUHMA_STILL_STARVING)
        elseif remaining >= 4 then
            player:messageText(npc, ID.text.YAZUHMA_HALFWAY)
        elseif remaining >= 2 then
            player:messageText(npc, ID.text.YAZUHMA_DENT)
        elseif remaining == 1 then
            player:messageText(npc, ID.text.YAZUHMA_LEFTOVER)
        end
    end)
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

