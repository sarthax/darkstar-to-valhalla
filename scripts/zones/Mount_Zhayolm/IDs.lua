-----------------------------------
-- Area: Mount_Zhayolm
-----------------------------------
require("scripts/globals/zone")
-----------------------------------

zones = zones or {}

zones[MOUNT_ZHAYOLM] =
{
    text =
    {
        NOTHING_HAPPENS         =  119, -- Nothing happens...
        ITEM_CANNOT_BE_OBTAINED = 6383, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED           = 6389, -- Obtained: <item>.
        GIL_OBTAINED            = 6390, -- Obtained <number> gil.
        KEYITEM_OBTAINED        = 6392, -- Obtained key item: <keyitem>.
        FELLOW_MESSAGE_OFFSET   = 6418, -- I'm ready. I suppose.
        CARRIED_OVER_POINTS     = 7000, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY = 7001, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER            = 7002, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        FISHING_MESSAGE_OFFSET  = 7050, -- You can't fish here.
        RESPONSE                = 7330, -- There is no response...
        MINING_IS_POSSIBLE_HERE = 7419, -- Mining is possible here if you have <item>.
        CANNOT_ENTER            = 7478, -- You cannot enter at this time. Please wait a while before trying again.
        AREA_FULL               = 7479, -- This area is fully occupied. You were unable to enter.
        MEMBER_NO_REQS          = 7483, -- Not all of your party members meet the requirements for this objective. Unable to enter area.
        MEMBER_TOO_FAR          = 7487, -- One or more party members are too far away from the entrance. Unable to enter area.
        SHED_LEAVES             = 7549, -- The ground is strewn with shed leaves...
        SICKLY_SWEET            = 7564, -- A sickly sweet fragrance pervades the air...
        DRAWS_NEAR              = 7576, -- Something draws near!
        HOMEPOINT_SET           = 8725, -- Home point set!
        -- Real BG Wiki mechanic ("Warhorse Hoofprint") -- confirmed real dat-extracted dialog text
        -- (mission_toolkit.py, idx 6398, identical string/index in all 4 real hoofprint zones):
        -- "You find the hoofprint of a gigantic warhorse..."
        HOOFPRINT_FOUND         = 6398,
    },
    mob =
    {
        ENERGETIC_ERUCA_PH    =
        {
            [17027146] = 17027466, -- 175.315 -14.444 -173.589
            [17027145] = 17027466, -- 181.601 -14.120 -166.218
        },
        IGNAMOTH_PH =
        {
            [17027421] = 17027423, -- -567.6 -15.35 252.201
            [17027422] = 17027423, -- -544.3 -14.8 262.992
        },
        CERBERUS              = 17027458,
        BRASS_BORER           = 17027471,
        CLARET                = 17027472,
        ANANTABOGA            = 17027473,
        KHROMASOUL_BHURBORLOR = 17027474,
        SARAMEYA              = 17027485,
    },
    npc =
    {
        MINING =
        {
            17027559,
            17027560,
            17027561,
            17027562,
            17027563,
            17027564,
        },
        -- Real Warhorse_Hoofprint rows in sql/npc_list.sql, positioned via real user-supplied
        -- !logpos captures 2026-09-13 (727.108,-14.442,-54.955 / -471.422,-13.772,337.187 /
        -- 153.357,-13.744,-208.806).
        WARHORSE_HOOFPRINT_1   = 17027510,
        WARHORSE_HOOFPRINT_2   = 17027511,
        WARHORSE_HOOFPRINT_3   = 17027512,
    },
}

return zones[MOUNT_ZHAYOLM]
