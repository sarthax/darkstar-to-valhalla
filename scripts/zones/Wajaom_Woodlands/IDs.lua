-----------------------------------
-- Area: Wajaom_Woodlands
-----------------------------------
require("scripts/globals/zone")
-----------------------------------

zones = zones or {}

zones[WAJAOM_WOODLANDS] =
{
    text =
    {
        NOTHING_HAPPENS             = 119, -- Nothing happens...
        ITEM_CANNOT_BE_OBTAINED     = 6383, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED               = 6389, -- Obtained: <item>.
        GIL_OBTAINED                = 6390, -- Obtained <number> gil.
        KEYITEM_OBTAINED            = 6392, -- Obtained key item: <keyitem>.
        FELLOW_MESSAGE_OFFSET       = 6418, -- I'm ready. I suppose.
        CARRIED_OVER_POINTS         = 7000, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY     = 7001, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER                = 7002, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        FISHING_MESSAGE_OFFSET      = 7050, -- You can't fish here.
        DIG_THROW_AWAY              = 7063, -- You dig up <item>, but your inventory is full. You regretfully throw the <item> away.
        FIND_NOTHING                = 7065, -- You dig and you dig, but find nothing.
        PLACE_HYDROGAUGE            = 7343, -- You set the <item> in the glowing trench.
        ENIGMATIC_LIGHT             = 7344, -- The <item> is giving off an enigmatic light.
        LEYPOINT                    = 7399, -- An eerie red glow emanates from this stone platform. The surrounding air feels alive with energy...
        HARVESTING_IS_POSSIBLE_HERE = 7407, -- Harvesting is possible here if you have <item>.
        HEAVY_FRAGRANCE             = 8486, -- The heady fragrance of wine pervades the air...
        INSECT_WINGS                = 8488, -- Broken shards of insect wing are scattered all over...
        PAMAMA_PEELS                = 8490, -- Piles of pamama peels litter the ground...
        BROKEN_SHARDS               = 8493, -- Broken shards of insect wing are scattered all over...
        DRAWS_NEAR                  = 8516, -- Something draws near!
        COMMON_SENSE_SURVIVAL       = 9634, -- It appears that you have arrived at a new survival guide provided by the Adventurers' Mutual Aid Network. Common sense dictates that you should now be able to teleport here from similar tomes throughout the world.
        -- Promotion: Lance Corporal (Mythralline Wellspring test-tube quest). Real LandSandBoat
        -- reference implementation used WELLSPRING=7472, but that's LSB's own dialog-table
        -- numbering, not this client's -- cross-checked against this zone's real dat-extracted
        -- dialog dump (mission_toolkit.py) and confirmed drifted (-29). Verified real value: 7443
        -- "The water in this spring is an unusual color..." with the expected +1/+2/+3 offset block
        -- immediately following it in the real dump ("You collect a sample of the water." /
        -- "You no longer need the water from this spring." / "You do not need any more water from
        -- this spring.") -- exact same real text/offset pattern LSB uses, just at the right index.
        WELLSPRING                  = 7443,
        -- Real BG Wiki mechanic ("Warhorse Hoofprint") -- confirmed real dat-extracted dialog text
        -- (mission_toolkit.py, idx 6398, identical string/index in all 4 real hoofprint zones):
        -- "You find the hoofprint of a gigantic warhorse..."
        HOOFPRINT_FOUND             = 6398,
    },
    mob =
    {
        JADED_JODY_PH          =
        {
            [16986376] = 16986378, -- -560 -8 -360
            [16986390] = 16986378, -- -565 -7 -324
        },
        ZORAAL_JA_S_PKUUCHA_PH =
        {
            [16986191] = 16986197, -- 181.000 -18.000 -63.000
            [16986192] = 16986197, -- 181.000 -19.000 -77.000
            [16986193] = 16986197, -- 195.000 -18.000 -95.000
            [16986194] = 16986197, -- 220.000 -19.000 -80.000
            [16986195] = 16986197, -- 219.000 -18.000 -59.000
            [16986196] = 16986197, -- 203.000 -16.000 -74.000
        },
        ZORAAL_JA_S_PKUUCHA    = 16986197,
        PERCIPIENT_ZORAAL_JA   = 16986198,
        VULPANGUE              = 16986428,
        IRIZ_IMA               = 16986429,
        GOTOH_ZHA_THE_REDOLENT = 16986430,
        TINNIN                 = 16986431,
    },
    npc =
    {
        HARVESTING =
        {
            16986725,
            16986726,
            16986727,
            16986728,
            16986729,
            16986730,
        },
        -- Real Mythralline Wellspring rows (Promotion: Lance Corporal) -- already present in
        -- sql/npc_list.sql at correct real positions (matched against LandSandBoat's own
        -- !pos comments almost exactly), just never given IDs.lua constants or a script. Real event
        -- ids per spring (4,5,6,7) confirmed via this zone's own client-compiled event table
        -- (mission_toolkit.py disassembly) -- npcs/Mythralline_Wellspring.lua derives which one from
        -- (id - MYTHRALLINE_WELLSPRING_1), same offset convention LSB uses.
        MYTHRALLINE_WELLSPRING_1    = 16986733,
        MYTHRALLINE_WELLSPRING_2    = 16986734,
        MYTHRALLINE_WELLSPRING_3    = 16986735,
        MYTHRALLINE_WELLSPRING_4    = 16986736,
        -- Real Warhorse_Hoofprint rows in sql/npc_list.sql, positioned via real user-supplied
        -- !logpos captures 2026-09-13 (-340.001,-31.621,685.425 / 154.929,-20.123,-227.454 /
        -- -99.640,-19.051,-552.911).
        WARHORSE_HOOFPRINT_1        = 16986599,
        WARHORSE_HOOFPRINT_2        = 16986600,
        WARHORSE_HOOFPRINT_3        = 16986601,
    },
}

return zones[WAJAOM_WOODLANDS]
