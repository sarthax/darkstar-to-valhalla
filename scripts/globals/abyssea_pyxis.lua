-----------------------------------
-- Abyssea Sturdy Pyxis (LSB backport, PHASE 1)
--
-- Ported from landsandboat-reference/scripts/globals/abyssea/sturdypyxis/*.lua.
-- PHASE 1: spawn on mob death, blue chest (twist dial) and red chest (air pressure) with
-- light / restore / cruor / experience rewards, and the Forbidden Key trade.
-- PHASE 2: gold chest (two-digit combination), temporary / numerous-temporary / item / pop item drops
-- with the unlocked-chest event (pick items, or send them to the treasure pool).
-- PHASE 3: augmented item and key item gold-chest drops (abyssea_pyxis_augs.lua).
-- NOT yet ported: Time Extension, abyssite key-item bonuses.
--
-- Message ids are the REAL client dialog ids verified per zone (mission_toolkit dialog.yml, 2026-10-02),
-- kept here rather than in TextIDs.lua (DSP's Abyssea TextIDs are +2 off the client).
-- Events 2004-2008 (locked) / 2068-2072 (unlocked) were confirmed on each zone's Sturdy_Pyxis entities.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/abyssea_lights");
require("scripts/globals/abyssea_pyxis_drops");
require("scripts/globals/abyssea_pyxis_augs");

PYXIS_BLUE = 1;
PYXIS_RED  = 2;
PYXIS_GOLD = 3;

PYXIS_DROP_TEMP     = 1;
PYXIS_DROP_ITEM     = 2;
PYXIS_DROP_POPITEM  = 3;
PYXIS_DROP_AUGMENT  = 4;
PYXIS_DROP_KEYITEM  = 5;
PYXIS_DROP_NUMEROUS = 11;
PYXIS_DROP_LIGHT   = 6;
PYXIS_DROP_RESTORE = 7;
PYXIS_DROP_TIME    = 9;
PYXIS_DROP_CRUOR   = 8;
PYXIS_DROP_EXP     = 10;

local PYXIS_LIFETIME = 180;  -- seconds a chest stays up
local PYXIS_RECYCLE  = 10;   -- seconds before a removed chest slot can be reused
local FORBIDDEN_KEY  = 2490; -- item_basic: forbidden_key
local ATTEMPTS       = 5;

-- zoneid -> first Sturdy_Pyxis npc id of the zone's 80-id block (sql/npc_list.sql; absent slots are skipped by name check)
local pyxisBase =
{
    [15]  = 16839114,
    [45]  = 16961991,
    [132] = 17318509,
    [215] = 17658390,
    [216] = 17662595,
    [217] = 17666615,
    [218] = 17670627,
    [253] = 17813987,
    [254] = 17818119,
};

-- client message ids (verified by text in all 9 zones)
local textA = { CONCEALED = 7475, DESPAWNED = 7494, CRUOR = 7495, NOT_OWN = 7506, DISAPPEARED = 7509,
                RANDOM_GUESS = 7531, AIR_PRESSURE = 7535, OPENED = 7547, FAILED = 7548, KEY_OPEN = 7549 };
local textB = { CONCEALED = 7375, DESPAWNED = 7394, CRUOR = 7395, NOT_OWN = 7406, DISAPPEARED = 7409,
                RANDOM_GUESS = 7431, AIR_PRESSURE = 7435, OPENED = 7447, FAILED = 7448, KEY_OPEN = 7449 };
-- phase 2 messages (client ids, same offsets across zones; Attohwa/Uleguerand are -100 except CANNOT_OBTAIN)
local function ext(t, d)
    t.OBTAINS_TEMP = 7485 - d; t.OBTAINS_ITEM = 7486 - d; t.SPOILS = 7488 - d; t.ALREADY_TEMP = 7489 - d;
    t.TEMP_GONE = 7491 - d; t.ITEM_GONE = 7493 - d; t.SEVERAL_TEMPS = 7496 - d; t.INPUT = 7540 - d;
    t.GREATER_LESS = 7541 - d; t.HUNCH_EVENODD = 7542 - d; t.HUNCH_IS = 7543 - d; t.HUNCH_IS_OR = 7544 - d;
    t.HUNCH_ONE = 7545 - d; t.HUNCH_SUM = 7546 - d; t.CANNOT_OBTAIN = 6382;
    t.OBTAINS_KI = 7487 - d; t.ALREADY_KI = 7490 - d; t.KI_GONE = 7492 - d;
    t.VISITANT_EXTENDED = 7326 - d;
end
ext(textA, 0);
ext(textB, 100);

local pyxisText =
{
    [15] = textA, [45] = textA, [132] = textA, [216] = textA, [217] = textA, [218] = textA, [254] = textA,
    [215] = textB, [253] = textB,
};

-- chest contents shown in the lock event (chest type is added on the low bits)
local contentMessage =
{
    [1]  = 0x0010000, [2]  = 0x0020000, [3]  = 0x0030000, [4]  = 0x0050000, [5]  = 0x0060000,
    [6]  = 0x0070000, [7]  = 0x0090000, [8]  = 0x00A0000, [9]  = 0x00B0000, [10] = 0x00D0000,
    [11] = 0x00E0000, [12] = 0x00F0000, [13] = 0x0110000, [15] = 0x0130000, [16] = 0x0140000,
    [14] = 0x0120000, [17] = 0x0150000, [42] = 0x1000000, [43] = 0x2000000, [44] = 0x3000000, [45] = 0x4000000,
    [18] = 0x0160000, [19] = 0x0170000, [20] = 0x0180000, [21] = 0x0190000, [22] = 0x01A0000,
    [23] = 0x01B0000, [24] = 0x01C0000, [25] = 0x01D0000, [26] = 0x01E0000, [27] = 0x01F0000,
    [28] = 0x0200000, [29] = 0x0210000, [30] = 0x0220000, [31] = 0x0230000, [32] = 0x0240000,
    [33] = 0x0250000, [34] = 0x0260000, [35] = 0x0270000, [36] = 0x0280000, [37] = 0x0290000,
    [38] = 0x02A0000, [39] = 0x02B0000, [40] = 0x02C0000, [41] = 0x02D0000,
};

-- blue chest: drop type -> content message per tier
local blueMessages =
{
    [PYXIS_DROP_TEMP]    = { 42, 42, 42, 42, 42 },
    [PYXIS_DROP_NUMEROUS] = { 14, 14, 14, 14, 14 },
    [PYXIS_DROP_RESTORE] = { 1, 4, 7, 10, 13 },
    [PYXIS_DROP_CRUOR]   = { 2, 5, 8, 11, 15 },
    [PYXIS_DROP_EXP]     = { 3, 6, 9, 12, 16 },
    [PYXIS_DROP_TIME]    = { 17, 17, 17, 17, 17 },
};
local blueDropTypes = { PYXIS_DROP_TEMP, PYXIS_DROP_RESTORE, PYXIS_DROP_CRUOR, PYXIS_DROP_EXP, PYXIS_DROP_NUMEROUS };

-- red chest: light amounts per tier
local chestLightValues =
{
    [1] = { [LIGHT_PEARL] = 5,  [LIGHT_RUBY] = 8,  [LIGHT_AZURE] = 8,  [LIGHT_AMBER] = 8 },
    [2] = { [LIGHT_PEARL] = 10, [LIGHT_RUBY] = 16, [LIGHT_AZURE] = 16, [LIGHT_AMBER] = 16 },
    [3] = { [LIGHT_PEARL] = 15, [LIGHT_RUBY] = 32, [LIGHT_AZURE] = 32, [LIGHT_AMBER] = 32,
            [LIGHT_GOLDEN] = 5, [LIGHT_SILVERY] = 5, [LIGHT_EBON] = 1 },
    [4] = { [LIGHT_RUBY] = 64, [LIGHT_AZURE] = 64, [LIGHT_GOLDEN] = 10, [LIGHT_SILVERY] = 10, [LIGHT_EBON] = 2 },
    [5] = { [LIGHT_GOLDEN] = 15, [LIGHT_SILVERY] = 15, [LIGHT_EBON] = 3 },
};
-- content message per light per tier
local lightsMessage =
{
    [LIGHT_PEARL]   = { 18, 18, 22, 22, 26 },
    [LIGHT_GOLDEN]  = { 30, 30, 36, 36, 39 },
    [LIGHT_SILVERY] = { 31, 31, 37, 37, 40 },
    [LIGHT_EBON]    = { 32, 32, 38, 38, 41 },
    [LIGHT_AZURE]   = { 19, 19, 23, 27, 33 },
    [LIGHT_RUBY]    = { 20, 20, 24, 28, 34 },
    [LIGHT_AMBER]   = { 21, 21, 25, 29, 35 },
};

local pressureChoice = { [2] = 10, [4] = 20, [8] = 30, [16] = 10, [32] = 20, [64] = 30 };
local lockwear = { 5, 10, 15, 30 };

-----------------------------------
-- helpers
-----------------------------------

local function rollTier(value)
    local tier = 5;
    if (value <= 63) then tier = 1;
    elseif (value <= 127) then tier = 2;
    elseif (value <= 191) then tier = 3;
    elseif (value <= 223) then tier = 4; end

    if (math.random(1, 100) < 5) then
        tier = math.random(tier, 5);
    end
    return tier;
end

-- PCs of the player's alliance that are in the same zone
local function allianceInZone(player)
    local list = {};
    for _, member in pairs(player:getAlliance()) do
        if (member:isPC() and member:getZoneID() == player:getZoneID()) then
            table.insert(list, member);
        end
    end
    return list;
end

-- message to every same-zone alliance member, with `player` as the named entity
local function pyxisMessage(player, msgid, p1, p2, p3, p4)
    for _, member in pairs(allianceInZone(player)) do
        member:messageSpecialFrom(player, msgid, p1 or 0, p2 or 0, p3 or 0, p4 or 0, true);
    end
end

local function canOpenPyxis(player, npc)
    local owner = GetPlayerByID(npc:getLocalVar("PLAYERID"));
    if (owner == nil or owner:getZoneID() ~= npc:getZoneID()) then
        return true; -- owner gone; LSB lets anyone open
    end

    for _, member in pairs(player:getAlliance()) do
        if (member:getID() == owner:getID()) then
            return true;
        end
    end

    player:messageSpecial(pyxisText[player:getZoneID()].NOT_OWN);
    return false;
end

local function removePyxis(player, npc, addcruor, delay)
    local text = pyxisText[player:getZoneID()];

    if (npc:getLocalVar("SPAWNSTATUS") ~= 1) then
        return;
    end
    npc:setLocalVar("SPAWNSTATUS", 2); -- closing; blocks double removal

    if (addcruor ~= 0) then
        local amount = npc:getLocalVar("TIER") * 10;
        player:addCurrency("cruor", amount);
        player:messageSpecial(text.CRUOR, amount);
    end

    npc:timer(delay * 1000, function(npcArg)
        npcArg:setLocalVar("SPAWNSTATUS", 0);
        npcArg:setLocalVar("FREEDAT", os.time());
        npcArg:AnimationSub(16);
        npcArg:setNpcFlags(3203);
        npcArg:entityAnimationPacket("kesu");
        npcArg:setStatus(STATUS_DISAPPEAR);
    end);
end

-----------------------------------
-- rewards
-----------------------------------

local function giveReward(npc, player)
    local dropType = npc:getLocalVar("DROPTYPE");
    local members = allianceInZone(player);
    local text = pyxisText[player:getZoneID()];

    if (dropType == PYXIS_DROP_LIGHT) then
        for _, m in pairs(members) do
            addAbysseaLights(m, npc:getLocalVar("LIGHT"), npc:getLocalVar("LIGHT_VALUE"));
        end
        removePyxis(player, npc, 0, 3);

    elseif (dropType == PYXIS_DROP_CRUOR) then
        local amount = npc:getLocalVar("CRUOR");
        for _, m in pairs(members) do
            m:addCurrency("cruor", amount);
            m:messageSpecial(text.CRUOR, amount);
        end
        removePyxis(player, npc, 0, 3);

    elseif (dropType == PYXIS_DROP_EXP) then
        local amount = npc:getLocalVar("EXP");
        for _, m in pairs(members) do
            m:addExp(amount);
        end
        removePyxis(player, npc, 0, 3);

    elseif (dropType == PYXIS_DROP_NUMEROUS) then
        local tier = npc:getLocalVar("TIER");
        local list = PYXIS_TEMP_DROPS[tier];
        for i = 1, #list do
            local item = list[math.random(1, #list)];
            for _, m in pairs(members) do
                if (not m:hasItem(item, LOC_TEMPITEMS)) then
                    m:addTempItem(item, 1);
                end
            end
        end
        for _, m in pairs(members) do
            m:messageSpecial(text.SEVERAL_TEMPS);
        end
        removePyxis(player, npc, 0, 3);

    elseif (dropType == PYXIS_DROP_TIME) then
        for _, m in pairs(members) do
            local effect = m:getStatusEffect(EFFECT_VISITANT);
            if (effect ~= nil and effect:getTimeRemaining() > 0) then
                effect:setDuration(effect:getTimeRemaining() + 600000);
                effect:resetStartTime();
                effect:setIcon(EFFECT_VISITANT);
                m:messageSpecial(text.VISITANT_EXTENDED, 10, 1);
            end
        end
        removePyxis(player, npc, 0, 3);

    elseif (dropType == PYXIS_DROP_RESTORE) then
        -- 1: HP, 2: MP, 3: TP 1000, 4: HP+MP+TP 3000, 5: as 4 + recasts reset
        local restore = npc:getLocalVar("RESTORE");
        for _, m in pairs(members) do
            local hp = m:getMaxHP() - m:getHP();
            local mp = m:getMaxMP() - m:getMP();
            if (restore == 1 or restore >= 4) then
                m:addHP(hp);
            end
            if (restore == 2 or restore >= 4) then
                m:addMP(mp);
            end
            if (restore == 1) then
                m:messageBasic(24, 0, hp); -- RECOVERS_HP
            elseif (restore == 2) then
                m:messageBasic(25, 0, mp); -- RECOVERS_MP
            elseif (restore >= 4) then
                m:messageBasic(26, 0, 0);  -- RECOVERS_HP_AND_MP
            end
            if (restore == 3) then
                m:addTP(1000);
            elseif (restore >= 4) then
                m:addTP(3000);
            end
            if (restore == 5) then
                m:resetRecasts();
                m:messageBasic(361, 0, 0); -- ALL_ABILITIES_RECHARGED
            end
        end
        removePyxis(player, npc, 0, 4);
    end
end

local function openPyxis(player, npc)
    print(string.format('[PYXIS DEBUG] open drop=%d', npc:getLocalVar('DROPTYPE')));
    npc:AnimationSub(13);
    giveReward(npc, player);
end

-----------------------------------
-- chest types
-----------------------------------

-- number of abyssite key items of a perk set the player holds
local function countKeyItems(player, list)
    local n = 0;
    for _, ki in ipairs(list) do
        if (player:hasKeyItem(ki)) then n = n + 1; end
    end
    return n;
end

local ABYSSITE_ACUMEN    = { 1409, 1410, 1411 }; -- blue: fewer correct answers needed
local ABYSSITE_KISMET    = { 1400, 1401, 1402 }; -- blue: +tier
local ABYSSITE_PROSPERITY = { 1403, 1404, 1405 }; -- red: +tier
local ABYSSITE_DESTINY   = { 1406, 1407, 1408 }; -- gold: +tier

local function setupBlue(player, lightValues)
    local tier = math.min(rollTier(lightValues[LIGHT_AZURE]) + countKeyItems(player, ABYSSITE_KISMET), 5);
    local pool = {};
    for _, d in ipairs(blueDropTypes) do table.insert(pool, d); end
    if (tier >= 4) then table.insert(pool, PYXIS_DROP_TIME); end
    local dropType = pool[math.random(1, #pool)];
    local required = math.max(math.random(2, 6) - countKeyItems(player, ABYSSITE_ACUMEN), 1);
    local restore = tier;
    if (tier <= 3) then restore = math.random(1, 3); end

    local nbItem = 0;
    if (dropType == PYXIS_DROP_TEMP) then
        nbItem = math.random(1, 3);
    end

    return
    {
        tier = tier, dropType = dropType, message = blueMessages[dropType][tier],
        model = 965, required = required, rand = math.random(10, 99), restore = restore,
        size = 3, nbItem = nbItem,
    };
end

local function setupRed(player, lightValues)
    local tier = math.min(rollTier(lightValues[LIGHT_RUBY]) + countKeyItems(player, ABYSSITE_PROSPERITY), 5);
    local available = {};
    for light, _ in pairs(chestLightValues[tier]) do
        table.insert(available, light);
    end
    table.sort(available);
    local light = available[math.random(1, #available)];

    return
    {
        tier = tier, dropType = PYXIS_DROP_LIGHT, message = lightsMessage[light][tier],
        model = 968, light = light, lightValue = chestLightValues[tier][light], rand = math.random(25, 60), size = 3,
    };
end

-- gold chest: amber light picks the tier, tier picks the combination range, drops are items
local goldTiers = { 24, 35, 46, 68, 90 };
local goldDrops =
{
    BIG    = { { drop = PYXIS_DROP_TEMP, message = 42, max = 3 }, { drop = PYXIS_DROP_ITEM, message = 43, max = 4 },
               { drop = PYXIS_DROP_POPITEM, message = 43, max = 2 }, { drop = PYXIS_DROP_AUGMENT, message = 44, max = 2 },
               { drop = PYXIS_DROP_KEYITEM, message = 45, max = 1 } },
    LITTLE = { { drop = PYXIS_DROP_TEMP, message = 42, max = 3 }, { drop = PYXIS_DROP_ITEM, message = 43, max = 4 },
               { drop = PYXIS_DROP_POPITEM, message = 43, max = 2 }, { drop = PYXIS_DROP_AUGMENT, message = 44, max = 2 } },
};

local function setupGold(player, zoneid, lightValues)
    local amber = lightValues[LIGHT_AMBER];
    local tier = 5;
    if (amber <= 63) then tier = 1;
    elseif (amber <= 127) then tier = 2;
    elseif (amber <= 191) then tier = 3;
    elseif (amber <= 223) then tier = 4; end

    local maxUnlock = goldTiers[tier];
    if (math.random(1, 100) < 5) then
        tier = math.max(tier, math.random(tier, 5));
        maxUnlock = goldTiers[math.min(tier + 1, 5)];
    end

    tier = math.min(tier + countKeyItems(player, ABYSSITE_DESTINY), 5);

    local size = 1155;
    if (tier >= 5 or math.random(1, 100) < 5) then
        size = 1159;
    end

    -- pop items only exist for Konschtat in LSB; skip that drop elsewhere
    local list = {};
    for _, d in ipairs(size == 1159 and goldDrops.BIG or goldDrops.LITTLE) do
        if ((d.drop ~= PYXIS_DROP_POPITEM or PYXIS_POP_DROPS[zoneid] ~= nil)
            and (d.drop ~= PYXIS_DROP_KEYITEM or PYXIS_KI_DROPS[zoneid] ~= nil)) then
            table.insert(list, d);
        end
    end
    local drop = list[math.random(1, #list)];

    local nbItem = 1;
    for i = 2, drop.max do
        if (math.random(1, 100) < 40) then nbItem = nbItem + 1; end
    end

    return
    {
        tier = tier, dropType = drop.drop, message = drop.message, model = 969, size = size,
        rand = math.random(11, maxUnlock), maxUnlock = maxUnlock, nbItem = nbItem,
    };
end

local function determineChestType(lightValues)
    local blueChance = math.max(math.random(1, math.max(lightValues[LIGHT_AZURE], 1)), 255 * 0.25);
    local redChance  = math.random(1, math.max(lightValues[LIGHT_RUBY], 1));
    local amberChance = math.random(1, math.max(lightValues[LIGHT_AMBER], 1));

    if (redChance > blueChance and redChance > amberChance) then
        return PYXIS_RED;
    elseif (amberChance > blueChance and amberChance > redChance) then
        return PYXIS_GOLD;
    end
    return PYXIS_BLUE;
end

local function findFreePyxis(zoneid)
    local base = pyxisBase[zoneid];
    local now = os.time();

    for id = base, base + 79 do
        local npc = GetNPCByID(id);
        if (npc ~= nil and npc:getName() == "Sturdy_Pyxis" and npc:getStatus() == STATUS_DISAPPEAR
            and npc:getLocalVar("SPAWNSTATUS") == 0 and now - npc:getLocalVar("FREEDAT") >= PYXIS_RECYCLE) then
            return npc;
        end
    end
    return nil;
end

-- Called from onMobDeathEx for the killer (non-NM mobs only)
function spawnPyxis(mob, player)
    local zoneid = player:getZoneID();
    if (pyxisBase[zoneid] == nil) then return; end

    local lightValues = getAbysseaLights(player);
    if (math.random(1 + lightValues[LIGHT_PEARL], 500) < 250) then return; end -- more pearl light = better odds

    local npc = findFreePyxis(zoneid);
    if (npc == nil) then return; end

    local chestType = determineChestType(lightValues);
    local data;
    if (chestType == PYXIS_RED) then
        data = setupRed(player, lightValues);
    elseif (chestType == PYXIS_GOLD) then
        data = setupGold(player, zoneid, lightValues);
    else
        data = setupBlue(player, lightValues);
    end

    npc:resetLocalVars();
    npc:setNpcFlags(data.size);
    npc:setLocalVar("PLAYERID", player:getID());
    npc:setLocalVar("TIER", data.tier);
    npc:setLocalVar("CHESTTYPE", chestType);
    npc:setLocalVar("SPAWNTIME", os.time());
    npc:setLocalVar("RAND_NUM", data.rand);
    npc:setLocalVar("REQUIRED", data.required or 0);
    npc:setLocalVar("MESSAGE", data.message);
    npc:setLocalVar("DROPTYPE", data.dropType);
    npc:setLocalVar("LIGHT", data.light or 1);
    npc:setLocalVar("LIGHT_VALUE", data.lightValue or 0);
    npc:setLocalVar("CRUOR", 250 * data.tier);
    npc:setLocalVar("EXP", 250 * data.tier);
    npc:setLocalVar("RESTORE", data.restore or 0);
    npc:setLocalVar("NB_ITEM", data.nbItem or 0);
    npc:setLocalVar("MAX_UNLOCK_NUMBER", data.maxUnlock or 0);
    npc:setLocalVar("SPAWNSTATUS", 1);

    npc:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos(), mob:getRotPos());
    npc:setModelId(data.model);
    npc:AnimationSub(12);
    npc:setStatus(STATUS_NORMAL);
    npc:entityAnimationPacket("deru");

    pyxisMessage(player, pyxisText[zoneid].CONCEALED, 0, 0, 0, 0);

    local ownerId = player:getID();
    npc:timer(PYXIS_LIFETIME * 1000, function(npcArg)
        if (npcArg:getLocalVar("SPAWNSTATUS") == 1 and npcArg:getLocalVar("PLAYERID") == ownerId) then
            local owner = GetPlayerByID(ownerId);
            if (owner ~= nil) then
                removePyxis(owner, npcArg, 0, 1);
            else
                npcArg:setLocalVar("SPAWNSTATUS", 0);
                npcArg:setLocalVar("FREEDAT", os.time());
                npcArg:AnimationSub(16);
                npcArg:setNpcFlags(3203);
                npcArg:setStatus(STATUS_DISAPPEAR);
            end
        end
    end);
end

-----------------------------------
-- item contents (temp / item / pop item) and the unlocked-chest event
-----------------------------------

-- local var prefix per drop type
local contentVar = { [PYXIS_DROP_TEMP] = "TEMP", [PYXIS_DROP_ITEM] = "ITEM", [PYXIS_DROP_POPITEM] = "POPITEM" };

local function getContents(npc)
    local var = contentVar[npc:getLocalVar("DROPTYPE")];
    local t = {};
    if (var ~= nil) then
        for i = 1, npc:getLocalVar("NB_ITEM") do
            t[i] = npc:getLocalVar(var .. i);
        end
    end
    return t;
end

local function chestEmpty(t)
    for _, v in ipairs(t) do
        if (v ~= 0) then return false; end
    end
    return true;
end

local function randomItem(zoneid, tier)
    local drops = {};
    for _, v in ipairs(PYXIS_COMMON_DROPS) do table.insert(drops, v); end
    local zoneList = PYXIS_ITEM_DROPS[zoneid];
    if (zoneList ~= nil) then
        for _, v in ipairs(zoneList) do table.insert(drops, v); end
    end
    local ded = 0;
    if (PYXIS_ITEM_DEDUCT[zoneid] ~= nil) then ded = PYXIS_ITEM_DEDUCT[zoneid][tier] or 0; end
    return drops[math.random(1, math.max(#drops - ded, 1))];
end

-- fill the chest contents once, the first time somebody looks inside
local function setDrops(npc)
    if (npc:getLocalVar("ITEMS_SET") == 1) then return; end
    local dropType = npc:getLocalVar("DROPTYPE");
    local tier = npc:getLocalVar("TIER");
    local zoneid = npc:getZoneID();
    local var = contentVar[dropType];

    if (dropType == PYXIS_DROP_AUGMENT) then
        setAugmentDrops(npc);
        npc:setLocalVar("ITEMS_SET", 1);
        return;
    elseif (dropType == PYXIS_DROP_KEYITEM) then
        local list = PYXIS_KI_DROPS[zoneid];
        npc:setLocalVar("KI", list[math.random(1, #list)]);
        npc:setLocalVar("ITEMS_SET", 1);
        return;
    end
    if (var == nil) then return; end

    for i = 1, npc:getLocalVar("NB_ITEM") do
        local item;
        if (dropType == PYXIS_DROP_TEMP) then
            item = PYXIS_TEMP_DROPS[tier][math.random(1, #PYXIS_TEMP_DROPS[tier])];
        elseif (dropType == PYXIS_DROP_ITEM) then
            item = randomItem(zoneid, tier);
        else
            item = PYXIS_POP_DROPS[zoneid][math.random(1, #PYXIS_POP_DROPS[zoneid])];
        end
        npc:setLocalVar(var .. i, item);
    end
    npc:setLocalVar("ITEMS_SET", 1);
end

local function takeItem(player, npc, index)
    local text = pyxisText[player:getZoneID()];
    local dropType = npc:getLocalVar("DROPTYPE");
    local var = contentVar[dropType];
    local list = getContents(npc);
    local item = list[index];

    if (item == nil) then return; end
    if (item == 0) then
        if (dropType == PYXIS_DROP_TEMP) then
            player:messageSpecial(text.TEMP_GONE);
        else
            player:messageSpecial(text.ITEM_GONE);
        end
        return;
    end

    if (dropType == PYXIS_DROP_TEMP) then
        if (player:hasItem(item, LOC_TEMPITEMS)) then
            player:messageSpecial(text.ALREADY_TEMP);
            return;
        end
        player:addTempItem(item, 1);
        pyxisMessage(player, text.OBTAINS_TEMP, item, 0, 0, 0);
    else
        if (player:getFreeSlotsCount() == 0) then
            player:messageSpecial(text.CANNOT_OBTAIN, item);
            return;
        end
        player:addItem(item, 1);
        pyxisMessage(player, text.OBTAINS_ITEM, item, 0, 0, 0);
    end

    npc:setLocalVar(var .. index, 0);
    list[index] = 0;
    if (chestEmpty(list)) then
        removePyxis(player, npc, 0, 3);
    end
end

-- augmented items: ITEM<n>ID, ITEM<n>A<k> / ITEM<n>V<k> (augment id / value), and KI for key item drops
local function rollAugment(npc, item, slot)
    local tier = npc:getLocalVar("TIER");
    local limit = 98;
    if (tier == 5) then limit = 65; elseif (tier >= 3) then limit = 80; end

    local list = PYXIS_AUG_TABLE[item];
    local count = math.max(#list - PYXIS_AUG_DEDUCT[item][tier], 1);
    local first = math.random(1, count);

    local function store(k, entry)
        local value = math.random(entry[2], entry[3]);
        npc:setLocalVar("ITEM" .. slot .. "A" .. k, entry[1]);
        npc:setLocalVar("ITEM" .. slot .. "V" .. k, value - 1);
    end

    store(1, list[first]);
    if (math.random(1, 100) > limit) then
        local second = math.random(1, count);
        if (second ~= first) then store(2, list[second]); end
    end
end

local function setAugmentDrops(npc)
    local tier = npc:getLocalVar("TIER");
    local drops = PYXIS_AUG_DROPS[npc:getZoneID()];
    local item1 = drops[math.random(1, #drops)];
    npc:setLocalVar("ITEM1ID", item1);
    rollAugment(npc, item1, 1);
    if (tier > 2 and math.random(0, 100) > (90 / tier)) then
        local item2 = drops[math.random(1, #drops)];
        npc:setLocalVar("ITEM2ID", item2);
        rollAugment(npc, item2, 2);
    end
end

local function packedAugment(npc, slot, k)
    local id = npc:getLocalVar("ITEM" .. slot .. "A" .. k);
    if (id == 0) then return 0; end
    return bit.bor(id, bit.lshift(npc:getLocalVar("ITEM" .. slot .. "V" .. k), 11));
end

local function takeAugment(player, npc, slot)
    local text = pyxisText[player:getZoneID()];
    local item = npc:getLocalVar("ITEM" .. slot .. "ID");
    if (item == 0) then
        player:messageSpecial(text.ITEM_GONE);
        return;
    end
    if (player:getFreeSlotsCount() == 0) then
        player:messageSpecial(text.CANNOT_OBTAIN, item);
        return;
    end
    player:addItem(item, 1,
        npc:getLocalVar("ITEM" .. slot .. "A1"), npc:getLocalVar("ITEM" .. slot .. "V1"),
        npc:getLocalVar("ITEM" .. slot .. "A2"), npc:getLocalVar("ITEM" .. slot .. "V2"));
    pyxisMessage(player, text.OBTAINS_ITEM, item, 0, 0, 0);
    npc:setLocalVar("ITEM" .. slot .. "ID", 0);
    if (npc:getLocalVar("ITEM1ID") == 0 and npc:getLocalVar("ITEM2ID") == 0) then
        removePyxis(player, npc, 0, 3);
    end
end

local function takeKeyItem(player, npc)
    local text = pyxisText[player:getZoneID()];
    local ki = npc:getLocalVar("KI");
    if (ki == 0) then
        player:messageSpecial(text.KI_GONE);
    elseif (player:hasKeyItem(ki)) then
        player:messageSpecial(text.ALREADY_KI);
    else
        player:addKeyItem(ki);
        pyxisMessage(player, text.OBTAINS_KI, ki, 0, 0, 0);
        npc:setLocalVar("KI", 0);
        removePyxis(player, npc, 0, 3);
    end
end

local function sendToTreasure(player, npc)
    local text = pyxisText[player:getZoneID()];
    for _, v in ipairs(getContents(npc)) do
        if (v ~= 0) then
            player:addTreasure(v);
        end
    end
    pyxisMessage(player, text.SPOILS, 0, 0, 0, 0);
    removePyxis(player, npc, 0, 1);
end

-----------------------------------
-- lock minigames
-----------------------------------

local function startBlue(player, npc, event, content, timeleft)
    player:startEvent(event, content, npc:getLocalVar("RAND_NUM"), npc:getLocalVar("CURRENT_ATTEMPTS"),
        npc:getLocalVar("REQUIRED"), npc:getLocalVar("FAILED_ATTEMPTS"), ATTEMPTS, 3, timeleft);
end

local function startRed(player, npc, event, content, timeleft)
    local target = npc:getLocalVar("RAND_NUM");
    local pressure = npc:getLocalVar("CURRENTPRESSURE");

    if (pressure <= 0) then
        pressure = math.random(90, 100);
        npc:setLocalVar("CURRENTPRESSURE", pressure);
    end

    local good = bit.bor(target - 10, bit.lshift(target + 10, 16));

    local wear = npc:getLocalVar("LOCKWEARMESSAGE");
    if (wear == 0) then
        wear = math.random(1, 4);
        npc:setLocalVar("LOCKWEARMESSAGE", wear);
    end
    npc:setLocalVar("LOCKWEARADD", math.random(0, lockwear[wear]));

    player:startEvent(event, content, pressure, good, wear - 1, ATTEMPTS, npc:getLocalVar("CURRENT_ATTEMPTS"), 3, timeleft);
end

local function failChest(player, npc, text)
    removePyxis(player, npc, 0, 1);
    pyxisMessage(player, text.FAILED, 0, 0, 0, 0);
    player:messageSpecial(text.DISAPPEARED);
end

local function unlockBlue(player, option, npc)
    local text = pyxisText[player:getZoneID()];
    local choice = bit.lshift(1, option - 1);
    local newRand = math.random(10, 99);
    local last = npc:getLocalVar("RAND_NUM");

    if (choice ~= 1 and choice ~= 2) then return; end
    npc:setLocalVar("RAND_NUM", newRand);

    local good = (choice == 1 and newRand > last) or (choice == 2 and newRand < last);

    if (good) then
        pyxisMessage(player, text.RANDOM_GUESS, newRand, 0, 0, 0);
        local correct = npc:getLocalVar("CORRECT_GUESSES") + 1;
        npc:setLocalVar("CORRECT_GUESSES", correct);

        if (correct >= npc:getLocalVar("REQUIRED")) then
            pyxisMessage(player, text.OPENED, 0, 0, 0, 0);
            openPyxis(player, npc);
        else
            npc:setLocalVar("CURRENT_ATTEMPTS", npc:getLocalVar("CURRENT_ATTEMPTS") + 1);
        end
    else
        pyxisMessage(player, text.RANDOM_GUESS, newRand, 1, 0, 0);
        local failed = npc:getLocalVar("FAILED_ATTEMPTS") + 1;
        npc:setLocalVar("FAILED_ATTEMPTS", failed);
        if (failed >= ATTEMPTS) then
            failChest(player, npc, text);
        end
    end
end

local function unlockRed(player, option, npc)
    local text = pyxisText[player:getZoneID()];
    local choice = bit.lshift(1, option);
    if (pressureChoice[choice] == nil) then return; end

    local attempts = npc:getLocalVar("CURRENT_ATTEMPTS") + 1;
    local target = npc:getLocalVar("RAND_NUM");
    local pressure = npc:getLocalVar("CURRENTPRESSURE");
    local change = pressureChoice[choice] + npc:getLocalVar("LOCKWEARADD");
    local increased = 0;
    local new;

    if (choice < 16) then
        new = pressure - change;
    else
        new = pressure + change;
        increased = 1;
    end

    npc:setLocalVar("CURRENT_ATTEMPTS", attempts);

    if (new >= target - 10 and new <= target + 10) then
        pyxisMessage(player, text.AIR_PRESSURE, change, increased, 0, new);
        pyxisMessage(player, text.OPENED, 0, 0, 0, 0);
        openPyxis(player, npc);
    elseif (attempts >= ATTEMPTS) then
        failChest(player, npc, text);
    else
        npc:setLocalVar("LOCKWEARMESSAGE", math.random(1, 4));
        if (new > 0) then
            npc:setLocalVar("CURRENTPRESSURE", new);
            pyxisMessage(player, text.AIR_PRESSURE, change, increased, 0, new);
        else
            npc:setLocalVar("CURRENTPRESSURE", 0);
            pyxisMessage(player, text.AIR_PRESSURE, change, increased, 1, 0);
        end
    end
end

local function startGold(player, npc, event, content, timeleft)
    player:startEvent(event, content, 11, npc:getLocalVar("MAX_UNLOCK_NUMBER"), ATTEMPTS,
        npc:getLocalVar("CURRENT_ATTEMPTS"), npc:getLocalVar("RAND_NUM"), 3, timeleft);
end

local function unlockGold(player, option, npc)
    local text = pyxisText[player:getZoneID()];
    local input = bit.band(option, 0xFF);
    local target = npc:getLocalVar("RAND_NUM");

    if (input <= 10 or input >= 100) then return; end

    local attempts = npc:getLocalVar("CURRENT_ATTEMPTS") + 1;
    npc:setLocalVar("CURRENT_ATTEMPTS", attempts);

    if (input == target) then
        pyxisMessage(player, text.INPUT, input, 1, 0, 0);
        pyxisMessage(player, text.OPENED, 0, 0, 0, 0);
        openPyxis(player, npc);
    elseif (attempts >= ATTEMPTS) then
        failChest(player, npc, text);
    else
        pyxisMessage(player, text.INPUT, input, 0, 0, 0);

        if (input > target) then
            player:messageSpecial(text.GREATER_LESS, input, 1, 0, 0);
        else
            player:messageSpecial(text.GREATER_LESS, input, 0, 0, 0);
        end

        local d = { math.floor(target / 10), target % 10 };
        local which = math.random(1, 2);
        local digit = d[which];
        local hint = math.random(1, 5);

        if (hint == 1) then
            player:messageSpecial(text.HUNCH_EVENODD, which - 1, digit % 2, 0, 0);
        elseif (hint == 2) then
            player:messageSpecial(text.HUNCH_IS, which - 1, digit, 0, 0);
        elseif (hint == 3) then
            -- a window of three digits containing the real one
            local lo = math.max(0, math.min(digit - math.random(0, 2), 7));
            player:messageSpecial(text.HUNCH_IS_OR, which - 1, lo, lo + 1, lo + 2);
        elseif (hint == 4) then
            player:messageSpecial(text.HUNCH_ONE, digit, 0, 0, 0);
        else
            player:messageSpecial(text.HUNCH_SUM, d[1] + d[2]);
        end
    end
end

-----------------------------------
-- NPC entry points (zones/Abyssea-*/npcs/Sturdy_Pyxis.lua)
-----------------------------------

function onPyxisTrade(player, npc, trade)
    if (npc:getLocalVar("SPAWNSTATUS") ~= 1 or not canOpenPyxis(player, npc)) then return; end

    if (npc:AnimationSub() == 12 and trade:hasItemQty(FORBIDDEN_KEY, 1) and trade:getItemCount() == 1) then
        player:tradeComplete();
        pyxisMessage(player, pyxisText[player:getZoneID()].KEY_OPEN, FORBIDDEN_KEY, 0, 0, 0);
        openPyxis(player, npc);
    end
end

function onPyxisTrigger(player, npc)
    print(string.format('[PYXIS DEBUG] trigger sub=%d status=%d chest=%d drop=%d tier=%d', npc:AnimationSub(), npc:getLocalVar('SPAWNSTATUS'), npc:getLocalVar('CHESTTYPE'), npc:getLocalVar('DROPTYPE'), npc:getLocalVar('TIER')));
    if (npc:getLocalVar("SPAWNSTATUS") ~= 1) then return; end
    if (not canOpenPyxis(player, npc)) then return; end

    local tier = npc:getLocalVar("TIER");
    setDrops(npc);

    if (npc:AnimationSub() == 13) then
        -- unlocked: show the contents (only temp / item / pop item chests stay open)
        local dropType = npc:getLocalVar("DROPTYPE");
        local view = 1;
        if (dropType == PYXIS_DROP_ITEM or dropType == PYXIS_DROP_POPITEM) then view = 2;
        elseif (dropType == PYXIS_DROP_AUGMENT) then view = 3;
        elseif (dropType == PYXIS_DROP_KEYITEM) then view = 4; end
        if (contentVar[dropType] ~= nil or view >= 3) then
            local timeleft = (os.time() - npc:getLocalVar("SPAWNTIME")) * 60;
            player:startEvent(2067 + tier, 1, 1, 1, view, 1, timeleft, 1, 1);
        end
        return;
    end

    if (npc:AnimationSub() ~= 12) then return; end

    local chestType = npc:getLocalVar("CHESTTYPE");
    local content = contentMessage[npc:getLocalVar("MESSAGE")] + chestType;
    local timeleft = (os.time() - npc:getLocalVar("SPAWNTIME")) * 60;
    local event = 2003 + tier;

    if (chestType == PYXIS_BLUE) then
        startBlue(player, npc, event, content, timeleft);
    elseif (chestType == PYXIS_GOLD) then
        startGold(player, npc, event, content, timeleft);
    else
        startRed(player, npc, event, content, timeleft);
    end
end

-- feeds the item list to the client while the lock / contents menu is open
function onPyxisEventUpdate(player, csid, option)
    print(string.format('[PYXIS DEBUG] update csid=%d option=%d', csid, option));
    local npc = player:getEventTarget();
    if (npc == nil or csid < 2004 or csid > 2072) then return; end
    local dropType = npc:getLocalVar("DROPTYPE");
    if (dropType == PYXIS_DROP_AUGMENT) then
        local flag = 0x0202;
        player:updateEvent(npc:getLocalVar("ITEM1ID"), flag, packedAugment(npc, 1, 1), packedAugment(npc, 1, 2),
            npc:getLocalVar("ITEM2ID"), flag, packedAugment(npc, 2, 1), packedAugment(npc, 2, 2));
    elseif (dropType == PYXIS_DROP_KEYITEM) then
        player:updateEvent(npc:getLocalVar("KI"), 0, 0, 0, 0, 0, 0, 0);
    elseif (contentVar[dropType] ~= nil) then
        player:updateEvent(unpack(getContents(npc)));
    end
end

function onPyxisEventFinish(player, csid, option)
    print(string.format('[PYXIS DEBUG] finish csid=%d option=%d', csid, option));
    local npc = player:getEventTarget();
    if (npc == nil or csid < 2004 or csid > 2072) then return; end

    if (option > 0 and npc:getLocalVar("SPAWNSTATUS") ~= 1) then
        player:messageSpecial(pyxisText[player:getZoneID()].DESPAWNED);
        return;
    end

    if (option == 999) then
        removePyxis(player, npc, 1, 1); -- gave up: cruor consolation
        return;
    end

    if (csid <= 2008) then
        local chestType = npc:getLocalVar("CHESTTYPE");
        if (chestType == PYXIS_BLUE) then
            unlockBlue(player, option, npc);
        elseif (chestType == PYXIS_GOLD) then
            unlockGold(player, option, npc);
        else
            unlockRed(player, option, npc);
        end
    else
        -- unlocked-chest menu: option low word 65 = take (slot in the high word, 9 = to treasure pool), 66 = leave
        local choice = bit.band(option, 0xFFFF);
        local slot = bit.rshift(option, 16);
        local dropType = npc:getLocalVar("DROPTYPE");
        if (choice == 65 and dropType == PYXIS_DROP_AUGMENT) then
            if (slot == 1 or slot == 2) then takeAugment(player, npc, slot); end
        elseif (choice == 65 and dropType == PYXIS_DROP_KEYITEM) then
            takeKeyItem(player, npc);
        elseif (choice == 65) then
            if (slot >= 1 and slot <= 8) then
                takeItem(player, npc, slot);
            elseif (slot == 9) then
                sendToTreasure(player, npc);
            end
        elseif (choice == 66) then
            removePyxis(player, npc, 1, 1);
        end
    end
end
