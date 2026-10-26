-----------------------------------
-- Chocobo Raising (VCS) - whistle and registration-card trades at the VCS trainer (slice 3, Lua part).
-- Event ids come from the client DATs (844/845 San d'Oria, 525/533 Bastok Mines, 752/760 Windurst Woods; 525 decompiled:
-- param 0 = hidden-entry mask, item 15533 = the whistle). Options and prices follow LandSandBoat
-- hobbies/chocobo_raising/whistle.lua (LSB GUESS: no capture on file). Showing a card never takes it.
-- Whistle charges come from the CLuaItem getCurrentCharges/getMaxCharges bindings (C++). Riding uses the registered stats (speed in battleentity.cpp GetSpeed, minutes in chocobo_whistle.lua); NOT PORTED: the personal-chocobo mount model.
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

local ITEM_CARD_REG, ITEM_COUPON, ITEM_WHISTLE = 2313, 2366, 15533;
local CHOCOCARD_ITEM = { [0] = 2339, [1] = 2342 };
local REG_PRICE, REPLACE_PRICE, CHOCOCARD_COST = 250, 20000, 300;
local OPT_BUY, OPT_COUPON, OPT_CHOCOCARD, OPT_REGISTER = 221, 476, 495, 479;
local MENU_BUY, MENU_CHOCOCARD, MENU_REGISTER, MENU_NOTHING = 1, 2, 3, 31;
local QUEST_DONE = 4; -- ChocoboWhistleProg, see chocobo_raising_whistle.lua

-- { card menu, whistle recharge, TextIDs: ITEM_OBTAINED, ITEM_CANNOT_BE_OBTAINED, NOT_HAVE_ENOUGH_GIL }
CR.tradeEvents =
{
    [230] = { 844, 845, 6432, 6426, 6437 },
    [234] = { 525, 533, 6388, 6382, 6393 },
    [241] = { 752, 760, 6547, 6541, 6552 },
};
local EV = CR.tradeEvents;
local rechargePrice = {}; -- player id -> gil owed for the whistle in the open trade
local RECHARGE_PER_CHARGE, OPT_PAY_RECHARGE = 400, 220;
local shownCard = {}; -- player id -> exdata of the card being shown (DSP has no player:getTrade())

local function questDone(player)
    return player:getVar("ChocoboWhistleProg") == QUEST_DONE;
end

local function tradeSlots(trade)
    local ids = {};
    for slot = 0, 7 do
        local id = trade:getItemId(slot);
        if (id ~= nil and id ~= 0) then
            ids[#ids + 1] = { id = id, slot = slot };
        end
    end
    return ids;
end

-- Card extra data (layout in chocobo_raising_day.lua): 4 stat bytes, 4 gene bytes, 4 spare, 12 signature bytes.
local function cardName(b)
    local name, pos = "", 0;
    for i = 1, 15 do
        local v = 0;
        for k = 0, 5 do
            local idx = math.floor(pos / 8) + 13;
            v = v + (math.floor((b[idx] or 0) / 2 ^ (pos % 8)) % 2) * 2 ^ k;
            pos = pos + 1;
        end
        if (v == 0) then break; end
        if (v <= 10) then name = name .. string.char(47 + v);
        elseif (v <= 36) then name = name .. string.char(54 + v);
        elseif (v <= 62) then name = name .. string.char(60 + v); end
    end
    return name;
end

local function cardChocobo(b)
    local function stat(v) return math.floor(v / 32) * 32 + (math.floor(v / 2) % 16) * 2; end
    local appearance = 0;
    if (b[1] % 2 == 1) then appearance = appearance + 1; end
    if (b[2] % 2 == 1) then appearance = appearance + 2; end
    if (b[3] % 2 == 1) then appearance = appearance + 4; end
    return
    {
        color = math.floor(b[8] / 2) % 8, appearance = appearance, sex = b[8] % 2,
        strength = stat(b[1]), endurance = stat(b[2]), discernment = stat(b[3]), receptivity = b[4],
        ability1 = math.floor(b[6] / 2) % 16, ability2 = math.floor(b[6] / 32) % 8 + (b[7] % 2) * 8,
        weather = math.floor(b[7] / 16) % 16,
    };
end

-- Riding speed stored = 80 * (80 + 2.5/rank)% (the mount runs at half of it) (max 8 ranks), minutes 17 + 4/rank (max 7); Gallop (1) / Canter (2) add a rank (LSB constants).
local function registration(c)
    local sRanks = math.min(math.floor(c.strength / 32) + ((c.ability1 == 1 or c.ability2 == 1) and 1 or 0), 8);
    local eRanks = math.floor(c.endurance / 32) + ((c.ability1 == 2 or c.ability2 == 2) and 1 or 0);
    return
    {
        color = c.color, largeBeak = c.appearance % 8 >= 4, fullTail = c.appearance % 4 >= 2, largeTalons = c.appearance % 2 == 1,
        speed = math.max(math.floor(80 * (80 + 2.5 * sRanks) / 100), 2), -- percent of the rental speed 80 (LSB MOUNT_SPEED)
        minutes = math.floor(17 + 4 * math.min(eRanks, 7)),
        ability1 = c.ability1, ability2 = c.ability2, strength = c.strength, endurance = c.endurance,
        discernment = c.discernment, receptivity = c.receptivity, weather = c.weather,
    };
end

local function canBuy(player)
    return questDone(player) and not player:hasItem(ITEM_WHISTLE);
end

-- A set bit hides the entry.
local function cardMenuMask(player)
    local shown = { MENU_CHOCOCARD, MENU_NOTHING };
    if (questDone(player)) then shown[#shown + 1] = MENU_REGISTER; end
    if (canBuy(player)) then shown[#shown + 1] = MENU_BUY; end
    local mask = 0xFFFFFFFF;
    for _, e in ipairs(shown) do mask = mask - 2 ^ e; end
    return mask;
end

-- Returns true when the trade was a registration card or a whistle with a coupon.
function CR.whistleTrade(player, trade)
    local ev = EV[player:getZoneID()];
    if (ev == nil) then return false; end
    local items = tradeSlots(trade);
    if (trade:getItemCount() == 1 and #items == 1 and items[1].id == ITEM_CARD_REG) then
        local exdata = trade:getItem(items[1].slot):getExData();
        shownCard[player:getID()] = exdata;
        local name = cardName(exdata);
        player:startEventString(ev[1], name, name, name, name, cardMenuMask(player));
        return true;
    end
    local whistleSlot, hasCoupon = nil, false;
    for _, it in ipairs(items) do
        if (it.id == ITEM_WHISTLE) then whistleSlot = it.slot; elseif (it.id == ITEM_COUPON) then hasCoupon = true; end
    end
    if (whistleSlot ~= nil and (#items == 1 or (#items == 2 and hasCoupon)) and trade:getItemCount() == #items) then
        -- LSB GUESS: price = 400 gil per used charge; a coupon pays it by swapping in a fresh whistle
        local whistle = trade:getItem(whistleSlot);
        local used = math.max(whistle:getMaxCharges() - whistle:getCurrentCharges(), 0);
        if (used == 0) then
            if (hasCoupon) then return false; end -- a full whistle keeps its coupon; nothing to recharge
            rechargePrice[player:getID()] = 0;
            player:startEvent(ev[2], 0, 0);
            return true;
        end
        if (hasCoupon) then
            player:tradeComplete();
            player:addItem(ITEM_WHISTLE);
            player:startEvent(ev[2], used, 0);
            return true;
        end
        rechargePrice[player:getID()] = used * RECHARGE_PER_CHARGE;
        player:startEvent(ev[2], used, used * RECHARGE_PER_CHARGE);
        return true;
    end
    return false;
end

function CR.whistleTradeUpdate(player, csid, option)
    local ev = EV[player:getZoneID()];
    if (ev ~= nil and csid == ev[2] and option == OPT_COUPON) then
        player:updateEvent(0xFFFFFFFF, OPT_COUPON, 0, 0, 0, 0, 0, 0);
    end
end

local function giveItem(player, ev, id, exdata)
    if (player:getFreeSlotsCount() == 0) then
        player:messageSpecial(ev[4], id);
        return false;
    end
    if (exdata ~= nil) then player:addItemExData(id, exdata, false); else player:addItem(id); end
    player:messageSpecial(ev[3], id);
    return true;
end

function CR.whistleTradeFinish(player, csid, option)
    local ev = EV[player:getZoneID()];
    if (ev == nil) then return; end
    if (csid == ev[2]) then
        local price = rechargePrice[player:getID()];
        rechargePrice[player:getID()] = nil;
        if (price ~= nil) then
            if (option == OPT_PAY_RECHARGE and price > 0) then
                if (player:getGil() < price) then
                    player:messageSpecial(ev[5]);
                else
                    player:tradeComplete();
                    player:delGil(price);
                    player:addItem(ITEM_WHISTLE);
                    return;
                end
            end
            player:confirmTrade();
        end
        return;
    end
    if (csid ~= ev[1]) then return; end
    local b = shownCard[player:getID()];
    shownCard[player:getID()] = nil;
    if (b ~= nil) then
        if (option == OPT_CHOCOCARD) then
            if (player:getGil() < CHOCOCARD_COST) then
                player:messageSpecial(ev[5]);
            elseif (giveItem(player, ev, CHOCOCARD_ITEM[b[8] % 2], b)) then
                -- the chococard carries the registration card's own extra data
                player:delGil(CHOCOCARD_COST);
            end
        elseif (option == OPT_REGISTER and questDone(player)) then
            if (player:getGil() < REG_PRICE) then
                player:messageSpecial(ev[5]);
            else
                player:delGil(REG_PRICE);
                player:registerChocobo(registration(cardChocobo(b)));
            end
        end
    end
    if (option == OPT_BUY and canBuy(player)) then
        if (player:getGil() < REPLACE_PRICE) then
            player:messageSpecial(ev[5]);
        elseif (giveItem(player, ev, ITEM_WHISTLE)) then
            player:delGil(REPLACE_PRICE);
        end
    end
    -- the card is shown, never taken: confirming with nothing confirmed releases the trade
    if (b ~= nil) then player:confirmTrade(); end
end
