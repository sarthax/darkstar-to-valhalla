-----------------------------------
-- Event Storage NPCs (port of LandSandBoat scripts/globals/event_storage.lua)
-- Olaky-Yayulaky (Windurst Waters), Poudoruchant (Southern San d'Oria), Gallagher (Port Bastok),
-- Garridan (Port Jeuno), Jarafah (Aht Urhgan Whitegate)
-- The NPC holds one of each listed event item for free. Taking it back costs a fee.
--
-- CSIDs verified against the Valhalla client DATs with explore_event.py (2026-10-17,
-- DSP-LSB-Gap-Audit/report/10e_event_storage_dat.txt). Item ids generated from LSB's item enum and
-- cross-checked by name against DSP item_basic. Race ids: Hume M/F 1/2, Elvaan M/F 3/4,
-- Taru M/F 5/6, Mithra 7, Galka 8.
-----------------------------------
require("scripts/globals/utils");
-----------------------------------

EventStorage = {};

-- { store event, storage menu }
local storageEvents =
{
    [50 ] = { 701, 702 }, -- Aht Urhgan Whitegate
    [236] = { 348, 349 }, -- Port Bastok
    [246] = { 307, 308 }, -- Port Jeuno
    [230] = { 778, 779 }, -- Southern San d'Oria
    [238] = { 909, 910 }, -- Windurst Waters
};

-- The client menu shows 250 gil (state2[23] = 250 in the event DAT), so the fee is 250.
EventStorage.withdrawalFee = 250;

-- Enchanted items (item_armor rows with item_usable.validTargets ~= 0, which DSP flags ITEM_CHARGED).
-- They are returned with their recast at the maximum via addUsedItem.
local chargedItems = {};
for _, id in ipairs({11273,11274,11275,11276,11277,11278,11279,11280,11290,11491,11500,14532,14533,14534,14535,15179,15198,15199,15204,15753,16118,16119,16120,16145,16182,16183,17588,17748,18400,18401,18845}) do
    chargedItems[id] = true;
end

-- Each category is one parameter of the storage menu. Bit n means the item at position n + 1 is stored.
-- Race/gender locked slots hold every variant; withdrawal gives the player's own race/gender.
-- optionBlocks holds { first position, option for that position } per block (options are not contiguous).
local categories =
{
    -- Furnishings 1
    {
        var          = 'evStor_furnishings1',
        optionBlocks = { { 1, 0 }, { 17, 64 } },
        items        =
        {
            86,
            115,
            116,
            87,
            117,
            118,
            119,
            193,
            88,
            154,
            204,
            203,
            205,
            140,
            141,
            155,
            192,
            179,
            323,
            324,
            325,
            176,
            177,
            178,
            180,
            215,
            196,
            197,
            199,
            320,
            415,
        },
    },

    -- Weapons and shields
    {
        var          = 'evStor_weapons',
        optionBlocks = { { 1, 16 }, { 17, 92 } },
        items        =
        {
            17074,
            17565,
            17566,
            17588,
            17830,
            17831,
            18102,
            18103,
            18400,
            18436,
            18401,
            18846,
            18845,
            18441,
            17748,
            17749,
            16182,
            16183,
            18863,
            18864,
        },
    },

    -- Armor - Head
    {
        var          = 'evStor_head',
        optionBlocks = { { 1, 32 }, { 17, 80 } },
        items        =
        {
            13916,
            13917,
            15176,
            15177,
            15178,
            15179,
            15198,
            15199,
            15204,
            16075,
            16076,
            16109,
            16118,
            16119,
            16120,
            16144,
            16145,
            11491,
            11500,
        },
    },

    -- Armor - Body, Legs, Feet
    {
        var          = 'evStor_body',
        optionBlocks = { { 1, 48 }, { 17, 84 }, { 22, 126 } },
        items        =
        {
            { male = 13819, female = 13820 },
            { male = 13821, female = 13822 },
            {
                [1  ] = 14450,
                [2  ] = 14451,
                [3] = 14452,
                [4] = 14453,
                [5  ] = 14454,
                [6  ] = 14471,
                [7  ] = 14455,
                [8   ] = 14456,
            },
            {
                [1  ] = 14457,
                [2  ] = 14458,
                [3] = 14459,
                [4] = 14460,
                [5  ] = 14461,
                [6  ] = 14472,
                [7  ] = 14462,
                [8   ] = 14463,
            },
            {
                [1  ] = 15408,
                [2  ] = 15409,
                [3] = 15410,
                [4] = 15411,
                [5  ] = 15412,
                [6  ] = 15423,
                [7  ] = 15413,
                [8   ] = 15414,
            },
            {
                [1  ] = 15415,
                [2  ] = 15416,
                [3] = 15417,
                [4] = 15418,
                [5  ] = 15419,
                [6  ] = 15424,
                [7  ] = 15420,
                [8   ] = 15421,
            },
            14519,
            14520,
            { male = 14532, female = 14533 },
            { male = 14534, female = 14535 },
            15752,
            15753,
            {
                [1  ] = 11265,
                [2  ] = 11266,
                [3] = 11267,
                [4] = 11268,
                [5  ] = 11269,
                [6  ] = 11270,
                [7  ] = 11271,
                [8   ] = 11272,
            },
            {
                [1  ] = 11273,
                [2  ] = 11274,
                [3] = 11275,
                [4] = 11276,
                [5  ] = 11277,
                [6  ] = 11278,
                [7  ] = 11279,
                [8   ] = 11280,
            },
            {
                [1  ] = 16321,
                [2  ] = 16322,
                [3] = 16323,
                [4] = 16324,
                [5  ] = 16325,
                [6  ] = 16326,
                [7  ] = 16327,
                [8   ] = 16328,
            },
            {
                [1  ] = 16329,
                [2  ] = 16330,
                [3] = 16331,
                [4] = 16332,
                [5  ] = 16333,
                [6  ] = 16334,
                [7  ] = 16335,
                [8   ] = 16336,
            },
            11300,
            11301,
            11290,
            { male = 11316, female = 11317 },
            { male = 11318, female = 11319 },
            11355,
            16378,
        },
    },

    -- Furnishings 2
    {
        var          = 'evStor_furnishings2',
        optionBlocks = { { 1, 96 } },
        items        =
        {
            264,
            455,
            265,
            266,
            267,
            456,
            457,
            458,
            138,
            269,
            3641,
            3642,
            270,
            271,
            3643,
            3644,
            3645,
            181,
            182,
            183,
            3622,
            3623,
            3624,
            3646,
        },
    },
}


local slotByItemId = {};
local slotByOption = {};
for categoryIndex, category in ipairs(categories) do
    for position, entry in ipairs(category.items) do
        local slot = { categoryIndex, position };
        if (type(entry) == "table") then
            for _, itemId in pairs(entry) do
                slotByItemId[itemId] = slot;
            end
        else
            slotByItemId[entry] = slot;
        end

        local blockStart  = 1;
        local blockOption = 0;
        for _, block in ipairs(category.optionBlocks) do
            if (position >= block[1]) then
                blockStart  = block[1];
                blockOption = block[2];
            end
        end
        slotByOption[blockOption + position - blockStart] = slot;
    end
end

local function itemForPlayer(player, entry)
    if (type(entry) == "number") then
        return entry;
    end

    -- getGender() returns 1 for male and 0 for female.
    if (entry.male) then
        if (player:getGender() == 1) then
            return entry.male;
        end
        return entry.female;
    end

    return entry[player:getRace()];
end

function EventStorage.onTrade(player, npc, trade)
    local events = storageEvents[player:getZoneID()];
    if (events == nil or trade:getItemCount() ~= 1 or trade:getGil() ~= 0) then
        return;
    end

    local itemId = trade:getItemId(0);
    local slot   = slotByItemId[itemId];

    -- One listed item per trade. Anything else gets no reply.
    if (slot == nil or trade:hasItemQty(itemId, 1) == false) then
        return;
    end

    local category = categories[slot[1]];
    local mask     = player:getVar(category.var);

    -- Only one variant can be stored in each slot.
    if (utils.mask.getBit(mask, slot[2] - 1)) then
        return;
    end

    if (player:tradeComplete() == false) then
        return;
    end

    player:setVar(category.var, utils.mask.setBit(mask, slot[2] - 1, true));
    player:startEvent(events[1], itemId);
end

function EventStorage.onTrigger(player, npc)
    local events = storageEvents[player:getZoneID()];
    if (events == nil) then
        return;
    end

    local masks = {};
    for categoryIndex, category in ipairs(categories) do
        masks[categoryIndex] = player:getVar(category.var);
    end

    -- Furnishings 1, weapons, head, body, the player's gil, furnishings 2. Retail sends garbage in the last two.
    player:startEvent(events[2], masks[1], masks[2], masks[3], masks[4], player:getGil(), masks[5], 0, 0);
end

function EventStorage.onEventFinish(player, csid, option)
    local events = storageEvents[player:getZoneID()];
    local slot   = slotByOption[option];

    -- Every other way out of the menu returns 0x40000000.
    if (events == nil or csid ~= events[2] or slot == nil) then
        return;
    end

    local category = categories[slot[1]];
    local mask     = player:getVar(category.var);

    if (utils.mask.getBit(mask, slot[2] - 1) == false or player:getGil() < EventStorage.withdrawalFee) then
        return;
    end

    local itemId = itemForPlayer(player, category.items[slot[2]]);
    if (itemId == nil) then
        return;
    end

    -- ITEM_CANNOT_BE_OBTAINED / ITEM_OBTAINED are the zone TextIDs globals of the calling NPC script.
    if (player:getFreeSlotsCount() == 0) then
        player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, itemId);
        return;
    end

    local given;
    if (chargedItems[itemId]) then
        given = player:addUsedItem(itemId);
    else
        given = player:addItem(itemId, 1);
    end
    if (given == false or given == nil) then
        return;
    end

    player:messageSpecial(ITEM_OBTAINED, itemId);
    player:delGil(EventStorage.withdrawalFee);
    player:setVar(category.var, utils.mask.setBit(mask, slot[2] - 1, false));
end
