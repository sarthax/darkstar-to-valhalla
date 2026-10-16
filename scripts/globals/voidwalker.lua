-----------------------------------
-- The Voidwalker NM System (LSB F-11e port, DSP idiom)
--   /heal while holding an abyssite -> hint, or pop the nearest matching NM within 4 yalms.
--   Kill the popped NM: 1/10 chance to upgrade the abyssite.
-- Data (text ids, mob ids, positions) lives in voidwalker_data.lua (generated).
-----------------------------------

require("scripts/globals/keyitems");
require("scripts/globals/status");
require("scripts/globals/settings");
require("scripts/globals/voidwalker_data");

voidwalker = {};

-- index here is the bit position the Assai Nybaem menu expects (1 = clear)
local ABYSSITE_BIT_ORDER =
{
    CLEAR_ABYSSITE, COLORFUL_ABYSSITE, BLUE_ABYSSITE, ORANGE_ABYSSITE, BROWN_ABYSSITE,
    YELLOW_ABYSSITE, PURPLE_ABYSSITE, GREY_ABYSSITE, BLACK_ABYSSITE,
};

-- first arg of the hint message: 0 feebly .. 5 furiously; only 0,1,2,3 are used by retail upgrades
local ABYSSITE_STRENGTH = {};
ABYSSITE_STRENGTH[CLEAR_ABYSSITE]    = 0;
ABYSSITE_STRENGTH[COLORFUL_ABYSSITE] = 1;
ABYSSITE_STRENGTH[BLUE_ABYSSITE]     = 2;
ABYSSITE_STRENGTH[ORANGE_ABYSSITE]   = 2;
ABYSSITE_STRENGTH[BROWN_ABYSSITE]    = 2;
ABYSSITE_STRENGTH[YELLOW_ABYSSITE]   = 2;
ABYSSITE_STRENGTH[GREY_ABYSSITE]     = 2;
ABYSSITE_STRENGTH[BLACK_ABYSSITE]    = 3;

local POPPED_BY   = "[VoidWalker]PopedBy";
local POPPED_WITH = "[VoidWalker]PopedWith";
local POPPED_AT   = "[VoidWalker]PopedAt";

-- runtime occupancy of position slots: occupied[zoneId][slot] = mobId
local occupied = {};

local function enabled()
    return ENABLE_VOIDWALKER == nil or ENABLE_VOIDWALKER == 1;
end

local function playerAbyssites(player)
    local results = {};
    for _, ki in ipairs(ABYSSITE_BIT_ORDER) do
        if (player:hasKeyItem(ki)) then
            table.insert(results, ki);
        end
    end
    return results;
end

local function abyssiteBits(player)
    local bits = 0;
    for i, ki in ipairs(ABYSSITE_BIT_ORDER) do
        if (player:hasKeyItem(ki)) then
            bits = bits + 2 ^ (i - 1);
        end
    end
    return bits;
end

local function clearSlot(zoneId, mobId)
    local slots = occupied[zoneId];
    if (slots ~= nil) then
        for slot, id in pairs(slots) do
            if (id == mobId) then
                slots[slot] = nil;
            end
        end
    end
end

local function setRandomPos(zoneId, mobId)
    local data = VOIDWALKER_DATA[zoneId];
    local mob = GetMobByID(mobId);
    if (mob == nil or data == nil) then
        return;
    end

    occupied[zoneId] = occupied[zoneId] or {};
    clearSlot(zoneId, mobId);

    local count = #data.pos;
    local slot = math.random(1, count);
    local tries = 0;
    while (occupied[zoneId][slot] ~= nil and tries < 200) do
        slot = math.random(1, count);
        tries = tries + 1;
    end

    occupied[zoneId][slot] = mobId;
    local p = data.pos[slot];
    mob:setSpawn(p[1], p[2], p[3]);
    mob:setPos(p[1], p[2], p[3]);
end

local function mobsForAbyssites(zoneId, abyssites)
    local results = {};
    local data = VOIDWALKER_DATA[zoneId];
    if (data == nil) then
        return results;
    end

    for _, ki in ipairs(abyssites) do
        if (data.mobs[ki] ~= nil) then
            for _, mobId in ipairs(data.mobs[ki]) do
                local mob = GetMobByID(mobId);
                if (mob ~= nil and mob:isAlive() and mob:getLocalVar(POPPED_BY) == 0) then
                    table.insert(results, { mobId = mobId, keyItem = ki });
                end
            end
        end
    end
    return results;
end

local function nearestMob(player, mobs)
    local best = nil;
    for _, v in ipairs(mobs) do
        local mob = GetMobByID(v.mobId);
        local dist = player:checkDistance(mob);
        if (best == nil or dist < best.distance) then
            best = { mobId = v.mobId, keyItem = v.keyItem, distance = dist };
        end
    end
    return best;
end

-- 0 east, 1 southeast, 2 south, 3 southwest, 4 west, 5 northwest, 6 north, 7 northeast (message choice order)
local function direction(player, mob)
    local pp = player:getPos();
    local mp = mob:getPos();
    local dx = mp.x - pp.x;
    local dz = mp.z - pp.z;
    local degree = math.abs(math.deg(math.atan2(dz, dx)));
    if (degree > 90) then
        degree = 180 - degree;
    end

    if (degree >= 70) then
        if (dz >= 0) then return 6; else return 2; end
    elseif (degree <= 20) then
        if (dx >= 0) then return 0; else return 4; end
    elseif (dz >= 0) then
        if (dx >= 0) then return 7; else return 5; end
    else
        if (dx >= 0) then return 1; else return 3; end
    end
end

local function checkUpgrade(player, mob, nextKeyItem)
    if (player == nil or mob:getZoneID() ~= player:getZoneID()) then
        return;
    end

    local text = VOIDWALKER_DATA[mob:getZoneID()].text;
    local currentKeyItem = mob:getLocalVar(POPPED_WITH);

    if (math.random(1, 10) == 5) then
        if (player:hasKeyItem(currentKeyItem)) then
            player:delKeyItem(currentKeyItem);
        end

        if (nextKeyItem ~= nil) then
            player:addKeyItem(nextKeyItem);

            if (currentKeyItem == CLEAR_ABYSSITE) then
                player:messageSpecial(text.UPGRADE_KI_1, currentKeyItem, nextKeyItem);
            elseif (currentKeyItem == COLORFUL_ABYSSITE) then
                player:messageSpecial(text.UPGRADE_KI_2, currentKeyItem, nextKeyItem);
            elseif (nextKeyItem == BLACK_ABYSSITE) then
                player:messageSpecial(text.OBTAIN_KI, nextKeyItem);
            end
        end
    end
end

local function hide(mob)
    mob:setStatus(STATUS_DISAPPEAR);
    mob:hideHP(true);
    mob:hideName(true);
    mob:untargetable(true);
end

local function reset(mob)
    mob:setLocalVar(POPPED_BY, 0);
    mob:setLocalVar(POPPED_WITH, 0);
    mob:setLocalVar(POPPED_AT, 0);
end

-----------------------------------
-- Zone hook (call from Zone.lua onInitialize)
-----------------------------------
function voidwalker.zoneOnInit(zone)
    local data = VOIDWALKER_DATA[zone:getID()];
    if (data == nil) then
        return;
    end
    for _, mobs in pairs(data.mobs) do
        for _, mobId in ipairs(mobs) do
            setRandomPos(zone:getID(), mobId);
        end
    end
end

-----------------------------------
-- Mob hooks (called from the per-NM scripts)
-----------------------------------
function voidwalker.onMobSpawn(mob)
    hide(mob);
end

function voidwalker.onMobFight(mob, target)
    local popAt = mob:getLocalVar(POPPED_AT);
    if (popAt ~= 0 and (os.time() > popAt + 7200 or mob:checkDistance(target) > 25)) then
        target:messageSpecial(VOIDWALKER_DATA[mob:getZoneID()].text.DESPAWN);
        DespawnMob(mob:getID());
    end
end

function voidwalker.onMobDisengage(mob)
    reset(mob);
    hide(mob);
end

function voidwalker.onMobDespawn(mob)
    local zoneId = mob:getZoneID();
    clearSlot(zoneId, mob:getID());
    setRandomPos(zoneId, mob:getID());
    reset(mob);
end

-- keyItem = the abyssite this NM may upgrade the popper's stone into
function voidwalker.onMobDeath(mob, player, isKiller, keyItem)
    if (player == nil) then
        return;
    end

    local poppedWith = mob:getLocalVar(POPPED_WITH);

    if (isKiller) then
        local popper = GetPlayerByID(mob:getLocalVar(POPPED_BY));
        if (popper ~= nil) then
            local inAlliance = false;
            for _, member in pairs(player:getAlliance()) do
                if (member:getID() == popper:getID()) then
                    inAlliance = true;
                    break;
                end
            end
            if (not inAlliance and not popper:hasKeyItem(keyItem)) then
                checkUpgrade(popper, mob, keyItem);
            end
        end
    end

    if (player:hasKeyItem(poppedWith) and not player:hasKeyItem(keyItem)) then
        checkUpgrade(player, mob, keyItem);
    end
end

-----------------------------------
-- /heal hook (called from effects/healing.lua)
-----------------------------------
function voidwalker.onHealing(player)
    if (not enabled()) then
        return;
    end

    local zoneId = player:getZoneID();
    local data = VOIDWALKER_DATA[zoneId];
    local abyssites = playerAbyssites(player);
    if (data == nil or #abyssites == 0) then
        return;
    end

    local text = data.text;
    local near = nearestMob(player, mobsForAbyssites(zoneId, abyssites));

    if (near == nil) then
        player:messageSpecial(text.NO_MOB, abyssites[1]);
    elseif (near.distance <= 4) then
        local mob = GetMobByID(near.mobId);
        mob:setLocalVar(POPPED_BY, player:getID());
        mob:setLocalVar(POPPED_WITH, near.keyItem);
        mob:setLocalVar(POPPED_AT, os.time());

        if (near.keyItem ~= CLEAR_ABYSSITE and near.keyItem ~= COLORFUL_ABYSSITE) then
            player:delKeyItem(near.keyItem);
            player:messageSpecial(text.BREAK_KI, near.keyItem);
        else
            player:messageSpecial(text.SPAWN_MOB);
            mob:hideHP(false);
        end

        mob:hideName(false);
        mob:untargetable(false);
        mob:setStatus(STATUS_NORMAL);
        mob:updateClaim(player);
    elseif (near.distance >= 300) then
        player:messageSpecial(text.MOB_TOO_FAR, near.keyItem);
    else
        local mob = GetMobByID(near.mobId);
        player:messageSpecial(text.MOB_HINT, ABYSSITE_STRENGTH[near.keyItem], direction(player, mob), near.distance, near.keyItem);
    end
end

-----------------------------------
-- Assai Nybaem (Ru'Lude Gardens). Event 10120 decompiled from the client (explore_event.py):
-- params[0] = abyssite bitmask in (bit n-1 = ABYSSITE_BIT_ORDER[n]), params[1] = price (client shows 1000).
-----------------------------------
local ASSAI_EVENT = 10120;
local ASSAI_PRICE = 1000;

function voidwalker.abyssiteBits(player)
    return abyssiteBits(player);
end

function voidwalker.npcOnTrigger(player)
    if (not enabled()) then
        return;
    end
    player:startEvent(ASSAI_EVENT, abyssiteBits(player));
end

function voidwalker.npcOnEventUpdate(player, csid, option)
    if (csid == ASSAI_EVENT and bit.band(option, 0xF) == 3) then
        if (player:getGil() < ASSAI_PRICE) then
            player:updateEvent(3);
        elseif (player:hasKeyItem(CLEAR_ABYSSITE)) then
            player:updateEvent(2);
        else
            player:updateEvent(1);
        end
    end
end

-- keyItemObtainedMsg: the zone's KEYITEM_OBTAINED text id (client-verified for Ru'Lude: 6531)
function voidwalker.npcOnEventFinish(player, csid, option, keyItemObtainedMsg)
    if (csid ~= ASSAI_EVENT) then
        return;
    end

    local opt = bit.band(option, 0xF);
    if (opt == 1) then
        if (player:getGil() >= ASSAI_PRICE and not player:hasKeyItem(CLEAR_ABYSSITE)) then
            player:delGil(ASSAI_PRICE);
            player:addKeyItem(CLEAR_ABYSSITE);
            player:messageSpecial(keyItemObtainedMsg, CLEAR_ABYSSITE);
        end
    elseif (opt == 2) then
        local ki = ABYSSITE_BIT_ORDER[bit.rshift(option, 4)];
        if (ki ~= nil and player:hasKeyItem(ki)) then
            player:delKeyItem(ki);
        end
    end
end
