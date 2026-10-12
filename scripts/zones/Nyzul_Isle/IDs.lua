-- DSP-PORT-MERGE: this file merges DSP's own pre-existing NyzulIsle table (Path of Darkness /
-- Nashmeira's Plea content, mobs[58]/[59]/npcs, all left UNCHANGED below) with Topaz's Nyzul Isle
-- Investigation (mission 51) additions. See MERGE_DECISIONS.md alongside this package for the
-- full reasoning -- summary: DSP's own `text` block had no verification trail at all (no header,
-- no source citation) and several of its ids numerically disagree with Topaz's, which WERE
-- extensively re-verified this session against a real client dialog table dump (POLUtils XML
-- export, cross-checked at multiple widely-spaced points). Topaz's numbers are used below for
-- every overlapping text key. **This has not been live-tested against the actual target DSP
-- client -- verify in-game before treating as final**, per MERGE_DECISIONS.md.
NyzulIsle = {

    text = {
        -- General Texts -- DSP's own values here (6379/6385/6386/6388) were NOT re-verified and
        -- are believed to have the same class of +1-ish drift as Topaz's own equivalent block had
        -- before this session's fix (Topaz: 6382/6388/6389/6391) -- using Topaz's verified values.
        ITEM_CANNOT_BE_OBTAINED    = 6382, -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE = 6386, -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        ITEM_OBTAINED              = 6388, -- Obtained: <item>.
        GIL_OBTAINED               = 6389, -- Obtained <number> gil.
        KEYITEM_OBTAINED           = 6391, -- Obtained key item: <keyitem>.
        KEYITEM_LOST               = 6392, -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL        = 6393, -- You do not have enough gil.
        ITEMS_OBTAINED             = 6397, -- You obtain <number> <item>!
        CARRIED_OVER_POINTS        = 6999, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY    = 7000, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER               = 7001, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        -- Assault Texts -- DSP had TIME_TO_COMPLETE=7300/MISSION_FAILED=7301/TIME_REMAINING_
        -- MINUTES=7305/SECONDS=7306/PARTY_FALLEN=7308 (unverified, no source cited). Topaz's
        -- values (7303/7304/7308/7309/7311) were confirmed against a real POLUtils XML dialog
        -- table export -- using those.
        TIME_TO_COMPLETE           = 7303, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED             = 7304, -- The mission has failed. Leaving area.
        TIME_REMAINING_MINUTES     = 7308, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS     = 7309, -- Time remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN               = 7311, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
        -- Real Nyzul Isle dialog table dump (POLUtils XML export, dialog table entries 7343-7367)
        -- -- genuinely new content, DSP's own file had none of this (Vending Box, Rune of Transfer
        -- CSID 94/201 menus, lamp order, objective text, gear/pathos penalty messages).
        VENDING_BOX_MENU           = 7343, -- What do you take? [Nothing. / item slots...]
        VENDING_ITEM_OBTAINED      = 7344, -- Obtained temporary item: <item>!
        VENDING_ALREADY_HAVE_ITEM  = 7345, -- You already have that temporary item.
        PATHOS_RECEIVED            = 7346, -- "You feel an incredible pressure bearing down on you. This area appears to be blanketed in some sort of intense psionic field..." -- per-floor pathos-received flavor text.
        -- Real CSID 201 (Rune of Transfer) menu text + its full real 7-option Selection Dialog:
        -- 0 Not yet. / 1 Exit the Assault area. / 2 Travel to the next floor. /
        -- 3 Travel to the floor on the right. / 4 Travel to the floor on the left. /
        -- 5 Travel to Floor <N>. / 6 Travel to Floor ???.
        RUNE_TRAVEL_PROMPT         = 7347,
        OBJECTIVE_COMPLETE         = 7348, -- "Floor <N> objective complete. Rune of Transfer activated."
        LAMP_ACTIVATE_PROMPT       = 7349, -- "Activate the lamp?" [Yes./Yes./No.]
        LAMP_REGISTER_STATUS       = 7350, -- "The certification code for all party members is required to activate this lamp." / "Your certification code has been registered." (both states, one id)
        LAMP_REGISTER_CONFIRMED    = 7351, -- standalone duplicate of just the second line above
        LAMP_ALREADY_ACTIVE        = 7352, -- "This lamp has already been activated."
        LAMP_UNLIT_DESCRIPTION     = 7353, -- "This lamp cannot be activated unless all other lamps are activated at the same time."
        LAMP_NEEDS_OTHER_ACTION    = 7354, -- "All lamps on this floor are activated, but some other action appears to be necessary in order to activate the Rune of Transfer."
        LAMP_COOLDOWN              = 7355, -- "It appears you cannot activate this lamp for some time..."
        LAMP_ORDER_REQUIRED        = 7356, -- "Apparently, this lamp must be activated in a specific order..."
        LAMP_NOT_ALL_LIT           = 7357, -- "Not all lights have been activated..." (ORDER variant's own distinct message)
        LAMP_CONFIRMING_PROCEDURE  = 7358, -- "Confirming operation procedure..." (ORDER variant's real 6s win-delay message)
        RUNE_ALREADY_ACTIVATED     = 7359, -- "The Rune of Transfer has already been activated." (about the rune, not a lamp)
        -- Mumor's own Final Eternal Heart cast line, capture id 7675 (this session's Heroines'
        -- Holdfast capture, CapLog 2025.05.02 00:18:53) = dialog.yml 7660 after the +15 capture
        -- offset; verified this session against a fresh dat-extractor pull of zone 77's dialog.yml,
        -- exact text match: "All life shall die and be born anew!Final!!! Eternal!!! Heart!!!"
        MUMOR_FINAL_ETERNAL_HEART  = 7660,
        -- Party-wipe taunt, 2 lines. Capture ids 7666 (Mumor)/no separate packet logged for Uka
        -- Totlihn's line -- both resolved via the same +15 capture offset rule and verified this
        -- session against a fresh dat-extractor pull of zone 77's dialog.yml (exact text match):
        -- "That's right! The Mighty Maidens are back and better than ever!" (7651) /
        -- "Oh, Mumor, we did it!" (7652). Fires ~6s after the party is wiped (CapLog 2025.05.01
        -- 00:38:00 wipe -> 00:38:06 line), well before the separate 3-minute-later mission-failure
        -- zone-out (onInstanceFailure) -- this is a taunt, not the failure message itself.
        MUMOR_WIPE_TAUNT           = 7651,
        UKA_TOTLIHN_WIPE_TAUNT     = 7652,
        -- Real per-stage objective announcements. Note: only 6 entries (7360-7365) exist for
        -- Nyzul.objective's 6 real values, and FREE_FLOOR (6) has none -- matches the wiki
        -- exactly ("Free floors will have no objective message."), not a gap to fill.
        -- 7360 and 7361 are an exact text duplicate ("Objective: Eliminate enemy leader.") -- both
        -- map to ELIMINATE_ENEMY_LEADER; only 7360 is used (no confirmed reason to prefer 7361 for
        -- either the boss-floor or regular-leader sub-case).
        OBJECTIVE_TEXT =
        {
            [1] = 7360, -- ELIMINATE_ENEMY_LEADER: "Objective: Eliminate enemy leader."
            [2] = 7362, -- ELIMINATE_SPECIFIED_ENEMIES: "Objective: Eliminate specified enemies."
            [3] = 7363, -- ACTIVATE_ALL_LAMPS: "Objective: Activate all lamps."
            [4] = 7364, -- ELIMINATE_SPECIFIED_ENEMY: "Objective: Eliminate specified enemy."
            [5] = 7365, -- ELIMINATE_ALL_ENEMIES: "Objective: Eliminate all enemies."
        },
        GEAR_AVOID_AGRO            = 7366, -- "Avoid discovery by archaic gears!"
        GEAR_DO_NOT_DESTROY        = 7367, -- "Do not destroy archaic gears!"
        GEAR_PENALTY_TIME          = 7368, -- "Time limit has been reduced by <N> minute[/s]."
        GEAR_PENALTY_MALFUNCTION   = 7369, -- "Security field malfunction."
        GEAR_PENALTY_TOKENS        = 7370, -- "Potential token reward reduced."
        -- Per-pathos-effect removed/applied message pairs, matched by MEANING (not table position)
        -- to all 29 real entries in Nyzul.pathos.
        PATHOS_REMOVED =
        {
            [ 1] = 7371, [ 2] = 7373, [ 3] = 7379, [ 4] = 7377, [ 5] = 7385, [ 6] = 7381,
            [ 7] = 7383, [ 8] = 7375, [ 9] = 7387, [10] = 7389, [11] = 7391, [12] = 7393,
            [13] = 7395, [14] = 7397, [15] = 7399, [16] = 7401, [17] = 7403, [18] = 7405,
            [19] = 7407, [20] = 7409, [21] = 7411, [22] = 7413, [23] = 7415, [24] = 7417,
            [25] = 7419, [26] = 7421, [27] = 7423, [28] = 7425, [29] = 7427,
        },
        PATHOS_APPLIED =
        {
            [ 1] = 7372, [ 2] = 7374, [ 3] = 7380, [ 4] = 7378, [ 5] = 7386, [ 6] = 7382,
            [ 7] = 7384, [ 8] = 7376, [ 9] = 7388, [10] = 7390, [11] = 7392, [12] = 7394,
            [13] = 7396, [14] = 7398, [15] = 7400, [16] = 7402, [17] = 7404, [18] = 7406,
            [19] = 7408, [20] = 7410, [21] = 7412, [22] = 7414, [23] = 7416, [24] = 7418,
            [25] = 7420, [26] = 7422, [27] = 7424, [28] = 7426, [29] = 7428,
        },
        -- Second real dialog-table range -- 7464-7484, covering Vending Box AND the Rune of
        -- Transfer's real CSID 94 floor-select menu.
        VENDING_CHEST_EXAMINE      = 7465, -- "There is a treasure chest here. It appears to create temporary items in exchange for tokens."
        VENDING_OBTAIN_PROMPT      = 7466, -- "Obtain a temporary item?" [Preferred items/Low/Medium/High-grade (N tokens)/All items/Not now.]
        VENDING_TOKEN_COUNT_PROMPT = 7470, -- "You currently possess <N> token[/s]. Do you wish to exchange tokens for this temporary item?"
        VENDING_NO_ITEMS_CATEGORY  = 7472, -- "There are no items available in this category."
        -- Real 2-step CSID 94 floor-select structure: pick a tier band first (7473: None/20/40/60/
        -- 80/100 -- boss floors), then a specific floor within it (7474: None/1/6/11/16.../96) --
        -- NOT wired into a 2-step menu (this port's csid 94 stays a flat 1-20 option list).
        RUNE_SELECT_FLOOR_TIER     = 7473,
        RUNE_SELECT_FLOOR_5S       = 7474,
        RUNE_TRANSFER_COST         = 7475, -- "Transfer to Floor <N> requires <N> token[/s]."
        RUNE_TRANSFER_CONFIRM      = 7476, -- "Use <N> token[/s] to travel to Floor <N>? Yes/No"
        RUNE_IN_OPERATION          = 7479, -- "Transfer controls in operation by another user."
        RUNE_INSUFFICIENT_TOKENS   = 7480, -- "Insufficient tokens."
        RUNE_NEW_USER_CONFIRMED    = 7461, -- "New user confirmed. Issuing <Runic Disc>."
        -- TODO (real per user, deferred, not fabricated): Runic Disc data CAN be reset in real
        -- retail -- exact trigger condition/whether it clears fully or partially is NOT confirmed.
        -- Related warning text (WARNING_RESET_DISC) exists but isn't wired anywhere yet.
        WARNING_RESET_DISC         = 7429, -- "The data on the <Runic Disc> will be reset when you complete the objective of the next floor."
        RUNE_DISC_RESET            = 7481, -- "<Runic Disc> data has been reset." -- no reset mechanic built yet
        RUNE_OBTAIN_TOKENS         = 7482, -- "You obtain <N> token[/s]!"
        RUNE_FLOOR_RECORD          = 7483, -- "Data up to and including Floor <N> has been recorded on your Runic Disc."
        RUNE_WELCOME_TO_FLOOR      = 7484, -- "Transfer complete. Welcome to Floor <N>."
        -- Amnaf/Naja/Raubahn/Alexander battle texts (Path of Darkness, mission 58/59) -- DSP's own
        -- values here were 7500-7540; Topaz's re-verified values for this same real content are
        -- 7503-7543 (a consistent +3 shift). Since these lines are ALREADY LIVE in DSP's own
        -- shipped Path of Darkness mob scripts (Amnaf_blu.lua etc reference NyzulIsle.text.X, not
        -- raw numbers), review before deploying: if DSP's mob scripts are working correctly in
        -- production today with the 7500-7540 numbering, that numbering is what's actually correct
        -- for DSP's own target client, and Topaz's 7503-7543 should NOT overwrite it here --
        -- flagged rather than silently guessed either way. See MERGE_DECISIONS.md.
        FORMATION_GELINCIK         = 7500, -- Formation Gelincik! Eliminate the intruders!
        SURRENDER                  = 7501, -- You would be wise to surrender. A fate worse than death awaits those who anger an Immortal...
        I_WILL_SINK_YOUR_CORPSES   = 7502, -- I will sink your corpses to the bottom of the Cyan Deep!
        AWAKEN                     = 7503, -- Awaken, powers of the Lamiae!
        MANIFEST                   = 7504, -- Manifest, powers of the Merrow!
        CURSED_ESSENCES            = 7505, -- Cursed essences of creatures devoured...Infuse my blood with your beastly might!
        UGH                        = 7506, -- Ugh...I should not be surprised...
        CANNOT_WIN                 = 7507, -- Hehe...hehehe...You are...too strong for me...I cannot win...in this way...
        CANNOT_LET_YOU_PASS        = 7508, -- <Wheeze>...I cannot...let you...pass...
        WHEEZE                     = 7509, -- <Wheeze>...
        WHEEZE_PHSHOOO             = 7510, -- <Wheeze>...<phshooo>!
        PHSHOOO                    = 7511, -- <Phshooo>...
        NOT_POSSIBLE               = 7512, -- <Phshooo>...Not...possible...
        ALRRRIGHTY                 = 7513, -- Alrrrighty!
        CHA_CHING                  = 7514, -- Cha-ching! Thirty gold coins!
        TWELVE_GOLD_COINS          = 7515, -- Hehe! This one'll cost ya twelve gold coins a punch! The grrreat gouts of blood are frrree of charge!
        NINETY_NINE_SILVER_COINS   = 7516, -- Ninety-nine silver coins a pop! A bargain, I tell ya!
        THIS_BATTLE                = 7517, -- This battle is rrreally draggin' on... Just think of the dry cleanin' bill!
        OW                         = 7518, -- Ow...! Ya do rrrealize the medical costs are comin' outta your salary, don't ya?
        ABQUHBAH                   = 7519, -- A-Abquhbah! D-don't even think about...rrraisin' the wages...Management...is a mean world...ugh...
        OH_ARE_WE_DONE             = 7520, -- Oh, are we done? I wasn't done rrrackin' up the fees...You've got more in ya, rrright?
        NOW_WERE_TALKIN            = 7521, -- Now we're talkin'! I can hear the clinkin' of coin mountains collapsin' over my desk...Let's get this over with!
        PRAY                       = 7522, -- Pray to whatever gods you serve.
        BEHOLD                     = 7523, -- Behold the power of my eldritch gaze!
        CARVE                      = 7524, -- I will carve the soul fresh from your bones.
        RESIST_MELEE               = 7525, -- My flesh remembers the wounds of ten thousand blades. Come, cut me again...
        RESIST_MAGIC               = 7526, -- My skin remembers the fires of ten thousand spells. Come, burn me again...
        RESIST_RANGE               = 7527, -- My belly remembers the punctures of ten thousand arrows. Come, shoot me again...
        NOW_UNDERSTAND             = 7528, -- Hehehe...Do you now understand what it is to fight a true Immortal? Realize your futility and embrace despair...
        MIRACLE                    = 7529, -- Ugh... Has your god granted you the miracle you seek...?
        SHALL_BE_JUDGED            = 7531, -- I am...Alexander...The meek...shall be rewarded...The defiant...shall be judged...
        OFFER_THY_WORSHIP          = 7532, -- Offer thy worship...I shall burn away...thy transgressions...
        OPEN_THINE_EYES            = 7533, -- Open thine eyes...My radiance...shall guide thee...
        CEASE_THY_STRUGGLES        = 7534, -- Cease thy struggles...I am immutable...indestructible...impervious...immortal...
        RELEASE_THY_SELF           = 7535, -- Release thy self...My divine flames...shall melt thy flesh...sear thy bones...unshackle thy soul...
        BASK_IN_MY_GLORY           = 7536, -- Bask in my glory...Mine existence...stretches into infinity...
        REPENT_THY_IRREVERENCE     = 7537, -- Repent thy irreverence...The gate to salvation...lies before thee...Revelation...is within thy reach...
        ACCEPT_THY_DESTRUCTION     = 7538, -- Accept thy destruction...Wish for eternity...yearn for immortality...Sense thy transience...know thy insignificance...
        OMEGA_SPAM                 = 7539, -- OMEGA SPAM
        SHALL_KNOW_OBLIVION        = 7540, -- I am...Alexander...The fearful...shall be embraced...The bold...shall know oblivion...
    },

    mobs = {
        -- Path of Darkness -- DSP's own, unchanged.
        [58] = {
            AMNAF_BLU          = 17093132,
            AMNAF_PSYCHEFLAYER = 17093133,
            IMPERIAL_GEAR1     = 17093134,
            IMPERIAL_GEAR2     = 17093135,
            IMPERIAL_GEAR3     = 17093136,
            IMPERIAL_GEAR4     = 17093137,
            NAJA               = 17093142,
        },
        -- Heroines' Holdfast (instance 80); mob_spawn_points ids are capture ids (unlike npc_list)
        [80] = {
            LION = 17093178,
            PRISHE = 17093211,
            NASHMEIRA = 17093247,
            OVJANG = 17093248,
            MNEJING = 17093249,
            LILISETTE = 17093286,
            LILISETTE_SPLIT = 17093287,
            MUMOR = 17093309,
        },
        [59] = {
            RAZFAHD = 17093143,
            ALEXANDER = 17093144,
            RAUBAHN = 17093145,
        },
        -- Nyzul Isle Investigation (instance 51) -- genuinely new, Topaz's addition. Real Layout 6
        -- "Demons" pool (Imp x10, Psycheflayer x2, per BG Wiki's enemy layout table). Real,
        -- pre-existing mob_spawn_points rows (mob_groups groupid 22/23, poolid 2065/3215, zone 77,
        -- level 66-68). See Imp.lua/Psycheflayer.lua.
        [51] = {
            IMP_OFFSET          = 17092691, -- 17092691-17092700 (10 total)
            PSYCHEFLAYER_OFFSET = 17092701, -- 17092701-17092702 (2 total)
            -- All 16 real BG Wiki enemy layouts (ELIMINATE_ALL_ENEMIES), keyed by the wiki's own
            -- layout number. Each entry is { real spawn id, real count } per family in that layout.
            -- mob_spawn_points lays them out as 16 contiguous 12-mob blocks starting at 17092631
            -- (base + 12*(layout-1)), matching LSB's own pTableFloorRandomEntities family scheme
            -- (Aquans/Amorphs/Arcana/Undead/Vermin/Demons/Dragons/Birds/Beasts/Plantoids/Lizards/
            -- Amorphs2/Mixed/Mixed2/Amorphs3/Arcana2) -- confirmed by cross-referencing LSB's
            -- floor_generation.lua against this codebase's own real mob_spawn_points/mob_groups
            -- rows (zone 77).
            ENEMY_LAYOUTS = {
                [1] = { -- Aquans (level 66-72)
                    { id = 17092631, count = 6 }, -- Greatclaw
                    { id = 17092637, count = 4 }, -- Stygian Pugil
                    { id = 17092641, count = 2 }, -- Kulshedra
                },
                [2] = { -- Amorphs (level 66-68)
                    { id = 17092643, count = 3 }, -- Bouncing Ball
                    { id = 17092646, count = 3 }, -- Thousand Eyes
                    { id = 17092649, count = 4 }, -- Mousse
                    { id = 17092653, count = 2 }, -- Black Pudding
                },
                [3] = { -- Arcana (level 66-68)
                    { id = 17092655, count = 2 }, -- Killing Weapon
                    { id = 17092657, count = 2 }, -- Ominous Weapon
                    { id = 17092659, count = 2 }, -- Magic Flagon
                    { id = 17092661, count = 2 }, -- Friar's Lantern (1st of 2 non-contiguous runs)
                    { id = 17092663, count = 2 }, -- Sweeping Cluster
                    { id = 17092665, count = 2 }, -- Friar's Lantern (2nd run)
                },
                [4] = { -- Undead (level 66-68)
                    { id = 17092667, count = 3 }, -- Garm
                    { id = 17092670, count = 3 }, -- Tainted Flesh
                    { id = 17092673, count = 4 }, -- Draugar
                    { id = 17092677, count = 2 }, -- Bhoot
                },
                [5] = { -- Vermin (level 66-68)
                    { id = 17092679, count = 3 }, -- Carmine Eruca
                    { id = 17092682, count = 3 }, -- Spinner
                    { id = 17092685, count = 4 }, -- Wamouracampa
                    { id = 17092689, count = 2 }, -- Wamoura
                },
                [6] = { -- Demons (level 66-68)
                    { id = 17092691, count = 10 }, -- Imp
                    { id = 17092701, count = 2 },  -- Psycheflayer
                },
                [7] = { -- Dragons (level 66-68)
                    { id = 17092703, count = 10 }, -- Puk
                    { id = 17092713, count = 2 },  -- Wyvern
                },
                [8] = { -- Birds (level 66-68)
                    { id = 17092715, count = 3 }, -- Marsh Murre
                    { id = 17092718, count = 3 }, -- Lesser Colibri
                    { id = 17092721, count = 4 }, -- Ziz
                    { id = 17092725, count = 2 }, -- Peryton
                },
                [9] = { -- Beasts (level 66-68)
                    { id = 17092727, count = 3 }, -- Wild Karakul
                    { id = 17092730, count = 3 }, -- Wajaom Tiger
                    { id = 17092733, count = 4 }, -- Manticore
                    { id = 17092737, count = 2 }, -- Marid
                },
                [10] = { -- Plantoids (level 66-68)
                    { id = 17092739, count = 3 }, -- Death Cap
                    { id = 17092742, count = 3 }, -- Puktrap
                    { id = 17092745, count = 4 }, -- Leshy
                    { id = 17092749, count = 2 }, -- Ameretat
                },
                [11] = { -- Lizards (level 66-68)
                    { id = 17092751, count = 3 }, -- Sand Lizard
                    { id = 17092754, count = 3 }, -- Deinonychus
                    { id = 17092757, count = 4 }, -- Bull Bugard
                    { id = 17092761, count = 2 }, -- Wivre
                },
                [12] = { -- Amorphs 2 (level 66-68)
                    { id = 17092763, count = 5 }, -- Bouncing Ball
                    { id = 17092768, count = 5 }, -- Thousand Eyes
                    { id = 17092773, count = 2 }, -- Mousse
                },
                [13] = { -- Mixed (level 66-68)
                    { id = 17092775, count = 10 }, -- Peryton
                    { id = 17092785, count = 2 },  -- Mousse
                },
                [14] = { -- Mixed 2 (level 66-68)
                    { id = 17092787, count = 10 }, -- Draugar
                    { id = 17092797, count = 2 },  -- Mousse
                },
                [15] = { -- Amorphs 3 (level 66-68)
                    { id = 17092799, count = 6 }, -- Mousse
                    { id = 17092805, count = 6 }, -- Black Pudding
                },
                [16] = { -- Arcana 2 (level 66-68)
                    { id = 17092811, count = 3 }, -- Killing Weapon
                    { id = 17092814, count = 3 }, -- Ominous Weapon
                    { id = 17092817, count = 6 }, -- Magic Flagon
                },
            },
            -- Real Archaic Gear secondary-objective pool (per LSB's own pTableFloorRandomEntities[17]
            -- = {GEAR_OFFSET+2, GEAR_OFFSET+7}) -- 3x Archaic_Gear (real mob_spawn_points rows
            -- 17092916-17092918, groupid 127/poolid 218) + 3x Archaic_Gears (17092919-17092921,
            -- groupid 128/poolid 219), both zone 77, level 66-68. GEAR_OFFSET itself is 17092914
            -- (real, matches LSB's GetFirstID('Archaic_Gear')). See globals/nyzul/pathos.lua's
            -- onGearEngage/onGearDeath and npcs/Archaic_Gear.lua/Archaic_Gears.lua.
            GEAR_OFFSET         = 17092914,
            -- Real random floor NM pool -- BG Wiki/FFXIclopedia: "There are various Notorious
            -- Monsters from throughout Vana'diel that are summoned by the archaic ramparts...Every
            -- 20 floors, there are 18 different NMs that may spawn." Confirmed via LSB's own
            -- pTableOddFloorRandomNMs/pTableEvenFloorRandomNMs -- both real, pre-existing
            -- mob_spawn_points ranges (17092824-17092913, 90 ids, zone 77) whose 5x18-name odd/even
            -- split matches the wiki's 5 floor-section lists name-for-name. NM_OFFSET = 17092824
            -- (GetFirstID('Bat_Eye'), matches LSB). DAHAK (17092823, NM_OFFSET-1) is real but
            -- separate -- LSB's own 20% ELIMINATE_ALL_ENEMIES bonus spawn.
            NM_OFFSET           = 17092824,
            DAHAK               = 17092823,
            NM_EVEN =
            {
                [1] = { id = 17092824, count = 9 }, -- Floors 1-20 (even)
                [2] = { id = 17092842, count = 9 }, -- Floors 21-40 (even)
                [3] = { id = 17092860, count = 9 }, -- Floors 41-60 (even)
                [4] = { id = 17092878, count = 9 }, -- Floors 61-80 (even)
                [5] = { id = 17092896, count = 9 }, -- Floors 81-100 (even)
            },
            NM_ODD =
            {
                [1] = { id = 17092833, count = 9 }, -- Floors 1-20 (odd)
                [2] = { id = 17092851, count = 9 }, -- Floors 21-40 (odd)
                [3] = { id = 17092869, count = 9 }, -- Floors 41-60 (odd)
                [4] = { id = 17092887, count = 9 }, -- Floors 61-80 (odd)
                [5] = { id = 17092905, count = 9 }, -- Floors 81-100 (odd)
            },
            -- Real Enemy Leaders (ELIMINATE_ENEMY_LEADER objective), Imp family -- BG Wiki's own
            -- roster (Mokke/Mokka/Mokku), real pre-existing mob_spawn_points rows, zone 77,
            -- level 76-77.
            MOKKE               = 17092944,
            MOKKA               = 17092945,
            MOKKU               = 17092946,
            -- Real remaining Enemy Leader families -- user-confirmed full roster (BG Wiki), real
            -- pre-existing mob_spawn_points rows (17092947-17092968, contiguous except 17092962 =
            -- 'Qiqirn_Mine', a real related prop the Qiqirn leaders drop, not a leader itself),
            -- zone 77, mob_groups groupid 132-153.
            VILE_WAHDAHA            = 17092947, -- Soulflayer
            VILE_INEEF              = 17092948, -- Soulflayer
            VILE_YABEEWA            = 17092949, -- Soulflayer
            URIRI_SAMARIRI          = 17092950, -- Poroggo, spams Water Bomb
            ERIRI_SAMARIRI          = 17092951, -- Poroggo, spams Frog Song
            ORIRI_SAMARIRI          = 17092952, -- Poroggo
            GINGER_CUSTARD          = 17092953, -- Flan, absorbs light elemental damage
            ANISE_CUSTARD           = 17092954, -- Flan, absorbs ice elemental damage
            CUMIN_CUSTARD           = 17092955, -- Flan, absorbs wind elemental damage
            NUTMEG_CUSTARD          = 17092956, -- Flan, absorbs earth elemental damage
            MINT_CUSTARD            = 17092957, -- Flan, absorbs lightning elemental damage
            CINNAMON_CUSTARD        = 17092958, -- Flan, absorbs water elemental damage
            CARAWAY_CUSTARD         = 17092959, -- Flan, absorbs fire elemental damage
            VANILLA_CUSTARD         = 17092960, -- Flan, absorbs dark elemental damage
            GEM_HEISTER_ROOROOROON  = 17092961, -- Qiqirn, Thief job, runs around dropping bombs
            STEALTH_BOMBER_GAGAROON = 17092963, -- Qiqirn, Thief job, runs around dropping bombs
            QUICK_DRAW_SASAROON     = 17092964, -- Qiqirn, Ranger job
            SHIELDED_CHARIOT        = 17092965, -- Chariot, uses Mortal Revolution
            BATTLEDRESSED_CHARIOT   = 17092966, -- Chariot, uses Discoid
            LONG_GUNNED_CHARIOT     = 17092967, -- Chariot, uses Homing Missile
            LONG_HORNED_CHARIOT     = 17092968, -- Chariot, uses Brainjack
            -- Real boss-floor HNMs (floors 20/40, per BG Wiki). Adamantoise's FIRST real row
            -- (17092999, mob_groups groupid 160) has poolid 0 -- genuinely undefined/incomplete
            -- data, not used.
            BEHEMOTH            = 17093000,
            FAFNIR              = 17093001,
            -- User-confirmed real roster (BG Wiki) -- Adamantoise IS a real floor 20/40 boss
            -- alongside Behemoth/Fafnir. A SECOND, correctly-populated Adamantoise mob_spawn_points
            -- row exists in zone 77 (17093102, mob_groups groupid 260, poolid 44, level 80-80).
            ADAMANTOISE         = 17093102,
            -- Real boss-floor HNMs (floors 60/80/100, per BG Wiki). Real, pre-existing
            -- mob_spawn_points rows (mob_groups groupid 163/164/165, zone 77, level 80).
            KHIMAIRA            = 17093002,
            HYDRA               = 17093003,
            CERBERUS            = 17093004,
            -- BG Wiki: "There will always be an Archaic Rampart next to the HNM; this can be used
            -- to build TP before engaging the boss." Real, pre-existing mob_spawn_points row
            -- (mob_groups groupid 1/poolid 221, zone 77) -- placeholder position (1,1,1). A second
            -- identical row (17092630) exists but only one is needed (wiki says singular).
            ARCHAIC_RAMPART     = 17092629,
            -- Real ELIMINATE_SPECIFIED_ENEMIES family groups (BG Wiki: "a particular group of
            -- enemies... 2-5 of these enemies... always a group of enemies introduced in or native
            -- to the ToAU areas"). Real, pre-existing mob_spawn_points rows (17092969-17092998,
            -- mob_groups groupid 154-159, zone 77, level 76-77) -- matches LSB's own
            -- pTableSpecifiedMobs family list exactly.
            SPECIFIED_GROUPS = {
                { id = 17092969, count = 5 }, -- Heraldic Imp
                { id = 17092974, count = 5 }, -- Psycheflayer
                { id = 17092979, count = 5 }, -- Poroggo Gent
                { id = 17092984, count = 5 }, -- Ebony Pudding
                { id = 17092989, count = 2 }, -- Qiqirn Treasure Hunter
                { id = 17092991, count = 3 }, -- Qiqirn Archaeologist
                { id = 17092994, count = 5 }, -- Racing Chariot
            },
        },
        -- Nyzul Isle Uncharted Area Survey (instance 52) -- boss-floor HNM reskins (20/40/60/80/100).
        -- Each boss reuses its confirmed real Topaz base mob's familyid/modelid/stats (reskin
        -- convention precedent: Enigmatic_Vampyr/Soaring_Vampyr both reskin Vampyr_Jarl's exact
        -- family/model elsewhere in this codebase). New poolids 6998-7008 (global max was 6997),
        -- new mob_groups groupids 339-349 (zone 77 max was 338, unaffected by this relocation).
        -- CORRECTED 2026-09-22: the original mob_spawn_points allocation (17093000-17093050) was
        -- WRONG -- that entire range was already live content.
        -- CORRECTED AGAIN 2026-09-23: the "fix" for the above (17093329-17093398, this comment
        -- block's old claim that 17093329-17096710 was "genuinely free") was ALSO wrong -- it was
        -- only checked against mob_spawn_points, never against npc_list. Direct query confirmed
        -- 17093329-17093398 collides with 30 real npc_list rows still live in zone 77 today,
        -- including 8 real `Moogle` NPCs at 17093345-17093352 and the real instance-51
        -- Rune_of_Transfer/Runic_Lamp npcs at 17093330-336 -- root cause of the reported
        -- floor 20/40 boss nameplates rendering as "Moogle"/"NPC[...]" (client targid = id &
        -- 0xFFF render-slot collision between the new mob row and the pre-existing npc_list row
        -- sharing the same id). Relocated to 17921019-17921051 -- WRONG AGAIN, discovered
        -- 2026-09-23: instance_loader.cpp's mob-load query joins
        -- "mob_groups.zoneid = ((mob_spawn_points.mobid>>12)&0xFFF)" -- zoneid is DERIVED from the
        -- mobid's own bits, not a free column. Zone 77 mobids are only valid inside the narrow
        -- 4096-id window 17092608-17096703 (decodes to zoneid 77); the entire 17921000-17921051
        -- range (both this relocation's bosses AND the previously "already clean" 17921000-17921018
        -- leader-NM pool, which had ALWAYS silently used this same wrong window and had simply never
        -- been playtested that deep) decodes to zoneid 279 and was INNER-JOINed out of existence --
        -- explains the "GetMobByID Mob doesn't exist" warnings for the entire mob[52] set, both old
        -- and new, despite mob_spawn_points/instance_entities/mob_groups/mob_pools all being
        -- correctly populated. RELOCATED AGAIN to 17093612-17093663 -- WRONG YET AGAIN, discovered
        -- 2026-09-23: per topaz_zone_id_encoding_scheme, only ids whose offset from the zone-77
        -- window base (17092608) is < 1024 (targid < 0x400) resolve as MOB/NPC at all -- ids
        -- 0x400+ collide with the PC-reserved targid range and GetMobByID silently fails forever,
        -- independent of collisions. 17093632-17093663 (offset 1024-1055) all violated this --
        -- matches the live "GetMobByID Mob doesn't exist" log for exactly those ids. RELOCATED
        -- (FINAL) to 17093483-17093534 (52 ids, offset 875-926, safely under the 1024 ceiling),
        -- confirmed via direct query to have ZERO existing rows in mob_spawn_points OR npc_list.
        -- Live DB migrated 2026-09-23 (UPDATE mob_spawn_points/instance_entities, verified by
        -- direct query post-migration). mob_groups groupids 339-368 unchanged (composite PK
        -- zoneid+groupid, not id-encoded). Per-boss relative offsets preserved (each base mob's
        -- real Lua hardcodes escort/pet adds as base+1, base+2, ... --
        -- Gulool_Ja_Ja.lua/Gurfurlur_the_Menacing.lua/Medusa.lua/Pandemonium_Warden.lua, confirmed
        -- by reading all 4 scripts, zero Lua changes needed for this relocation). Vampyr_Jarl (Lord
        -- Vryko's base) has NO script anywhere in the tree and no adds -- simple reskin.
        [52] = {
            -- 2026-09-23: boss self-id relocated to match the client DAT name table (Polutils
            -- NPC/Monster List Entry dump: 0x0104D207-0x0104D20B == 17093127-17093131) so the
            -- nameplate shows the real name instead of "NPC". The add-mob pet arrays still anchor
            -- off the ADDBASE constants (the ids these bosses occupied before this relocation) --
            -- DO NOT collapse SELF and ADDBASE back together, the DAT-matched ids are packed
            -- contiguously (127,128,129,130,131) and would collide with the neighboring boss.
            STEALTHLORD_HARAAL_JA         = 17093127, -- DAT-matched self id (Polutils 0x0104D207)
            STEALTHLORD_HARAAL_JA_ADDBASE = 17093502, -- base Gulool_Ja_Ja; +1/+2 = Ja Chamberlain Escort x2, +3/+4 = Ja Palatine Escort x2
            DABARGAR_THE_STOIC            = 17093128, -- DAT-matched self id (Polutils 0x0104D208)
            DABARGAR_THE_STOIC_ADDBASE    = 17093507, -- base Gurfurlur_the_Menacing; +1/+2 = Hilltroll Honor Guard x2, +3/+4 = Woodtroll Honor Guard x2
            STHENO                        = 17093129, -- DAT-matched self id (Polutils 0x0104D209)
            STHENO_ADDBASE                = 17093512, -- base Medusa; +1..+4 = Stheno's Gorgon Handmaid x4 (reskinned Lamia_Exon)
            DVALI_JONAH                   = 17093131, -- DAT-matched self id (Polutils 0x0104D20B)
            DVALI_JONAH_ADDBASE           = 17093517, -- base Pandemonium_Warden; +1..+16 = Dvali's Ritual Lamp x16 (reskinned Pandemonium_Lamp)
            LORD_VRYKO                    = 17093130, -- DAT-matched self id (Polutils 0x0104D20A); base Vampyr_Jarl, no adds, no custom AI

            -- Item 2: 19 non-boss "Eliminate Enemy Leader" NMs, BG-Wiki-cross-checked 2026-09-22.
            -- Real roster is 19 (not 18 -- a 4th real Chariot, Cornum, was missing from the original brief).
            SCUTUM_CHARIOT          = 17093483, -- Chariot, Mortal Revolution
            BELLUM_CHARIOT          = 17093484, -- Chariot, Discoid
            PISTOLIUM_CHARIOT       = 17093485, -- Chariot, Homing Missile
            CORNUM_CHARIOT          = 17093486, -- Chariot, Brainjack
            GROATY_CUSTARD          = 17093487, -- Flan, Amplification (absorbs phys dmg)
            CARAMEL_CUSTARD         = 17093488, -- Flan, reduced magic dmg
            CARDAMOM_CUSTARD        = 17093489, -- Flan, Amorphic Scythe only, high def
            NUKKU                   = 17093490, -- Imp, Grating Tantara
            NOKKO                   = 17093491, -- Imp, Stifling Tantara
            NEKKE                   = 17093492, -- Imp, Bugle Call/Frenetic Rip
            URORO_SAMARORO          = 17093493, -- Poroggo, Water/Waterga + Water Bomb
            IRORO_SAMARORO          = 17093494, -- Poroggo, Magic Hammer
            ARORO_SAMARORO          = 17093495, -- Poroggo, tier3 -ga + Providence/Ancient Magic
            ABJECT_AWIIJA           = 17093496, -- Soulflayer, Mind Purge + ice spells + Reprobation
            ABJECT_FARZAHD          = 17093497, -- Soulflayer, Mind Blast + Blizzaga III + Reprobation
            ABJECT_KHAROUB          = 17093498, -- Soulflayer, std TP moves + Unbridled Learning + Reprobation
            NERVE_RENDER_YIYIROON   = 17093499, -- Qiqirn, triplet Faze, high evasion
            EYE_PIERCER_FAFAROON    = 17093500, -- Qiqirn, Eagle Eye Shot x2, high evasion
            MAD_MINER_BOBOROON      = 17093501, -- Qiqirn, Qiqirn Mine AoE
        },
    },

    npc = {
        -- Nyzul Isle Investigation (instance 51) -- ids confirmed against our own npc_list.sql
        -- (all real, pre-existing rows -- see instance_list.sql's row 51 comment for the entrance
        -- rune's cross-check against LSB's Rune_of_Transfer_Start.lua header position).
        RUNE_OF_TRANSFER_OFFSET   = 17093330, -- moving rune used on each floor (paired with +1, one hidden at a time)
        RUNE_OF_TRANSFER_ENTRANCE = 17093429, -- lobby rune, opens the floor-select menu
        RUNIC_LAMP_OFFSET         = 17093332, -- first of the 5-lamp block (17093332-17093336)
        VENDING_BOX               = 17093430,
        -- 2026-09-23: relocated onto the client DAT name table's Armoury Crate block (Polutils
        -- NPC/Monster List Entry dump: 0x0104D001-0x0104D014 == 17092609-17092628) so the
        -- nameplate shows "Armoury Crate" instead of "NPC" -- previously this project avoided
        -- 17092609 because that npcid's row had model 50 baked in (not a real chest mesh, likely
        -- why it rendered invisible). The fix migrates the real 965 "Blue Casket" mesh row
        -- (formerly 17093609, real distinct npc_list positions e.g. x=492/500/544) INTO 17092609,
        -- carrying its correct look/position with it, rather than reusing the old model-50 row.
        -- Exactly 3 of the 20 DAT-matched slots are used (17092609-17092611), unregistered to any
        -- other instance. ARMOURY_CRATE_OFFSET is used as the single leader-kill drop crate
        -- (dropArmouryCrate); all 3 (OFFSET..OFFSET+2) are used together for Free Floor's real
        -- "random Armoury Crates scattered about" per BG Wiki/FFXIclopedia -- see
        -- nyzul_isle_investigation.lua's pickSetPoint.
        ARMOURY_CRATE_OFFSET      = 17092609,

        _257       = 17093359,
        _259       = 17093361,
        QM1        = 17093472,
        BLANK1     = 17093473,
        BLANK2     = 17093474,
        BLANK3     = 17093475,
        NASHMEIRA1 = 17093476,
        NASHMEIRA2 = 17093477,
        RAZFAHD    = 17093478,
        CSNPC1     = 17093479,
        GHATSAD    = 17093480,
        ALEXANDER  = 17093481,
        CSNPC2     = 17093482,
        WEATHER    = 17093423,

        -- Nyzul Isle Investigation (instance 51) -- genuinely new, Topaz's addition. Ids confirmed
        -- against our own npc_list.sql (all real, pre-existing rows).
        RUNE_OF_TRANSFER_OFFSET   = 17093330, -- moving rune used on each floor (paired with +1, one hidden at a time)
        RUNE_OF_TRANSFER_ENTRANCE = 17093429, -- lobby rune, opens the floor-select menu
        RUNIC_LAMP_OFFSET         = 17093332, -- first of the 5-lamp block (17093332-17093336)
        VENDING_BOX               = 17093430,
        -- Real model 965 ("965 -- Blue Casket", matching caskets.lua's own documented mesh).
        -- Exactly 3 of these real-model crates exist (17093609-17093611, real distinct npc_list
        -- positions), unregistered to any other instance. ARMOURY_CRATE_OFFSET is the single
        -- leader-kill drop crate; all 3 (OFFSET..OFFSET+2) are used together for Free Floor's real
        -- "random Armoury Crates scattered about" per BG Wiki/FFXIclopedia.
        ARMOURY_CRATE_OFFSET      = 17093609,
    }
}

-- 2026-10-02: Topaz scripts index NyzulIsle.npcs; DSP's table here is named npc. Alias so both resolve
-- (nil .npcs broke 52's onInstanceTimeUpdate every tick and every npcs.* lookup in globals/nyzul).
NyzulIsle.npcs = NyzulIsle.npc
