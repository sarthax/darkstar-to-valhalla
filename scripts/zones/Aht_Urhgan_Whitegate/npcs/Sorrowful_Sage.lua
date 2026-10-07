-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Sorrowful Sage
-- Type: Assault Mission Giver
-- !pos 134.096 0.161 -30.401 50
-----------------------------------
-- 2026-09-02: rebuilt to match the other 5 Whitegate Assault mission givers (Yahsra/Isdebaaq/
-- Famad/Lageegee/Bhoy_Yhupplo -- see besieged.lua's getAssaultRank() comment for why the rank
-- gets capped, not stripped out). The (offerCSID, noRankCSID) pair for each giver runs
-- sequentially -- Leujaoam 273/279, Mamool 274/280, Lebros 275/281, Periqia 276/282,
-- Ilrusi 277/283 -- 278/284 (this file's pre-existing values, unlike everything else in this
-- file which was still a disabled stub) slot in as the next zone in that same sequence, matching
-- Nyzul Isle's position as the 6th Assault zone.
-- NYZUL_ISLE_ASSAULT_POINT (besieged.lua) and NYZUL_ISLE_ASSAULT_ORDERS (keyitems.lua id 878)
-- both already existed pre-built, as does the Alzadaal Undersea Ruins entrance NPC (_20m.lua)
-- that consumes NYZUL_ISLE_ASSAULT_ORDERS via player:getCurrentAssault() -> createInstance(id, 77).
-- Real assault ids for Nyzul Isle are 51 (nyzul_isle_investigation, recommended level 75) and
-- 52 (nyzul_isle_uncharted_survey, recommended level 99) -- confirmed via besieged.lua's
-- assaultLevels table (indices 51/52 = 75/99) and the matching commented-out instance_list rows
-- 51/52. Unlike the other 5 zones, Nyzul Isle has no rank-tiered list of 10 missions -- only
-- these 2 fixed entries -- so "rank" here only gates whether the menu opens at all, same as the
-- IMPERIAL_ARMY_ID_TAG gate on the other 5.
-- No item-purchase branch (selectiontype == 2) is wired in -- unlike the other 5 givers, no real
-- Nyzul Isle shop item list/prices has been confirmed against a capture or wiki source yet, so
-- nothing is fabricated here.
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/zones/Aht_Urhgan_Whitegate/TextIDs")
require("scripts/globals/besieged")
require("scripts/globals/missions")
require("scripts/globals/nyzul")
-----------------------------------
function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local rank = getMercenaryRank(player)
    local haveimperialIDtag
    local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)

    if player:hasKeyItem(IMPERIAL_ARMY_ID_TAG) then
        haveimperialIDtag = 1
    else
        haveimperialIDtag = 0
    end

    -- 2026-09-09: real fix -- user reported the "Runic Disc" always shows 0 floors completed.
    -- Real cause: this call only ever supplied 4 values (params slots 0-3), but the real
    -- "Confirm completed floors" menu (text 6161/6164-6166, confirmed via a full-zone dialog.yml
    -- text search) reads ${number:4} and ${number:5} -- two slots this call never populated at
    -- all, so the client always displayed its own uninitialized default (0). Both real floor
    -- lines (6164/6165 "Nyzul Isle Investigation", 6166 "Uncharted Region") use the exact same
    -- real per-character tracker, scripts/globals/nyzul.lua's own "NyzulFloorProgress" charvar.
    -- 2026-09-22: NyzulFloorProgress is now mission-scoped (Nyzul.floorProgressVar) -- Topaz
    -- previously had no separate Investigation-vs-Uncharted-Region floor value so the same number
    -- was supplied for both slots, but now that each mission tracks its own progress separately,
    -- each of the two display lines (6164/6165 Investigation = assault 51, 6166 Uncharted = 52)
    -- gets its own real value instead.
    local floorProgress51 = player:getVar(Nyzul.floorProgressVar(51))
    local floorProgress52 = player:getVar(Nyzul.floorProgressVar(52))
    if (rank > 0) then
        player:startEvent(278, rank, haveimperialIDtag, tokens, player:getCurrentAssault(), floorProgress51, floorProgress52)
    else
        player:startEvent(284) -- no rank
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 278 then
        local selectiontype = bit.band(option, 0xF)
        if selectiontype == 1 then
            -- taken assault mission
            player:addAssault(bit.rshift(option, 4))
            player:delKeyItem(IMPERIAL_ARMY_ID_TAG)
            player:addKeyItem(NYZUL_ISLE_ASSAULT_ORDERS)
            player:messageSpecial(KEYITEM_OBTAINED, NYZUL_ISLE_ASSAULT_ORDERS)
        end
    end
end

