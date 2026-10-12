-----------------------------------
-- Mog Tablets and Super Kupowers (framework)
--
-- Design / evidence: docs/super-kupopower/ (SCOPE.md, EVIDENCE.md)
-- Source tags: [C] real capture, [W] ffxiclopedia, [S] LSB mog_tablets.lua skeleton, [D] repo data.
--
-- State lives in server variables (survives restarts):
--   [MOGTAB]Zone<t> / Spot<t>  zone id and spot index (1-based) tablet <t> (0..10) is hidden at
--   [MOGTAB]Found<t>           0/1, tablet <t> already discovered this cycle
--   [MOGTAB]Finder<t>          char id of the finder
--   [MOGTAB]Powers             bitmask of active Super Kupowers (bit = 1 << (power-1)) [C]
--   [MOGTAB]PowersEnd          os.time() the active powers expire
--   [MOGTAB]ScatterAt          os.time() the tablets are scattered again
-- Char var [MOGTAB]Pending is a bitmask (bit t) of found-but-not-turned-in tablets.
--
-- Nothing here ticks by itself: tick() is evaluated lazily on zone-in, tablet trigger and Explorer Moogle trigger.
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/mog_tablet_data");
-----------------------------------

MOG_TABLET = MOG_TABLET or {};

-- Tablet index 0..10 order is confirmed by the Explorer Moogle list packets [C]
-- (event 10109 updates: param0 = tablet index: piety 2, courage 10, hope 4, compassion 6, temperance 0, fortitude 1).
MOG_TABLET.TABLETS =
{
    [0]  = { name = "temperance", reward = 268   },  -- Nomad Moogle Statue
    [1]  = { name = "fortitude",  reward = 11403 },  -- Talaria
    [2]  = { name = "piety",      reward = 3973  },  -- Mog Kupon I-Orche [C: item 3973 given for Piety]
    [3]  = { name = "justice",    reward = 4063  },  -- Macrocosmic Orb
    [4]  = { name = "hope",       reward = 18842 },  -- Nomad Moogle Rod
    [5]  = { name = "wisdom",     reward = 19181 },  -- Moogle's Largesse
    [6]  = { name = "compassion", reward = 26166 },  -- Invisible Ring
    [7]  = { name = "dignity",    reward = 26167 },  -- Sneak Ring
    [8]  = { name = "loyalty",    reward = 26168 },  -- Deodorize Ring
    [9]  = { name = "charity",    reward = 26169 },  -- Reraise Ring
    [10] = { name = "courage",    reward = 15554 },  -- Pelican Ring
};
MOG_TABLET.KUPOFRIEDS_RING = 15840;  -- [C] given with every reward
MOG_TABLET.EXPLORER_MOOGLE_ZONE = 243; -- Ru'Lude Gardens

-- bit = 1 << (id-1). Martial Master(2)+Treasure Hound(4)+Swift Shoes(10) = 522 matched the capture's option-1 update [C].
MOG_TABLET.POWERS =
{
    THRIFTY_TRANSIT      = 1,
    MARTIAL_MASTER       = 2,
    BLOOD_OF_THE_VAMPYR  = 3,
    TREASURE_HOUND       = 4,
    ARTISANS_ADVANTAGE   = 5,
    MYRIAD_MYSTERY_BOXES = 6,
    DILATORY_DIGESTION   = 7,
    BOUNDARY_BUSTER      = 8,
    BOUNTIFUL_BAZAAR     = 9,
    SWIFT_SHOES          = 10,
    CRYSTAL_CABOODLE     = 11,
};
MOG_TABLET.POWER_NAMES =
{
    "Thrifty Transit", "Martial Master", "Blood of the Vampyr", "Treasure Hound", "Artisan's Advantage",
    "Myriad Mystery Boxes", "Dilatory Digestion", "Boundary Buster", "Bountiful Bazaar", "Swift Shoes", "Crystal Caboodle",
};

-- Wording captured at login [C]; the client-side message ids differ per client generation so plain text is sent instead.
MOG_TABLET.AFFECTED_TEXT = "This area is currently affected by the Super Kupower: %s!";

-- Place names as used by the discovery broadcast [S/C: "...in the Sanctuary of Zi'Tah!"]
MOG_TABLET.PLACE =
{
    [100] = "West Ronfaure",     [101] = "East Ronfaure",       [102] = "the La Theine Plateau", [103] = "the Valkurm Dunes",
    [104] = "Jugner Forest",     [105] = "the Batallia Downs",  [106] = "North Gustaberg",       [107] = "South Gustaberg",
    [108] = "the Konschtat Highlands", [109] = "the Pashhow Marshlands", [110] = "the Rolanberry Fields", [111] = "Beaucedine Glacier",
    [112] = "Xarcabard",         [113] = "Cape Teriggan",       [114] = "the Eastern Altepa Desert", [115] = "West Sarutabaruta",
    [116] = "East Sarutabaruta", [117] = "the Tahrongi Canyon", [118] = "the Buburimu Peninsula", [119] = "the Meriphataud Mountains",
    [120] = "the Sauromugue Champaign", [121] = "the Sanctuary of Zi'Tah", [122] = "Ro'Maeve", [123] = "the Yuhtunga Jungle",
    [124] = "the Yhoator Jungle", [125] = "the Western Altepa Desert", [126] = "Qufim Island", [127] = "Behemoth's Dominion",
    [128] = "the Valley of Sorrows",
};

local function getv(k) return GetServerVariable("[MOGTAB]" .. k); end
local function setv(k, v) SetServerVariable("[MOGTAB]" .. k, v); end

-----------------------------------
-- State helpers
-----------------------------------

-- Zones where powers apply. Verified: the 29 tablet zones and Ru'Lude Gardens ([C] message seen in Ru'Lude).
-- TODO: the retail rule is "original, ZM and CoP areas"; extend once the full list is confirmed (do not guess).
function MOG_TABLET.isAffectedZone(zoneId)
    return MOG_TABLET_DATA.zones[zoneId] ~= nil or zoneId == MOG_TABLET.EXPLORER_MOOGLE_ZONE;
end

function MOG_TABLET.tabletInZone(zoneId)
    for t = 0, 10 do
        if (getv("Zone" .. t) == zoneId) then return t; end
    end
    return nil;
end

function MOG_TABLET.countFound()
    local n = 0;
    for t = 0, 10 do n = n + (getv("Found" .. t) == 1 and 1 or 0); end
    return n;
end

function MOG_TABLET.getPowers()
    if (getv("Powers") ~= 0 and os.time() >= getv("PowersEnd")) then
        return 0;
    end
    return getv("Powers");
end

-- Use this from power hooks. Only valid inside an affected zone.
function MOG_TABLET.hasPower(power, zoneId)
    if (zoneId ~= nil and not MOG_TABLET.isAffectedZone(zoneId)) then return false; end
    return bit.band(MOG_TABLET.getPowers(), bit.lshift(1, power - 1)) ~= 0;
end

-----------------------------------
-- Zone application
-----------------------------------

function MOG_TABLET.applyZone(zoneId)
    local data = MOG_TABLET_DATA.zones[zoneId];
    if (data == nil) then return; end
    local npc = GetNPCByID(data.npc);
    if (npc == nil) then return; end
    local t = MOG_TABLET.tabletInZone(zoneId);
    if (t ~= nil and getv("Found" .. t) == 0) then
        local s = data.spots[getv("Spot" .. t)];
        if (s ~= nil) then
            npc:setPos(s[1], s[2], s[3], s[4]);
            npc:setStatus(STATUS_NORMAL);
            return;
        end
    end
    npc:setStatus(STATUS_DISAPPEAR);
end

-- Put the 11 tablets in 11 distinct zones that have at least one known spot.
function MOG_TABLET.scatter()
    local pool = {};
    for zoneId, data in pairs(MOG_TABLET_DATA.zones) do
        if (#data.spots > 0) then table.insert(pool, zoneId); end
    end
    table.sort(pool);
    for t = 0, 10 do
        if (#pool == 0) then
            setv("Zone" .. t, 0);
        else
            local i = math.random(1, #pool);
            local zoneId = table.remove(pool, i);
            setv("Zone" .. t, zoneId);
            setv("Spot" .. t, math.random(1, #MOG_TABLET_DATA.zones[zoneId].spots));
        end
        setv("Found" .. t, 0);
        setv("Finder" .. t, 0);
    end
    setv("Powers", 0);
    setv("PowersEnd", 0);
    setv("ScatterAt", 0);
    for zoneId, _ in pairs(MOG_TABLET_DATA.zones) do MOG_TABLET.applyZone(zoneId); end
    MOG_TABLET.applyExplorerMoogles();
end

-- Lazy state machine: scatter on first use, power expiry, rescatter.
function MOG_TABLET.tick()
    local now = os.time();
    if (getv("Zone0") == 0 and getv("Zone1") == 0) then
        MOG_TABLET.scatter();
        return;
    end
    local scatterAt = getv("ScatterAt");
    if (scatterAt ~= 0 and now >= scatterAt) then
        MOG_TABLET.messageAll("The strength of the ancient moogle magic has weakened, and the tablets have been scattered to the winds once more. You can feel your Super Kupowers begin to fade away...");  -- [S: message 2]
        MOG_TABLET.scatter();
    end
end

-----------------------------------
-- Messaging (plain text: client TextIDs are generation-specific, see DSP TextID notes)
-----------------------------------

function MOG_TABLET.messageAll(text)
    for zoneId, _ in pairs(MOG_TABLET_DATA.zones) do
        local zone = GetZone(zoneId);
        if (zone ~= nil) then
            for _, p in pairs(zone:getPlayers()) do p:PrintToPlayer(text); end
        end
    end
    local ru = GetZone(MOG_TABLET.EXPLORER_MOOGLE_ZONE);
    if (ru ~= nil) then
        for _, p in pairs(ru:getPlayers()) do p:PrintToPlayer(text); end
    end
end

function MOG_TABLET.onZoneInitialize(zone)
    MOG_TABLET.tick();
    MOG_TABLET.applyExplorerMoogles();
    MOG_TABLET.applyZone(zone:getID());
end

-- Login/zone-in notice: one line per active power [C: Raguza login].
function MOG_TABLET.onZoneIn(player)
    MOG_TABLET.tick();
    MOG_TABLET.syncMods(player);
    local zoneId = player:getZoneID();
    if (not MOG_TABLET.isAffectedZone(zoneId)) then return; end
    local mask = MOG_TABLET.getPowers();
    for p = 1, 11 do
        if (bit.band(mask, bit.lshift(1, p - 1)) ~= 0) then
            player:PrintToPlayer(string.format(MOG_TABLET.AFFECTED_TEXT, MOG_TABLET.POWER_NAMES[p]));
        end
    end
end

-----------------------------------
-- Tablet NPC (npcs/Mog-Tablet.lua in each of the 29 field zones)
-----------------------------------

function MOG_TABLET.onTabletTrigger(player, npc)
    MOG_TABLET.tick();
    local zoneId = player:getZoneID();
    local t = MOG_TABLET.tabletInZone(zoneId);
    if (t == nil or getv("Found" .. t) == 1) then
        npc:setStatus(STATUS_DISAPPEAR);
        return;
    end
    setv("Found" .. t, 1);
    setv("Finder" .. t, player:getID());
    player:setVar("[MOGTAB]Pending", bit.bor(player:getVar("[MOGTAB]Pending"), bit.lshift(1, t)));
    npc:setStatus(STATUS_DISAPPEAR);
    -- Text from the Zi'Tah capture [C].
    player:PrintToPlayer("You've recovered one of the long-lost mog tablets! You should share the news of your discovery with the Explorer Moogle in Ru'Lude Gardens.");
    MOG_TABLET.messageAll(string.format("A mog tablet has been discovered in %s!", MOG_TABLET.PLACE[zoneId]));

    if (MOG_TABLET.countFound() >= 11) then
        MOG_TABLET.activatePowers();
    end
end

-- Pick the 3 powers (all 11 if MOG_TABLET_ALL_POWERS), run for one week [W], tablets rescatter 8-24h after expiry [W].
function MOG_TABLET.activatePowers()
    local mask = 0;
    if (MOG_TABLET_ALL_POWERS == 1) then
        mask = 0x7FF;
    else
        local pool = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
        for i = 1, 3 do
            local p = table.remove(pool, math.random(1, #pool));
            mask = bit.bor(mask, bit.lshift(1, p - 1));
        end
    end
    local now = os.time();
    setv("Powers", mask);
    setv("PowersEnd", now + 7 * 86400);
    setv("ScatterAt", now + 7 * 86400 + math.random(8 * 3600, 24 * 3600));
    MOG_TABLET.applyExplorerMoogles();
    MOG_TABLET.messageAll("The complete set of mog tablets has been restored to Ru'Lude Gardens! The ancient magic of King Kupofried permeates the air to instill adventurers in this area with its Super Kupowers!");  -- [S: message 1]
end

-----------------------------------
-- GM helpers (use from a GM command or the lua console)
-----------------------------------

function MOG_TABLET.gmReset()
    MOG_TABLET.scatter();
end

function MOG_TABLET.gmForcePowers(mask, hours)
    local now = os.time();
    setv("Powers", mask);
    setv("PowersEnd", now + hours * 3600);
    setv("ScatterAt", now + hours * 3600 + 3600);
end

-----------------------------------
-- Power effects: stat-mod powers (Signet gated)
-- Treasure Hound  [W]: Signet grants Gilfinder +1 and Treasure Hunter +1.
-- Martial Master  [W]: Signet makes combat/magic skills rise faster. The wiki gives no magnitude,
--                      so it is the tunable MOG_TABLET_SKILLUP_RATE (percent, settings.lua).
-- Mods are tracked per player id so they can be removed exactly; the table is cleared on login
-- (a fresh login rebuilds mods from scratch) via MOG_TABLET.onLogin.
-----------------------------------

MOG_TABLET.appliedMods = {};

function MOG_TABLET.desiredMods(player)
    local mods = {};
    if (player:hasStatusEffect(EFFECT_SIGNET)) then
        local zoneId = player:getZoneID();
        if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.TREASURE_HOUND, zoneId)) then
            mods[MOD_GILFINDER] = 1;
            mods[MOD_TREASURE_HUNTER] = 1;
        end
        -- Boundary Buster [W]: double Conquest Points, except in Tu'Lia (region 16).
        -- Engine awards exp * (10% own nation / 15% otherwise + MOD_CONQUEST_BONUS), so adding the base
        -- percentage as a bonus doubles it. Region ownership is read at sync time (zone-in / Signet change).
        if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.BOUNDARY_BUSTER, zoneId)) then
            local zone = GetZone(zoneId);
            local region = zone ~= nil and zone:getRegionID() or -1;
            if (region >= 0 and region <= 22 and region ~= 16) then
                mods[MOD_CONQUEST_BONUS] = (GetRegionOwner(region) == player:getNation()) and 10 or 15;
            end
        end
        if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.MARTIAL_MASTER, zoneId)) then
            local r = MOG_TABLET_SKILLUP_RATE or 0;
            if (r ~= 0) then
                mods[MOD_COMBAT_SKILLUP_RATE] = r;
                mods[MOD_MAGIC_SKILLUP_RATE] = r;
            end
        end
        -- Blood of the Vampyr [W]: latent Regen 1 HP/tick below 51% HP and Refresh 1 MP/tick below 51% MP while Signet.
        -- The threshold is checked each regen tick in status_effect_container.cpp; stacks with other regen/refresh.
        if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.BLOOD_OF_THE_VAMPYR, zoneId)) then
            mods[MOD_VAMPYR_REGEN] = 1;
            mods[MOD_VAMPYR_REFRESH] = 1;
        end
        -- Crystal Caboodle [W]: crystals more likely in affected zones, obtainable in beastmen-controlled regions,
        -- and clusters may rarely drop instead of a crystal. Consumed by the crystal drop in mobentity.cpp.
        if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.CRYSTAL_CABOODLE, zoneId)) then
            mods[MOD_CRYSTAL_DROP_RATE] = MOG_TABLET_CRYSTAL_RATE or 25;
            mods[MOD_CLUSTER_DROP_RATE] = MOG_TABLET_CLUSTER_RATE or 10;
        end
    end
    -- Artisan's Advantage [W]: ingredient loss on a failed synthesis is drastically reduced with Synthesis Image
    -- Support (and possibly regardless). Magnitudes are settings; applied in doSynthFail (synthutils.cpp).
    if (MOG_TABLET.hasPower(MOG_TABLET.POWERS.ARTISANS_ADVANTAGE, player:getZoneID())) then
        mods[MOD_ARTISAN_LOSS_SUPPORT] = MOG_TABLET_ARTISAN_LOSS_SUPPORT or 90;
        mods[MOD_ARTISAN_LOSS_ALWAYS] = MOG_TABLET_ARTISAN_LOSS_ALWAYS or 0;
    end
    return mods;
end

-- Idempotent: removes what was applied before, applies what is wanted now.
function MOG_TABLET.syncMods(player)
    MOG_TABLET.dropSwiftShoes(player);
    local id = player:getID();
    local old = MOG_TABLET.appliedMods[id] or {};
    local new = MOG_TABLET.desiredMods(player);
    for mod, amt in pairs(old) do
        if (new[mod] ~= amt) then player:delMod(mod, amt); end
    end
    for mod, amt in pairs(new) do
        if (old[mod] ~= amt) then player:addMod(mod, amt); end
    end
    MOG_TABLET.appliedMods[id] = new;
end

-- Signet effect lost: the effect is already gone when onEffectLose runs on some paths, so drop by registry.
function MOG_TABLET.clearMods(player)
    local id = player:getID();
    for mod, amt in pairs(MOG_TABLET.appliedMods[id] or {}) do player:delMod(mod, amt); end
    MOG_TABLET.appliedMods[id] = nil;
end

-- Fresh login: mods were rebuilt by the server, so forget the registry without delMod.
function MOG_TABLET.onLogin(player)
    MOG_TABLET.appliedMods[player:getID()] = nil;
end

-----------------------------------
-- Swift Shoes [W ffxiclopedia Swift_Shoes / Quickening]
-- After resting >= 1 healing tick, the player gets Quickening. Rest longer = stronger and longer.
-- Wiki table (ticks: speed/duration): 1: 12.5%/15m  2: 15%/20m  3: 17.5%/25m  4: 20%/30m  5+: 25%.
-- Duration is +5 min per tick from 15 min, "maxing out at an hour" (the wiki's table row says 1h30,
-- the text says 1 hour; text used, so the cap is MOG_TABLET.SWIFT_MAX_MINUTES). MOD_MOVE is an integer
-- percent, so 12.5 and 17.5 are stored as 12 and 17.
-- Removal: leaving the affected area (syncMods), KO/job change/level sync via the engine are NOT yet hooked.
-- Not applied: Alter Egos, Fellows, Automatons, Wyverns (no verified hook).
-----------------------------------

MOG_TABLET.SWIFT_MARK        = 7701;   -- our own marker in the effect's subpower, to tell it from other Quickening sources
MOG_TABLET.SWIFT_MAX_MINUTES = 60;
MOG_TABLET.SWIFT_SPEED       = { 12, 15, 17, 20, 25 };

-- ticks = healing ticks completed (wiki numbering; the first heal tick of healing.lua is wiki tick 1).
function MOG_TABLET.onHealTick(player, ticks)
    if (ticks < 1 or not player:isPC()) then return; end
    if (not MOG_TABLET.hasPower(MOG_TABLET.POWERS.SWIFT_SHOES, player:getZoneID())) then return; end
    if (player:hasStatusEffect(EFFECT_DISEASE)) then return; end
    local cur = player:getStatusEffect(EFFECT_QUICKENING);
    if (cur ~= nil and cur:getSubPower() ~= MOG_TABLET.SWIFT_MARK) then return; end  -- another source (gear/Jig/Fleet) keeps priority
    local speed   = MOG_TABLET.SWIFT_SPEED[math.min(ticks, #MOG_TABLET.SWIFT_SPEED)];
    local minutes = math.min(10 + 5 * ticks, MOG_TABLET.SWIFT_MAX_MINUTES);
    if (cur ~= nil and cur:getPower() == speed and cur:getDuration() >= minutes * 60) then return; end
    player:delStatusEffectSilent(EFFECT_QUICKENING);
    player:addStatusEffect(EFFECT_QUICKENING, speed, 0, minutes * 60, 0, MOG_TABLET.SWIFT_MARK);
end

-- Called from syncMods: strip a Swift Shoes quickening once its power or area no longer applies.
function MOG_TABLET.dropSwiftShoes(player)
    local cur = player:getStatusEffect(EFFECT_QUICKENING);
    if (cur ~= nil and cur:getSubPower() == MOG_TABLET.SWIFT_MARK
        and not MOG_TABLET.hasPower(MOG_TABLET.POWERS.SWIFT_SHOES, player:getZoneID())) then
        player:delStatusEffectSilent(EFFECT_QUICKENING);
    end
end

-----------------------------------
-- Thrifty Transit [W ffxiclopedia Thrifty_Transit]
-- Free outpost teleports: OP_TeleFee (conquest.lua) returns 0 while active.
-- Explorer Moogles (Bastok Mines, N San d'Oria, Port Windurst, Selbina, Mhaura) already exist in npc_list and
-- always appear on this server; retail shows them only during Thrifty Transit. Optional gate, off by default:
-- MOG_TABLET_GATE_EXPLORER_MOOGLES = 1 hides them unless the power is active (ids = npc_list rows, zones 234/231/240/249/248).
-- Survival Guide teleports are not implemented anywhere in this tree (no script), so nothing to make free yet.
-----------------------------------

MOG_TABLET.CITY_EXPLORER_MOOGLES = { 17723648, 17735856, 17760450, 17793131, 17797253 };

function MOG_TABLET.applyExplorerMoogles()
    if (MOG_TABLET_GATE_EXPLORER_MOOGLES ~= 1) then return; end
    local on = MOG_TABLET.hasPower(MOG_TABLET.POWERS.THRIFTY_TRANSIT);
    for _, id in ipairs(MOG_TABLET.CITY_EXPLORER_MOOGLES) do
        local npc = GetNPCByID(id);
        if (npc ~= nil) then npc:setStatus(on and STATUS_NORMAL or STATUS_DISAPPEAR); end
    end
end
