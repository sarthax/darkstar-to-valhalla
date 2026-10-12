-----------------------------------
-- Area: Lebros Cavern
--  NPC: Ancient Lockbox
-----------------------------------
-- Real reward tables ported from LandSandBoat's Lebros_Cavern/npcs/Ancient_Lockbox.lua
-- (user-provided reference), translated from LSB's xi.assault.mission.*/xi.item.* enums to
-- this codebase's numeric item IDs (see sql/item_basic.sql) and instance IDs (see
-- sql/instance_list.sql: 21=excavation_duty, 22=lebros_supplies, 23=troll_fugitives -- this
-- zone's one physical lockbox is shared by all three, repositioned per-instance).
-- Roll/give logic itself now lives in scripts/globals/assault_lockbox.lua so it isn't
-- duplicated across every zone that shares a lockbox between missions.
-- XP/gil are still the flat 1000/1000 placeholder carried over from Leujaoam_Sanctum's
-- reference build -- LSB's sample doesn't expose those values (they're inside
-- xi.appraisal.assaultChestTrigger, which we don't have source for), so they remain
-- unconfirmed for this zone specifically.
-- 2026-08-18: this table only ever had entries for 21/22/23 -- missions 24 (Evade and Escape)
-- and 29 (Operation: Black Pearl) share this same physical lockbox (their own instance scripts
-- already reference ID.npc.ANCIENT_LOCKBOX) but had no reward table at all, so `chestTrigger`
-- was silently giving nothing but the flat XP/gil. Real capture data (Thris Nov 2025 set) gave
-- exact contents for both -- added below. Each pool is modeled as guaranteed (single capture,
-- no way to know real drop odds, flagged same as everywhere else this session).
-- 2026-08-18 (later): added 28 (Egg Conservation) from the same capture set. 30 (Better Than
-- One) is still missing -- no capture mined for it yet.
-- 2026-08-18 (later still): a real capture for 22 (Lebros Supplies) confirmed the pre-existing
-- LSB-ported ???_cape box draw (already in Q_ITEMS[22]) and showed a hi-potion +2 (item 4118)
-- drop not in the existing REG_ITEMS[22] pools -- added as a new pool rather than replacing the
-- LSB-sourced entries, since one capture doesn't disprove them.
-- 2026-08-18 (even later still): added 25 (Siegemaster Assassination) real capture data -- box
-- item 2286 (???_box), opened to hi-potion +3 + hi-potion tank.
-- 2026-08-18 (last one): added 30 (Better Than One) real capture data -- box item 2286
-- (???_box), opened to hi-potion +3 + hi-potion tank.
-- 2026-08-18 (actually last one): a real capture for 23 (Troll Fugitives) validated the existing
-- LSB-ported reward tables -- drew ???_headpiece (item 2276, already in Q_ITEMS[23]) and
-- hi-potion +3 (already in REG_ITEMS[23]), no changes needed.
-- 2026-08-18 (truly last one): added 27 (Wamoura Farm Raid) real capture data -- box item 2192
-- (???_polearm, same item already known from Troll Fugitives), opened to hi-potion +3. This
-- mission's lockbox had no reward entry at all before (silently gave XP/gil only). All missions
-- in this zone with a findable Thris-set capture are now mined.
-----------------------------------
require("scripts/globals/assault_lockbox")
-----------------------------------
-- instance_list id -> qItem pools ("???" items, one drawn per pool, given directly to opener)
local Q_ITEMS =
{
    [21] = { { { 300, 2286 }, { 700, 2277 } } },                                     -- Excavation Duty:  ???_box / ???_earring
    [22] = { { { 300, 2286 }, { 700, 2279 } } },                                     -- Lebros Supplies:  ???_box / ???_cape
    [23] = { { { 300, 2193 }, { 200, 2192 }, { 100, 2276 }, { 400, 2286 } } },        -- Troll Fugitives:  ???_axe / ???_polearm / ???_headpiece / ???_box
    [24] = { { { 1000, 2286 } } },                                                    -- Evade and Escape: ???_box (real capture, 2026-08-18)
    [25] = { { { 1000, 2286 } } },                                                    -- Siegemaster Assassination: ???_box (real capture, 2026-08-18)
    [26] = { { { 334, 2277 }, { 333, 2280 }, { 333, 2286 } } },                        -- Apkallu Breeding: ???_earring / ???_sash / ???_box
    [27] = { { { 1000, 2192 } } },                                                    -- Wamoura Farm Raid: ???_polearm (real capture, 2026-08-18)	
    [28] = { { { 1000, 2278 } } },                                                    -- Egg Conservation: ???_ring (real capture, 2026-08-18)
    [29] = { { { 1000, 2277 } } },                                                    -- Operation: Black Pearl: ???_earring (real capture, 2026-08-18)
    [30] = { { { 1000, 2286 } } },                                                    -- Better Than One: ???_box (real capture, 2026-08-18)

}

-- instance_list id -> regItem pools (regular items, staggered into the party Treasure Pool)
local REG_ITEMS =
{
    [21] =
    {
        { { 900, 4155 }, { 100, 0 } },
        { { 200, 4155 }, { 800, 0 } },
        { { 400, 4119 }, { 600, 0 } },
        { { 200, 4119 }, { 800, 0 } },
    },
    [22] =
    {
        { { 800, 4155 },  { 200, 0 } },
        { { 200, 4172 },  { 800, 0 } },
        { { 100, 13688 }, { 900, 0 } },
        { { 1000, 4118 } }, -- hi-potion_+2 (real capture, 2026-08-18)
    },
    [23] =
    {
        { { 800, 4119 },  { 200, 0 } },
        { { 200, 4172 },  { 800, 0 } },
        { { 100, 13688 }, { 900, 0 } },
        { { 100, 13689 }, { 900, 0 } },
    },
    [24] =                                            -- Evade and Escape (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
        { { 1000, 13689 } },                          -- hi-ether_tank
    },
    [25] =                                            -- Siegemaster Assassination (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
        { { 1000, 13688 } },                          -- hi-potion_tank
    },
	[26] =                                            -- Apkallu Breeding (user-provided, 2026-08-19)
    {
        { { 1000, 4118 } },                           -- hi-potion_+2
        { { 1000, 13688 } },                          -- hi-potion_tank
        { { 1000, 4172 } },                           -- reraiser
    },
	[27] =                                            -- Wamoura Farm Raid (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
    },
    [28] =                                            -- Egg Conservation (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
    },
    [29] =                                            -- Operation: Black Pearl (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
        { { 1000, 13688 } },                          -- hi-potion_tank
    },
    [30] =                                            -- Better Than One (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },                           -- hi-potion_+3
        { { 1000, 13688 } },                          -- hi-potion_tank
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

