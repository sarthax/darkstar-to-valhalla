-----------------------------------
-- Area: Mamool Ja Training Grounds
--  NPC: Ancient Lockbox
-----------------------------------
-- Real reward tables ported from LandSandBoat's Mamool_Ja_Training_Grounds/npcs/Ancient_Lockbox.lua
-- (user-provided reference), translated to this codebase's numeric item IDs and instance IDs
-- (sql/instance_list.sql: 11=imperial_agent_rescue, 12=preemptive_strike -- this zone's one
-- physical lockbox is shared by both, repositioned per-instance).
-- Roll/give logic lives in scripts/globals/assault_lockbox.lua (shared across zones).
-- XP/gil are the flat 1000/1000 placeholder carried over from Leujaoam_Sanctum's reference
-- build -- not confirmed for this zone specifically, see that file's comments for why.
-- 2026-08-18: this lockbox is now also shared by Sagelord Elimination (instance 13), which has no
-- DSP-PORT-TODO: tpz\.assault\.chestTrigger -- see data/dsp_namespace_map.json
-- confirmed reward data. No entry needed for it in Q_ITEMS/REG_ITEMS -- tpz.assault.chestTrigger
-- treats a missing instanceID key as "no items", so it correctly falls through to XP/gil only.
-- 2026-08-18 (later): The Double Agent (instance 15) real capture -- box item 2286 (???_box,
-- same item confirmed for mission 11), opened to a hi-potion +3 (item 4119, same as Sagelord
-- Elimination's confirmed reward). Only one drop of each type was observed in this capture, so
-- both are listed at 100% weight like Sagelord's single-confirmed-item entries.
-- 2026-08-18 (later still): Imperial Treasure Retrieval (instance 16) real capture -- box item
-- 2279 (???_cape), opened to 2x remedy (item 4155) + 1x hi-potion +3 (item 4119) in a single
-- pull -- REG_ITEMS entries aren't mutually exclusive rolls in this shared trigger (see
-- assault_lockbox.lua), so both are listed and can drop together same as observed.
-- 2026-08-18 (even later): Blitzkrieg (instance 17) real capture -- box item 2190 (???_sword,
-- same item confirmed for Sagelord Elimination), opened to hi-potion +3 (4119) + hi-ether tank
-- (13689).
-- 2026-08-18 (even later still): Marids in the Mist (instance 18) real capture -- box item 2286
-- (???_box, same item confirmed for missions 11/15), opened to hi-potion +3 (4119) + hi-potion
-- tank (13688).
-- 2026-08-18 (even later still): The Susanoo Shuffle (instance 20) real capture -- box item 2196
-- (???_footwear), opened to hi-potion +3 (4119).
-- 2026-08-18 (last one): Preemptive Strike (instance 12) real capture -- confirmed the existing
-- LSB-ported ???_box draw and showed a hi-potion +2 (item 4118) drop not in the existing
-- REG_ITEMS[12] pools -- added as a new pool rather than replacing the LSB-sourced entries.
-----------------------------------
require("scripts/globals/assault_lockbox")
-----------------------------------
local Q_ITEMS =
{
    [11] = { { { 300, 2286 }, { 700, 2278 } } }, -- Imperial Agent Rescue: ???_box / ???_ring
    [12] = { { { 300, 2286 }, { 700, 2282 } } }, -- Preemptive Strike:     ???_box / ???_necklace
    [13] = { { { 1000, 2190 } } },                -- Sagelord Elimination: ???_sword
    -- 2026-08-19, user-provided: Breaking Morale's real ??? item pool -- 3 items, no odds given,
    -- equal-weight pool same as other unconfirmed-split missions in this file (e.g. mission 11's
    -- 300/700 split IS confirmed real; this one isn't, so ~333 each rather than assuming an equal
    -- split is itself confirmed).
    [14] = { { { 334, 2192 }, { 333, 2190 }, { 333, 2286 } } }, -- Breaking Morale: ???_polearm / ???_sword / ???_box
    [15] = { { { 1000, 2286 } } },                -- The Double Agent:     ???_box
    [16] = { { { 1000, 2279 } } },                -- Imperial Treasure Retrieval: ???_cape
    [17] = { { { 1000, 2190 } } },                -- Blitzkrieg:                  ???_sword
    [18] = { { { 1000, 2286 } } },                -- Marids in the Mist:          ???_box
    [20] = { { { 1000, 2196 } } },                -- The Susanoo Shuffle:         ???_footwear
    -- 2026-08-19, user-provided: Azure Ailments' real ??? item pool -- 3 items, no odds given,
    -- equal-weight pool same reasoning as mission 14 above.
    [19] = { { { 334, 2286 }, { 333, 2277 }, { 333, 2280 } } }, -- Azure Ailments: ???_box / ???_earring / ???_sash
}

local REG_ITEMS =
{
    [11] =
    {
        { { 900, 4118 },  { 100, 0 } },
        { { 100, 13688 }, { 900, 0 } },
        { { 530, 4172 },  { 470, 0 } },
    },
    [12] =
    {
        { { 100, 13688 }, { 900, 0 } },
        { { 300, 4172 },  { 700, 0 } },
        { { 500, 4173 },  { 500, 0 } },
        { { 1000, 4118 } }, -- hi-potion_+2 (real capture, 2026-08-18)
    },
    [14] = -- Breaking Morale (user-provided, 2026-08-19)
    {
        { { 1000, 4118 } },  -- hi-potion_+2
        { { 1000, 13688 } }, -- hi-potion_tank
        { { 1000, 4172 } },  -- reraiser
    },
    [19] = -- Azure Ailments (user-provided, 2026-08-19)
    {
        { { 1000, 13689 } }, -- hi-ether_tank
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 4173 } },  -- hi-reraiser
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [13] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [15] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3 (real capture, 2026-08-18)
    },
    [16] =
    {
        { { 1000, 4155 } },  -- remedy (real capture, 2026-08-18 -- dropped twice, see 2nd entry)
        { { 1000, 4155 } },  -- remedy, 2nd independent pool (both hit in the one capture seen)
        { { 1000, 4119 } },  -- hi-potion_+3
    },
    [17] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3 (real capture, 2026-08-18)
        { { 1000, 13689 } }, -- hi-ether_tank
    },
    [18] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3 (real capture, 2026-08-18)
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [20] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3 (real capture, 2026-08-18)
    },
}

local XP_REWARD  = 1000
local GIL_REWARD = 1000

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local instanceID = npc:getInstance():getID()
    AssaultLockbox.chestTrigger(player, npc, Q_ITEMS[instanceID], REG_ITEMS[instanceID], XP_REWARD, GIL_REWARD)
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-23: removed an empty onEventFinish stub -- part of the systemic
-- instance-timeout black-screen fix (see documentation/Assault_Fix_Log.md, the
-- 2026-08-18 'SYSTEMIC' entry, and Nyzul_Isle/npcs/Rune_of_Transfer.lua's own header
-- comment). An empty-but-defined onEventFinish here permanently pins
-- PChar->m_event.Script to this file whenever it's the last NPC a player clicked
-- (the custom EVENTFIX patch preserves that pin across resets), so LoadEventScript
-- never falls through to Zone.lua's real csid==102 handler on instance
-- timeout/mission-failed -- the eject cutscene plays, the client acks it, and the
-- player is never actually removed from the failed instance: stuck at a black
-- screen forever. Deleting the stub (this file has no real per-csid logic to keep)
-- lets dispatch reach the working fallback.

