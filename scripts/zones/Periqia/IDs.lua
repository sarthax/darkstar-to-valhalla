-----------------------------------
-- Area: Periqia
-----------------------------------

Periqia =
{
    text = {
        ITEM_CANNOT_BE_OBTAINED    = 6382, -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE = 6386, -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        -- Confirmed off by one against this zone's real dialog table via mission_toolkit.py, same
        -- bug class as Leujaoam Sanctum's ITEM_OBTAINED fix -- was pointing at "Obtained <number>
        -- gil." (6389) instead of the real item message (6388).
        ITEM_OBTAINED              = 6388, -- Obtained: <item>.
        GIL_OBTAINED               = 6390, -- Obtained <number> gil.
        KEYITEM_OBTAINED           = 6391, -- Obtained key item: <keyitem>.
        KEYITEM_LOST               = 6392, -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL        = 6393, -- You do not have enough gil.
        ITEMS_OBTAINED             = 6397, -- You obtain <number> <item>!
        CARRIED_OVER_POINTS        = 7000, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY    = 7001, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER               = 7002, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        -- Block below was off by +1, verified against this zone's own dialog table dump (same
        -- shared 7507-7515 block as the other zones, plus this zone's own Excaliace escort
        -- dialogue at 7524-7541, also uniformly shifted).
        ASSAULT_31_START           = 7477, -- Commencing <assault>! Objective: Escort the prisoner
        ASSAULT_32_START           = 7478, -- Commencing <assault>! Objective: Destroy the undead
        ASSAULT_33_START           = 7479, -- Commencing <assault>! Objective: Find the survivors
        ASSAULT_34_START           = 7480, -- Commencing <assault>! Objective: Eliminate the Black Baron
        ASSAULT_35_START           = 7481, -- Commencing <assault>! Objective: Activate the bridge
        -- Building Bridges Lamia guards, dat-extractor-confirmed against periqia_6476.json -- raw
        -- capture MesNums were drifted +15, same class of drift documented elsewhere this codebase,
        -- confirmed here independently via exact text search rather than assumed: real
        -- detection/capture sequence, matches the wiki exactly.
        LAMIA_SIGHT_WARNING = 7555, -- True Sight detection: "You think the monster may have looked this way!"
        LAMIA_FOUND         = 7556, -- capture triggered (within 5'): "You've been found!"
        LAMIA_FROZEN        = 7557, -- "Your limbs are frozen...!"
        LAMIA_WARPED        = 7558, -- "You appear to have been warped to some unfamiliar place." -- teleport back to instance start
        -- Building Bridges switch activation dialog (dat-extracted from the real client dialog
        -- table via mission_toolkit.py -- see periqia_toolkit_output/dialog.yml).
        BRIDGE_SWITCH_ACTIVATED = 7564, -- "You lift the switch on the bridge mechanism."
        BRIDGE_SWITCH_ALREADY_ON = 7565, -- "The switch is already on."
        BRIDGE_SWITCH_FINAL     = 7566, -- 4th/final switch: "...From a distance, you hear the sound of machinery coming to life..."
        ASSAULT_36_START           = 7482, -- Commencing <assault>! Objective: Exterminate the chigoes
        ASSAULT_37_START           = 7483, -- Commencing <assault>! Objective: Clear the mine fields
        ASSAULT_38_START           = 7484, -- Commencing <assault>! Objective: Locate the generals
        ASSAULT_39_START           = 7485, -- Commencing <assault>! Objective: Retrieve the Mark-IIs
        ASSAULT_40_START           = 7486, -- Commencing <assault>! Objective: Assassinate King Goldemar
        TIME_TO_COMPLETE           = 7507, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED             = 7508, -- The mission has failed. Leaving area.
        RUNE_UNLOCKED_POS          = 7509, -- Mission objective completed. Unlocking Rune of Release ([A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z]-#).
        RUNE_UNLOCKED              = 7510, -- Mission objective completed. Unlocking Rune of Release.
        -- Wake the Puppet (mission 39): real text confirmed via dat-extractor (periqia_6476.json),
        -- corrected for a +8 raw-capture MesNum drift (same bug class as Defuse the Threat's own
        -- +15 drift below -- each capture/session drifts by its own arbitrary amount, not a
        -- universal constant).
        MAYMUN_AWAITING_COMMAND    = 7598, -- Battle automaton Mark-II, Maymun. Awaiting command.
        MAYMUN_SHUTTING_DOWN       = 7599, -- Compliance. Shutting down systems.
        MAYMUN_COMBAT_ONLINE       = 7600, -- Compliance. Combat maneuvers online.
        MAYMUN_COMBAT_OFFLINE      = 7601, -- Compliance. Combat maneuvers offline.
        -- Gesture texts (Maymun's spoken line while performing each gesture) and their real
        -- required emote response, confirmed word-for-word against Adeeha's own in-game "Maymun
        -- commands" help dialogue (7630-7642) -- the most solidly-confirmed data in this file,
        -- official client text, not inferred from gameplay logs.
        MAYMUN_GESTURE_BOW         = 7602, -- Battle automaton Mark-II, Maymun. Greetings. Greetings. (Bowing -> /kneel)
        MAYMUN_GESTURE_POINT       = 7611, -- Changing vector. (Pointing -> /no)
        MAYMUN_GESTURE_WAVE        = 7613, -- ...programmed to regularly inform her master of her position. (Waving -> /welcome)
        MAYMUN_GESTURE_DANCE       = 7610, -- ...programmed to entertain her master. (Dancing -> /joy)
        MAYMUN_GESTURE_BLUSH       = 7614, -- Warning! ...Maymun Mark-II's revealing attire! Warning! (Blushing -> /doze)
        MAYMUN_GESTURE_SALUTE      = 7604, -- Maymun reporting for duty, master! (Saluting -> /praise)
        MAYMUN_GESTURE_HAPPY       = 7605, -- Maymun is pleased to serve her new master. (Happy -> /smile)
        MAYMUN_GESTURE_CONFUSED    = 7606, -- (garbled text) (Confused -> /slap)
        MAYMUN_GESTURE_SHOCKED     = 7612, -- ...my parts will be melted down for use in the new models... (Shocked -> /comfort)
        MAYMUN_GESTURE_PRAISE      = 7609, -- The master is great. The master's command is absolute. (Praising -> /blush)
        MAYMUN_GESTURE_CLAP        = 7607, -- ...Are you pleased? x7 (Clapping -> /angry)
        MAYMUN_GESTURE_CHEER       = 7608, -- The enemy must be eradicated. Powering weapons systems. (Cheering -> /psych)
        -- Defuse the Threat (mission 37): real text confirmed via dat-extractor (periqia_6476.json)
        -- -- raw captured MesNum values (7570/7571/7576/7577/7578) all had the same +15 drift bug
        -- already found and fixed once on Saving Private Ryaaf's dialogue (this capture's own
        -- MesNum was 15 higher than the real client index in every case, e.g. raw 7592 -> real 7577).
        MINE_DETECTOR_LOST_SIGNAL  = 7570, -- The mine detector lost its signal...
        MINE_DETECTOR_FAINT_SIGNAL = 7571, -- The mine detector seems to be picking up a faint signal...
        MINE_FUSE_ACTIVATED        = 7576, -- A Qiqirn mine's time-based fuse seems to have been activated somewhere...
        QIQIRN_MINE_EXPLODES       = 7577, -- The Qiqirn mine explodes!
        QIQIRN_MINE_DEFUSED        = 7578, -- You defuse the Qiqirn mine!
        ASSAULT_POINTS_OBTAINED    = 7511, -- You gain <number> [Assault point/Assault points]!
        TIME_REMAINING_MINUTES     = 7512, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS     = 7513, -- Time remaining: <number> [second/seconds] (Earth time).
        FADES_INTO_NOTHINGNESS     = 7514, -- The <keyitem> fades into nothingness...
        PARTY_FALLEN               = 7515, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
        -- Saving Private Ryaaf (33) survivor dialogue. Originally read as raw MesNum values off the
        -- client's own rendered 0x036-family packets in "Periqia SP - Saving Private Ryaaf.zip"
        -- (7557-7569) -- that capture's client build numbers this dialog table 15 higher than
        -- dat-extractor's real client dialog table dump, the same class of cross-client-version DAT
        -- renumbering drift flagged elsewhere in this codebase. Independently confirmed here: this
        -- zone's own shared system-message block (TIME_TO_COMPLETE=7507 through PARTY_FALLEN=7515)
        -- already matches dat-extractor exactly, with zero drift -- so the -15 correction is
        -- specific to this dialogue block, not a zone-wide shift. Real values below (7542-7554),
        -- content cross-checked line-by-line against dat-extractor's dump, not just shifted blindly.
        RYAAF_LINE1     = 7542, -- Y-you're not a zombie...? You came all the way in here to find me...?
        RYAAF_LINE2     = 7543, -- ...
        RYAAF_LINE3     = 7544, -- They probably kept all of this secret from my sister...
        RYAAF_LINE4     = 7545, -- If she knew what had happened, she would've come after me alone.
        RYAAF_LINE5     = 7546, -- I better get back and let her know that everything's okay.
        BALARAHB_LINE1  = 7547, -- My thanks!
        BALARAHB_LINE2  = 7548, -- You're a mercenary? You came to rescue me after talking to <Speaker Name>?
        BALARAHB_LINE3  = 7549, -- No? Figures. Who would waste all those resources on a simple soldier like me.
        BALARAHB_LINE4  = 7550, -- But I'm grateful for your help, all the same.
        RHAGMAKAH_LINE1 = 7551, -- I thank you for saving me. My name is <Speaker Name>...
        RHAGMAKAH_LINE2 = 7552, -- What were you doing here anyway? You have the look of a mercenary...
        RHAGMAKAH_LINE3 = 7553, -- You're looking for Ryaaf!? I've seen him...
        RHAGMAKAH_LINE4 = 7554, -- The Lamiae replenish their troops from the bodies of the slain, you know.
        EXCALIACE_START            = 7524, -- Such a lot of trouble for one little corsair... Shall we be on our way?
        EXCALIACE_END1             = 7525, -- Yeah, I got it. Stay here and keep quiet.
        EXCALIACE_END2             = 7526, -- Hey... It was a short trip, but nothing is ever dull around you, huh?
        EXCALIACE_ESCAPE           = 7527, -- Heh. The Immortals really must be having troubles finding troops if they sent this bunch of slowpokes to watch over me...
        EXCALIACE_PAIN1            = 7528, -- Oomph!
        EXCALIACE_PAIN2            = 7529, -- Ouch!
        EXCALIACE_PAIN3            = 7530, -- Youch!
        EXCALIACE_PAIN4            = 7531, -- Damn, that's gonna leave a mark!
        EXCALIACE_PAIN5            = 7532, -- Urggh!
        EXCALIACE_CRAB1            = 7533, -- Over to you.
        EXCALIACE_CRAB2            = 7534, -- What's this guy up to?
        EXCALIACE_CRAB3            = 7535, -- Uh-oh.
        EXCALIACE_DEBAUCHER1       = 7536, -- Wh-what the...!?
        EXCALIACE_DEBAUCHER2       = 7537, -- H-help!!!
        EXCALIACE_RUN              = 7538, -- Now's my chance!
        EXCALIACE_TOO_CLOSE        = 7539, -- Okay, okay, you got me! I promise I won't run again if you step back a bit...please. Someone's been eating too much garlic...
        EXCALIACE_TIRED            = 7540, -- <Pant>...<wheeze>...
        EXCALIACE_CAUGHT           = 7541, -- Damn...
    },

    mob =
    {
        -- Seagull Grounded
        [31] =
        {
            -- Moved here from ID.npc -- Excaliace converted from npc_list to a real mob (see
            -- sql/mob_pools.sql poolid 6995's own comment for the full writeup).
            EXCALIACE  = 17006593,
            CRAB1      = 17006594,
            CRAB2      = 17006595,
            CRAB3      = 17006596,
            CRAB4      = 17006597,
            CRAB5      = 17006598,
            CRAB6      = 17006599,
            CRAB7      = 17006600,
            CRAB8      = 17006601,
            CRAB9      = 17006602,
            DEBAUCHER1 = 17006603,
            PUGIL1     = 17006604,
            PUGIL2     = 17006605,
            PUGIL3     = 17006606,
            PUGIL4     = 17006607,
            PUGIL5     = 17006608,
            DEBAUCHER2 = 17006610,
            DEBAUCHER3 = 17006611,
        },
        -- Requiem
        [32] =
        {
            PUTRID_IMMORTAL_GUARD1 = 17006612,
            PUTRID_IMMORTAL_GUARD2 = 17006613,
            BATTEILANT_BHOOT1      = 17006614,
            BATTEILANT_BHOOT2      = 17006615,
            DARKLING_DRAUGAR1      = 17006616,
            DRACONIC_DRAUGAR1      = 17006617,
            DARKLING_DRAUGAR2      = 17006619,
            DARKLING_DRAUGAR3      = 17006620,
            DRACONIC_DRAUGAR2      = 17006621,
            DRACONIC_DRAUGAR3      = 17006623,
            BATTEILANT_BHOOT3      = 17006625,
            BATTEILANT_BHOOT4      = 17006626,
            DARKLING_DRAUGAR4      = 17006627,
            DRACONIC_DRAUGAR4      = 17006628,
            DARKLING_DRAUGAR5      = 17006630,
            DRACONIC_DRAUGAR5      = 17006631,
            DARKLING_DRAUGAR6      = 17006633,
            DARKLING_DRAUGAR7      = 17006634,
        },
        -- Saving Private Ryaaf -- real mechanic, from a community wiki writeup + a real capture,
        -- "Periqia SP - Saving Private Ryaaf.zip": 5 rooms, each with 3 Cursed Chigoe (ambient
        -- obstacle, ids below) and one "hunched-over figure" that resolves to one of the 3 real
        -- survivors (Ryaaf/Balarahb/Rhagmakah, already in the npc table above) or an Experimental
        -- Undead (Fomor) -- see instances/saving_private_ryaaf.lua for the room/pattern table. 15
        -- Cursed_Chigoe ids were already sitting unwired in mob_spawn_points.sql, in 5 clean
        -- clusters of 3 matching the 5 rooms. 8 Experimental_Undead ids also already existed (job
        -- variants thf/brd/blm) -- 5 assigned one-per-room as the room's possible Fomor (nearest
        -- real spawn point to each room's chigoe cluster, some closer matches than others, see
        -- instance script), the remaining 3 used as separate always-present roaming "wandering
        -- fomors in the tunnels" ambient content (the wiki explicitly describes these as distinct
        -- from the room figures).
        [33] =
        {
            CURSED_CHIGOE1  = 17006635,
            CURSED_CHIGOE2  = 17006636,
            CURSED_CHIGOE3  = 17006637,
            CURSED_CHIGOE4  = 17006638,
            CURSED_CHIGOE5  = 17006639,
            CURSED_CHIGOE6  = 17006640,
            CURSED_CHIGOE7  = 17006641,
            CURSED_CHIGOE8  = 17006642,
            CURSED_CHIGOE9  = 17006643,
            CURSED_CHIGOE10 = 17006644,
            CURSED_CHIGOE11 = 17006645,
            CURSED_CHIGOE12 = 17006646,
            CURSED_CHIGOE13 = 17006647,
            CURSED_CHIGOE14 = 17006648,
            CURSED_CHIGOE15 = 17006649,
            -- Room-assigned possible Fomors (one per room -- see ROOMS in the instance script).
            EXP_UNDEAD_NORTH  = 17006654,
            EXP_UNDEAD_EAST   = 17006651,
            EXP_UNDEAD_SOUTH  = 17006652,
            EXP_UNDEAD_WEST   = 17006656,
            EXP_UNDEAD_CENTER = 17006657,
            -- Roaming ambient Fomors, not tied to any specific room.
            EXP_UNDEAD_ROAM1  = 17006650,
            EXP_UNDEAD_ROAM2  = 17006653,
            EXP_UNDEAD_ROAM3  = 17006655,
        },
        -- Shooting Down the Baron: Black_Baron (boss, mob_groups id 13) plus 5 Periqia_Pugil
        -- (obstacles, mob_groups id 3). Real objective text (ASSAULT_34_START, "Eliminate the Black
        -- Baron") is singular -- only the Baron's death is tracked, same shape as Sagelord
        -- Elimination. Real reward data for this mission was already sitting in this zone's
        -- Ancient_Lockbox.lua comments (ported from LSB) -- wired in below.
        [34] =
        {
            BLACK_BARON   = 17006658,
            PERIQIA_PUGIL1 = 17006659,
            PERIQIA_PUGIL2 = 17006660,
            PERIQIA_PUGIL3 = 17006661,
            PERIQIA_PUGIL4 = 17006662,
            PERIQIA_PUGIL5 = 17006663,
        },
        -- Stop the Bloodshed: 3 real Chigoe Breeder + 35 real Augmented Chigoe, all with real
        -- individually-captured coordinates (not 0,0,0 stubs, unlike most other trash in this
        -- codebase). Real objective text (ASSAULT_36_START, "Exterminate the chigoes") matches
        -- well. Modeled as kill-all-38.
        [36] =
        {
            CHIGOE_BREEDER1   = 17006679,
            CHIGOE_BREEDER2   = 17006680,
            CHIGOE_BREEDER3   = 17006681,
            AUGMENTED_CHIGOE1  = 17006682,
            AUGMENTED_CHIGOE2  = 17006683,
            AUGMENTED_CHIGOE3  = 17006684,
            AUGMENTED_CHIGOE4  = 17006685,
            AUGMENTED_CHIGOE5  = 17006686,
            AUGMENTED_CHIGOE6  = 17006687,
            AUGMENTED_CHIGOE7  = 17006688,
            AUGMENTED_CHIGOE8  = 17006689,
            AUGMENTED_CHIGOE9  = 17006690,
            AUGMENTED_CHIGOE10 = 17006691,
            AUGMENTED_CHIGOE11 = 17006692,
            AUGMENTED_CHIGOE12 = 17006693,
            AUGMENTED_CHIGOE13 = 17006694,
            AUGMENTED_CHIGOE14 = 17006695,
            AUGMENTED_CHIGOE15 = 17006696,
            AUGMENTED_CHIGOE16 = 17006697,
            AUGMENTED_CHIGOE17 = 17006698,
            AUGMENTED_CHIGOE18 = 17006699,
            AUGMENTED_CHIGOE19 = 17006700,
            AUGMENTED_CHIGOE20 = 17006701,
            AUGMENTED_CHIGOE21 = 17006702,
            AUGMENTED_CHIGOE22 = 17006703,
            AUGMENTED_CHIGOE23 = 17006704,
            AUGMENTED_CHIGOE24 = 17006705,
            AUGMENTED_CHIGOE25 = 17006706,
            AUGMENTED_CHIGOE26 = 17006707,
            AUGMENTED_CHIGOE27 = 17006708,
            AUGMENTED_CHIGOE28 = 17006709,
            AUGMENTED_CHIGOE29 = 17006710,
            AUGMENTED_CHIGOE30 = 17006711,
            AUGMENTED_CHIGOE31 = 17006712,
            AUGMENTED_CHIGOE32 = 17006713,
            AUGMENTED_CHIGOE33 = 17006714,
            AUGMENTED_CHIGOE34 = 17006715,
            AUGMENTED_CHIGOE35 = 17006716,
        },
        -- Defuse the Threat: 7 real Qiqirn Miner. Real objective text (ASSAULT_37_START, "Clear the
        -- mine fields") is the 15 Qiqirn Mine below, not the Miners (ambient guards) -- see
        -- instances/defuse_the_threat.lua for the real, capture-confirmed mechanic.
        [37] =
        {
            QIQIRN_MINER1 = 17006732,
            QIQIRN_MINER2 = 17006733,
            QIQIRN_MINER3 = 17006734,
            QIQIRN_MINER4 = 17006735,
            QIQIRN_MINER5 = 17006736,
            QIQIRN_MINER6 = 17006737,
            QIQIRN_MINER7 = 17006738,
        },
        -- Operation: Snake Eyes: 15 real mobs -- 5 Qutrub, 5 Merrow Shadowdancer, plus 5 named
        -- uniques (Merrow No.16, Karazahm, Lamia No.14, Umarid, Lamia No.17). Real objective text
        -- (ASSAULT_38_START, "Locate the generals") plausibly fits the 5 named uniques. Modeled as
        -- kill-all-15.
        [38] =
        {
            QUTRUB1              = 17006739,
            QUTRUB2              = 17006740,
            QUTRUB3              = 17006741,
            QUTRUB4              = 17006742,
            QUTRUB5              = 17006743,
            MERROW_SHADOWDANCER1 = 17006744,
            MERROW_SHADOWDANCER2 = 17006745,
            MERROW_SHADOWDANCER3 = 17006746,
            MERROW_SHADOWDANCER4 = 17006747,
            MERROW_SHADOWDANCER5 = 17006748,
            MERROW_NO16          = 17006749,
            KARAZAHM             = 17006750,
            LAMIA_NO14           = 17006751,
            UMARID               = 17006752,
            LAMIA_NO17           = 17006753,
        },
        -- Wake the Puppet: 31 real Wight, ambient hazard, NOT the objective -- see npc.MAYMUN1-6
        -- and instances/wake_the_puppet.lua for the real escort/emote-response mechanic, built from
        -- a real WIN capture (Siknawz) + user-provided walkthrough, cross-confirmed word-for-word
        -- against Adeeha's own in-game help dialogue via dat-extractor.
        [39] =
        {
            WIGHT1 = 17006770,
            WIGHT2 = 17006771,
            WIGHT3 = 17006772,
            WIGHT4 = 17006773,
            WIGHT5 = 17006774,
            WIGHT6 = 17006775,
            WIGHT7 = 17006776,
            WIGHT8 = 17006777,
            WIGHT9 = 17006778,
            WIGHT10 = 17006779,
            WIGHT11 = 17006780,
            WIGHT12 = 17006781,
            WIGHT13 = 17006782,
            WIGHT14 = 17006783,
            WIGHT15 = 17006784,
            WIGHT16 = 17006785,
            WIGHT17 = 17006786,
            WIGHT18 = 17006787,
            WIGHT19 = 17006788,
            WIGHT20 = 17006789,
            WIGHT21 = 17006790,
            WIGHT22 = 17006791,
            WIGHT23 = 17006792,
            WIGHT24 = 17006793,
            WIGHT25 = 17006794,
            WIGHT26 = 17006795,
            WIGHT27 = 17006796,
            WIGHT28 = 17006797,
            WIGHT29 = 17006798,
            WIGHT30 = 17006799,
            WIGHT31 = 17006800,
        },
        -- The Price Is Right: King Goldemar (real coordinates, boss) + 6 obstacle mobs (2 Bloody
        -- Daggers, Demonic Rod, Living Staves, Cursed Axe, Magic Shields). Real objective text
        -- matches exactly ("Assassinate King Goldemar") -- singular target, same pattern as
        -- Sagelord Elimination. This is the last of this zone's 10 Assault missions -- Periqia is
        -- fully built out.
        [40] =
        {
            KING_GOLDEMAR   = 17006801,
            BLOODY_DAGGERS1 = 17006802,
            BLOODY_DAGGERS2 = 17006803,
            DEMONIC_ROD     = 17006804,
            LIVING_STAVES   = 17006805,
            CURSED_AXE      = 17006806,
            MAGIC_SHIELDS   = 17006807,
        },
        -- Shades of Vengeance
        [79] =
        {
            K23H1LAMIA1  = 17006754,
            K23H1LAMIA2  = 17006755,
            K23H1LAMIA3  = 17006756,
            K23H1LAMIA4  = 17006757,
            K23H1LAMIA5  = 17006758,
            K23H1LAMIA6  = 17006759,
            K23H1LAMIA7  = 17006760,
            K23H1LAMIA8  = 17006761,
            K23H1LAMIA9  = 17006762,
            K23H1LAMIA10 = 17006763,
        }
    },

    npc =
    {
        -- EXCALIACE moved to ID.mob[31] -- converted from npc_list to a real mob, see
        -- sql/mob_pools.sql poolid 6995's own comment.
        -- Wake the Puppet (mission 39): ADEEHA already had a real npc_list row and
        -- instance_entities registration but was never named here. 6 real Maymun automatons, all
        -- real positions -- 3 independent captures between them cover 3 distinct real room-cluster
        -- pairs ("the four rooms at the edges of the map"), see npc_list.sql's comment on 17006764
        -- for the full writeup. See instances/wake_the_puppet.lua.
        ADEEHA          = 17006822,
        MAYMUN1         = 17006764,
        MAYMUN2         = 17006765,
        MAYMUN3         = 17006766,
        MAYMUN4         = 17006767,
        MAYMUN5         = 17006768,
        MAYMUN6         = 17006769,
        -- Defuse the Threat (mission 37): 15 real Qiqirn Mine entities, real position/entityFlags
        -- from the Thris Nov2025 capture -- see npc_list.sql's comment on 17006717 and
        -- instances/defuse_the_threat.lua for the mechanic.
        QIQIRN_MINE1    = 17006717,
        QIQIRN_MINE2    = 17006718,
        QIQIRN_MINE3    = 17006719,
        QIQIRN_MINE4    = 17006720,
        QIQIRN_MINE5    = 17006721,
        QIQIRN_MINE6    = 17006722,
        QIQIRN_MINE7    = 17006723,
        QIQIRN_MINE8    = 17006724,
        QIQIRN_MINE9    = 17006725,
        QIQIRN_MINE10   = 17006726,
        QIQIRN_MINE11   = 17006727,
        QIQIRN_MINE12   = 17006728,
        QIQIRN_MINE13   = 17006729,
        QIQIRN_MINE14   = 17006730,
        QIQIRN_MINE15   = 17006731,
        ANCIENT_LOCKBOX = 17006809,
        RUNE_OF_RELEASE = 17006810,
        -- Saving Private Ryaaf -- found unwired in sql/npc_list.sql, sitting right after
        -- RUNE_OF_RELEASE. All 3 are real, individually-positioned entities (not 0,0,0 stubs),
        -- matching retail's plural "Find the survivors" objective.
        RYAAF           = 17006811,
        BALARAHB        = 17006812,
        RHAGMAKAH       = 17006813,
        HUNCHED_FIGURE1 = 17006818,
        HUNCHED_FIGURE2 = 17006819,
        -- Building Bridges: 4 real, individually-positioned Bridge_Switch NPCs found in
        -- npc_list.sql. Real objective text (ASSAULT_35_START, "Activate the bridge") matches the
        -- switches well.
        BRIDGE_SWITCH1  = 17006814,
        BRIDGE_SWITCH2  = 17006815,
        BRIDGE_SWITCH3  = 17006816,
        BRIDGE_SWITCH4  = 17006817,
        -- The 15 Lamia guard ids (17006664-17006678) were previously checked against SQL and found
        -- unbacked -- true at the time (zero SQL rows existed), but a fresh NPCLogger crossref
        -- pipeline run against a real Thris Nov2025 "Building Bridges" capture found real data for
        -- every single one (names, positions, entityFlags) -- now added for real in npc_list.sql.
        -- See npcs/Lamia_Guard.lua for the real True-Sight-detection/capture mechanic these drive.
        LAMIA1  = 17006664,
        LAMIA2  = 17006665,
        LAMIA3  = 17006666,
        LAMIA4  = 17006667,
        LAMIA5  = 17006668,
        LAMIA6  = 17006669,
        LAMIA7  = 17006670,
        LAMIA8  = 17006671,
        LAMIA9  = 17006672,
        LAMIA10 = 17006673,
        LAMIA11 = 17006674,
        LAMIA12 = 17006675,
        LAMIA13 = 17006676,
        LAMIA14 = 17006677,
        LAMIA15 = 17006678,
        _1K1            = 17006840,
        _1K2            = 17006841,
        _1K3            = 17006842,
        _1K4            = 17006843,
        _1K5            = 17006844,
        _1K6            = 17006845,
        _1K7            = 17006846,
        _1K8            = 17006847,
        _1K9            = 17006848,
        _1KA            = 17006849,
        _1KB            = 17006850,
        _1KC            = 17006851,
        _1KD            = 17006852,
        _1KE            = 17006853,
        _1KF            = 17006854,
        _1KG            = 17006855,
        _1KH            = 17006856,
        _1KI            = 17006857,
        _1KJ            = 17006858,
        _1KK            = 17006859,
        _1KL            = 17006860,
        _1KM            = 17006861,
        _1KN            = 17006862,
        _1KO            = 17006863,
        _1KP            = 17006864,
        _1KQ            = 17006865,
        _1KR            = 17006866,
        _1KS            = 17006867,
        _1KT            = 17006868,
        _1KU            = 17006869,
        _1KV            = 17006870,
        _1KW            = 17006871,
        _1KX            = 17006872,
        _1KY            = 17006873,
        _1KZ            = 17006874,
        _JK0            = 17006875,
        _JK1            = 17006876,
        _JK2            = 17006877,
        _JK3            = 17006878,
        _JK4            = 17006879,
        _JK5            = 17006880,
        _JK6            = 17006881,
        _JK7            = 17006882,
        _JK8            = 17006883,
        _JK9            = 17006884,
        _JKA            = 17006885,
        _JKB            = 17006886,
        _JKC            = 17006887,
        _JKD            = 17006888,
        _JKE            = 17006889,
        _JKF            = 17006890,
        _JKG            = 17006891,
        _JKH            = 17006892,
        _JKI            = 17006893,
        _JKJ            = 17006894,
        _JKK            = 17006895,
        _JKL            = 17006896,
        _JKM            = 17006897,
        _JKN            = 17006898,
        _JKO            = 17006899,
    }
}

return Periqia
