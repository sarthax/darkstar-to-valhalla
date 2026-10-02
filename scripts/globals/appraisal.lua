-----------------------------------
-- Shared "???" item appraisal system (Chochoroon / Drahbah / Memeroon).
-----------------------------------
-- Proof-of-concept per user-provided retail data (2026-08-17): a player trades an
-- unidentified "???" item (from an Assault Ancient Lockbox) to one of these three NPCs, pays a
-- flat gil fee, and gets back one item drawn from a weighted pool specific to that "???" item.
--
-- Only two pools have confirmed data so far: ??? Earring (real retail weights) and ??? Box
-- (equal chance across all 14 possible results -- exact odds not given, "just make it random and
-- equal chance for all from that pool" per the user). The other five "???" item types the
-- Ancient Lockboxes can hand out (ring, cape, necklace, axe, polearm, headpiece, sword, gloves,
-- bow) have no data yet -- traded in, they're handed back with a "not appraisable yet" message
-- instead of being silently eaten.
--
-- Reward routing: solo players get the appraised item directly in their inventory; in a party it
-- goes to the shared Treasure Pool so it can be distributed even if the result is Ex (per the
-- user's explicit instruction). player:getPartySize() defaults to 1 with no active party
-- (src/map/lua/lua_baseentity.cpp), so partySize <= 1 is the solo case -- confirmed via source,
-- there is no existing script anywhere in this codebase that already does this branch, so this is
-- a new pattern, not a copy of an established one.
-----------------------------------
require("scripts/globals/npc_util")
require("scripts/globals/zone")
-----------------------------------
Appraisal = Appraisal or {}

-- 2026-08-27: real fix attempts for "not proper dialog" (user-reported: Drahbah's appraisal
-- result showed raw PrintToPlayer text, not client dialogue). In order:
-- (1) messageSpecialFrom() with Topaz IDs.lua text ids -- wrong number space entirely, rendered
--     an unrelated message ("You currently posess 5353 scylds").
-- (2) messageSpecialFrom() with the REAL client ROM dialog index (5214, confirmed via
--     dat-extractor against ROM4\0\123.DAT) -- sent without error, but the item-name substitution
--     inside that message (its several back-to-back "Possible Special Code" markers -- POLUtils'
--     own way of saying it can't decode what those bytes do) never resolved; blank where the name
--     should go. CMessageSpecialPacket (src/map/packets/message_special.cpp) only carries 4 raw
--     uint32 params -- there's no per-message spec anywhere in this codebase for what those special
--     codes actually consume, so this is genuinely unimplemented/unreverse-engineered plumbing.
-- (3) LandSandBoat-style CS re-trigger -- `player:startEvent(appraisalCsid, 1, appraisedItem)`,
--     same csid as the NPC's opening dialogue, hypothesizing the client's own event bytecode would
--     branch to the RESULT lines (5213/5214, confirmed structurally identical across all three
--     NPCs -- see the full index mapping below) given a different option/param. LIVE-TESTED AND
--     DISPROVEN 2026-08-27: this just replayed the INTRO dialogue from the start (5206 again), with
--     "1" being read as the fee parameter ("...for the low, low price of 1 gil!") rather than a
--     branch selector. Topaz's startEvent/client event execution does not honor LSB's param
--     semantics the way LSB's own comment implied -- reverted.
-- FINAL (current) approach: messageSpecialFrom() for the "thinking" line only (5213-equivalent --
-- this one has no item-name substitution in it, so it renders correctly as real client dialogue),
-- followed by PrintToPlayer for the actual result text including the item name. This is a
-- deliberate compromise, not a full fix -- true item-name substitution in a special message (or a
-- working CS branch mechanism) remains unimplemented; revisit only if a real reverse-engineering
-- pass on either mechanism becomes worthwhile.
--
-- Full dialog-table index mapping (relative position -> real index), kept for reference/any future
-- attempt, even though none of these are used directly by the code below anymore except the
-- "thinking" line per zone:
--   intro(fee)        Drahbah 5206 | Chochoroon 7919 | Memeroon 10570
--   selection          "     5207 |    "        7920 |    "     10571
--   trade prompt(fee)  "     5208 |    "        7921 |    "     10572
--   room/stack warning "     5209 |    "        7922 |    "     10573+10574 (split into 2 here)
--   declined           "     5210 |    "        7923 |    "     10575
--   flavor text        "     5211 |    "        7924 |    "     10576
--   thank you          "     5212 |    "        7925 |    "     10577
--   RESULT: thinking   "     5213 |    "        7926 |    "     10578
--   RESULT: item name  "     5214 |    "        7927 |    "     10579 (substitution unresolved)
-- 2026-09-14, live map-server error: these 3 keys were bare zone-name globals with no
-- old-dsp-reference equivalent (confirmed absent -- this codebase has no named per-zone
-- constants at all, only literal numeric ids, same convention already used throughout this
-- project's other zone-id fixes) -- all 3 evaluated to nil, so every key collided into a single
-- `[nil] = ...` entry, crashing with "table index is nil" the moment this module loaded. Real
-- ids confirmed via sql/zone_settings.sql: Aht_Urhgan_Whitegate=50, Al_Zahbi=48, Nashmau=53.
local zoneResultThinkingText =
{
    [50] = 5213, -- Aht_Urhgan_Whitegate
    [48] = 7926, -- Al_Zahbi
    [53] = 10578, -- Nashmau
}

-- ???ItemId -> { name = "display name for messages", pool = { { weight, resultItemId, resultItemName }, ... } }
Appraisal.pools =
{
    [2277] = -- ??? Earring
    {
        name = "??? Earring",
        pool =
        {
            {  31, 15968, "Storm Loop" },        -- 3.1%
            {  63, 14790, "Reraise Earring" },    -- 6.3%
            { 250, 13323, "Beetle Earring" },     -- 25%
            { 188, 13327, "Silver Earring" },     -- 18.8%
            { 203, 13321, "Bone Earring" },       -- 20.3%
            { 250, 13313, "Shell Earring" },      -- 25%
        },
    },

    [2286] = -- ??? Box (equal chance placeholder, exact retail odds not confirmed)
    {
        name = "??? Box",
        pool =
        {
            { 1, 828,  "Velvet Cloth" },
            { 1, 769,  "Red Rock" },
            { 1, 928,  "Bomb Ash" },
            { 1, 1108, "Sulfur" },
            { 1, 640,  "Copper Ore" },
            { 1, 5341, "Spartan Bullet Pouch" },
            { 1, 1590, "Holy Basil" },
            { 1, 2160, "Troll Pauldron" },
            { 1, 5359, "Bronze Bullet Pouch" },
            { 1, 5340, "Silver Bullet Pouch" },
            { 1, 5353, "Iron Bullet Pouch" },
            { 1, 5363, "Bullet Pouch" },
            { 1, 2175, "Flan Meat" },
            { 1, 2302, "Troll Bronze Ingot" },
        },
    },
}

-- "???" items the lockboxes can hand out that don't have appraisal data yet -- traded in, these
-- get a clear message and are handed back untouched (no tradeComplete() call) rather than
-- silently vanishing.
Appraisal.unsupported =
{
    [2190] = "??? Sword",
    [2192] = "??? Polearm",
    [2193] = "??? Axe",
    [2194] = "??? Bow",
    [2195] = "??? Gloves",
    [2276] = "??? Headpiece",
    [2278] = "??? Ring",
    [2279] = "??? Cape",
    [2282] = "??? Necklace",
}

-- Sum-then-roll weighted pick, same idiom as scripts/globals/helm.lua's pickItem and
-- scripts/globals/assault_lockbox.lua's pickWeighted.
local function pickWeighted(pool)
    local sum = 0
    for _, v in ipairs(pool) do
        sum = sum + v[1]
    end

    local roll = math.random(sum)
    local acc = 0
    for _, v in ipairs(pool) do
        acc = acc + v[1]
        if roll <= acc then
            return v[2], v[3]
        end
    end
end

-- Call from an Appraiser NPC's onTrade. fee is a flat gil cost specific to that NPC
-- (Chochoroon 50, Drahbah/Memeroon 500 per the user). Returns true if the trade was consumed.
Appraisal.tryAppraise = function(player, npc, trade, fee)
    if trade:getItemCount() ~= 1 then
        return false
    end

    for itemID, entry in pairs(Appraisal.pools) do
        if trade:hasItemQty(itemID, 1) then
            if player:getGil() < fee then
                player:PrintToPlayer(string.format("Appraising the %s costs %u gil. You don't have enough.", entry.name, fee))
                return false
            end

            player:tradeComplete()
            player:delGil(fee)

            local resultItemID, resultItemName = pickWeighted(entry.pool)

            if player:getPartySize() <= 1 then
                if player:getFreeSlotsCount() < 1 then
                    player:PrintToPlayer(string.format("You don't have room for the %s -- clear a slot in your inventory.", resultItemName))
                else
                    player:addItem({ id = resultItemID, quantity = 1, silent = true })
                end
            else
                player:addTreasure(resultItemID)
            end

            -- Real "thinking" reaction (no item-name substitution needed in this line, so it
            -- renders correctly) followed 2s later by the plain-text result -- see header note
            -- above for why the item name itself can't go through real client dialogue yet. The
            -- delay lets the "thinking" dialogue box actually be read before the result appears,
            -- same staggered-timer idiom as Hunched_Figure.lua/Periqia (npc:timer(ms, func)).
            local thinkingText = zoneResultThinkingText[npc:getZoneID()]
            if thinkingText then
                player:showText(npc, thinkingText, 0, 0, 0, 0, true)
            end
            npc:timer(2000, function()
                player:PrintToPlayer(string.format("The %s appraisal came back! You got a %s.", entry.name, resultItemName))
            end)

            return true
        end
    end

    for itemID, name in pairs(Appraisal.unsupported) do
        if trade:hasItemQty(itemID, 1) then
            player:PrintToPlayer(string.format("The %s cannot be appraised yet.", name))
            return false
        end
    end

    return false
end

return Appraisal
