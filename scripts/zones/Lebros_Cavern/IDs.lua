-----------------------------------
-- Area: Lebros_Cavern
-----------------------------------

Lebros =
{
    text = {
        ITEM_CANNOT_BE_OBTAINED    = 6382, -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE = 6386, -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        ITEM_OBTAINED              = 6389, -- Obtained: <item>.
        GIL_OBTAINED               = 6390, -- Obtained <number> gil.
        KEYITEM_OBTAINED           = 6391, -- Obtained key item: <keyitem>.
        KEYITEM_LOST               = 6392, -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL        = 6393, -- You do not have enough gil.
        ITEMS_OBTAINED             = 6397, -- You obtain <number> <item>!
        MINE_COUNTDOWN             = 6980, -- <number>...
        MINE_EXPLODES              = 6981, -- The mine explodes!
        CARRIED_OVER_POINTS        = 7000, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY    = 7001, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER               = 7002, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        TEMP_ITEM                  = 7210, -- Obtained temporary item: <item>! (dialog.yml 2026-09-19)
        -- Also off by +1, verified against this zone's own dialog table dump.
        ASSAULT_21_START           = 7367, -- Commencing <assault>! Objective: Remove the obstructions
        ASSAULT_22_START           = 7368, -- Commencing <assault>! Objective: Deliver the provisions
        ASSAULT_23_START           = 7369, -- Commencing <assault>! Objective: Destroy the Troll fugitives
        ASSAULT_24_START           = 7370, -- Commencing <assault>! Objective: Discover alternate route
        ASSAULT_25_START           = 7371, -- Commencing <assault>! Objective: Assassinate Borgerlur
        -- Dat-extractor-confirmed (lebros_cavern_6483.json index 7440), from a real wiki
        -- walkthrough (user-provided): shown on killing the correct disguised Old Troll.
        BORGERLUR_CAUGHT           = 7440, -- "Uggghhh... H-how did you know...? Borgerlur, lost in own clever plan..."
        ASSAULT_26_START           = 7372, -- Commencing <assault>! Objective: Match the Apkallu
        ASSAULT_27_START           = 7373, -- Commencing <assault>! Objective: Remove the threat
        ASSAULT_28_START           = 7374, -- Commencing <assault>! Objective: Drive out the hunters
        ASSAULT_29_START           = 7375, -- Commencing <assault>! Objective: Rescue Princess Kadjaya
        ASSAULT_30_START           = 7376, -- Commencing <assault>! Objective: Defeat Black Shuck
        TIME_TO_COMPLETE           = 7407, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED             = 7408, -- The mission has failed. Leaving area.
        RUNE_UNLOCKED_POS          = 7409, -- Mission objective completed. Unlocking Rune of Release ([A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z]-#).
        RUNE_UNLOCKED              = 7410, -- Mission objective completed. Unlocking Rune of Release.
        ASSAULT_POINTS_OBTAINED    = 7411, -- You gain <number> [Assault point/Assault points]!
        TIME_REMAINING_MINUTES     = 7412, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS     = 7413, -- Time remaining: <number> [second/seconds] (Earth time).
        FADES_INTO_NOTHINGNESS     = 7414, -- The <keyitem> fades into nothingness...
        PARTY_FALLEN               = 7415, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].

        -- Lebros Supplies (22) NPC dialogue.
        YAZUHMA_GRANT_1             = 7430, -- This should keep a whole unit filled up for a while.
        YAZUHMA_GRANT_2             = 7429, -- The advance unit is depending on these provisions. Don't let them down!
        YAZUHMA_ALREADY_HAVE_RATION = 7428, -- Why don't you deliver the rations I already gave you?
        YAZUHMA_STILL_STARVING      = 7431, -- (7-12 left) There are still brave soldiers starving out there!
        YAZUHMA_HALFWAY             = 7432, -- (4-6 left) It looks like about half of the advance unit has received their rations.
        YAZUHMA_DENT                = 7433, -- (2-3 left, unconfirmed) You've made a decent dent in my pile of rations.
        YAZUHMA_LEFTOVER            = 7434, -- (1 left, unconfirmed) That's strange, there are some rations left over.
        YAZUHMA_ALL_DONE            = 7435, -- Thanks to you, the advance unit is now completely provisioned. Excellent work!
        YAZUHMA_TEMP_ITEM_OBTAINED  = 7209, -- <entity> obtains the temporary item: <item>! (needs showName=true for player name)
        IMPERIAL_STORMER_THANKS     = 7424, -- Thank Zahak you're here. I was about to start eating my boots!
        IMPERIAL_STORMER_MORE       = 7425, -- You brought more supplies? Well, you can never have too much...
        IMPERIAL_STORMER_PROVISIONS = 7426, -- Have you brought the provisions?
        IMPERIAL_STORMER_FULL_BELLY = 7427, -- There's nothing like a full belly to put the power back in your sword swing. I pity the next monster that crosses my path!

        -- Evade and Escape (24) Switch messages -- confirmed real.
        SWITCH_ACTIVATED  = 7436, -- A switch lights up on the device...\nIt is flickering faintly...
        SWITCH_EXPIRING   = 7437, -- The switch looks like it may cut out at any moment...
        SWITCH_NOTHING    = 7438, -- Nothing happens... The other switches appear to have shut down as well...
        SWITCH_REFRESHED  = 7439, -- The switch on the device is glowing brightly.\nYou don't think it will fade any time soon.
    },

    mob = {
        -- Excavation Duty
        [21] =
        {
            VOLCANIC_BOMB1   = 17035265,
            VOLCANIC_BOMB2   = 17035266,
            VOLCANIC_BOMB3   = 17035267,
            QIQIRN_CERAMIST1 = 17035268,
            QIQIRN_VOLCANIS1 = 17035269,
            VOLCANIC_BOMB4   = 17035270,
            VOLCANIC_BOMB5   = 17035271,
            VOLCANIC_BOMB6   = 17035272,
            QIQIRN_CERAMIST2 = 17035273,
            QIQIRN_VOLCANIS2 = 17035274,
            QIQIRN_VOLCANIS3 = 17035275,
            QIQIRN_CERAMIST3 = 17035276,
            QIQIRN_CERAMIST4 = 17035277,
            QIQIRN_CERAMIST5 = 17035278,
            QIQIRN_VOLCANIS4 = 17035279,
            VOLCANIC_BOMB7   = 17035280,
            VOLCANIC_BOMB8   = 17035281,
            BRITTLE_ROCK1    = 17035282,
            BRITTLE_ROCK2    = 17035284,
            BRITTLE_ROCK3    = 17035286,
            BRITTLE_ROCK4    = 17035288,
            BRITTLE_ROCK5    = 17035290,
            -- A dup-entity theory (spawning a second, fully-identical overlapping mob per rock via
            -- BRITTLE_ROCK*_DUP entries) was real, capture-confirmed data, but live-testing showed
            -- it made rocks 1-3 unreliable (walk-past-able while alive) without ever fixing 4/5 --
            -- reverted. See Brittle_Rock.lua and Assault_Fix_Log.md for the full investigation trail.
        },
        -- Lebros Suplies
        [22] =
        {
            CRIMSON_ERUCA1 = 17035304,
            CRIMSON_ERUCA2 = 17035305,
            CRIMSON_ERUCA3 = 17035306,
            CRIMSON_ERUCA4 = 17035307,
            CRIMSON_ERUCA5 = 17035308,
            CRIMSON_ERUCA6 = 17035309,
        },
        -- Troll Figitives
        [23] =
        {
            TROLL_FUGITIVE1  = 17035310,
            TROLL_FUGITIVE2  = 17035311,
            TROLL_FUGITIVE3  = 17035312,
            TROLL_FUGITIVE4  = 17035313,
            TROLL_FUGITIVE5  = 17035314,
            TROLL_FUGITIVE6  = 17035315,
            TROLL_FUGITIVE7  = 17035316,
            TROLL_FUGITIVE8  = 17035317,
            TROLL_FUGITIVE9  = 17035318,
            TROLL_FUGITIVE10 = 17035319,
            TROLL_FUGITIVE11 = 17035320,
            TROLL_FUGITIVE12 = 17035321,
            TROLL_FUGITIVE13 = 17035322,
            TROLL_FUGITIVE14 = 17035323,
            TROLL_FUGITIVE15 = 17035324,
        },
        -- Evade and Escape
        [24] =
        {
            DAHAK1 = 17035325,
            DAHAK2 = 17035326,
            DAHAK3 = 17035327,
        },
        -- Siegemaster Assassination
        [25] =
        {
            OLD_TROLL1 = 17035328,
            OLD_TROLL2 = 17035329,
            OLD_TROLL3 = 17035330,
            OLD_TROLL4 = 17035331,
            OLD_TROLL5 = 17035332,
            OLD_TROLL6 = 17035333,
            OLD_TROLL7 = 17035334,
            OLD_TROLL8 = 17035335,
        },
        -- These 16 real NPCs used to sit in a mistaken nested `[26]` sub-table (believed to be
        -- Apkallu Breeding, mission 26). Both consuming scripts (mobs/Lebros_Apkallu.lua's
        -- MALE_IDS, mobs/Qiqirn_Eggler.lua's female list) actually read them as FLAT
        -- `ID.npc.LEBROS_APKALLU_*` keys, not `ID.npc[26].*` -- so every reference was silently
        -- resolving to nil (isMale() always false, qiqirnIds/female-id lists full of nils) and Egg
        -- Conservation's real mob AI never actually ran correctly. A fresh re-check of the real
        -- "Apkallu Breeding (Thris)" capture's own NPCLogger db also confirmed these ids
        -- (17035380-395) are NOT Apkallu Breeding's entities at all -- that mission's real pairing
        -- NPCs are a completely different id range, 17035337-17035351 (see npc_list.sql and
        -- instance_entities.sql). Flattened back to top-level (matching how the consuming scripts
        -- actually read them, and matching Egg Conservation's real ownership: mob_groups.sql
        -- groupid 23). Male/female split from real data (2 independent captures, NPCLogger Flags3
        -- field cleanly splits 380/387/388 from the other 13) -- 3-large/13-small fits
        -- "larger = male, aid the fight" vs "smaller = female, must be protected" far better than
        -- an arbitrary split would. See mob_groups.sql groupid 23.
        LEBROS_APKALLU_MALE1    = 17035380,
        LEBROS_APKALLU_MALE2    = 17035387,
        LEBROS_APKALLU_MALE3    = 17035388,
        LEBROS_APKALLU_FEMALE1  = 17035381,
        LEBROS_APKALLU_FEMALE2  = 17035382,
        LEBROS_APKALLU_FEMALE3  = 17035383,
        LEBROS_APKALLU_FEMALE4  = 17035384,
        LEBROS_APKALLU_FEMALE5  = 17035385,
        LEBROS_APKALLU_FEMALE6  = 17035386,
        LEBROS_APKALLU_FEMALE7  = 17035389,
        LEBROS_APKALLU_FEMALE8  = 17035390,
        LEBROS_APKALLU_FEMALE9  = 17035391,
        LEBROS_APKALLU_FEMALE10 = 17035392,
        LEBROS_APKALLU_FEMALE11 = 17035393,
        LEBROS_APKALLU_FEMALE12 = 17035394,
        LEBROS_APKALLU_FEMALE13 = 17035395,
        -- Apkallu Breeding (mission 26) real pairing-minigame NPCs -- 13 of 16 claimed ids resolved
        -- a position in the real "Apkallu Breeding (Thris)" capture's NPCLogger db
        -- (17035336/17035339/17035341 unconfirmed, left as 0,0,0 stubs in npc_list.sql, not
        -- registered to the instance). Pairing/compatibility mechanic itself still not built -- see
        -- instances/apkallu_breeding.lua's header.
        [26] =
        {
            APKALLU1  = 17035337,
            APKALLU2  = 17035338,
            APKALLU3  = 17035340,
            APKALLU4  = 17035342,
            APKALLU5  = 17035343,
            APKALLU6  = 17035344,
            APKALLU7  = 17035345,
            APKALLU8  = 17035346,
            APKALLU9  = 17035347,
            APKALLU10 = 17035348,
            APKALLU11 = 17035349,
            APKALLU12 = 17035350,
            APKALLU13 = 17035351,
        },
        -- Wamoura Farm Raid Assault
        [27] =
        {
            RANCH_WAMOURA1  = 17035359,
            RANCH_WAMOURA2  = 17035360,
            RANCH_WAMOURA3  = 17035361,
            RANCH_WAMOURA4  = 17035362,
            RANCH_WAMOURA5  = 17035363,
            RANCH_WAMOURA6  = 17035365,
            RANCH_WAMOURA7  = 17035367,
            RANCH_WAMOURA8  = 17035368,
            RANCH_WAMOURA9  = 17035369,
            RANCH_WAMOURA10 = 17035370,
            RANCH_WAMOURA11 = 17035371,
            RANCH_WAMOURA12 = 17035372,
            RANCH_WAMOURA13 = 17035376,
            RANCH_WAMOURA14 = 17035377,
            RANCH_WAMOURA15 = 17035378,
        },
        -- The 2 previously-unwired Ranch Wamouracampa (17035373/17035374) are the FFXI Atlas map's
        -- cyan "share a spawn (only one will spawn)" markers -- both sit at the mission's 2
        -- northernmost branch points. Real mechanic (user-confirmed against the atlas map): only
        -- ONE of these two ever spawns per instance, forcing the player to gamble which northern
        -- branch to check rather than clearing both for free. Kept separate from mob[27] above
        -- since that whole table is unconditionally spawned by the onInstanceCreated loop -- these
        -- two need random, mutually exclusive selection instead. Kill-all-15 already excludes these
        -- (they're bonus/optional, not required for mission completion), confirmed by real capture
        -- per this instance's header.
        --
        -- 17035373 (northeast branch, 544.29,-40.47,346.082) sits past a known corridor blocker in
        -- this instance and is NOT usable yet. Left in the candidate list (commented out) so it's
        -- not lost, but excluded from the active pool -- do not re-add until the blocker is
        -- resolved (check the mission's own tracker/instance header for that fix's status first).
        WAMOURACAMPA_SHARED_SPAWN_27 =
        {
            -- 17035373, -- 544.29,-40.47,346.082 -- northeast branch -- BLOCKED, see comment above
            17035374, -- 480.59,-46.44,423.104 -- northwest branch
            -- 3rd real candidate, user-supplied real !logpos (previously a genuine (0,0,0,0) unset
            -- placeholder in mob_spawn_points.sql, no capture on disk ever showed it spawning).
            -- Different mob_groups id (14, not 13) from its 2 siblings -- real, just a distinct
            -- level range, not a data error.
            17035375, -- 354.8704,-60.0237,579.3699
        },
        -- Egg Conservation: 6 real Qiqirn Eggler. Real objective text (ASSAULT_28_START, "Drive out
        -- the hunters") fits the egglers well. Modeled as kill-all-6. This block used to also carry
        -- 16 LEBROS_APKALLU_* constants -- those are real, but belong to Apkallu Breeding (mission
        -- 26), not this mission (moved to the [26] block above, see its comment).
        [28] =
        {
            QIQIRN_EGGLER1 = 17035396,
            QIQIRN_EGGLER2 = 17035397,
            QIQIRN_EGGLER3 = 17035398,
            QIQIRN_EGGLER4 = 17035399,
            QIQIRN_EGGLER5 = 17035400,
            QIQIRN_EGGLER6 = 17035401,
        },
        -- Operation: Black Pearl: a real Thris Nov 2025 capture resolved two things --
        -- mob_spawn_points.sql's own "-- ids 17035467 to 17035469 are NPCs" comment marks the real
        -- end of this block, well after Crimson Eruca/Vulcanian Bomb, so they DO belong here (an
        -- earlier pass had wrongly cut this block off at the Wamouracampa group, 18). The capture
        -- also resolved the ASSAULT_29_START ("Rescue Princess Kadjaya") mismatch: this is a
        -- boss-kill mission (kill Jorporbor the Hellraker, who aggros when you approach the captive
        -- Kadjaya), NOT a kill-all -- the 64 trash mobs (4 Troll Combatant, 20 Wamouracampa, 20
        -- Crimson Eruca, 20 Vulcanian Bomb) are ambient camp guards, same pattern as Breaking
        -- Morale's corrected build. A duplicate empty `[29] = {}` block used to sit directly below
        -- this one in the same table constructor -- since later table-constructor keys win in Lua,
        -- that silently nulled out this entire real mob list, meaning Operation: Black Pearl
        -- spawned ZERO mobs. Removed as a real bug independent of the capture findings.
        [29] =
        {
            JORPORBOR_THE_HELLRAKER = 17035402,
            TROLL_COMBATANT1        = 17035403,
            TROLL_COMBATANT2        = 17035404,
            TROLL_COMBATANT3        = 17035405,
            TROLL_COMBATANT4        = 17035406,
            WAMOURACAMPA1           = 17035407,
            WAMOURACAMPA2           = 17035408,
            WAMOURACAMPA3           = 17035409,
            WAMOURACAMPA4           = 17035410,
            WAMOURACAMPA5           = 17035411,
            WAMOURACAMPA6           = 17035412,
            WAMOURACAMPA7           = 17035413,
            WAMOURACAMPA8           = 17035414,
            WAMOURACAMPA9           = 17035415,
            WAMOURACAMPA10          = 17035416,
            WAMOURACAMPA11          = 17035417,
            WAMOURACAMPA12          = 17035418,
            WAMOURACAMPA13          = 17035419,
            WAMOURACAMPA14          = 17035420,
            WAMOURACAMPA15          = 17035421,
            WAMOURACAMPA16          = 17035422,
            WAMOURACAMPA17          = 17035423,
            WAMOURACAMPA18          = 17035424,
            WAMOURACAMPA19          = 17035425,
            WAMOURACAMPA20          = 17035426,
            CRIMSON_ERUCA1          = 17035427,
            CRIMSON_ERUCA2          = 17035428,
            CRIMSON_ERUCA3          = 17035429,
            CRIMSON_ERUCA4          = 17035430,
            CRIMSON_ERUCA5          = 17035431,
            CRIMSON_ERUCA6          = 17035432,
            CRIMSON_ERUCA7          = 17035433,
            CRIMSON_ERUCA8          = 17035434,
            CRIMSON_ERUCA9          = 17035435,
            CRIMSON_ERUCA10         = 17035436,
            CRIMSON_ERUCA11         = 17035437,
            CRIMSON_ERUCA12         = 17035438,
            CRIMSON_ERUCA13         = 17035439,
            CRIMSON_ERUCA14         = 17035440,
            CRIMSON_ERUCA15         = 17035441,
            CRIMSON_ERUCA16         = 17035442,
            CRIMSON_ERUCA17         = 17035443,
            CRIMSON_ERUCA18         = 17035444,
            CRIMSON_ERUCA19         = 17035445,
            CRIMSON_ERUCA20         = 17035446,
            VULCANIAN_BOMB1         = 17035447,
            VULCANIAN_BOMB2         = 17035448,
            VULCANIAN_BOMB3         = 17035449,
            VULCANIAN_BOMB4         = 17035450,
            VULCANIAN_BOMB5         = 17035451,
            VULCANIAN_BOMB6         = 17035452,
            VULCANIAN_BOMB7         = 17035453,
            VULCANIAN_BOMB8         = 17035454,
            VULCANIAN_BOMB9         = 17035455,
            VULCANIAN_BOMB10        = 17035456,
            VULCANIAN_BOMB11        = 17035457,
            VULCANIAN_BOMB12        = 17035458,
            VULCANIAN_BOMB13        = 17035459,
            VULCANIAN_BOMB14        = 17035460,
            VULCANIAN_BOMB15        = 17035461,
            VULCANIAN_BOMB16        = 17035462,
            VULCANIAN_BOMB17        = 17035463,
            VULCANIAN_BOMB18        = 17035464,
            VULCANIAN_BOMB19        = 17035465,
            VULCANIAN_BOMB20        = 17035466,
        },
        -- Better Than One: Black Shuck (real coordinates, the boss) + 6 Nocuous Inferno
        -- (obstacles). Real objective text matches exactly ("Defeat Black Shuck") -- singular
        -- target, same pattern as Sagelord Elimination/Shooting Down the Baron. Only Black Shuck's
        -- death is tracked; the Infernos are ambient, unscripted.
        [30] =
        {
            BLACK_SHUCK = 17035470,
            NOCUOUS_INFERNO1 = 17035471,
            NOCUOUS_INFERNO2 = 17035472,
            NOCUOUS_INFERNO3 = 17035473,
            NOCUOUS_INFERNO4 = 17035474,
            NOCUOUS_INFERNO5 = 17035475,
            NOCUOUS_INFERNO6 = 17035476,
        }
    },

    npc =
    {
        -- Cross-referenced this whole block against the real Lebros Cavern LC capture's own
        -- PathLog (per-entity folders, ground truth for both id AND real letter name). Found a
        -- consistent off-by-one-too-low bug in an earlier pass for every entry this capture covers
        -- (id was always 1 less than the real PathLog folder's id) -- corrected below. Entries this
        -- capture doesn't cover (_1r5/_1ra/_1rf/_1rt/_1rv/_ir4) are left unverified, not blindly
        -- extrapolated -- see Assault_Issue_Tracker.md.
        _1r5 = 17035509, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        _1ra = 17035514, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        _1rf = 17035519, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        -- _1ro moved below -- an earlier value here (17035529, "was really _1rn's id") was wrong,
        -- see the corrected definition further down.
        _1rt = 17035533, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        _1rv = 17035535, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        _ir4 = 17035544, -- filled from real capture data, was NOT_CAPTURED -- unverified by this pass
        -- A prior "correction" that shifted this entire _irb..._irk block +1 was itself wrong -- the
        -- original mapping was already right. Confirmed conclusively: the shifted value for _irk
        -- (17035561) pointed at this zone's `blank` terminator row, not a real entity at all -- and
        -- every reverted value below matches its corresponding npc_list row name exactly
        -- (_irb->_jrb, _irc->_jrc, etc). User confirmed 17035551 is the correct _irb value.
        _irb = 17035551,
        _irc = 17035552,
        _ird = 17035553,
        _ire = 17035554,
        _irf = 17035555,
        _irg = 17035556,
        _iri = 17035557,
        _irh = 17035558,
        _irj = 17035559,
        _irk = 17035560, -- unreferenced anywhere in IDs.lua for a while, despite being registered
        -- to instance 24 -- its npc_list row was still a NOT_CAPTURED stub until real PathLog data
        -- filled it in.
        ANCIENT_LOCKBOX = 17035478,
        RUNE_OF_RELEASE = 17035479,
        YAZUHMA         = 17035480,
        -- Evade and Escape (mission 24): real switch mechanic, see npc_list.sql for the full
        -- writeup and position caveats.
        SWITCH1         = 17035481,
        SWITCH2         = 17035482,
        SWITCH3         = 17035483,
        -- Id/name confirmed against the user's authoritative list and shift-corrected capture data
        -- (raw capture id = current id + 1).
        _1r3            = 17035507,
        _1r4            = 17035508,
        _1r6            = 17035510,
        _1r7            = 17035511,
        _1r8            = 17035512,
        _1r9            = 17035513,
        _1rb            = 17035515,
        _1rc            = 17035516,
        _1rd            = 17035517,
        _1rg            = 17035520,
        -- _1rh/_1ri and (below) _1ro/_1rp were each off by +1, confirmed against the user's
        -- authoritative full id/name list for this range and against their own raw npc_list row
        -- names (_1rh's row is 17035521, not 17035522, etc).
        _1rh            = 17035521,
        _1ri            = 17035522,
        _1rl            = 17035525,
        _1rm            = 17035526,
        _1rn            = 17035527,
        _1ro            = 17035528, -- corrected (was 17035529 -- also retracts an earlier "was
        -- really _1rn's id" claim on that old value, which was wrong)
        _1rp            = 17035529, -- corrected (was 17035530)
        _1rs            = 17035532,
        _1ru            = 17035534,
        _1rw            = 17035536,
        _1rx            = 17035537,
        _1ry            = 17035538,
        _1rz            = 17035539,
        _ir0            = 17035540,
        _ir1            = 17035541,
        _ir2            = 17035542,
        _ir3            = 17035543,
        _ir5            = 17035545,
        _ir6            = 17035546,
        _ir7            = 17035547,
        _ir8            = 17035548,
        _ir9            = 17035549,
        _ira            = 17035550,
        -- Removed duplicate/stale _irc/_ire definitions that used to sit here (17035553/17035555,
        -- wrong values) -- they came AFTER the corrected definitions earlier in this table and were
        -- silently overriding them (Lua table literals use last-value-wins for a repeated key). The
        -- correct values (17035552/17035554) are set once, earlier in this file.
        QIQIRN_MINE1    = 17037312,
        QIQIRN_MINE2    = 17037313,
        QIQIRN_MINE3    = 17037314,
        QIQIRN_MINE4    = 17037315,
        IMPERIAL_STORMER1  = 17035292,
        IMPERIAL_STORMER2  = 17035293,
        IMPERIAL_STORMER3  = 17035294,
        IMPERIAL_STORMER4  = 17035295,
        IMPERIAL_STORMER5  = 17035296,
        IMPERIAL_STORMER6  = 17035297,
        IMPERIAL_STORMER7  = 17035298,
        IMPERIAL_STORMER8  = 17035299,
        IMPERIAL_STORMER9  = 17035300,
        IMPERIAL_STORMER10 = 17035301,
        IMPERIAL_STORMER11 = 17035302,
        IMPERIAL_STORMER12 = 17035303,
    }
}

return Lebros
