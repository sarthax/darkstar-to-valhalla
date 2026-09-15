-----------------------------------
-- Area: Leujaoam Sanctum
--  NPC: Ancient Lockbox
-----------------------------------
-- 2026-08-18: this lockbox is shared by every mission in this zone (Leujaoam Cleansing,
-- Orichalcum Survey, and now Escort Professor Chanoix), but DIRECT_ITEMS/TREASURE_POOL_ITEMS
-- below were hardcoded to always apply regardless of which instance was actually running --
-- meaning Orichalcum Survey (and now Chanoix) players were silently getting Leujaoam Cleansing's
-- ??? Ring/??? Box rewards this whole time. Found and fixed while wiring up Chanoix's own
-- DSP-PORT-TODO: tpz\.assault\.chestTrigger -- see data/dsp_namespace_map.json
-- lockbox usage. Rather than migrating this whole file to the shared tpz.assault.chestTrigger
-- pattern used in Lebros/Mamool Ja/Periqia (which would drop the getRecommendedAssaultLevel gate
-- below -- real, already-validated behavior for mission 1), this just guards the existing logic
-- behind an instance-ID check. Missions 2 and 3 still have no confirmed reward data, so they
-- correctly fall through to "no items, XP/gil only" rather than getting mission 1's rewards.
-----------------------------------
require("scripts/globals/npc_util")
require("scripts/globals/besieged")  -- for getRecommendedAssaultLevel
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
require("scripts/globals/status")    -- for tpz.status
local ID = Leujaoam
-----------------------------------
-- This assault's ID within instance_list / assaultLevels (Leujaoam Cleansing = 1)
local ASSAULT_ID = 1

-- The "???" unidentified items exclusive to Leujaoam Cleansing, given directly to whoever opens
-- the lockbox (not the treasure pool). Only applies when ASSAULT_ID matches the running instance.
local DIRECT_ITEMS =
{
    2278, -- ??? Ring
    2286, -- ??? Box
}

-- Remaining Leujaoam Cleansing treasure that goes into the party's shared Treasure Pool. Only
-- applies when ASSAULT_ID matches the running instance.
local TREASURE_POOL_ITEMS =
{
    4155, -- Remedy
    4119, -- Hi-potion +3
}

-- 2026-08-18: real capture data for Imperial Code (instance id 8) -- same lockbox, different
-- mission, real contents confirmed by a Thris Nov 2025 capture. Kept as a small per-mission
-- table rather than folding into DIRECT_ITEMS/TREASURE_POOL_ITEMS above (those are guarded to
-- ASSAULT_ID == 1 specifically, same reasoning as the file header's fix).
local OTHER_MISSION_ITEMS =
{
    -- 2026-08-19, user-provided: Orichalcum Survey's real lockbox contents. Correction from an
    -- initial "give all 3" guess -- these 3 "???" items are a random pick (1-in-3 each), not a
    -- batch like mission 1's Ring+Box above. `randomPick = true` picks one from `direct` at open
    -- time instead of giving the whole list.
    [2] = { direct = { 2195, 2282, 2286 }, pool = { 4155, 4119 }, randomPick = true }, -- Orichalcum Survey: 1 of (??? Gloves / ??? Necklace / ??? Box) + remedy + hi-potion_+3
    [3] = { direct = { 2286 }, pool = { 4118, 13688 } }, -- Escort Professor Chanoix: ??? Box + hi-potion_+2 + hi-potion_tank
    [5] = { direct = { 2191 }, pool = { 4118, 13688 } }, -- Counting Sheep: ??? Dagger + hi-potion_+2 + hi-potion_tank (real capture, 2026-08-18)
    [9] = { direct = { 2277 }, pool = { 4119 } },        -- Red versus Blue: ??? Earring + hi-potion_+3 (real capture, 2026-08-18)
    [4] = { direct = { 2280 }, pool = { 4155, 4119 } },   -- Shanarha Grass Conservation: ??? Sash + remedy + hi-potion_+3
    [6] = { direct = { 2286 }, pool = { 4119 } },         -- Supplies Recovery: ??? Box + hi-potion_+3 (real capture, 2026-08-18)
    [7] = { direct = { 2278 }, pool = { 4119 } },         -- Azure Experiments: ??? Ring + hi-potion_+3 (real capture, 2026-08-18)
    [8] = { direct = { 2286 }, pool = { 4119 } },         -- Imperial Code: ??? Box + hi-potion_+3
}

-- Flat reward amounts, applied to every character in the instance.
local XP_REWARD  = 1000
local GIL_REWARD = 1000

-- 2026-08-19, user-provided real mechanics writeup for the Ancient Lockbox system generally (not
-- specific to one mission): a "???" item is NOT guaranteed -- the box rolls against a fixed
-- drop rate, "typically ranging from ~20% to ~50% depending on the specific Assault" (a few
-- missions have a guaranteed base item instead, which isn't modeled here since none of this
-- file's missions are confirmed to be one of those). Every mission in this file previously gave
-- its "???" item at a guaranteed 100% -- real bug, not previously known. Also per the same
-- writeup: the "???" item goes to whoever personally opened the box (already correct here,
-- `npcUtil.giveItem(player, ...)`), and performance modifiers (party size, clear speed, etc.) do
-- NOT affect the lockbox at all, unlike Assault Points -- nothing here should ever scale this
-- roll by party size.
--
-- 2026-08-19 (later): set back to 100 (guaranteed) at the user's request for easier live
-- testing while other Orichalcum Survey mechanics are still being verified. **The real value
-- should be 50** -- change this back to 50 once testing no longer needs guaranteed drops.
local QITEM_DROP_CHANCE_PCT = 100

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    -- Guard against repeat opens - same localvar pattern used by
    -- DSP-PORT-TODO: tpz\.battlefield\.HandleLootRolls -- see data/dsp_namespace_map.json
    -- tpz.battlefield.HandleLootRolls for BCNM Armoury Crates.
    if npc:getLocalVar("opened") == 1 then
        return
    end
    npc:setLocalVar("opened", 1)

    -- 2026-08-27 CORRECTION: this file's earlier note assumed the box stays visible forever
    -- with no disappear, based on a guess (no real capture cited) that `setAnimation(90)`
    -- (borrowed from the unrelated BCNM Armoury Crate reference) was the right animation and
    -- that an earlier disappear call had simply cut its sparkle effect short. Checked a real
    -- Thris Nov2025 capture for this same prop type (Mamool Ja Training Grounds, Imperial Agent
    -- Rescue -- same shared Ancient Lockbox mechanism, see scripts/globals/assault_lockbox.lua's
    -- matching fix) directly: the real open event is a `CEntityAnimationPacket` with
    -- FourCCString "open" (a one-shot canned clip, same mechanism as this zone's own
    -- Rune_of_Release "deru" reveal) -- NOT setAnimation(), which just flips a persisted pose/
    -- state field and never plays whatever VFX is baked into the real clip. The same capture
    -- also confirms the box genuinely DOES disappear, via FourCCString "kesu", ~15s after
    -- opening -- contradicting the "stays visible forever" assumption. 15s is ample time for any
    -- reasonable sparkle animation to finish, so the earlier "cut short" symptom was very likely
    -- this same setAnimation(90)-isn't-a-real-clip bug, not a genuinely-too-early disappear.
    npc:entityAnimationPacket("open")
    npc:timer(15000, function(n)
        n:entityAnimationPacket("kesu")
        n:setStatus(STATUS_DISAPPEAR)
    end)

    -- Only Leujaoam Cleansing (ASSAULT_ID) has confirmed reward data -- see the file header for
    -- why this guard exists. Orichalcum Survey/Escort Professor Chanoix correctly get no items
    -- here (still get XP/gil below) until real data is found for them.
    if npc:getInstance():getID() == ASSAULT_ID then
        -- The "???" items are exclusive to whoever opens the lockbox, and only
        -- if the assault was completed at or above the recommended level.
        -- Batched into a single giveItem call - npcUtil.giveItem checks free
        -- slot count once for the whole batch and adds items sequentially,
        -- which avoids the same-tick inventory slot collision that hit when
        -- these were given via separate individual calls.
        local recommendedLevel = getRecommendedAssaultLevel(ASSAULT_ID)
        if player:getMainLvl() >= recommendedLevel and math.random(100) <= QITEM_DROP_CHANCE_PCT then
            npcUtil.giveItem(player, DIRECT_ITEMS)
        end

        -- Everything else goes into the shared party Treasure Pool. addTreasure
        -- has no batch form, and calling it back-to-back in the same tick hit
        -- the same slot-collision issue as above - staggering each call by a
        -- short delay works around it.
        local playerId = player:getID()
        for i, itemID in ipairs(TREASURE_POOL_ITEMS) do
            if itemID ~= 0 then
                -- 2026-09-14, crash-reported (assert: addTreasure's self-entity was not TYPE_PC),
                -- via a queued AI action on the Escort Professor Chanoix route: this timer is
                -- scheduled on npc, so the engine only refreshes `n` (the npc) -- the outer-scope
                -- `player` capture is never re-validated and can point at freed/reused memory by
                -- the time the callback fires. Same stale-capture bug class as Mulwahah.lua --
                -- re-resolve the player by id instead of trusting the captured reference.
                npc:timer(i * 250, function(n)
                    local livePlayer = GetPlayerByID(playerId)
                    if livePlayer and n then
                        livePlayer:addTreasure(itemID, n)
                    end
                end)
            end
        end
    elseif OTHER_MISSION_ITEMS[npc:getInstance():getID()] then
        local reward = OTHER_MISSION_ITEMS[npc:getInstance():getID()]
        -- 2026-08-19: this branch never had the level-gate check the ASSAULT_ID==1 branch above
        -- always had -- real gap, not previously known, per the same user-provided mechanics
        -- writeup ("must complete at or above the mission's Recommended Level to be eligible for
        -- a ??? drop").
        local recommendedLevel = getRecommendedAssaultLevel(npc:getInstance():getID())
        if player:getMainLvl() >= recommendedLevel and math.random(100) <= QITEM_DROP_CHANCE_PCT then
            if reward.randomPick then
                npcUtil.giveItem(player, reward.direct[math.random(#reward.direct)])
            else
                npcUtil.giveItem(player, reward.direct)
            end
        end
        local playerId = player:getID()
        for i, itemID in ipairs(reward.pool) do
            -- 2026-09-14, same stale-capture fix as the ASSAULT_ID==1 branch above -- re-resolve
            -- player by id instead of trusting the outer-scope capture.
            npc:timer(i * 250, function(n)
                local livePlayer = GetPlayerByID(playerId)
                if livePlayer and n then
                    livePlayer:addTreasure(itemID, n)
                end
            end)
        end
    end

    -- XP/gil reward for the whole party in the instance, not just the opener.
    local instance = npc:getInstance()
    if instance then
        local chars = instance:getChars()
        for _, char in pairs(chars) do
            char:addExp(XP_REWARD)
            char:addGil(GIL_REWARD)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

