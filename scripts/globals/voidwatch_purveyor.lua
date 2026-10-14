-----------------------------------
-- Voidwatch Purveyor (shared logic). FIRST PASS, UNTESTED IN-GAME. No captures exist for this NPC.
-- Evidence tags: [V] client event decompile (FFXI-EventsDump, all 20 Purveyor dumps are structurally identical, same prices)
--                [W] BG-wiki  [D] design choice (flagged)
--
-- Event params [V, in-game test 2026-10-14]: param 1 = current balance ($1 in the client text). The currency (0 Conquest Points,
--   1 Imperial Standing, 2 Allied Notes) is read from one of the even params 0/2/4/6 (exact slot not isolated, we send it in all four);
--   the event fills the item prices itself from the currency. Odd params 3,5,7.. are price slots and must stay 0.
-- Menu slots [V]: 1 Cobalt Cell 3434, 2 Rubicund Cell 3435, 3 Xanthous Cell 3436, 4 Jade Cell 3437, 5 Pouch of Voiddust 3450.
-- Prices baked into the client event [V] (user rule: use these): cells 2000 for CP and Imperial Standing, 3000 for Allied Notes; voiddust 2000 for all.
--   (the BG-wiki table says 3000 for every cell, which disagrees with the baked code for CP / Imperial Standing.)
-- Result option [V]: bits 0-15 = 1 (purchase), bits 16-21 = slot (1..5), bits 22-31 = quantity (slots 1-4: 1..99; voiddust: 1). 0 = cancelled.
-- Which currency each city uses is [D]: Imperial Standing in Whitegate/Al Zahbi/Nashmau, Allied Notes in the [S] zones, Conquest Points elsewhere.
-- The client re-checks the balance itself; the server re-checks too.
-----------------------------------

VWP = {};

VWP.CP = 0;
VWP.IMPERIAL = 1;
VWP.ALLIED = 2;

VWP.ITEMS = {3434, 3435, 3436, 3437, 3450};
VWP.NAMES = {"Cobalt Cell", "Rubicund Cell", "Xanthous Cell", "Jade Cell", "Pouch of Voiddust"};
VWP.PRICE = {
    [0] = {2000, 2000, 2000, 2000, 2000},
    [1] = {2000, 2000, 2000, 2000, 2000},
    [2] = {3000, 3000, 3000, 3000, 2000},
};
VWP.CURRENCY_NAME = {[0] = "Conquest Points", [1] = "Imperial Standing", [2] = "Allied Notes"};
local STACK = 12; -- item_basic stackSize for all five items

local function balance(player, cur)
    if (cur == VWP.CP) then
        return player:getCP();
    elseif (cur == VWP.IMPERIAL) then
        return player:getCurrency("imperial_standing");
    end
    return player:getCurrency("allied_notes");
end

local function spend(player, cur, amount)
    if (cur == VWP.CP) then
        player:delCP(amount);
    elseif (cur == VWP.IMPERIAL) then
        player:delCurrency("imperial_standing", amount);
    else
        player:delCurrency("allied_notes", amount);
    end
end

-- cfg = {csid = <event id for this npc>, currency = 0|1|2}
function vwpTrigger(player, cfg)
    local bal = balance(player, cfg.currency);
    -- TEMP DIAGNOSTIC (remove before commit): shows what each currency reads for this character
    player:PrintToPlayer(string.format("[VWP debug] zone %u csid %u uses %s (%u) -> sent balance %d", player:getZoneID(), cfg.csid, VWP.CURRENCY_NAME[cfg.currency], cfg.currency, bal));
    player:PrintToPlayer(string.format("[VWP debug] all balances: CP %d | Imperial Standing %d | Allied Notes %d", player:getCP(), player:getCurrency("imperial_standing"), player:getCurrency("allied_notes")));
    local c = cfg.currency;
    -- balance is param 1 ($1 in the client text) [V probe 2026-10-14]; currency slot unknown, tried in every even slot
    player:startEvent(cfg.csid, c, bal, c, 0, c, 0, c, 0);
end

function vwpFinish(player, cfg, option)
    player:PrintToPlayer(string.format("[VWP debug] finish csid %u option %u (slot %u qty %u)", cfg.csid, option, bit.band(bit.rshift(option, 16), 0x3F), bit.rshift(option, 22))); -- TEMP DIAGNOSTIC
    if (bit.band(option, 0xFFFF) ~= 1) then
        return;
    end
    local slot = bit.band(bit.rshift(option, 16), 0x3F);
    local qty = bit.rshift(option, 22);
    if (slot < 1 or slot > 5) then
        return;
    end
    if (slot == 5) then
        qty = 1;
    end
    if (qty < 1 or qty > 99) then
        return;
    end
    local cost = VWP.PRICE[cfg.currency][slot] * qty;
    if (balance(player, cfg.currency) < cost) then
        player:PrintToPlayer(string.format("[VWP debug] server refused: cost %d > balance %d", cost, balance(player, cfg.currency))); -- TEMP DIAGNOSTIC
        return;
    end
    if (player:getFreeSlotsCount() < math.ceil(qty / STACK)) then
        player:PrintToPlayer("Your inventory is full.", 0xD);
        return;
    end
    if (player:addItem(VWP.ITEMS[slot], qty)) then
        spend(player, cfg.currency, cost);
        player:PrintToPlayer("Obtained " .. qty .. " x " .. VWP.NAMES[slot] .. " (" .. cost .. " " .. VWP.CURRENCY_NAME[cfg.currency] .. ").", 0xD);
    end
end
