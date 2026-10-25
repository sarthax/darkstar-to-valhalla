-----------------------------------
-- Chocobo Raising (VCS) - walks: short (cmd 242 arg 42), regular (arg 43), long (arg 44).
-- Ported from LandSandBoat hobbies/chocobo_raising event_vm.lua handleGoOnAWalk; energy costs, the p1 encoding and the
-- walk csids come from the Complete Timeline [SandOria] capture, not from LSB (LSB's 25/33/50 + 0..5 does not match).
-- Reply: updateEvent(walkCsid, (energyAfter << 8) | energyBefore, 7 if an item was found, 0, stage, 0, 0, weather).
-- Not enough energy: p1 = -1.
-- Watch Over (cmd 242 arg 48, 12530): reply (watchCsid, (after<<8)|before, 1 = item given, held item, stage, 0, 0, 1). Captured cost
-- is 3 or 4 energy (LSB says 5), none for an egg (p1 = energy*257). Full bag = p2 2 is LSB's, not in the captures. The found item is only handed over by Watch Over (cmd 243), not by the walk itself.
-- Cost: base + 0..1 in clear weather (weather 0/1 in the walk zone), base + 6/8/9 otherwise (captures: 23-24/29-30 short,
-- 31-32/39-40 regular, 38/47-48 long). Weather is the walk zone's, via the GetZoneWeather global.
-- Walk csids per trainer zone are the LSB csidTable short/regular/long entries; Bastok and Windurst have no capture.
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

CR.WALK_CMD          = 242;
CR.WALK_EVENT_CHANCE = 33; -- LSB value, the captures only show a handful of finds

-- [arg] = { clear cost, bad weather cost, location map key }
local WALKS =
{
    [42] = { 23, 29, "short"  },
    [43] = { 31, 39, "medium" },
    [44] = { 38, 47, "long"   },
};

-- trainer zone -> walk csids { short, regular, long, watch over }
local WALK_CSIDS =
{
    [230] = { 298, 299, 300, 304 },
    [234] = { 554, 555, 556, 560 },
    [241] = { 810, 811, 812, 816 },
};

-- location (1 San d'Oria, 2 Bastok, 3 Windurst) -> walk zone
local WALK_ZONES =
{
    short  = { 100, 106, 116 }, -- West Ronfaure, North Gustaberg, East Sarutabaruta
    medium = { 102, 108, 117 }, -- La Theine Plateau, Konschtat Highlands, Tahrongi Canyon
    long   = { 104, 109, 119 }, -- Jugner Forest, Pashhow Marshlands, Meriphataud Mountains
};

-- Items that can be found on a walk, by walk zone (ids from LSB enum item.lua, same as DSP item_basic)
local WALK_ITEMS =
{
    [100] =
    {
        656, -- BEASTCOIN
        16640, -- BRONZE_AXE
        639, -- RONFAURE_CHESTNUT
        768, -- FLINT_STONE
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        511, -- GOBLIN_MASK
        17396, -- LITTLE_WORM
        17296, -- PEBBLE
        750, -- SILVER_BEASTCOIN
        2201, -- CLUMP_OF_TOKOPEKKO_WILDGRASS
        2235, -- BAG_OF_WILDGRASS_SEEDS
    },
    [106] =
    {
        656, -- BEASTCOIN
        768, -- FLINT_STONE
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        511, -- GOBLIN_MASK
        17396, -- LITTLE_WORM
        629, -- EAR_OF_MILLIONCORN
        17296, -- PEBBLE
        596, -- QUADAV_BACKPLATE
        750, -- SILVER_BEASTCOIN
        2201, -- CLUMP_OF_TOKOPEKKO_WILDGRASS
        2235, -- BAG_OF_WILDGRASS_SEEDS
    },
    [116] =
    {
        656, -- BEASTCOIN
        768, -- FLINT_STONE
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        511, -- GOBLIN_MASK
        508, -- GOBLIN_HELM
        17396, -- LITTLE_WORM
        17296, -- PEBBLE
        16995, -- PIECE_OF_ROTTEN_MEAT
        750, -- SILVER_BEASTCOIN
        620, -- BOX_OF_TARUTARU_RICE
        2201, -- CLUMP_OF_TOKOPEKKO_WILDGRASS
        2235, -- BAG_OF_WILDGRASS_SEEDS
        498, -- YAGUDO_BEAD_NECKLACE
    },
    [102] =
    {
        656, -- BEASTCOIN
        881, -- CRAB_SHELL
        2203, -- CUPID_WORM
        645, -- CHUNK_OF_DARKSTEEL_ORE
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        510, -- GOBLIN_ARMOR
        956, -- LILAC
        17296, -- PEBBLE
        750, -- SILVER_BEASTCOIN
        2201, -- CLUMP_OF_TOKOPEKKO_WILDGRASS
        5608, -- ZEGHAM_CARROT
        749, -- MYTHRIL_BEASTCOIN
    },
    [108] =
    {
        656, -- BEASTCOIN
        2203, -- CUPID_WORM
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        510, -- GOBLIN_ARMOR
        508, -- GOBLIN_HELM
        17296, -- PEBBLE
        645, -- CHUNK_OF_DARKSTEEL_ORE
        738, -- CHUNK_OF_PLATINUM_ORE
        949, -- RAIN_LILY
        882, -- SHEEP_TOOTH
        750, -- SILVER_BEASTCOIN
        2201, -- CLUMP_OF_TOKOPEKKO_WILDGRASS
        5607, -- VOMP_CARROT
        5608, -- ZEGHAM_CARROT
    },
    [117] =
    {
        957, -- AMARYLLIS
        656, -- BEASTCOIN
        898, -- CHICKEN_BONE
        2203, -- CUPID_WORM
        645, -- CHUNK_OF_DARKSTEEL_ORE
        2202, -- CLUMP_OF_GARIDAV_WILDGRASS
        510, -- GOBLIN_ARMOR
        17296, -- PEBBLE
        738, -- CHUNK_OF_PLATINUM_ORE
        750, -- SILVER_BEASTCOIN
        5607, -- VOMP_CARROT
        5608, -- ZEGHAM_CARROT
        1237, -- BAG_OF_TREE_CUTTINGS
    },
    [104] =
    {
        646, -- CHUNK_OF_ADAMAN_ORE
        508, -- GOBLIN_HELM
        748, -- GOLD_BEASTCOIN
        2205, -- GREGARIOUS_WORM
        749, -- MYTHRIL_BEASTCOIN
        1412, -- OLIVE_FLOWER
        739, -- CHUNK_OF_ORICHALCUM_ORE
        17296, -- PEBBLE
        16995, -- PIECE_OF_ROTTEN_MEAT
        750, -- SILVER_BEASTCOIN
        1237, -- BAG_OF_TREE_CUTTINGS
        2235, -- BAG_OF_WILDGRASS_SEEDS
    },
    [109] =
    {
        646, -- CHUNK_OF_ADAMAN_ORE
        1413, -- CATTLEYA
        508, -- GOBLIN_HELM
        2205, -- GREGARIOUS_WORM
        749, -- MYTHRIL_BEASTCOIN
        739, -- CHUNK_OF_ORICHALCUM_ORE
        17296, -- PEBBLE
        16995, -- PIECE_OF_ROTTEN_MEAT
        750, -- SILVER_BEASTCOIN
        1237, -- BAG_OF_TREE_CUTTINGS
    },
    [119] =
    {
        646, -- CHUNK_OF_ADAMAN_ORE
        1120, -- CASABLANCA
        508, -- GOBLIN_HELM
        748, -- GOLD_BEASTCOIN
        2205, -- GREGARIOUS_WORM
        749, -- MYTHRIL_BEASTCOIN
        17296, -- PEBBLE
        16995, -- PIECE_OF_ROTTEN_MEAT
        750, -- SILVER_BEASTCOIN
        1237, -- BAG_OF_TREE_CUTTINGS
        739, -- CHUNK_OF_ORICHALCUM_ORE
    },
};

-- GetZoneWeather is a C++ global (luautils.cpp); 0 (none) when the walk zone is not loaded on this map server or on an older binary.
local function walkWeather(zoneId)
    if (GetZoneWeather ~= nil) then
        return GetZoneWeather(zoneId);
    end
    return 0;
end

local function handleWatchOver(player, saved, csid)
    local before = saved.energy;
    if (saved.stage == CR.stage.EGG) then
        player:updateEvent(csid, before * 256 + before, 0, 0, saved.stage, 0, 0, 1);
        return;
    end

    local cost = 3 + math.random(0, 1);
    if (before < cost) then
        player:updateEvent(csid, -1, 0, 0, saved.stage, 0, 0, 1);
        return;
    end
    saved.energy = before - cost;

    local giving, item = 0, 0;
    if (saved.held_item > 0) then
        giving, item = 1, saved.held_item;
        if (player:getFreeSlotsCount() == 0) then
            giving = 2;
        end
    end

    if (giving == 1) then
        player:addItem(item);
        saved.held_item = 0;
    end
    player:setChocoboRaisingInfo(saved);
    player:updateEvent(csid, saved.energy * 256 + before, giving, item, saved.stage, 0, 0, 1);
end

function CR.handleWalk(player, saved, arg)
    local walk = WALKS[arg];
    local csids = WALK_CSIDS[player:getZoneID()];
    if (arg == 48 and csids ~= nil) then
        handleWatchOver(player, saved, csids[4]);
        return;
    end
    if (walk == nil or csids == nil) then
        return;
    end

    local location = saved.location;
    local walkZone = WALK_ZONES[walk[3]][location];
    local weather  = walkWeather(walkZone);
    local csid     = csids[arg - 41];

    local cost = (weather <= 1 and walk[1] or walk[2]) + math.random(0, 1);
    if (saved.energy < cost) then
        player:updateEvent(csid, -1, 0, 0, saved.stage, 0, 0, weather);
        return;
    end

    local before = saved.energy;
    saved.energy = before - cost;

    local found = 0;
    if (saved.held_item == 0 and math.random(1, 100) <= CR.WALK_EVENT_CHANCE) then
        local pool = WALK_ITEMS[walkZone];
        saved.held_item = pool[math.random(1, #pool)];
        found = 7;
    end

    player:setChocoboRaisingInfo(saved);
    player:updateEvent(csid, saved.energy * 256 + before, found, 0, saved.stage, 0, 0, weather);
end
