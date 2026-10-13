-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Berangere
-- Type: Nyzul Isle Uncharted Area Survey (instance 52) -- astraria fragment redemption
-- !pos 135.210 1.161 -30.401 63
-----------------------------------
-- Real entity (id 16982180, npc_list.sql line 3997 -- already present, no SQL change needed).
-- Real dialog ids confirmed this session via mission_toolkit.py + explore_event.py against a
-- fresh same-session dat-extractor pull: 6187/5660 (greeting), 6189 (ask-menu), 6199-6205
-- (astraria lore). All still used below via player:messageText(npc, id) calls (no compiled
-- bytecode involved -- messageText just prints real dialog-table text as a private text packet;
-- npc:say() is NOT a real binding -- confirmed 2026-09-24 via live map-server crash + grep of
-- lua_baseentity.cpp, it was a decompiler-invented name for the compiled event's internal opcode).
--
-- 2026-09-24: REPLACED the csid-288-driven purchase flow entirely. See
-- docs/project-memory/11-berangere-bitwork-investigation.md for the full writeup. Short version:
-- csid 288's compiled client event gates the "do you possess this astrarium" check using
-- CodeGETBITWORK/CodeSETBITWORK opcodes (confirmed via raw bytecode disassembly,
-- mission_reports/Aht_Urhgan_Whitegate/events_disasm.txt lines 19318-21129). Topaz's C++ engine
-- has zero implementation of this opcode anywhere (grep -rn "BITWORK" src -> no results), and
-- the entire csid 288 interaction runs client-side with no server round-trip until the very last
-- packet, so there is no way to intercept or patch the broken check mid-flow. Ruled out first:
-- startEvent params 5-7 (live mask test, unchanged CS behavior), keyList/seenList (client-set
-- only, already-seen KIs re-tested with no change), and client-side caching (full relog, no
-- change). No prior art exists anywhere in Topaz: the same 684-byte BITWORK event is reused
-- verbatim across ~9 other zones and none of them have ever been implemented (checked Lebros
-- Cavern's matching entity 17035492 -- still an unresolved 'NPC[e4]' placeholder in npc_list.sql).
--
-- New flow is fully server-authoritative, using only real, already-proven-reliable bindings:
--   - player:hasKeyItem() is the sole truth source for which astrarium is held (100% reliable
--     throughout this investigation -- the bug was always client-side, never server-side).
--   - Tier is auto-selected via the existing redemptionPreference tie-break (unchanged from the
--     old flow) rather than asked, since a player only ever holds a completed astrarium for one
--     tier at a time in practice, and redemptionPreference already defines what to do if more
--     than one is somehow held.
--   - Family+slot (15 real combinations -- 5 slots x 3 families) is NOT trackable server-side
--     (checked scripts/globals/nyzul.lua's fragment-granting code -- it never records which
--     Uncharted Area/family was explored), so per the user's explicit "no randomness, same item
--     for same choice" rule, the player picks explicitly and deterministically: trade Berangere
--     1-15 gil, where the amount is a fixed index into (slot, family). This is a plain FFXI
--     trade-window interaction -- no compiled event, no invented ids, nothing client-side to
--     desync. Instructions are printed via PrintToPlayer (already used elsewhere in this file
--     for free-form status text, e.g. the old inventory-full message).
--
-- Tier -> augment mapping is the real BG Wiki redemption schedule (user-confirmed 2026-09-23):
-- Bronze->+1, Silver->+2, Mythril->+3, Gold->HQ, Platinum->HQ. This is intentionally NOT the same
-- table as Nyzul.unchartedBossArmorDrops (per-kill RNG drops from bosses) -- that table is
-- untouched and must stay that way.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
-- Zone-local on purpose: the bare global ITEM_OBTAINED is overwritten by whichever zone TextIDs loaded last
-- (it printed Nyzul/other-zone text, "Which sample..."). 225 verified in game 2026-10-03 for this zone.
local ITEM_OBTAINED_WHITEGATE = 225

local tierOrder = { "BRONZE", "SILVER", "MYTHRIL", "GOLD", "PLATINUM" }

-- Preference order when a player holds more than one completed astrarium at once: redeem the
-- highest tier held first. Unchanged from the old flow -- this was already our own server-side
-- tie-break, not something copied from client behavior.
local redemptionPreference = { "PLATINUM", "GOLD", "MYTHRIL", "SILVER", "BRONZE" }

-- tier name -> augment suffix granted on redemption
local tierAugment =
{
    BRONZE   = "+1",
    SILVER   = "+2",
    MYTHRIL  = "+3",
    GOLD     = "HQ",
    PLATINUM = "HQ",
}

-- real item ids, fresh-verified against C:\topaz\sql\item_basic.sql this session (2026-09-23),
-- zero invented ids -- indexed [slot 1-5][family][augment]
local astrariaItems =
{
    -- body
    { RHEIC = { ["+1"] = 10471, ["+2"] = 10472, ["+3"] = 10473, HQ = 10474 },
      EUXINE = { ["+1"] = 10476, ["+2"] = 10477, ["+3"] = 10478, HQ = 10479 },
      TETHYAN = { ["+1"] = 10481, ["+2"] = 10482, ["+3"] = 10483, HQ = 10484 } },
    -- hands
    { RHEIC = { ["+1"] = 10520, ["+2"] = 10521, ["+3"] = 10522, HQ = 10523 },
      EUXINE = { ["+1"] = 10525, ["+2"] = 10526, ["+3"] = 10527, HQ = 10528 },
      TETHYAN = { ["+1"] = 10530, ["+2"] = 10531, ["+3"] = 10532, HQ = 10533 } },
    -- legs
    { RHEIC = { ["+1"] = 10551, ["+2"] = 10552, ["+3"] = 10553, HQ = 10554 },
      EUXINE = { ["+1"] = 10556, ["+2"] = 10557, ["+3"] = 10558, HQ = 10559 },
      TETHYAN = { ["+1"] = 10561, ["+2"] = 10562, ["+3"] = 10563, HQ = 10564 } },
    -- feet
    { RHEIC = { ["+1"] = 10617, ["+2"] = 10618, ["+3"] = 10619, HQ = 10620 },
      EUXINE = { ["+1"] = 10622, ["+2"] = 10623, ["+3"] = 10624, HQ = 10625 },
      TETHYAN = { ["+1"] = 10627, ["+2"] = 10628, ["+3"] = 10629, HQ = 10630 } },
    -- head
    { RHEIC = { ["+1"] = 10898, ["+2"] = 10899, ["+3"] = 10900, HQ = 10901 },
      EUXINE = { ["+1"] = 10903, ["+2"] = 10904, ["+3"] = 10905, HQ = 10906 },
      TETHYAN = { ["+1"] = 10908, ["+2"] = 10909, ["+3"] = 10910, HQ = 10911 } },
}

local slotNames = { "Body", "Hands", "Legs", "Feet", "Head" }
local familyOrder = { "RHEIC", "EUXINE", "TETHYAN" }
local familyNames = { RHEIC = "Rheic", EUXINE = "Euxine", TETHYAN = "Tethyan" }

-- Deterministic 1-15 gil amount -> (slot index, family) menu, printed to the player and used to
-- decode the trade in onTrade below. slotIdx = ceil(gil/3), familyIdx = ((gil-1) % 3) + 1.
local function decodeChoice(gilAmount)
    if gilAmount < 1 or gilAmount > 15 then
        return nil
    end
    local slotIdx = math.ceil(gilAmount / 3)
    local familyIdx = ((gilAmount - 1) % 3) + 1
    return slotIdx, familyOrder[familyIdx]
end

local function printMenu(player, tier)
    player:PrintToPlayer(string.format("Berangere: You possess a fully assembled %s (%s augment).", Nyzul.astraria[tier].name, tierAugment[tier]))
    player:PrintToPlayer("Trade me gil to choose your reward. Rheic / Euxine / Tethyan:")
    for slotIdx, slotName in ipairs(slotNames) do
        local first = (slotIdx - 1) * 3 + 1
        player:PrintToPlayer(string.format("  %u / %u / %u gil: %s", first, first + 1, first + 2, slotName))
    end
end

function onTrigger(player, npc)
    npc:lookAt(player:getPos())

    if player:getLocalVar("BerangereGreeted") == 0 then
        -- 2026-09-26 (issue #5): the greeting used to dump the whole astraria lore wall (10 lines) at
        -- once on first contact. Only the real short greeting is kept; the lore ids (6189, 6199-6205)
        -- remain valid for a future on-request lore option.
        player:setLocalVar("BerangereGreeted", 1)
        player:messageText(npc, 6187) -- Welcome to the Nyzul Isle field station of the Aht Urhgan Archaeological Research...
        player:messageText(npc, 5660) -- How may I help you today?
    end

    local tier = nil
    for _, candidate in ipairs(redemptionPreference) do
        if player:hasKeyItem(Nyzul.astraria[candidate].ki) then
            tier = candidate
            break
        end
    end

    if tier then
        printMenu(player, tier)
    else
        for _, t in ipairs(tierOrder) do
            local data = Nyzul.astraria[t]
            local fragments = player:getVar(data.charvar)
            if fragments > 0 then
                player:PrintToPlayer(string.format("%s: %u/%u fragments.", data.name, fragments, data.maxFragments))
            end
        end
        player:PrintToPlayer("Berangere: Assemble a full astrarium in the Uncharted Areas of Nyzul Isle, then speak with me again.")
    end
end

function onTrade(player, npc, trade)
    -- 2026-10-03: on the DSP/Valhalla core CTradeContainer::getTotalQuantity() counts a gil stack as 1
    -- (not the gil amount -- that was Topaz behavior), so a pure gil trade is getGil() > 0 and
    -- getItemCount() == 1. The earlier `getItemCount() ~= gil` check only ever passed for 1 gil.
    -- Same pattern as Cacaroon.lua.
    local gil = trade:getGil()

    if gil == 0 or trade:getItemCount() ~= 1 then
        return
    end

    local slotIdx, family = decodeChoice(gil)
    if not slotIdx then
        return
    end

    local tier = nil
    for _, candidate in ipairs(redemptionPreference) do
        if player:hasKeyItem(Nyzul.astraria[candidate].ki) then
            tier = candidate
            break
        end
    end

    if not tier then
        player:PrintToPlayer("Berangere: You do not currently possess a fully assembled astrarium.")
        return
    end

    local itemId = astrariaItems[slotIdx][family][tierAugment[tier]]

    if player:getFreeSlotsCount() <= 0 then
        player:PrintToPlayer("Berangere: Your inventory is full. Make room and speak with me again.")
        return
    end

    -- 2026-10-03: every astrarium reward is Rare/Ex, and addItem() silently refuses a Rare item the
    -- player already owns. Add the item FIRST and only consume the astrarium KI + gil if it actually
    -- landed, otherwise a duplicate piece would eat the KI and give nothing.
    if player:hasItem(itemId) then
        player:PrintToPlayer("Berangere: You already possess that piece (it is Rare/Ex). Choose a different slot or family; your astrarium and gil were not taken.")
        return
    end

    if not player:addItem(itemId) then
        player:PrintToPlayer("Berangere: I could not hand that over. Your astrarium and gil were not taken.")
        return
    end

    if Nyzul.unchartedAstrariaRedeem(player, tier) then
        player:tradeComplete()
        player:messageSpecial(ITEM_OBTAINED_WHITEGATE, itemId)
    end
end

