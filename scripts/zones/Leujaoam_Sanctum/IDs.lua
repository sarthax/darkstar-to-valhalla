-----------------------------------
-- Area: Leujaoam_Sanctum
-----------------------------------

Leujaoam =
{
    text = {
        -- This whole block was off by exactly -1, confirmed directly against this zone's real
        -- client dialog table via the dat-extractor tool (cache: leujaoam_sanctum_6489.json) --
        -- same class of client-version text-ID drift found and fixed elsewhere this session, just
        -- never caught for this specific shared block since nothing in this zone used it until
        -- Orichalcum Survey. Confirmed zero other Leujaoam Sanctum scripts reference any of these
        -- constants, so the correction is fully scoped to this block.
        ITEM_CANNOT_BE_OBTAINED    = 6382, -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE = 6386, -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        -- User-reported live: ??? items from the Ancient Lockbox displayed as "obtains the
        -- temporary item: ..." even though they are permanent items. Root cause: ITEM_OBTAINED was
        -- set to 7526, the SAME temp-item message used by TEMP_ITEM_OBTAINED below (a copy/paste
        -- collision from when the Orichalcum Survey block was added). Real "Obtained: <item>."
        -- (permanent) is 6388, confirmed via mission_toolkit.py -- same value already correct in
        -- Mamool Ja Training Grounds' IDs.lua.
        ITEM_OBTAINED              = 6388, -- Obtained: <item>.
        GIL_OBTAINED               = 6389, -- Obtained <number> gil
        CANNOT_CARRY_ANYMORE       = 6998, -- You cannot carry any more of that item.
        KEYITEM_OBTAINED           = 6391, -- Obtained key item: <keyitem>.
        KEYITEM_LOST               = 6392, -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL        = 6393, -- You do not have enough gil.
        ITEMS_OBTAINED             = 6397, -- You obtain <number> <item>!
        -- Real text for the "failed mining roll" flavor outcome (previously an untracked cosmetic
        -- gap in Mining_Point.lua -- see Assault_Issue_Tracker.md). This id (7524) was already
        -- correct in the ASSAULT block below and independently confirmed live in-game, so it's not
        -- part of the -1 shift above.
        CARRIED_OVER_POINTS        = 7000, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY    = 7001, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER               = 7002, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        -- Block below was off by exactly +1, verified against a real client dialog table dump for
        -- this zone. Uniform shift here (unlike Lebros, which also had RUNE_UNLOCKED_POS missing
        -- outright).
        ASSAULT_01_START           = 7447, -- Commencing <assault>! Objective: Remove all threats
        ASSAULT_02_START           = 7448, -- Commencing <assault>! Objective: Discover orichalcum ore
        ASSAULT_03_START           = 7449, -- Commencing <assault>! Objective: Protect the professor
        ASSAULT_04_START           = 7450, -- Commencing <assault>! Objective: Protect the vegetation
        ASSAULT_05_START           = 7451, -- Commencing <assault>! Objective: Buy black sheep
        ASSAULT_06_START           = 7452, -- Commencing <assault>! Objective: Retrieve the supplies
        ASSAULT_07_START           = 7453, -- Commencing <assault>! Objective: Become a test subject
        ASSAULT_08_START           = 7454, -- Commencing <assault>! Objective: Retrieve the OGMA
        ASSAULT_09_START           = 7455, -- Commencing <assault>! Objective: Defeat Raubahn
        ASSAULT_10_START           = 7456, -- Commencing <assault>! Objective: Defeat the count

        -- Orichalcum Survey (Mission 2)
        PLAYER_OBTAINS_TEMP_ITEM  = 7310, -- Obtained temporary item: <item>!
        YOU_DO_NOT_HAVE_A_PICKAXE = 7300, -- You do not have a pickaxe.
        MINING_FIND_NOTHING       = 7524, -- You find nothing.
        FINDS_ITEM                = 7525, -- <name> find <item>!
        TEMP_ITEM_OBTAINED        = 7526, -- obtains the temporary item: <item>.
        MINING_TOOL_BROKE_TEMP_ITEM = 7527, -- Your <item> (temporary item) breaks!
        MINING_POSSIBLE           = 7528, -- Mining is possible here if you have a <item> temporary item).
        MOVE_CLOSER               = 7529, -- You must move closer to the target.
        CANNOT_MINE_NOW           = 7530, -- You cannot mine here right now. -- used for worm spawn or when holding ore
        MINING_TOOL_BROKE         = 7531, -- Your <item> breaks! You don't think you can mine with it anymore...
        MULWAHAH_PICKAXE_GRANT     = 7536, -- Take this. If you come across a chunk of orichalcum ore, bring it directly back to me.
        MULWAHAH_ALREADY_HAVE_PICKAXE = 7535, -- You only get as many pickaxes as you need. Now, get moving
        MULWAHAH_ORE_TURNED_IN_1  = 7532, -- You found some? Let's take a look then...
        MULWAHAH_ORE_TURNED_IN_2  = 7533, -- Amazing...  Look at it shine! This is definitely <item>
        MULWAHAH_ORE_TURNED_IN_3  = 7534, -- The rumors were true! Excellent work!
        MULWAHAH_GO_AWAY_1  = 7537, -- I have to organize a mining team as soon as possible...
        MULWAHAH_GO_AWAY_2  = 7538, -- Hm? Are you still here?  Your work is done.

        -- Escort Professor Chanoix (mission 3) real flavor dialogue.
        CHANOIX_LINE1  = 7539, -- Oh dear... There was no such branching of passages on the map I was given...
        CHANOIX_LINE2  = 7540, -- Atelloune was right. The map the society sent me is barely fit for starting a fire...
        CHANOIX_LINE3  = 7541, -- I seem to have taken a wrong turning somewhere...
        CHANOIX_LINE4  = 7542, -- The map says it's this way, but...
        CHANOIX_LINE5  = 7545, -- I'm quite out of breath... I think I'll rest for a spell and take another look at the map.
        CHANOIX_LINE6  = 7546, -- Time to move, lazy bones. We can't be sitting here all day!
        CHANOIX_LINE7  = 7547, -- Does anyone happen to know the way from here?
        CHANOIX_LINE8  = 7549, -- Hmmm... Maybe we should have taken a left back at the...
        CHANOIX_LINE9  = 7552, -- Right, then. Shall we have a bit of a poke around?
        CHANOIX_LINE10 = 7553, -- Hmmm... I guess this isn't the place...
        CHANOIX_LINE12 = 7543, -- Oh dear... (short)
        CHANOIX_LINE13 = 7544, -- I was certain I was on the right track...
        CHANOIX_LINE14 = 7548, -- I guess not... Well, come on then. Don't fall behind.
        CHANOIX_LINE15 = 7550, -- No, this is definitely the right way.
        CHANOIX_LINE16 = 7551, -- All right now, who was it? Who said this was the right way?
        CHANOIX_ARRIVAL1 = 7554, -- Hello!? Something huge...beneath the ice...
        CHANOIX_ARRIVAL2 = 7555, -- This is it! This is what I've been searching for!
        CHANOIX_ARRIVAL3 = 7556, -- And look at the state of preservation... Almost as if it were still alive...
        CHANOIX_ARRIVAL4 = 7557, -- I must take a sample back to my laboratory at once. I am most grateful for your assistance.

        -- Shanarha Grass Conservation (mission 4) real Vegetation examine text -- found via a Thris
        -- Nov2025 capture, whose own CapLog labels these +15 drifted (showed 7573-7576,
        -- dat-extractor-confirmed real ids are 7558-7561). Confirmed as a genuine monotonic 4-stage
        -- decay by tracing one specific Vegetation entity (17060050) across the capture's full
        -- timeline -- see mobs/Coney.lua and npcs/Vegetation.lua.
        VEGETATION_UNTOUCHED = 7558, -- There is some shanarha grass growing here. It is still untouched.
        VEGETATION_CHEWED    = 7559, -- ...It looks like a rabbit has been chewing on some of it.
        VEGETATION_TORN      = 7560, -- ...It looks like the rabbits have torn into most of it.
        VEGETATION_DESTROYED = 7561, -- ...The rabbits have almost completely destroyed it.

        -- Supplies Recovery (mission 6) -- user-provided real wiki objective/walkthrough + verified
        -- against this project's own dat-extractor cache by TEXT, not trusted from the capture's
        -- raw MesNum (which was drifted -- capture reported 7626/7627 for Kuihlud's lines, but
        -- those 2 real ids decode to unrelated "You obtain <item>" template text in our own dats;
        -- real ids found by searching the cache for the actual dialogue text instead).
        KUIHLUD_INTRO      = 7611, -- "I am Kuihlud of the Inexorables... Our unit is clearly superior."
        KUIHLUD_REMINDER   = 7612, -- "No matter what it takes, you must recover more supplies than the Immortals..."
        KUIHLUD_WIN        = 7613, -- "Excellent work, soldier! You have recovered all the supplies..."
        IMMORTALS_SUPPLY_COUNT = 7610, -- "The Immortals have recovered <N> supply package(s) thus far." (numeric param)
        NO_SUPPLIES_OBTAINED   = 7609, -- "You did not receive any supplies."
        -- User-supplied real dialog table dump, cross-checked against dat-extractor by exact text
        -- and correlated against 6 real captures' raw MesNum context (same -15 drift as this
        -- mission's other text): Gasharyad/Salimuhl taunt lines. GASHARYAD_TAUNT_GLORY fires paired
        -- with SALIMUHL_TAUNT_KEHEHE once at mission start, and also fires solo later, correlated
        -- with the Immortals' own supply count incrementing. GASHARYAD_TAUNT_WIN/
        -- SALIMUHL_TAUNT_NO_CHALLENGE always fire together, correlated with an Imp dying while
        -- Gasharyad/Salimuhl were fighting it. See npcs/Kuihlud.lua and
        -- mobs/Imp.lua/npcs/supplies_recovery_common.lua for the wiring.
        GASHARYAD_TAUNT_GLORY         = 7614, -- "Heh heh heh... Glory to the Immortals!"
        SALIMUHL_TAUNT_KEHEHE         = 7615, -- "Kehehe! Look at the little mercenary trying to play with the Immortals...a pathetic sight."
        GASHARYAD_TAUNT_WIN           = 7616, -- "Haha! This day belongs to the Immortals!"
        SALIMUHL_TAUNT_NO_CHALLENGE   = 7617, -- "Ho hum...no challenge at all!"

        -- Imperial Code (mission 8): both real, confirmed via dat-extractor full-table search.
        DANZO_ENGAGE  = 7646, -- Impressive... You have done well in finding me...
        DANZO_DEATH   = 7647, -- Hence my boiling blood / Flowers bloom on foreign shores / Under the spring moon
        -- UNCONFIRMED: "Rinpyotosha!" (a real ninjutsu incantation) never actually appears anywhere
        -- in the real CapLog. https://ffxiclopedia.fandom.com/wiki/Rinpyotosha -- when used is not
        -- established. Not wired into any mob file until that's confirmed.
        DANZO_RINPYOTOSHA = 7648,
        DANZO_TAUNT   = 7649, -- May the light of my ancestors guide my blade to your throats!
        OKO_ENGAGE    = 7650, -- Come, come, little hare. Come dance with the fox.
        OKO_DEATH     = 7651, -- And so the hare...outsmarts...the fox...
        OKO_TAUNT     = 7652, -- Playtime is over, my dear!
        OKO_DEATH1     = 7653, -- Will the fox live happily ever after?
        SAIZO_ENGAGE  = 7654, -- Two weeks until retirement... "Don't worry," Danzo says... "Nothing can go wrong," Oko says...
        SAIZO_DEATH   = 7655, -- Remember when you said...you'd kill me last...?
        SAIZO_TERMINATE = 7656, -- Terminate!
        SAIZO_TAUNT   = 7657, -- I think you need to let off some steam!
        SAIZO_LOW_HP  = 7658, -- Two weeks... Two...weeks...!
        EXAMINE_NOTHING = 7659, -- The area is littered with junk, but you find nothing of interest.
        OGMA_RETRIEVED = 7660, -- You retrieve the OGMA!
        -- Shared Objective Dialog
        TIME_TO_COMPLETE           = 7507, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED             = 7508, -- The mission has failed. Leaving area.
        RUNE_UNLOCKED_POS          = 7509, -- Mission objective completed. Unlocking Rune of Release ([A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z]-#).
        RUNE_UNLOCKED              = 7510, -- Mission objective completed. Unlocking Rune of Release.
        ASSAULT_POINTS_OBTAINED    = 7511, -- You gain <number> [Assault point/Assault points]!
        TIME_REMAINING_MINUTES     = 7512, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS     = 7513, -- Time remaining: <number> [second/seconds] (Earth time).
        FADES_INTO_NOTHINGNESS     = 7514, -- The <keyitem> fades into nothingness...
        PARTY_FALLEN               = 7515, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
    },

    mob =
    {
        -- Leujaoam Cleansing
        [1] =
        {
            LEUJAOAM_WORM1  = 17059841,
            LEUJAOAM_WORM2  = 17059842,
            LEUJAOAM_WORM3  = 17059843,
            LEUJAOAM_WORM4  = 17059844,
            LEUJAOAM_WORM5  = 17059845,
            LEUJAOAM_WORM6  = 17059846,
            LEUJAOAM_WORM7  = 17059847,
            LEUJAOAM_WORM8  = 17059848,
            LEUJAOAM_WORM9  = 17059849,
            LEUJAOAM_WORM10 = 17059850,
            LEUJAOAM_WORM11 = 17059851,
            LEUJAOAM_WORM12 = 17059852,
            LEUJAOAM_WORM13 = 17059853,
            LEUJAOAM_WORM14 = 17059854,
            LEUJAOAM_WORM15 = 17059855,
        },
        -- Orichalcum Survey -- real data found unwired in sql/mob_spawn_points.sql, right after the
        -- block above. User confirmed via a real retail walkthrough (FFXIclopedia) plus direct
        -- confirmation: the mining hazard is a real NM named Mineral Eater.
        [2] =
        {
            QIQIRN_MINER1  = 17059856,
            QIQIRN_MINER2  = 17059857,
            QIQIRN_MINER3  = 17059858,
            QIQIRN_MINER4  = 17059859,
            QIQIRN_MINER5  = 17059860,
            QIQIRN_MINER6  = 17059861,
            QIQIRN_MINER7  = 17059862,
            QIQIRN_MINER8  = 17059863,
            MINERAL_EATER  = 17059864,
            MINERAL_EATER1  = 17059865,
            MINERAL_EATER2  = 17059866,
            MINERAL_EATER3  = 17059867,
            MINERAL_EATER4  = 17059868,
            MINERAL_EATER5  = 17059869,
            MINERAL_EATER6  = 17059870,
            MINERAL_EATER7  = 17059871,
            MINERAL_EATER8  = 17059872,
            MINERAL_EATER9  = 17059873,
        },
        -- Escort Professor Chanoix -- found unwired in sql/mob_spawn_points.sql under an explicit
        -- "-- Escort Professor Chanoix" comment. CLAVAUERT_B_CHANOIX is the escort target himself,
        -- using a Clavauert (elemental) model -- no unique human model was ever captured for him,
        -- so this is what the original data extraction left to work with.
        [3] =
        {
            CLAVAUERT_B_CHANOIX = 17059874,
            FROZEN_BONES1       = 17059875,
            FROZEN_BONES2       = 17059876,
            FROZEN_BONES3       = 17059877,
            FROZEN_BONES4       = 17059878,
            FROZEN_BONES5       = 17059879,
            FROZEN_BONES6       = 17059880,
            FROZEN_BONES7       = 17059881,
            FROZEN_BONES8       = 17059882,
            FROZEN_BONES9       = 17059883,
            GELID_BHOOT1        = 17059884,
            GELID_BHOOT2        = 17059885,
            GELID_BHOOT3        = 17059886,
            GELID_BHOOT4        = 17059887,
            GELID_BHOOT5        = 17059888,
            GELID_BHOOT6        = 17059889,
            GELID_BHOOT7        = 17059890,
        },
        -- Shanarha Grass Conservation
        [4] =
        {
            CONEY1  = 17059891,
            CONEY2  = 17059892,
            CONEY3  = 17059893,
            CONEY4  = 17059894,
            CONEY5  = 17059895,
            CONEY6  = 17059896,
            CONEY7  = 17059897,
            CONEY8  = 17059898,
            CONEY9  = 17059899,
            CONEY10 = 17059900,
            CONEY11 = 17059901,
            CONEY12 = 17059902,
            CONEY13 = 17059903,
            CONEY14 = 17059904,
            CONEY15 = 17059905,
            CONEY16 = 17059906,
            CONEY17 = 17059907,
            CONEY18 = 17059908,
            CONEY19 = 17059909,
            CONEY20 = 17059910,
        },
        -- Supplies Recovery -- found unwired in sql/mob_spawn_points.sql under an explicit
        -- "-- supplies recovery" comment: 10 real Imp + 1 Gasharyad + 1 Salimuhl, all with real
        -- individually-captured coordinates. User-provided real wiki objective/walkthrough confirms
        -- 11 real Imps total (1 at start + 3 in the main room + 3 in the hallway + 2 at H-8 + 2 in
        -- the north room at H-7), but only 10 real positions have ever been found in any capture --
        -- left at the honest 10, not fabricated up to 11. Real mechanic is NOT kill-all -- see
        -- instances/supplies_recovery.lua.
        [6] =
        {
            IMP1       = 17059936,
            IMP2       = 17059937,
            IMP3       = 17059938,
            IMP4       = 17059939,
            IMP5       = 17059940,
            IMP6       = 17059941,
            IMP7       = 17059942,
            IMP8       = 17059943,
            IMP9       = 17059944,
            IMP10      = 17059945,
            GASHARYAD  = 17059946,
            SALIMUHL   = 17059947,
        },
        -- Azure Experiments -- found unwired in sql/mob_spawn_points.sql under an explicit
        -- "-- Azure Experiments" comment: 10 real mobs (4 Lamia Prosector, 3 Lamia Bowyer, 3 Lamia
        -- Sharper). Real objective text (ASSAULT_07_START, "Become a test subject") matches this
        -- mission's theme well. Modeled as kill-all-10. NOTE: this mission was initially
        -- mis-numbered as mission 6 (that slot actually belongs to Supplies Recovery above) --
        -- corrected same day before going live.
        [7] =
        {
            LAMIA_PROSECTOR1 = 17059948,
            LAMIA_BOWYER1    = 17059949,
            LAMIA_SHARPER1   = 17059950,
            LAMIA_PROSECTOR2 = 17059951,
            LAMIA_BOWYER2    = 17059952,
            LAMIA_SHARPER2   = 17059953,
            LAMIA_PROSECTOR3 = 17059954,
            LAMIA_BOWYER3    = 17059955,
            LAMIA_SHARPER3   = 17059956,
            LAMIA_PROSECTOR4 = 17059957,
        },
        -- Imperial Code -- found unwired in sql/mob_spawn_points.sql under an explicit "-- Imperial
        -- code @ -320 -4 -440.7 rot 142" comment: 26 real mobs, all with real individually-captured
        -- coordinates -- 16 Kusa, 3 named uniques (Saizo, Oko, Danzo, all ninja-themed like the
        -- mission name), 7 Kudagitsune. Real objective text (ASSAULT_08_START, "Retrieve the OGMA")
        -- fits an espionage/code theme well. Modeled as kill-all-26.
        [8] =
        {
            KUSA1        = 17059958,
            KUSA2        = 17059959,
            KUSA3        = 17059960,
            KUSA4        = 17059961,
            KUSA5        = 17059962,
            KUSA6        = 17059963,
            KUSA7        = 17059964,
            KUSA8        = 17059965,
            KUSA9        = 17059966,
            KUSA10       = 17059967,
            KUSA11       = 17059968,
            KUSA12       = 17059969,
            KUSA13       = 17059970,
            KUSA14       = 17059971,
            KUSA15       = 17059972,
            KUSA16       = 17059973,
            SAIZO        = 17059974,
            OKO          = 17059975,
            DANZO        = 17059976,
            KUDAGITSUNE1 = 17059977,
            KUDAGITSUNE2 = 17059978,
            KUDAGITSUNE3 = 17059979,
            KUDAGITSUNE4 = 17059980,
            KUDAGITSUNE5 = 17059981,
            KUDAGITSUNE6 = 17059982,
            KUDAGITSUNE7 = 17059983,
        },
        -- Red versus Blue -- found unwired in sql/mob_spawn_points.sql under an explicit "-- Red
        -- versus Blue entrance @ 19.99 -7.5 -363.797 rot 172" comment: 27 real, individually-named/
        -- positioned mobs (ids 17059984-17059992 "start as npcs then turn into mobs" -- an ambush/
        -- reveal mechanic not modeled here, flagging it). Real objective text (ASSAULT_09_START,
        -- "Defeat Raubahn") names one specific mob in this list (17059993) -- modeled as
        -- kill-all-27 for now rather than singling him out, since the rest of the group is clearly
        -- part of the encounter too.
        [9] =
        {
            SHAILHAM    = 17059984,
            DHIADJHAR   = 17059985,
            ZHADJARAF   = 17059986,
            GANMUUL     = 17059987,
            JALYAAT     = 17059988,
            RAHDJAB     = 17059989,
            GHAHNIS     = 17059990,
            TAHBMAR     = 17059991,
            RHUSHOUF    = 17059992,
            RAUBAHN     = 17059993,
            GHAYARAAN   = 17059994,
            KRINAHAL    = 17059995,
            VARAJAHL    = 17059996,
            MAREYAMAD   = 17059997,
            SHAYAAM     = 17059998,
            HABRAHEEM   = 17059999,
            QUDEEN      = 17060000,
            SALYHAAR    = 17060001,
            SHARAYAAN   = 17060002,
            UBDEEN      = 17060003,
            BASHDEEL    = 17060004,
            WHARADI     = 17060005,
            HKADOUF     = 17060006,
            AFRHAAD     = 17060007,
            NAREEMA     = 17060008,
            UDHAAMAN    = 17060009,
            YHALBIN     = 17060010,
        },
        -- Bloody Rondo -- found unwired in sql/mob_spawn_points.sql under an explicit "-- Bloody
        -- Rondo entrance @ 424 4.3 -341 rot 0" comment: Count Dracula (real coords) + Cursed
        -- Doppelganger. Real objective text matches exactly ("Defeat the count"). Modeled as
        -- kill-all-2.
        [10] =
        {
            COUNT_DRACULA       = 17060011,
            CURSED_DOPPELGANGER = 17060012,
        }
    },

    npc =
    {
        ANCIENT_LOCKBOX = 17060014,
        RUNE_OF_RELEASE = 17060015,
        KUIHLUD = 17060101, -- Supplies Recovery (mission 6) mission-start NPC, real position confirmed
        -- Supplies Recovery (mission 6): 2 real door props, registered to instance 6 but never
        -- activated -- animation=9 (closed/impassable) default, same "_1x registered but never
        -- toggled" bug class already found and fixed elsewhere this session (Lamia No.13's _1jd,
        -- Lost and Found's _1j3/_1j4/_1j5/_1jb). User-reported live: need to be passable.
        _1XH = 17060136,
        _1XJ = 17060138,
        -- Imperial Code (mission 8): shared searchable "???" prop (real client name 'qm0'),
        -- repositioned to wherever each of the 3 named NMs (Saizo/Oko/Danzo) dies -- real capture
        -- confirms this, ids 17060103, MesNum 7674/7675 each time. Real mechanic (user-confirmed,
        -- matching wiki): examining the body where the LAST (3rd) NM died retrieves the OGMA and
        -- completes the mission -- see npcs/qm0.lua and mobs/Saizo.lua/Oko.lua/Danzo.lua.
        MYSTERY_BODY    = 17060103,
        -- Counting Sheep -- DATA LAYER ONLY (no mechanic logic built yet -- see
        -- instances/counting_sheep.lua's header for the full research writeup, sourced from a real
        -- wiki walkthrough + 3 independent captures).
        ICE_CAGE1        = 17059911,
        ICE_CAGE2        = 17059912,
        ICE_CAGE3        = 17059913,
        ICE_CAGE4        = 17059914,
        ICE_CAGE5        = 17059915,
        QIQIRN_SHEPHERD1 = 17059922,
        QIQIRN_SHEPHERD2 = 17059924,
        QIQIRN_MINE1     = 17059925, -- ice-breaker prop -- only 1 of a likely 5 (1 per cage) confirmed by any capture so far
        QIQIRN_SHEPHERD3 = 17059926,
        QIQIRN_MINE_BARON = 17059928,
        QIQIRN_GREENGROCER = 17059929,
        QIQIRN_DEALER    = 17059930,
        KARAKUL1         = 17059934,
        KARAKUL2         = 17059935, -- 3 of 5 real Karakul ids still unconfirmed -- see instances/counting_sheep.lua
        -- RENAMED from MINING_POINT1-7 -- that name collided with Orichalcum Survey's own
        -- MINING_POINT1-10 (17060016-025) block further down this same flat npc{} table. Lua table
        -- constructors silently let a later duplicate key win, so ID.npc.MINING_POINT1 was ALWAYS
        -- resolving to Orichalcum Survey's id, never this mission's -- a real, previously-undetected
        -- bug that would have broken this mission's mining regardless of anything else built here.
        SHEEP_MINING_POINT1    = 17060067,
        SHEEP_MINING_POINT2    = 17060070,
        SHEEP_MINING_POINT3    = 17060071,
        SHEEP_MINING_POINT4    = 17060072,
        SHEEP_MINING_POINT5    = 17060076,
        SHEEP_MINING_POINT6    = 17060077,
        SHEEP_MINING_POINT7    = 17060078,
        SHEEP_HARVESTING_POINT1 = 17060088,
        SHEEP_HARVESTING_POINT2 = 17060091,
        SHEEP_HARVESTING_POINT3 = 17060092,
        SHEEP_HARVESTING_POINT4 = 17060093,
        SHEEP_HARVESTING_POINT5 = 17060097,
        SHEEP_HARVESTING_POINT6 = 17060098,
        SHEEP_HARVESTING_POINT7 = 17060099,
        -- Shanarha Grass Conservation: 29 real Vegetation props (2 already wired, 27 more added
        -- from NOT_CAPTURED placeholders -- 2 independent captures, 17060038/17060045 still
        -- genuinely NOT_CAPTURED, absent from both). "Eaten" by Coney over the course of the
        -- mission -- see instances/shanarha_grass_conservation.lua.
        VEGETATION1     = 17060027,
        VEGETATION2     = 17060028,
        VEGETATION3     = 17060029,
        VEGETATION4     = 17060030,
        VEGETATION5     = 17060031,
        VEGETATION6     = 17060032,
        VEGETATION7     = 17060033,
        VEGETATION8     = 17060034,
        VEGETATION9     = 17060035,
        VEGETATION10    = 17060036,
        VEGETATION11    = 17060037,
        VEGETATION12    = 17060039,
        VEGETATION13    = 17060040,
        VEGETATION14    = 17060041,
        VEGETATION15    = 17060042,
        VEGETATION16    = 17060043,
        VEGETATION17    = 17060044,
        VEGETATION18    = 17060046,
        VEGETATION19    = 17060047,
        VEGETATION20    = 17060048,
        VEGETATION21    = 17060049,
        VEGETATION22    = 17060050,
        VEGETATION23    = 17060051,
        VEGETATION24    = 17060052,
        VEGETATION25    = 17060053,
        VEGETATION26    = 17060054,
        VEGETATION27    = 17060055,
        VEGETATION28    = 17060056,
        VEGETATION29    = 17060057,
        -- Azure Experiments, real mechanic (from real-WIN Grievor captures): Nareema is the real
        -- graft-giving NPC, previously a NOT_CAPTURED stub. See npcs/Nareema.lua.
        NAREEMA         = 17060102,
        -- Orichalcum Survey: 10 Mining Points + Mulwahah (pickaxe issuance / ore turn-in), + door
        -- prop. Default npc_list status is hidden (0) for the Mining Points, props were manually added.
        MINING_POINT1   = 17060016,
        MINING_POINT2   = 17060017,
        MINING_POINT3   = 17060018,
        MINING_POINT4   = 17060019,
        MINING_POINT5   = 17060020,
        MINING_POINT6   = 17060021,
        MINING_POINT7   = 17060022,
        MINING_POINT8   = 17060023,
        MINING_POINT9   = 17060024,
        MINING_POINT10  = 17060025,
        MULWAHAH        = 17060026,
        -- CORRECTED: an earlier conclusion here was wrong -- it matched raw NPCLogger capture ids
        -- directly against current npc_list ids without applying this zone's confirmed -1 id-shift
        -- correction (sql/npc_list.sql's "offset starts/Ends here" markers, 17060106-17060176). Raw
        -- capture id 17060143 (357,-7,59, the Cleansing corridor) shifts to current id 17060142
        -- (ROCK_PROP_1XN below) -- THAT is the real Leujaoam Cleansing door. ROCK_PROP_1XO
        -- (17060143) is real, but for Orichalcum Survey (mission 2) -- its own raw capture id
        -- 17060144 shifts to 17060143, matching this row's current position (-460,-32,120) exactly.
        -- Re-registered accordingly in sql/instance_entities.sql and wired into orichalcum_survey.lua.
        ROCK_PROP_1XO   = 17060143,
        _1X1            = 17060120,
        _1X2            = 17060121,
        _1X3            = 17060122,
        _1X4            = 17060123,
        _1X5            = 17060124,
        _1X6            = 17060125,
        _1X7            = 17060126,
        _1X8            = 17060127,
        _1X9            = 17060128,
        _1XA            = 17060129,
        _1XB            = 17060130,
        _1XC            = 17060131,
        _1XD            = 17060132,
        _1XE            = 17060133,
        _1XF            = 17060134,
        _1XG            = 17060135,
        _1XH            = 17060136,
        _1XI            = 17060137,
        _1XJ            = 17060138,
        _1XK            = 17060139,
        _1XL            = 17060140,
        _1XM            = 17060141,
        -- CORRECTED: this IS the real Leujaoam Cleansing (mission 1) door, per 2 independent
        -- captures, once the zone's -1 id-shift correction is applied to the raw capture id (see
        -- ROCK_PROP_1XO's comment above for the full writeup). It is registered ONLY to mission 1 in
        -- the live instance_entities table -- an earlier "also shared with Shanarha Grass
        -- Conservation (4) and Supplies Recovery (6)" claim was stale/unverified, removed.
        ROCK_PROP_1XN   = 17060142,
        _1XP            = 17060144,
        _1XQ            = 17060145,
        _1XR            = 17060146,
        _1XS            = 17060147,
        _1XT            = 17060148,
        _1XU            = 17060149,
        _1XV            = 17060150,
        -- Real for Leujaoam Cleansing (mission 1). npc_list position was wrong (mixed up with
        -- _1XX's real spot), corrected -- see npc_list.sql's comment on 17060151. ROCK_PROP_1XO is
        -- Orichalcum Survey's (mission 2) and _1XX is Imperial Code's (mission 8); see _1XX's own
        -- comment below.
        _1XW            = 17060151,
        -- CORRECTED: this is NOT a Leujaoam Cleansing (mission 1) door -- that earlier match used
        -- raw capture ids directly without this zone's -1 id-shift correction. Shift-corrected
        -- captures show: the Cleansing capture's raw id (17060152, pos 280/-40/220) actually
        -- resolves to `_1XW` (17060151) once corrected, not this id; and a separate Imperial Code
        -- capture's raw id (17060153, pos -360/-8/-378) resolves to exactly this id (17060152),
        -- matching its npc_list position. This IS the real Imperial Code (mission 8) door, matching
        -- its live instance_entities registration -- not currently wired into imperial_code.lua
        -- (flagged for review: unclear whether an explicit setStatus/setAnimation call is needed or
        -- SQL defaults are sufficient, same open question as other prop families).
        _1XX            = 17060152,
        _1XY            = 17060153,
        _1XZ            = 17060154,
        _JX0            = 17060155,
        _JX1            = 17060156,
        _JX2            = 17060157,
        _JX3            = 17060158,
        _JX4            = 17060159,
        _JX5            = 17060160,
        _JX6            = 17060161,
        _JX7            = 17060162,
        _JX8            = 17060163,
        _JX9            = 17060164,
        _JXA            = 17060165,
        _JXB            = 17060166,
        _JXC            = 17060167,
        _JXD            = 17060168,
        _JXE            = 17060169,
        _JXF            = 17060170,
        _JXG            = 17060171,
        _JXH            = 17060172,
        _JXI            = 17060173,
        _JXJ            = 17060174,
        _JXK            = 17060175,
    }
}

return Leujaoam
