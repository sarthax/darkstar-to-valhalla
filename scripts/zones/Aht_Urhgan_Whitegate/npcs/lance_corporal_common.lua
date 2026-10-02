-----------------------------------
-- Promotion: Lance Corporal -- shared quest-state helpers
-----------------------------------
-- 2026-08-31, ported from a real LandSandBoat reference implementation (user-provided source,
-- scripts/quests/ahtUrhgan/Promotion_Lance_Corporal.lua). LSB uses its own Quest:new()/quest:setVar
-- framework (persistent per-quest var storage with automatic save/load) which this codebase doesn't
-- have -- translated 1:1 onto plain charVars instead, same convention Naja_Salaheem.lua's own
-- PFC/SP promotion flow already uses (PromotionPFC/PromotionSP/AssaultPromotion). All game LOGIC
-- (bit-packed tube-fill tracking, density/reward-tier math, minigame result decoding) is unchanged
-- from the real LSB source -- only the storage/dispatch API differs.
--
-- charVars used (all real Lua ints, no floats -- safe for this engine's int32 CharVar storage):
--   PromotionLC   -- see common.stage below: 0 not accepted, 1 accepted/not yet given tubes
--                    (START), 2 filling (FIRST_MIX), 3 remixing (REMIX), 4 waiting on the
--                    day-gate (WAIT). Shifted by one from LSB's own 0-indexed stage enum -- see
--                    the real correction noted on common.stage itself.
--   LCProg        -- bit-packed CURRENT tube state during filling/mixing, 2 bits/tube x5 = 10 bits.
--   LCOption      -- bit-packed FINAL submitted tube state, used for the reward-tier calc once in
--                    the WAIT stage.
--   LCSubmitDay   -- VanadielDayOfTheYear() at the moment of turn-in. This codebase's own real,
--                    already-established "wait a Vana'diel day" idiom (same `~= VanadielDayOfTheYear()`
--                    pattern Naja_Salaheem.lua already uses for TOAUM11_STARTDAY/TOAUM18_STARTDAY/
--                    TOAUM33_STARTDAY) -- LSB's own VanadielUniqueDay() has no real equivalent
--                    binding in this engine (only VanadielDayOfTheYear/VanadielTime exist).
-----------------------------------
require("scripts/globals/keyitems")
-----------------------------------
local common = {}

-- 2026-08-31 CORRECTED: LSB keeps quest ACCEPTANCE (its own questStatus enum) and this same-named
-- `stage` value as two SEPARATE tracked fields -- Stage only means anything once the quest is
-- already accepted. Folded both into this one charVar cleanly by adding an explicit NOT_ACCEPTED
-- state and shifting LSB's START(0)/FIRST_MIX(1)/REMIX(2)/WAIT(3) up by one, rather than
-- overloading FIRST_MIX==0 to also mean "never accepted" (an earlier draft of this file did this
-- and it was a real bug -- couldn't distinguish "just accepted, no tubes yet" from "not on this
-- quest at all").
common.stage =
{
    NOT_ACCEPTED = 0,
    START        = 1, -- accepted via Abquhbah (event 5030), hasn't gotten tubes from Nafiwaa yet
    FIRST_MIX    = 2,
    REMIX        = 3,
    WAIT         = 4,
}

common.tube = { ONE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5 }

common.fillLevel =
{
    FULL            = 0,
    ONE_THIRD_USED  = 1,
    TWO_THIRDS_USED = 2,
    EMPTY           = 3,
}

common.tubeKeyItems =
{
    [1] = { filledTube = TEST_TUBE_1, emptyTube = EMPTY_TEST_TUBE_1 },
    [2] = { filledTube = TEST_TUBE_2, emptyTube = EMPTY_TEST_TUBE_2 },
    [3] = { filledTube = TEST_TUBE_3, emptyTube = EMPTY_TEST_TUBE_3 },
    [4] = { filledTube = TEST_TUBE_4, emptyTube = EMPTY_TEST_TUBE_4 },
    [5] = { filledTube = TEST_TUBE_5, emptyTube = EMPTY_TEST_TUBE_5 },
}

-- Real LSB densities (from the wellspring hint text, "...appears to be very light" etc) and the
-- real quality->reward-tier bands. Unchanged from the LSB source.
local DENSITIES = { [1] = 0.5, [2] = 1.5, [3] = 2.0, [4] = 1.5, [5] = 1.0 }

local function getFluidLevel(packed, tubeNum)
    return bit.band(bit.rshift(packed, (tubeNum - 1) * 2), 0x3)
end
common.getFluidLevel = getFluidLevel

local function setFluidLevelBits(packed, tubeNum, value)
    local shift = (tubeNum - 1) * 2
    local cleared = bit.band(packed, bit.bnot(bit.lshift(0x3, shift)))
    return bit.bor(cleared, bit.lshift(bit.band(value, 0x3), shift))
end

function common.getFilledTubeCount(player)
    local count = 0
    for _, keyItems in pairs(common.tubeKeyItems) do
        if player:hasKeyItem(keyItems.filledTube) then
            count = count + 1
        end
    end
    return count
end

-- 2026-08-31 real bug found: player-confirmed via the real capture video, the wellspring fill only
-- ever shows ONE message ("Obtained key item: Test tube #N") -- our server was also showing a
-- "Lost key item: Empty test tube #N" first. Root cause: neither addKeyItem nor delKeyItem sends
-- any text message server-side (checked both bindings directly, lua_baseentity.cpp:6297/6336) --
-- BOTH "Obtained"/"Lost key item" lines are purely client-generated, from the client diffing the
-- raw key-item bitmask packet it receives. Calling delKeyItem then addKeyItem as two separate calls
-- sends two separate packets, so the client sees the empty tube's bit clear as its own standalone
-- event and announces a loss the real server apparently never triggers (likely a single combined
-- packet in the real implementation, which this codebase has no Lua binding for). Fix: stop
-- deleting the empty tube key item at all -- keep it (harmless, matches the observed single-message
-- real behavior) and track "has this tube ever been collected" independently via a new bitmask
-- charvar (LCTubesFilled) instead of key-item possession, so canFillTube's gating still works
-- correctly without depending on a delete that shouldn't happen.
local function isTubeEverFilled(player, tubeNum)
    return bit.band(player:getVar("LCTubesFilled"), bit.lshift(1, tubeNum - 1)) ~= 0
end

-- A tube can be filled if it's never been collected before, or (during REMIX) if its packed fluid
-- level isn't already FULL (0) -- same real gating LSB's own canFillTube expresses, just keyed off
-- LCTubesFilled instead of empty-tube key-item possession (see this file's own note above).
function common.canFillTube(player, tubeNum)
    if not isTubeEverFilled(player, tubeNum) then
        return true
    end
    return player:getVar("PromotionLC") == common.stage.REMIX
        and getFluidLevel(player:getVar("LCProg"), tubeNum) ~= common.fillLevel.FULL
end

-- Fills one tube at a wellspring: clears its 2-bit "used" field (fresh sample = FULL/unused),
-- grants the filled-tube key item (real empty tube is intentionally kept, not deleted -- see this
-- file's own note above), and messages the player. Text ids (KEYITEM_OBTAINED/WELLSPRING) are now
-- ambient bare globals from the calling zone's own required TextIDs.lua (old-dsp-reference
-- convention -- see TextIDs.lua's own header) -- no longer passed in explicitly, since a flat
-- id-file has no module table to pass.
function common.fillTestTube(player, tubeNum)
    player:setVar("LCProg", setFluidLevelBits(player:getVar("LCProg"), tubeNum, common.fillLevel.FULL))

    local alreadyFilled = isTubeEverFilled(player, tubeNum)
    if not alreadyFilled then
        player:setVar("LCTubesFilled", bit.bor(player:getVar("LCTubesFilled"), bit.lshift(1, tubeNum - 1)))
    end
    if not player:hasKeyItem(common.tubeKeyItems[tubeNum].filledTube) then
        player:addKeyItem(common.tubeKeyItems[tubeNum].filledTube)
    end

    if not alreadyFilled then
        player:messageSpecial(KEYITEM_OBTAINED, common.tubeKeyItems[tubeNum].filledTube)
    else
        player:messageSpecial(WELLSPRING + 1)
    end
end

-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- Real item ids -- this codebase has no tpz.item.* name enum (unlike tpz.ki for key items), items
-- are referenced by their raw sql/item_basic.sql id directly, same convention
-- Naja_Salaheem.lua already uses (player:addItem(2187) for Westerly Winds). Confirmed:
-- 2186 = imperial_mythril_piece, 2187 = imperial_gold_piece.
local IMPERIAL_MYTHRIL_PIECE = 2186
local IMPERIAL_GOLD_PIECE    = 2187

-- Real LSB reward-quality calc: sum(usedThirds[tube] * density[tube]) across all 5 tubes, banded
-- into a reward tier. Only the top two bands (Platinum/Luminium) actually grant a bonus item in the
-- real source -- everything below that is real, but reward-less (matches LSB exactly, not a gap).
function common.getQuestReward(player)
    local quality = 0
    for tubeNum = 1, 5 do
        quality = quality + (getFluidLevel(player:getVar("LCOption"), tubeNum) * DENSITIES[tubeNum])
    end

    if quality == 10 then
        return { item = IMPERIAL_GOLD_PIECE, amount = 2 }
    elseif quality >= 6 and quality <= 9.5 then
        if math.random(0, 1) == 0 then
            return { item = IMPERIAL_MYTHRIL_PIECE, amount = math.random(3, 4) }
        else
            return { item = IMPERIAL_GOLD_PIECE, amount = 1 }
        end
    end
    return nil
end

return common
