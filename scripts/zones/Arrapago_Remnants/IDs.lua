-----------------------------------
-- Area: Arrapago_Remnants
-----------------------------------
-- text ids verified by TEXT against a fresh zone-74 dialog.yml pull (2026-10-09).
-----------------------------------

Arrapago =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED    = 6382, -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE = 6386, -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        ITEM_OBTAINED              = 6388, -- Obtained: <item>.
        GIL_OBTAINED               = 6389, -- Obtained <number> gil.
        KEYITEM_OBTAINED           = 6391, -- Obtained key item: <keyitem>.
        KEYITEM_LOST               = 6392, -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL        = 6393, -- You do not have enough gil.
        ITEMS_OBTAINED             = 6397, -- You obtain <number> <item>!
        SALVAGE_START              = 7235, -- You feel an incredible pressure bearing down on you. This area appears to be blanketed in some sort of intense psionic field...
        TIME_TO_COMPLETE           = 7442, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED             = 7443, -- The mission has failed. Leaving area.
        TIME_REMAINING_MINUTES     = 7447, -- ime remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS     = 7448, -- ime remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN               = 7450, -- ll party members have fallen in battle. Mission failure in <number> [minute/minutes].
        -- Both off by 1, same pattern as CELL_OFFSET. Confirmed via mission_toolkit.py's real
        -- dialog.yml (dat-id 6494): 7462 is actually "Open the door? [Yes/No]" (why clicking a
        -- sealed door was popping a Yes/No prompt instead of just stating it's sealed), and 7465 is
        -- an unrelated "ragged sighing" sound-effect line, not the mysterious-force text. Real ids
        -- are 7461/7464.
        DOOR_IS_SEALED             = 7461, -- The door is sealed...
        DOOR_IS_SEALED_MYSTERIOUS  = 7464, -- The door is sealed by some mysterious force...
        -- Was off by 1. Confirmed via mission_toolkit.py's fresh dialog.yml export straight from
        -- the real client dat (dat-id 6494), NOT the earlier FFXI-EventsDump strings.txt dump
        -- (which was stale/mis-indexed and caused an earlier misfire). Real 7212 = "Main
        -- Weapon/Sub-Weapon restriction removed"; every cell item's own offset (0-19) was already
        -- correct once this base is right.
        TEMP_ITEM                  = 7233, -- Obtained temporary item: <item>!
        HAVE_TEMP_ITEM             = 7234, -- You already have that temporary item.
        CELL_OFFSET                = 7212, -- Main Weapon/Sub-Weapon restriction removed.
    },
    mobs =
    {
        [1] = {
            [2] = {
                mobs_start = 17080323,
                mobs_end   = 17080395,
                rampart    = 17080321,
                sabotender = 17080322,
            }
        },
        [2] = {
            [0] = {
                astrologer = 17080431,
            },
            [1] = {
                mobs_start = 17080421,
                mobs_end   = 17080430,
            },
            [2] = {
                mobs_start = 17080413,
                mobs_end   = 17080420,
                princess   = 17080597,
            },
            [3] = {
                mobs_start = 17080404,
                mobs_end   = 17080412,
                wahzil     = 17080596,
            },
            [4] = {
                mobs_start = 17080396,
                mobs_end   = 17080403,
            },
        },
        [3] = {
            [1] = {
                mobs_start = 17080432,
                mobs_end   = 17080451,
            },
            [2] = {
                mobs_start = 17080454,
                mobs_end   = 17080474,
            },
            treasure_hunter1 = 17080452,
            qiqirn_mine_1    = 17080453,
            treasure_hunter2 = 17080475,
            qiqirn_mine_2    = 17080476,
        },
        [4] = {
            [1] = {
                mobs_start = 17080477,
                mobs_end   = 17080489,
                rampart2   = 17080492,
            },
            [2] = {
                mobs_start = 17080497,
                mobs_end   = 17080509,
                rampart2   = 17080512,
            },
            treasure_hunter1 = 17080514,
            qiqirn_mine_1    = 17080515,
            treasure_hunter2 = 17080495,
            qiqirn_mine_2    = 17080496,
        },
        [5] = {
            [1] = {
                [1] = {
                mobs_start = 17080516,
                mobs_end   = 17080519,
                },
                [2] = {
                mobs_start = 17080521,
                mobs_end   = 17080522,
                },
                [3] = {
                mobs_start = 17080526,
                mobs_end   = 17080530,
                },
                astrologer = 17080520,
                rampart1   = 17080523,
                rampart2   = 17080533,
                chariot    = 17080537,
            },
            [2] = {
                [1] = {
                mobs_start = 17080538,
                mobs_end   = 17080541,
                },
                [2] = {
                mobs_start = 17080543,
                mobs_end   = 17080544,
                },
                [3] = {
                mobs_start = 17080549,
                mobs_end   = 17080553,
                },
                astrologer = 17080542,
                rampart1   = 17080545,
                -- This id was missing entirely. Confirmed real in sql/mob_spawn_points.sql
                -- (17080555, SQL name 'Archaic_Rampart_2', within this branch's own real mob id
                -- range) -- also missing from LSB's own IDs.lua, a shared upstream omission, not
                -- something introduced in Topaz. Floor 5 branch [1] has exactly 2 real ramparts
                -- (rampart1/rampart2); branch [2] should match.
                rampart2   = 17080555,
                chariot    = 17080558,
            },
        },
        [6] = {
            [1] = {
                mobs_start = 17080562,
                mobs_end   = 17080569,
            },
            rampart1 = 17080559,
            rampart2 = 17080570,
            rampart3 = 17080577,
            rampart4 = 17080581,
            treasure_hunter1 = 17080573,
            qiqirn_mine_1    = 17080574,
            treasure_hunter2 = 17080575,
            qiqirn_mine_2    = 17080576,
        },
        [7] = {
            [1] = {
            chariot = 17080585,
            },
        },
    },
    npcs =
    {
        -- scripts/globals/salvage.lua's spawnTempChest (used by this zone's own trash mobs) expects
        -- this top-level ID.npc.ARMOURY_CRATE array convention (element 1 = fixed real crate,
        -- elements 2+ = repositionable temp-drop pool), matching Bhaflau/Silver Sea/Zhayolm.
        -- Element 1 reuses the same real fixed crate id already used by npcs/Armoury_Crate.lua
        -- (ID.npc[1][2].ARMORY_CRATE, unchanged, still used directly by that file's own onTrigger).
        -- The 4 reserved pool ids (17080593/594/595/598) were genuine NC/uncaptured zero-position
        -- placeholders -- per the real mechanic (spawnTempChest moves them via setPos() to wherever
        -- a mob died, confirmed same as Bhaflau's own working pool), their starting position is
        -- never actually used, so there was nothing left to "capture" -- uncommented in
        -- npc_list.sql with the working crate's own real position/model and added here now that
        -- Armoury_Crate.lua actually branches pool ids to the real temp-item flow.
        ARMOURY_CRATE = { 17080586, 17080593, 17080594, 17080595, 17080598 },
        [1] = {
            [1] = {
                DOOR1 = 17080974,
            },
            [2] = {
                ARMORY_CRATE = 17080586,
            },
            [3] = {
                DOOR1 = 17080975,
                DOOR2 = 17080976,
                DOOR3 = 17080977,
                DOOR4 = 17080978,
            },
        },
        [2] = {
            [1] = {
                DOOR1 = 17080979,
                DOOR2 = 17080980,
                DOOR3 = 17080981,
                DOOR4 = 17080982,
            },
            [2] = {
                SOCKET = 17080941,
                SLOT   = 17080942,
            },
        },
        [3] = {
            [1] = {
                DOOR1 = 17080983,
                DOOR2 = 17080984,
            },
        },
        [4] = {
            [1] = {
                DOOR1 = 17080985,
                DOOR2 = 17080986,
            },
        },
        [5] = {
            [1] = {
                DOOR1 = 17080987,
                DOOR2 = 17080988,
            },
        },
        [6] = {
            DOOR = 17080989,
        },
        -- _22g (17080990) was never referenced anywhere in this file, needed to reveal it from
        -- _22f's onEventFinish (same missing-reveal chain fix across the whole floor progression).
        -- Revised with real ground-truth confirmation from our own client's real entity names
        -- (build_database.py --zones 74): _22g (17080990) is a genuine door ("Gilded Doors",
        -- matching its 16 siblings). _22h (17080991) has NO real descriptive name at all -- its
        -- actual client name is the literal string "_22h", unlike every real door -- confirming
        -- it's not a door itself, but the passive mechanism/hinge piece that animates alongside the
        -- real door. _22i (17080992) is the real second door leaf, genuinely named "Gilded
        -- Gateway". _22g sits 40 units away from _22h/_22i (confirmed via real position data) -- a
        -- separate, independent alternate door, same pattern as _22b/_22c and _22d/_22e elsewhere
        -- in this zone. [7] stays the reveal group for _22f.lua's "make all viable stage-7 doors
        -- targetable" loop (all three really do need revealing together) -- the animate/lock
        -- PAIRING is scoped separately (see GATEWAY_MECHANISM below), since _22g must not be tied
        -- to _22h/_22i's own open/close.
        [7] = { 17080990, 17080991, 17080992 },
        -- _22i's own real twin. _22h (the passive mechanism) gets animated and locked alongside
        -- _22i (the real door) specifically, not _22g.
        GATEWAY_MECHANISM = 17080991,
    },
    points =
    {
        [3] =
        {
            [0] = -- 2nd Floor Astrologer
            {
                point1 =
                {
                    302, -2, 99,
                },
                point2 =
                {
                    309, -4, 99,
                },
                point3 =
                {
                    319, -4, 100,
                },
                point4 =
                {
                    330, -4, 101,
                },
                point5 =
                {
                    335, -3, 113,
                },
                point6 =
                {
                    340, -3, 109,
                },
            },
        },
        [4] =
        {
            [2] = -- 3rd Floor S Treasure Hunter
            {
                route =
                {
                    380, -4, 422,
                    379, -4, 373,
                    300, -4, 371,
                    300, -4, 421,
                    219, -4, 420,
                    224, -3, 461,
                    217, -4, 499,
                    260, -4, 500,
                    260, -4, 459,
                    339, 0, 460,
                    260, -4, 459,
                    260, -4, 500,
                    217, -4, 499,
                    224, -3, 461,
                    219, -4, 420,
                    300, -4, 421,
                    300, -4, 371,
                    379, -4, 373,
                    380, -4, 422,
                },
            },
            [3] = -- 3rd Floor N Treasure Hunter
            {
                route =
                {
                    300, -4, 497,
                    300, -4, 548,
                    379, -4, 549,
                    380, -4, 499,
                    460, -4, 500,
                    462, -4, 459,
                    458, -4, 419,
                    419, -4, 420,
                    419, -4, 460,
                    340, 0, 459,
                    419, -4, 460,
                    419, -4, 420,
                    458, -4, 419,
                    462, -4, 459,
                    460, -4, 500,
                    380, -4, 499,
                    379, -4, 549,
                    300, -4, 548,
                    300, -4, 497,
                },
            },
        },
        [5] =
        {
            [2] = -- 4th Floor S Treasure Hunter
            {
                route =
                {
                    -377, 0, -579,
                    -340, 0, -580,
                    -377, 0, -579,
                    -382, 0, -608,
                    -377, 0, -579,
                    -340, 0, -580,
                    -377, 0, -579,
                },
            },
            [3] = -- 4th Floor N Treasure Hunter
            {
                route =
                {
                    -301, 0, -499,
                    -339, 0, -500,
                    -301, 0, -499,
                    -298, 0, -472,
                    -301, 0, -499,
                    -339, 0, -500,
                    -301, 0, -499,
                },
            },
        },
        [6] =
        {
            [1] = --5th Floor S Astrologer
            {
                point1 =
                {
                    -340, 3, -160,
                },
                point2 =
                {
                    -340, 0, -202,
                },
                point3 =
                {
                    -354, 0, -219,
                },
                point4 =
                {
                    -380, 0, -219,
                },
                point5 =
                {
                    -380, 0, -198,
                },
                point6 =
                {
                    -380, 0, -180,
                },
            },
            [2] = --5th Floor N Astrologer
            {
                point1 =
                {
                    -339, -4, -35,
                },
                point2 =
                {
                    -340, 0, -11,
                },
                point3 =
                {
                    -333, 0, 21,
                },
                point4 =
                {
                    -300, 0, 19,
                },
                point5 =
                {
                    -299, 0, 0,
                },
                point6 =
                {
                    -300, 0, -19,
                },
            },
        },
        [7] =
        {
            [0] = -- Floor 6 2x Treasure Hunters
            {
                route =
                {
                    -413, 0, 219,
                    -340, 0, 219,
                },
            },
        },
    },
}
