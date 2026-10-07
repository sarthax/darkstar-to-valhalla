-----------------------------------
-- func: salvagedrinks [quantity]
-- desc: GM debug command - adds one of each of the 13 real Salvage "Bottle of X's Drink" items
--       to the player's inventory for testing (item_basic.sql ids 5385-5397). These are hard to
--       obtain randomly in normal play (Armoury Crate temp-item pool), hence this shortcut.
--
-- Usage: !salvagedrinks        -- adds 1 of each
--        !salvagedrinks 5      -- adds 5 of each
-----------------------------------
cmdprops =
{
    permission = 1,
    parameters = "i"
}

local DRINKS =
{
    5385, -- Bottle of Barbarian's Drink
    5386, -- Bottle of Fighter's Drink
    5387, -- Bottle of Oracle's Drink
    5388, -- Bottle of Assassin's Drink
    5389, -- Bottle of Spy's Drink
    5390, -- Bottle of Braver's Drink
    5391, -- Bottle of Soldier's Drink
    5392, -- Bottle of Champion's Drink
    5393, -- Bottle of Monarch's Drink
    5394, -- Bottle of Gnostic's Drink
    5395, -- Bottle of Cleric's Drink
    5396, -- Bottle of Shepherd's Drink
    5397, -- Bottle of Sprinter's Drink
}

function onTrigger(player, quantity)
    quantity = tonumber(quantity) or 1
    if quantity < 1 then
        quantity = 1
    end

    for _, itemId in ipairs(DRINKS) do
        if player:getFreeSlotsCount() == 0 then
            player:PrintToPlayer(string.format("[SALVAGEDRINKS] Inventory full -- stopped before item %d.", itemId))
            return
        end
        player:addItem(itemId, quantity)
    end

    player:PrintToPlayer(string.format("[SALVAGEDRINKS] Added %d of each of the 13 Salvage drink items.", quantity))
end
