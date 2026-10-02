-----------------------------------
-- Area: Ilrusi Atoll
--  NPC: Ancient Lockbox
-----------------------------------
-- 2026-08-18: this was a completely empty stub (onTrigger did nothing) -- user-reported bug
-- DSP-PORT-TODO: tpz\.assault\.chestTrigger -- see data/dsp_namespace_map.json
-- ("Ancient Lockbox cannot be used"). Rebuilt using the shared tpz.assault.chestTrigger pattern
-- already used in Lebros Cavern/Mamool Ja Training Grounds/Periqia, seeded with mission 42's
-- real capture-confirmed contents. Missions 41 (Golden Salvage) and 43 have no reward data yet
-- DSP-PORT-TODO: tpz\.assault\.chestTrigger -- see data/dsp_namespace_map.json
-- -- tpz.assault.chestTrigger treats a missing instanceID key as "no items", so they correctly
-- fall through to XP/gil only until real data is found for them.
-- 2026-08-18 (later): added 45 (Searat Salvation) real capture data -- box item 2286 (???_box),
-- opened to hi-potion +2.
-- 2026-08-19, user-provided: Golden Salvage (mission 41) real reward data -- previously fully
-- missing (flagged in the missing-rewards audit). 2 qItems, no odds given, equal-weight pool same
-- as other unconfirmed-split missions added this session.
-----------------------------------
require("scripts/globals/assault_lockbox")
-----------------------------------
local Q_ITEMS =
{
    [41] = { { { 500, 2277 }, { 500, 2286 } } }, -- Golden Salvage: ???_earring / ???_box (user-provided, 2026-08-19)
    [42] = { { { 1000, 2196 } } }, -- Lamia No.13: ???_footwear
    [43] = { { { 1000, 2286 } } }, -- Extermination: ???_box
    [44] = { { { 1000, 2286 } } }, -- Demolition Duty: ???_box
    [45] = { { { 1000, 2286 } } }, -- Searat Salvation: ???_box (real capture, 2026-08-18)
    [48] = { { { 1000, 2278 } } }, -- Deserter: ???_ring
    [49] = { { { 1000, 2277 } } }, -- Desperately Seeking Cephalopods: ???_earring
    [50] = { { { 1000, 2276 } } }, -- Bellerophon's Bliss: ???_headpiece
    [46] = { { { 1000, 2193 } } }, -- Apkallu Seizure: ???_axe (real capture, 2026-08-18)
    [47] = { { { 1000, 2195 } } }, -- Lost and Found: ???_gloves (real capture, 2026-08-18)
}

local REG_ITEMS =
{
    [41] = -- Golden Salvage (user-provided, 2026-08-19)
    {
        { { 1000, 4118 } },  -- hi-potion_+2
        { { 1000, 13688 } }, -- hi-potion_tank
        { { 1000, 4172 } },  -- reraiser
    },
    [42] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [43] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13689 } }, -- hi-ether_tank
    },
    [44] =
    {
        { { 1000, 4155 } }, -- remedy
    },
    [45] =
    {
        { { 1000, 4118 } }, -- hi-potion_+2 (real capture, 2026-08-18)
    },
    [48] =
    {
        { { 1000, 4119 } }, -- hi-potion_+3
    },
    [49] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [50] =
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [46] = -- Apkallu Seizure (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 4173 } },  -- hi-reraiser
    },
    [47] = -- Lost and Found (real capture, 2026-08-18)
    {
        { { 1000, 4118 } },  -- hi-potion_+2
        { { 1000, 13688 } }, -- hi-potion_tank
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

function onEventFinish(player, csid, option)
end

