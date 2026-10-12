-----------------------------------
-- Global functionality for Ephemeral Moogles (crystal storage)
-- Ported from Topaz scripts/globals/ephemeral.lua
-- Crystals are stored in char_points (fire_crystals .. dark_crystals)
-----------------------------------
require("scripts/globals/npc_util");
-----------------------------------

ephemeral = {};

-- Cap per crystal type that can be stored. Retail/Default is 5000
local CrystalCap = 5000;

-- Information for currency storage and event params
local crystalData =
{
    { crystal = 4096, cluster = 4104, tradeparam = 1, eventparam = 1, offset = 0,  name = "fire_crystals" },      -- Fire
    { crystal = 4097, cluster = 4105, tradeparam = 2, eventparam = 1, offset = 16, name = "ice_crystals" },       -- Ice
    { crystal = 4098, cluster = 4106, tradeparam = 3, eventparam = 2, offset = 0,  name = "wind_crystals" },      -- Wind
    { crystal = 4099, cluster = 4107, tradeparam = 4, eventparam = 2, offset = 16, name = "earth_crystals" },     -- Earth
    { crystal = 4100, cluster = 4108, tradeparam = 5, eventparam = 3, offset = 0,  name = "lightning_crystals" }, -- Lightning
    { crystal = 4101, cluster = 4109, tradeparam = 6, eventparam = 3, offset = 16, name = "water_crystals" },     -- Water
    { crystal = 4102, cluster = 4110, tradeparam = 7, eventparam = 4, offset = 0,  name = "light_crystals" },     -- Light
    { crystal = 4103, cluster = 4111, tradeparam = 8, eventparam = 4, offset = 16, name = "dark_crystals" },      -- Dark
};

-- Helper function for getting crystal counts as params
local function getCrystalTotals(player)
    local params = { 0, 0, 0, 0 };
    for _, v in pairs(crystalData) do
        params[v.eventparam] = bit.bor(params[v.eventparam], bit.lshift(player:getCurrency(v.name), v.offset));
    end
    return params;
end

-- Confirm up to qty of itemId across trade slots (confirmItem takes a SLOT id, not an item id)
local function confirmItemQty(trade, itemId, qty)
    local left = qty;
    for slot = 0, 7 do
        if (left <= 0) then break; end
        if (trade:getItemId(slot) == itemId) then
            local take = math.min(trade:getSlotQty(slot), left);
            if (take > 0 and trade:confirmItem(slot, take)) then
                left = left - take;
            end
        end
    end
    return qty - left;
end

-- Give items with a zone-local obtained message (bare ITEM_OBTAINED global can belong to another zone)
local function giveCrystals(player, itemId, qty, obtainedMsg)
    if (player:getFreeSlotsCount() < math.ceil(qty / 12)) then return 0; end
    -- addItem places at most one stack (12) per call, so hand out one stack at a time
    local left = qty;
    while (left > 0) do
        local n = math.min(left, 12);
        if (player:addItem(itemId, n)) then
            player:messageSpecial(obtainedMsg, itemId);
        else
            break;
        end
        left = left - n;
    end
    return qty - left;
end

function ephemeral.onTrade(player, trade, successEvent, failEvent)
    local params = { 0, 0, 0, 0, 0, 0, 0, 0 };
    local success = false;
    for _, v in pairs(crystalData) do
        if (trade:getItemQty(v.crystal) > 0 or trade:getItemQty(v.cluster) > 0) then
            local currentCount = math.min(player:getCurrency(v.name), CrystalCap);
            local diff = CrystalCap - currentCount;

            local hqQty = math.min(trade:getItemQty(v.cluster), math.floor(diff / 12));
            hqQty = confirmItemQty(trade, v.cluster, hqQty);
            diff = math.max(diff - hqQty * 12, 0);

            local qty = math.min(trade:getItemQty(v.crystal), diff);
            qty = confirmItemQty(trade, v.crystal, qty);

            params[v.tradeparam] = hqQty + qty * 65536;

            local total = qty + hqQty * 12;
            if (total > 0) then
                player:addCurrency(v.name, total);
                success = true;
            end
        end
    end

    if (success) then
        player:startEvent(successEvent, unpack(params));
    else
        player:startEvent(failEvent);
    end
end

function ephemeral.onTrigger(player, event)
    local totals = getCrystalTotals(player);
    player:startEvent(event, totals[1], totals[2], totals[3], totals[4], 0, 0, 0, 0);
end

function ephemeral.onEventUpdate(player, csid, option, wasTrade)
    -- Only the trade event has updates (matches LSB)
    if (wasTrade) then
        player:confirmTrade();
        player:updateEvent(unpack(getCrystalTotals(player)));
    end
end

function ephemeral.onEventFinish(player, option, wasTrade, obtainedMsg)
    -- Early out if the player cancelled the menu
    if (not wasTrade and bit.band(option, 0xFFFF) == 0) then
        return;
    end

    if (wasTrade) then
        player:confirmTrade();
        return;
    end

    -- Grab the crystal type and quantities
    local index = bit.band(bit.rshift(option, 16), 0xFF);
    local quantity = bit.band(option, 0xFFFF);
    local crystals = quantity % 12;
    local clusters = math.floor(quantity / 12);

    if (crystalData[index] == nil) then
        return;
    end

    -- Player selected "as many as can fit"
    option = option % 4294967296;
    if (option > 0x80000000) then
        local freeSlots = player:getFreeSlotsCount();
        if (freeSlots > 0) then
            local clusterStacks = math.ceil(clusters / 12);

            -- If we don't have room for everything, drop the extra crystals first
            if ((clusterStacks + math.ceil(crystals / 12)) > freeSlots) then
                crystals = 0;
            end

            clusterStacks = math.min(clusterStacks, freeSlots);
            clusters = math.min(clusters, clusterStacks * 12);
        end
    end

    local totalToRemove = 0;

    -- Clusters first
    if (clusters > 0) then
        totalToRemove = giveCrystals(player, crystalData[index].cluster, clusters, obtainedMsg) * 12;
    end

    -- Then crystals
    if (crystals > 0) then
        totalToRemove = totalToRemove + giveCrystals(player, crystalData[index].crystal, crystals, obtainedMsg);
    end

    -- Remove what was handed out from char_points
    if (totalToRemove > 0) then
        player:delCurrency(crystalData[index].name, totalToRemove);
    end
end
