-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Nafiwaa
-----------------------------------
-- 2026-08-31, real "Promotion: Lance Corporal" mechanic -- see npcs/lance_corporal_common.lua for
-- the full charVar/porting writeup. Real events (5035/5036/5037/5038/5039) confirmed present on
-- this exact entity (16982133) via this zone's own client-compiled event table
-- (mission_toolkit.py). Nafiwaa hands out the 5 empty test tubes, runs the real mixing minigame
-- (event 5038), and re-states the wait-gate once the mixture's been turned in (5039).
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/npc_util")
local questCommon = require("scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common")
-----------------------------------
function onTrade(player, npc, trade)
end

-- 2026-08-31, real capture-confirmed (Promotion Lance Corporal Pt.1, Rabadaba): the entire per-pour
-- "which sample do you want to look at/pour" mixing UI, the 6-thirds beaker fill, and the "what
-- should we do?" keep-or-discard prompt are ALL simulated client-side within one continuous
-- cutscene -- the server only ever sees ONE 0x05B round-trip per full 6-third checkpoint, not one
-- per pour. Real raw packet bytes (packetviewer, cross-checked against
-- src/map/packet_system.cpp:2914's `data.ref<uint32>(0x08)`, confirmed that's exactly what reaches
-- Lua as `option`) prove the combined 32-bit decode (low16=tube state, high16 result flag, top 2
-- bits of that 2=accept/1=discard) is correct -- e.g. a real discard packet was raw 0x40000216
-- (option 534, flag 0x4000->result 1), a real accept was raw 0x8000_03F9 (option 1017, flag
-- 0x8000->result 2). Extracted into a helper since both onTrigger (first approach) and the
-- discard-auto-continue path (onEventFinish below) need to build the same event.
-- Real observed threshold (Pt.1 capture): reaching all-5-tubes-EMPTY (packed value 1023, sum of
-- fillLevel fields = 15) with no full beaker is exactly what fell through to event 5036 rather than
-- continuing -- so "enough liquid" just means "not all 5 tubes are EMPTY yet".
local function hasEnoughLiquid(tubeContents)
    for tubeNum = 1, 5 do
        if questCommon.getFluidLevel(tubeContents, tubeNum) ~= questCommon.fillLevel.EMPTY then
            return true
        end
    end
    return false
end

local function fireMixingRound(player, tubeContents, isRemix)
    local emptyTubes = 0
    for tubeNum, keyItems in pairs(questCommon.tubeKeyItems) do
        if player:hasKeyItem(keyItems.emptyTube) then
            emptyTubes = bit.bor(emptyTubes, bit.lshift(1, tubeNum - 1))
        end
    end
    player:startEvent(5038, 0, tubeContents, 0, 0, emptyTubes, 0, isRemix and 1 or 0, 0, 0)
end

function onTrigger(player, npc)
    local stage = player:getVar("PromotionLC")

    if stage == questCommon.stage.WAIT then
        -- 2026-08-31 CORRECTED: real completion event 5031 is owned by ABQUHBAH's own
        -- client-compiled event table, not Nafiwaa's (confirmed via this zone's own
        -- mission_toolkit.py disassembly -- Nafiwaa's real table only has 5030/5035-5039, no
        -- 5031) -- see Abquhbah.lua for the actual completion trigger. Talking to Nafiwaa during
        -- WAIT is always just the real restate line (5039), matching LSB's own per-NPC ownership.
        -- 2026-08-31 real fix: padded to the full 10-argument signature every confirmed-working
        -- call in this codebase uses (see Abquhbah.lua's own note) -- these were bare
        -- startEvent(csid) calls, matching the exact pattern that froze the client for 5030.
        player:startEvent(5039, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return
    end

    if stage == questCommon.stage.NOT_ACCEPTED then
        -- Not on this quest at all -- real generic placeholder, same idle-NPC convention this file
        -- used before this quest was built.
        player:startEvent(661)
        return
    end

    if stage == questCommon.stage.START then
        -- Just accepted via Abquhbah (event 5030), hasn't gotten the 5 empty tubes yet.
        player:startEvent(5035, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return
    end

    local tubeContents = player:getVar("LCProg")
    local isRemix = stage == questCommon.stage.REMIX

    if stage == questCommon.stage.FIRST_MIX then
        local filledTubeCount = questCommon.getFilledTubeCount(player)
        if filledTubeCount == 0 then
            player:startEvent(5036, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            return
        elseif filledTubeCount < 5 then -- must gather all 5 tubes on the first mix
            player:startEvent(5037, filledTubeCount, 0, 0, 0, 0, 0, 0, 0, 0)
            return
        end
    elseif isRemix and not hasEnoughLiquid(tubeContents) then
        player:startEvent(5036, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return
    end

    fireMixingRound(player, tubeContents, isRemix)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 5035 then
        player:setVar("PromotionLC", questCommon.stage.FIRST_MIX)
        npcUtil.giveKeyItem(player, { EMPTY_TEST_TUBE_1, EMPTY_TEST_TUBE_2,
            EMPTY_TEST_TUBE_3, EMPTY_TEST_TUBE_4, EMPTY_TEST_TUBE_5 })
    elseif csid == 5038 then
        -- 2026-08-31, decode verified against REAL raw packet bytes (Promotion Lance Corporal
        -- Pt.1 capture, Rabadaba), not just ported from LSB blind: src/map/packet_system.cpp:2914's
        -- `data.ref<uint32>(0x08)` is confirmed to be exactly what reaches Lua as `option` for a
        -- 0x05B packet -- a real discard round's raw bytes were 0x40000216 (low16=534 tube state,
        -- high16=0x4000), a real accept was 0x8000_03F9 (low16=1017, high16=0x8000). CapLog's own
        -- "Option: 534"/"Option: 1017" display only shows the low 16 bits, which is what caused an
        -- earlier false alarm this session (thought the decode was wrong when it was really just
        -- CapLog's simplified display truncating the high bits). Confirmed: low 16 bits = tube
        -- state (same 2-bit-per-tube packing as LCProg), top 2 bits of the high 16 = 2 accept / 1
        -- discard.
        local remainingTubeContents = bit.band(option, 0xFFFF)
        local mask = bit.rshift(option, 16)
        local result = bit.rshift(mask, 14)

        if result == 2 then -- accept the results, turn in to the guild
            local startingContents = player:getVar("LCProg")
            player:setVar("PromotionLC", questCommon.stage.WAIT)
            player:setVar("LCSubmitDay", VanadielDayOfTheYear())
            player:setVar("LCOption", remainingTubeContents - startingContents)

            for keyItem = EMPTY_TEST_TUBE_1, TEST_TUBE_5 do
                if player:hasKeyItem(keyItem) then
                    player:delKeyItem(keyItem)
                end
            end
        elseif result == 1 then -- threw it out, remix
            player:setVar("PromotionLC", questCommon.stage.REMIX)
            player:setVar("LCProg", remainingTubeContents)

            for tubeNum, keyItems in pairs(questCommon.tubeKeyItems) do
                if questCommon.getFluidLevel(remainingTubeContents, tubeNum) == questCommon.fillLevel.EMPTY
                    and player:hasKeyItem(keyItems.filledTube) then
                    player:delKeyItem(keyItems.filledTube)
                    player:addKeyItem(keyItems.emptyTube)
                end
            end

            -- 2026-08-31 real capture-confirmed (Pt.1): after "Oh well, back to square one." the
            -- client immediately re-requests a fresh mixing round with NO new player action -- the
            -- whole "Hello Rabadaba..." greeting replays on its own a few seconds later. Only falls
            -- to 5036 if that was the last of the liquid.
            if hasEnoughLiquid(remainingTubeContents) then
                fireMixingRound(player, remainingTubeContents, true)
            else
                player:startEvent(5036, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            end
        end
    end
end

