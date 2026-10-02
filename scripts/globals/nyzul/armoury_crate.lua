-----------------------------------
-- Nyzul Isle: Armoury Crate (temp-item version -- Free Floor scattered crates)
-----------------------------------
-- 2026-09-02: ported from LandSandBoat's scripts/globals/nyzul/armoury_crate.lua's tempBoxTrigger/
-- tempBoxFinish only. Item ids reused from vending_box.lua's already-verified real Topaz ids (see
-- that file's header) -- not LSB's numbers.
--
-- NOT ported: handleAppraisalItem and the 90-entry per-NM appraisal-origin table (LSB's real
-- getAppraisalID/setAppraisalID C++ item field + LSB's own "???"-item-per-slot appraisal-pool
-- flow). Deliberately superseded rather than ported.
--
-- 2026-09-04: RESOLVED -- the real per-NM unique-item reward is delivered a different, simpler
-- real way: each floor NM's own real dropid was cross-referenced and repointed in
-- sql/mob_groups.sql (zone 77) to the SAME real drop table its overworld/dungeon counterpart
-- already uses elsewhere in the game (e.g. Cactuar_Cantautor's own pre-existing dropid=397
-- already included item 2196 = '???_footwear'; Leaping_Lizzy was repointed from the shared
-- placeholder dropid 906 to its own real dropid=1504 from zone 107). Topaz's engine populates the
-- killer's Treasure Pool automatically from a mob's dropid on death (mobentity.cpp:871) --
-- standard behavior for every mob in the game, no crate/coffer prop or appraisal step needed. This
-- is a real, deliberate simplification over the user's own explicit choice (2026-09-04): skip the
-- ???-item/appraisal detour (Topaz has no getAppraisalID/setAppraisalID equivalent, and building
-- one would be genuine new C++ purely to reproduce a middleman step) and let the Treasure Pool
-- drop be the reward directly. One name (Sabotender_Bailarin) has no real drop data anywhere in
-- SQL and was deliberately left on the placeholder rather than guessed.
--
-- csid 2 and its bit-packed option encoding (itemID + amount*65536 per slot) are ported from LSB
-- as-is -- not yet confirmed against one of our own Nyzul Isle captures. Topaz does have its own
-- real, working temp-item-chest mechanism (scripts/globals/caskets.lua, csid range 1000-1048) --
-- not reused here since it's tied to a different entity/model (the generic outdoor "casket" prop)
-- and its own zones[...].npc.CASKET_BASE convention, whereas Nyzul's Armoury Crate is its own
-- distinct real entity (per the wiki: "blue and gold in color").
-----------------------------------
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
tpz = tpz or {}
Nyzul = Nyzul or {}

-- Real Topaz item ids (see vending_box.lua for the name->id resolution against item_basic.sql).
local tempBoxItems =
{
    [ 1] = { itemID = 5385, amount = math.random(1, 3) }, -- Bottle of Barbarian's Drink
    [ 2] = { itemID = 5386, amount = math.random(1, 3) }, -- Bottle of Fighter's Drink
    [ 3] = { itemID = 5387, amount = math.random(1, 3) }, -- Bottle of Oracle's Drink
    [ 4] = { itemID = 5388, amount = math.random(1, 3) }, -- Bottle of Assassin's Drink
    [ 5] = { itemID = 5389, amount = math.random(1, 3) }, -- Bottle of Spy's Drink
    [ 6] = { itemID = 5390, amount = math.random(1, 3) }, -- Bottle of Braver's Drink
    [ 7] = { itemID = 5391, amount = math.random(1, 3) }, -- Bottle of Soldier's Drink
    [ 8] = { itemID = 5392, amount = math.random(1, 3) }, -- Bottle of Champion's Drink
    [ 9] = { itemID = 5393, amount = math.random(1, 3) }, -- Bottle of Monarch's Drink
    [10] = { itemID = 5394, amount = math.random(1, 3) }, -- Bottle of Gnostic's Drink
    [11] = { itemID = 5395, amount = math.random(1, 3) }, -- Bottle of Cleric's Drink
    [12] = { itemID = 5396, amount = math.random(1, 3) }, -- Bottle of Shepherd's Drink
    [13] = { itemID = 5397, amount = math.random(1, 3) }, -- Bottle of Sprinter's Drink
    [14] = { itemID = 5437, amount = math.random(1, 5) }, -- Flask of Strange Milk
    [15] = { itemID = 5438, amount = math.random(1, 5) }, -- Bottle of Strange Juice
    [16] = { itemID = 5434, amount = 1                 }, -- Bottle of Fanatic's Drink
    [17] = { itemID = 5435, amount = 1                 }, -- Bottle of Fool's Drink
    [18] = { itemID = 5440, amount = 1                 }, -- Dusty Wing
    [19] = { itemID = 5439, amount = math.random(1, 3) }, -- Bottle of Vicar's Drink
    [20] = { itemID = 5431, amount = math.random(1, 3) }, -- Dusty Potion
    [21] = { itemID = 5432, amount = math.random(1, 3) }, -- Dusty Ether
    [22] = { itemID = 5433, amount = 1                 }, -- Dusty Elixir
}

Nyzul.tempBoxTrigger = function(player, npc)
    if npc:getLocalVar("itemsPicked") == 0 then
        local pool = {}
        for i = 1, #tempBoxItems do
            table.insert(pool, tempBoxItems[i])
        end

        local item2Roll = math.random(1, 100)
        local item3Roll = math.random(1, 100)

        local entry = math.random(1, #pool)
        local item = pool[entry]
        npc:setLocalVar("itemID_1", item.itemID)
        npc:setLocalVar("itemAmount_1", item.amount)
        table.remove(pool, entry)

        if item2Roll <= 60 and #pool > 0 then
            entry = math.random(1, #pool)
            item = pool[entry]
            npc:setLocalVar("itemID_2", item.itemID)
            npc:setLocalVar("itemAmount_2", item.amount)
            table.remove(pool, entry)
        end

        if item2Roll <= 60 and item3Roll <= 20 and #pool > 0 then
            entry = math.random(1, #pool)
            item = pool[entry]
            npc:setLocalVar("itemID_3", item.itemID)
            npc:setLocalVar("itemAmount_3", item.amount)
            table.remove(pool, entry)
        end

        npc:entityAnimationPacket("open")
        npc:AnimationSub(13)
        npc:setLocalVar("itemsPicked", 1)
    end

    player:startEvent(
        2,
        npc:getLocalVar("itemID_1") + npc:getLocalVar("itemAmount_1") * 65536,
        npc:getLocalVar("itemID_2") + npc:getLocalVar("itemAmount_2") * 65536,
        npc:getLocalVar("itemID_3") + npc:getLocalVar("itemAmount_3") * 65536
    )
end

local function giveSlot(player, npc, slotIndex)
    local idVar = "itemID_" .. slotIndex
    local amountVar = "itemAmount_" .. slotIndex
    local itemId = npc:getLocalVar(idVar)
    local amount = npc:getLocalVar(amountVar)

    if itemId <= 0 or amount <= 0 then
        return
    end

    if player:hasItem(itemId, LOC_TEMPITEMS) then
        -- 2026-09-04: real id confirmed -- dialog_text zoneid 77 idx 7345 is generic "You already
        -- have that temporary item." (no vending-specific wording), same real id vending_box.lua
        -- already uses for the identical case.
        player:messageSpecial(NyzulIsle.text.VENDING_ALREADY_HAVE_ITEM, itemId)
        return
    end

    player:addTempItem(itemId)
    -- 2026-09-04: real id confirmed -- dialog_text zoneid 77 idx 7344 is generic "Obtained
    -- temporary item: <item>!" (no vending-specific wording), same real id vending_box.lua already
    -- uses for the identical case. Replaces the previous ITEM_OBTAINED (6388, "Obtained: <item>.",
    -- the non-temp-item wording) stand-in.
    player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, itemId)
    npc:setLocalVar(amountVar, amount - 1)
end

Nyzul.tempBoxFinish = function(player, csid, option, npc)
    if csid ~= 2 then
        return
    end

    if option == 1 then
        giveSlot(player, npc, 1)
    elseif option == 2 then
        giveSlot(player, npc, 2)
    elseif option == 3 then
        giveSlot(player, npc, 3)
    end

    if
        npc:getLocalVar("itemAmount_1") <= 0 and
        npc:getLocalVar("itemAmount_2") <= 0 and
        npc:getLocalVar("itemAmount_3") <= 0
    then
        npc:timer(10000, function(crate)
            -- CUTSCENE_ONLY (not DISAPPEAR) matches this specific pool's own default/rest state
            -- in npc_list.sql (status 6) -- restoring it rather than a different hidden state.
            crate:setStatus(STATUS_CUTSCENE_ONLY)
            crate:AnimationSub(0)
            crate:resetLocalVars()
        end)
    end
end

return Nyzul
