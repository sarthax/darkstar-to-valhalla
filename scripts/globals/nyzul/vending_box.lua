-----------------------------------
-- Nyzul Isle: Vending Box (lobby temp-item shop)
-----------------------------------
-- 2026-09-02: ported from LandSandBoat's scripts/globals/nyzul/vending_box.lua. Item ids are NOT
-- LSB's own (LSB's ids don't match Topaz's item_basic.sql -- e.g. LSB's 8450 "Bottle of
-- Barbarian's Drink" is Topaz item 5385) -- every id below was resolved against our own
-- sql/item_basic.sql by item name, not copied from LSB. The item list itself matches the BG Wiki
-- page (Nyzul Isle Investigation).
--
-- 2026-09-03: TWO real bugs fixed against an actual capture ("Nyzul Isle Uncharted Area Survey x1
-- + Appraisals", idview/raw/Nyzul Isle.log) -- repeated identically 3 times there, and
-- cross-confirmed by CSID 95/96 (Rune of Transfer) using the exact same param shape:
-- "Params: 1, 100913, 1, 80003072, 50, 100, 150, 0".
--   1) Cost tiers are 50/100/150, not the previously-guessed 100/200/300 -- was never actually
--      verified against a capture despite the header comment's old claim it matched the wiki.
--   2) Param slot order was wrong: real layout is [1, tokens, 1, itemsBitmask, LOW, MED, HIGH, 0]
--      -- the items-bitmask is slot 3, not slot 2 (which is a constant 1); slot 0 is also a
--      constant 1, not 0. Both vendingBoxOnTrigger's startEvent and vendingBoxOnEventUpdate's
--      updateEvent are fixed to match.
--
-- 2026-09-03 (later): the option-value/bitmask scheme is COMPLETELY REBUILT against the real
-- decompiled CSID 202 event bytecode (FFXI-EventsDump's "17093431 - Vending Box.md" -- note that
-- specific file's own npc-id label drifted from a different client version than the one our real
-- captures/client use, but the CSID 202 BYTECODE ITSELF is version-independent and directly
-- confirms the mechanism). LSB's "option 20737 = buy all" / "4354+4096 offset math" was fabricated
-- or from an unrelated client build -- the real mechanism, read directly from the branch logic, is
-- a plain positional index: CREATE_DIALOG(message_id=7466, ...) builds one fixed 27-choice list
-- ["Preferred items"(unused here)/All of them/<25 individual items>/Not now], and
-- WAIT_DIALOG_SELECT's returned option IS that list position, 0-indexed from the menu's own
-- structure -- confirmed by the branch at instruction 256 (`Work_Zone[0] == 1` triggers
-- `DISPLAY_ITEM_INFO(item_id=5385)`, the exact first item this same script loads into its own
-- fixed slot list). The 25 real items below are in the EXACT real load order the bytecode assigns
-- them (Work_Zone[2..9] then Work_Zone_1700[0..16]) -- slot position IS the option value for a
-- single-item purchase (option 0 = buy all not-yet-owned+affordable; option 1..25 = that exact
-- item; option 26 = "Not now"/cancel, matches the 25-item + all + none = 27 total real choices).
-- The bit-index used for the owned-items mask (CREATE_DIALOG's option_flags /
-- SET_BIT_WORK_RANGE's bit_index_work_offset, both directly visible in the bytecode) is also
-- exactly this same slot position -- replaces the old arbitrary LSB "slot = 0x40000"-style powers
-- ported from a different, unconfirmed scheme.
-- Not ported this pass: the "preferred items" bulk-buy personalization feature (option flags 8-11
-- in the real bytecode) -- core buy-one-item and buy-all-missing flows only.
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
tpz = tpz or {}
Nyzul = Nyzul or {}

local itemCost =
{
    LOW_GRADE    = 50,
    MEDIUM_GRADE = 100,
    HIGH_GRADE   = 150,
}

-- Real Topaz item ids (resolved by name against item_basic.sql) in the exact real fixed load
-- order from the CSID 202 bytecode -- table key IS the real slot position (1-25), which the real
-- client also uses directly as both the single-item option value and the owned-item bitmask bit
-- index.
local itemsTable =
{
    [ 1] = { item = 5385, cost = itemCost.LOW_GRADE    }, -- Bottle of Barbarian's Drink
    [ 2] = { item = 5386, cost = itemCost.LOW_GRADE    }, -- Bottle of Fighter's Drink
    [ 3] = { item = 5387, cost = itemCost.LOW_GRADE    }, -- Bottle of Oracle's Drink
    [ 4] = { item = 5388, cost = itemCost.LOW_GRADE    }, -- Bottle of Assassin's Drink
    [ 5] = { item = 5389, cost = itemCost.LOW_GRADE    }, -- Bottle of Spy's Drink
    [ 6] = { item = 5394, cost = itemCost.LOW_GRADE    }, -- Bottle of Gnostic's Drink
    [ 7] = { item = 5396, cost = itemCost.LOW_GRADE    }, -- Bottle of Shepherd's Drink
    [ 8] = { item = 5436, cost = itemCost.LOW_GRADE    }, -- Dusty Scroll of Reraise
    [ 9] = { item = 5437, cost = itemCost.LOW_GRADE    }, -- Flask of Strange Milk
    [10] = { item = 5438, cost = itemCost.LOW_GRADE    }, -- Bottle of Strange Juice
    [11] = { item = 5439, cost = itemCost.LOW_GRADE    }, -- Bottle of Vicar's Drink
    [12] = { item = 5397, cost = itemCost.LOW_GRADE    }, -- Bottle of Sprinter's Drink

    [13] = { item = 5390, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Braver's Drink
    [14] = { item = 5391, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Soldier's Drink
    [15] = { item = 5392, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Champion's Drink
    [16] = { item = 5393, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Monarch's Drink
    [17] = { item = 5395, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Cleric's Drink
    [18] = { item = 5431, cost = itemCost.MEDIUM_GRADE }, -- Dusty Potion
    [19] = { item = 5432, cost = itemCost.MEDIUM_GRADE }, -- Dusty Ether
    [20] = { item = 5434, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Fanatic's Drink
    [21] = { item = 5435, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Fool's Drink
    [22] = { item = 5440, cost = itemCost.MEDIUM_GRADE }, -- Dusty Wing
    [23] = { item = 4147, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Body Boost
    [24] = { item = 4200, cost = itemCost.MEDIUM_GRADE }, -- Bottle of Mana Boost

    [25] = { item = 5433, cost = itemCost.HIGH_GRADE   }, -- Dusty Elixir
}

-- 2026-09-04: rebuilt after live captures showed the option-value scheme above was wrong for
-- medium/high grade purchases -- e.g. clicking Braver's Drink (the FIRST real medium-grade item)
-- produced a raw EndPara of 12546 (0x3102); masking to the low byte (2) and looking it up in the
-- flat 1-25 itemsTable above resolved to slot 2 = Fighter's Drink, a LOW-GRADE item. Confirmed by
-- 4 live captures (packet_decode.py against real GP_CLI_COMMAND_EVENTEND 0x05B packets):
--   Sprinter's Drink (12th/last LOW item)   -> EndPara 0x0D21 -> low byte 13
--   Braver's Drink   (1st MEDIUM item)      -> EndPara 0x0231 -> low byte 2
--   Soldier's Drink  (2nd MEDIUM item)      -> EndPara 0x0331 -> low byte 3
--   Champion's Drink (3rd MEDIUM item)      -> EndPara 0x0431 -> low byte 4
-- The HIGH BYTE is NOT a per-trigger session counter as first assumed (that theory only
-- "worked" by coincidence because early testing happened to progress low->medium->high->buy-all
-- in order, mimicking an increment) -- it's a fixed GRADE constant, confirmed identical across
-- independent real sessions both this pass and the prior one (0x51 = Buy All in both). The LOW
-- BYTE is a per-grade LOCAL position, 1-indexed, with real items starting at position 2 (position
-- 1 reserved -- likely the unported "preferred items" bulk-buy feature this file's own header
-- mentions, option flags 8-11). HIGH grade has only 1 real item, so its own position value is
-- irrelevant -- whatever it is, there's only one possible item to resolve to.
local GRADE_LOW    = 0x21
local GRADE_MEDIUM = 0x31
local GRADE_HIGH   = 0x41
local GRADE_ALL    = 0x51

-- Exposed so other scripts (e.g. heroines_holdfast.lua's trash-mob drop roll) can reuse the same
-- real 25-item catalog without duplicating it. Table itself, not a copy -- read-only usage only.
Nyzul.itemsTable = itemsTable

local lowGradeItems, mediumGradeItems, highGradeItems = {}, {}, {}
for slot = 1, 25 do
    local entry = itemsTable[slot]
    if entry.cost == itemCost.LOW_GRADE then
        lowGradeItems[#lowGradeItems + 1] = entry
    elseif entry.cost == itemCost.MEDIUM_GRADE then
        mediumGradeItems[#mediumGradeItems + 1] = entry
    else
        highGradeItems[#highGradeItems + 1] = entry
    end
end

local function buildTemporaryItemBitmask(player)
    local hasTempItem = 1 -- All players start with 1 temp item slot in inventory. Uses bit 0.

    for slot, entry in pairs(itemsTable) do
        if player:hasItem(entry.item, LOC_TEMPITEMS) then
            hasTempItem = hasTempItem + bit.lshift(1, slot)
        end
    end

    return hasTempItem
end

local function giveAllTemporaryItems(player)
    -- 2026-09-04 TEMP DEBUG: LOC_TEMPITEMS is confirmed 50 slots (charutils.cpp:530 AddBuff(50)
    -- unconditionally on char load), so the old "1 temp item slot" theory for "buy all only grants
    -- 1 item" is dead -- 50 slots easily holds all 25. Most likely explanation is the player simply
    -- didn't have enough AP for a 2nd item (50 AP per low-grade item) and this is correct behavior,
    -- but logging real per-slot eligibility here instead of assuming, so a live "buy all" test gives
    -- real ground truth. Remove once confirmed either way.
    -- print(string.format("DEBUG_VENDING_BOX buyAll: player=%s tokens=%s", player:getName(), tostring(player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT))))
    for slot, entry in pairs(itemsTable) do
        local owned  = player:hasItem(entry.item, LOC_TEMPITEMS)
        local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
        local afford = tokens >= entry.cost
        -- print(string.format("DEBUG_VENDING_BOX buyAll:   slot=%d item=%d cost=%d owned=%s tokens=%d afford=%s", slot, entry.item, entry.cost, tostring(owned), tokens, tostring(afford)))
        if not owned and afford then
            player:addTempItem(entry.item)
            -- Real id (Dialog Table Entry 7344, "Obtained temporary item: <item>!").
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, entry.item)
            player:delAssaultPoint(NYZUL_ISLE_ASSAULT_POINT, entry.cost)
        end
    end
end

Nyzul.vendingBoxOnTrigger = function(player)
    local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
    local itemsGottenBitmask = buildTemporaryItemBitmask(player)

    player:startEvent(202, 1, tokens, 1, itemsGottenBitmask, itemCost.LOW_GRADE, itemCost.MEDIUM_GRADE, itemCost.HIGH_GRADE, 0)
end

Nyzul.vendingBoxOnEventUpdate = function(player, csid, option)
    if csid ~= 202 then
        return
    end

    -- 2026-09-04: real root cause found via 4 live packet_decode.py-verified captures -- the high
    -- byte is a fixed GRADE constant (0x21/0x31/0x41/0x51), not a per-trigger session counter as
    -- first assumed (that theory only "worked" by coincidence -- see the itemsTable-adjacent
    -- comment block above for the full real evidence). The low byte is a per-grade LOCAL position
    -- (real items start at 2, not 1) -- the flat 1-25 global lookup this used to do collided
    -- across grades (e.g. medium position 2 == low slot 2 == Fighter's Drink).
    local grade = bit.rshift(bit.band(option, 0xFF00), 8)
    local pos   = bit.band(option, 0xFF)
    -- 2026-09-15, re-enabled temporarily to diagnose a user-reported live bug: "Obtain All Items"
    -- prints to chat but doesn't behave like a real menu purchase, while individual items work
    -- fine. Need the real raw option value for the "All of them" click to confirm whether it's
    -- actually resolving to GRADE_ALL (0x51) as this file assumes, or something else entirely.
    dbgPrint(string.format("[NYZUL VENDING DEBUG] player=%s csid=%s option=%s (0x%X) grade=0x%X pos=%d",
        player:getName(), tostring(csid), tostring(option), option, grade, pos))

    if grade == GRADE_ALL then
        -- Real "All of them" (buy every not-yet-owned, affordable item across all grades).
        giveAllTemporaryItems(player)
    else
        local list
        if grade == GRADE_LOW then
            list = lowGradeItems
        elseif grade == GRADE_MEDIUM then
            list = mediumGradeItems
        elseif grade == GRADE_HIGH then
            list = highGradeItems
        end

        local entry
        if list == highGradeItems then
            entry = list[1] -- only one possible item in this grade, position value is irrelevant
        elseif list then
            entry = list[pos - 1] -- real items start at local position 2
        end

        if entry then
            if player:hasItem(entry.item, LOC_TEMPITEMS) then
                -- Real id (Dialog Table Entry 7345, "You already have that temporary item.").
                player:messageSpecial(NyzulIsle.text.VENDING_ALREADY_HAVE_ITEM, entry.item)
            elseif player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT) >= entry.cost then
                player:addTempItem(entry.item)
                player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, entry.item)
                player:delAssaultPoint(NYZUL_ISLE_ASSAULT_POINT, entry.cost)
            end
        end
    end

    local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
    local itemsGottenBitmask = buildTemporaryItemBitmask(player)
    player:updateEvent(1, tokens, 1, itemsGottenBitmask, itemCost.LOW_GRADE, itemCost.MEDIUM_GRADE, itemCost.HIGH_GRADE, 0)
end

return Nyzul
