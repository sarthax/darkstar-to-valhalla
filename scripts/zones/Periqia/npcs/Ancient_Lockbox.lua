-----------------------------------
-- Area: Periqia
--  NPC: Ancient Lockbox
-----------------------------------
-- Real reward tables ported from LandSandBoat's Periqia/npcs/Ancient_Lockbox.lua
-- (user-provided reference), translated to this codebase's numeric item IDs and instance IDs
-- (sql/instance_list.sql: 31=seagull_grounded, 32=requiem -- this zone's one physical lockbox
-- is shared by both, repositioned per-instance). Roll/give logic lives in
-- scripts/globals/assault_lockbox.lua (shared across zones). XP/gil are the flat 1000/1000
-- placeholder carried over from Leujaoam_Sanctum's reference build -- not confirmed for this
-- zone specifically, see that file's comments for why.
-- 2026-08-18: Saving Private Ryaaf (instance 33) now has real reward data from a capture --
-- qItem ???_shield (2281). No regItem observed in that capture (may not have rolled, or this
-- mission may only have the one qItem pool); left unset rather than guessed.
-- 2026-08-19, user-provided: full Saving Private Ryaaf data -- 4 qItems (axe/polearm/shield/box)
-- and 4 regItems (Hi-Potion+3/Hi-Reraiser/Hi-Potion Tank/Hi-Ether Tank). Supersedes the
-- single-item capture above; no odds given for the qItem split, equal-weight pool same as other
-- unconfirmed-split missions this session.
-- 2026-08-19, user-provided: full Building Bridges (instance 35) data -- 3 qItems (axe/polearm/
-- box) and 4 regItems (Hi-Potion+3/Hi-Potion Tank/Hi-Ether Tank/Hi-Reraiser). Supersedes the
-- previous single-item (???_axe only) entry; no odds given for the qItem split.
-- 2026-08-18: Shooting Down the Baron (instance 34) is now built (see
-- instances/shooting_down_the_baron.lua) -- its LSB reward data, previously just a comment
-- here, is now wired in for real: qItem 600/400 split (???_bow=2194 / ???_box=2286), regItem
-- 4 independent pools (Hi-Potion+2/+3/Tank, Hi-Reraiser vs nothing).
-----------------------------------
require("scripts/globals/assault_lockbox")
-----------------------------------
local Q_ITEMS =
{
    [31] = { { { 400, 2286 }, { 200, 2190 }, { 200, 2192 }, { 200, 2195 } } }, -- Seagull Grounded: ???_box / ???_sword / ???_polearm / ???_gloves
    [33] = { { { 250, 2193 }, { 250, 2192 }, { 250, 2281 }, { 250, 2286 } } }, -- Saving Private Ryaaf: ???_axe / ???_polearm / ???_shield / ???_box (user-provided, 2026-08-19)
    [35] = { { { 334, 2193 }, { 333, 2192 }, { 333, 2286 } } },                -- Building Bridges: ???_axe / ???_polearm / ???_box (user-provided, 2026-08-19)
    [36] = { { { 1000, 2190 } } },                                            -- Stop the Bloodshed: ???_sword
    [37] = { { { 1000, 2286 } } },                                            -- Defuse the Threat: ???_box
    [40] = { { { 1000, 2195 } } },                                            -- The Price is Right: ???_gloves
    [32] = { { { 400, 2286 }, { 200, 2195 }, { 200, 2192 }, { 200, 2193 } } }, -- Requiem:          ???_box / ???_gloves / ???_polearm / ???_axe
    [34] = { { { 600, 2194 }, { 400, 2286 } } },                              -- Shooting Down the Baron: ???_bow / ???_box
    [38] = { { { 1000, 2282 } } },                                            -- Operation: Snake Eyes: ???_necklace (real capture, 2026-08-18)
    [39] = { { { 1000, 2286 } } },                                            -- Wake the Puppet: ???_box (real capture, 2026-08-18)
}

local REG_ITEMS =
{
    [33] = -- Saving Private Ryaaf (user-provided, 2026-08-19)
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 4173 } },  -- hi-reraiser
        { { 1000, 13688 } }, -- hi-potion_tank
        { { 1000, 13689 } }, -- hi-ether_tank
    },
    [35] = -- Building Bridges (user-provided, 2026-08-19)
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
        { { 1000, 13689 } }, -- hi-ether_tank
        { { 1000, 4173 } },  -- hi-reraiser
    },
    [31] =
    {
        { { 700, 4173 },  { 300, 0 } },
        { { 100, 13688 }, { 100, 13689 }, { 800, 0 } },
        { { 530, 4119 },  { 470, 0 } },
    },
    [32] =
    {
        { { 500, 4119 },  { 500, 0 } },
        { { 100, 13689 }, { 900, 0 } },
        { { 500, 4173 },  { 500, 0 } },
    },
    [34] =
    {
        { { 850, 4118 },  { 150, 0 } }, -- Hi-Potion+2
        { { 50, 4119 },   { 950, 0 } }, -- Hi-Potion+3
        { { 400, 13688 }, { 600, 0 } }, -- Hi-Potion Tank
        { { 200, 4173 },  { 800, 0 } }, -- Hi-Reraiser
    },
    [36] =
    {
        { { 1000, 4155 } }, -- remedy
    },
    [37] =
    {
        { { 1000, 4118 } }, -- hi-potion_+2
    },
    [40] =
    {
        { { 1000, 4119 } }, -- hi-potion_+3
    },
    [38] = -- Operation: Snake Eyes (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },  -- hi-potion_+3
        { { 1000, 13688 } }, -- hi-potion_tank
    },
    [39] = -- Wake the Puppet (real capture, 2026-08-18)
    {
        { { 1000, 4119 } },  -- hi-potion_+3
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

