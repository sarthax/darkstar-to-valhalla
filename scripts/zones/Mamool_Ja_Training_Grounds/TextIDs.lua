-----------------------------------
-- Area: Mamool_Ja_Training_Grounds
-- Text message ids only -- old-dsp-reference (DarkstarProject/darkstar) convention confirmed by
-- reading scripts/zones/Ilrusi_Atoll/TextIDs.lua directly: flat bare globals at the top level, no
-- wrapping table of any kind, and NO MobIDs.lua exists for this zone at all (see mob/npc ids
-- hardcoded directly in each consumer script instead, same as the real Rune_of_Release.lua/
-- Ancient_Lockbox.lua convention).
-----------------------------------

-- This block (like Leujaoam Sanctum's identical one) was off by exactly -1 -- confirmed
-- against this zone's real client dialog table via dat-extractor. Only Supplies_Crate.lua
-- references these.
ITEM_CANNOT_BE_OBTAINED = 6382; -- You cannot obtain the <item>. Come back after sorting your inventory.
-- Shadow Western_Adoulin's leaked _1/_2/_3 variants (npcUtil.giveItem prefers them; _2=6379 is the 'token of thanks' text)
ITEM_CANNOT_BE_OBTAINED_1 = 6382
ITEM_CANNOT_BE_OBTAINED_2 = 6382
ITEM_CANNOT_BE_OBTAINED_3 = 6382
ITEM_OBTAINED           = 6388; -- Obtained: <item>.
GIL_OBTAINED            = 6389; -- Obtained <number> gil.
KEYITEM_OBTAINED        = 6391; -- Obtained key item: <keyitem>.
-- Real value confirmed via dat-extractor -- same shared system message already confirmed
-- for Leujaoam Sanctum's Orichalcum Survey fix, reused here by Supplies_Crate.lua.
PLAYER_OBTAINS_TEMP_ITEM = 7310; -- Obtained temporary item: <item>!
CARRIED_OVER_POINTS     = 7000; -- You have carried over <number> login point[/s].
LOGIN_CAMPAIGN_UNDERWAY = 7001; -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
LOGIN_NUMBER            = 7002; -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
-- Block below was off by exactly +1, verified against a real client dialog table dump
-- (same shared 7507-7515 block as Leujaoam Sanctum).
ASSAULT_11_START        = 7457; -- Commencing <assault>! Objective: Rescue the agent
ASSAULT_12_START        = 7458; -- Commencing <assault>! Objective: Destroy the assassins
ASSAULT_13_START        = 7459; -- Commencing <assault>! Objective: Defeat Sagelord Molaal Ja
ASSAULT_14_START        = 7460; -- Commencing <assault>! Objective: Steal the supplies
ASSAULT_15_START        = 7461; -- Commencing <assault>! Objective: Apprehend the spy
ASSAULT_16_START        = 7462; -- Commencing <assault>! Objective: Recover the treasure
ASSAULT_17_START        = 7463; -- Commencing <assault>! Objective: Annihilate the enemy
ASSAULT_18_START        = 7464; -- Commencing <assault>! Objective: Neutralize the marids
ASSAULT_19_START        = 7465; -- Commencing <assault>! Objective: Gather pathological data
ASSAULT_20_START        = 7466; -- Commencing <assault>! Objective: Defeat Orochi
TIME_TO_COMPLETE        = 7507; -- You have <number> [minute/minutes] (Earth time) to complete this mission.
MISSION_FAILED          = 7508; -- The mission has failed. Leaving area.
RUNE_UNLOCKED_POS       = 7509; -- Mission objective completed. Unlocking Rune of Release ([A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z]-#).
RUNE_UNLOCKED           = 7510; -- Mission objective completed. Unlocking Rune of Release.
ASSAULT_POINTS_OBTAINED = 7511; -- You gain <number> [Assault point/Assault points]!
TIME_REMAINING_MINUTES  = 7512; -- Time remaining: <number> [minute/minutes] (Earth time).
TIME_REMAINING_SECONDS  = 7513; -- Time remaining: <number> [second/seconds] (Earth time).
FADES_INTO_NOTHINGNESS  = 7514; -- The <keyitem> fades into nothingness...
PARTY_FALLEN            = 7515; -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
-- Imperial Treasure Retrieval -- Zahakahm's real turn-in dialogue. The raw CapLog's MesNum
-- labels (7599/7600) were drifted vs. this zone's real client table (dat-extractor
-- confirmed those actually decode to unrelated "ally obtained/took X" flavor text). Real
-- indices found by searching dat-extractor for the actual spoken text.
ZAHAKAHM_INTRO_1          = 7581; -- Listen up! The enemy has stolen multiple gems from the Empress's royal treasury! The treasure has been sighted in this area!
ZAHAKAHM_INTRO_2          = 7582; -- You will get them back from those two-legged lizards if it means your life! Do you hear me, soldiers?
ZAHAKAHM_INTRO_3          = 7583; -- Remember, the enemy will go to desperate measures to keep the treasure. Stay on your toes and don't let them take any gems back! Get to it now, soldiers!
ZAHAKAHM_GEM_SCORED       = 7584; -- Great work, soldier! I will see to it that this treasure is delivered back to the royal treasury. Now find the rest!
ZAHAKAHM_MISSION_COMPLETE = 7585; -- You have collected <number> [gem/gems]... Great work, soldier! The Empress will hear of this.
-- Coffer/carrier/steal system messages, dat-extractor-confirmed. Raw CapLog labels
-- 7606/7607 for the carrier lines were also drifted (decode to unrelated Escort-mission
-- NPC lines) -- real indices found by searching for the actual spoken text.
LOST_CARRIED_GEMS         = 7588; -- You have lost the gems you were carrying.
GOVERNOR_STEAL_TAUNT      = 7589; -- Ahahaha! Mine, the treasure is!!!
CARRIER_STEAL_TAUNT       = 7590; -- Scaleless heathen! Our treasure, you steal!
CARRIER_IDLE_TAUNT        = 7591; -- Poor try, that was. Here, no treasure!
CARRIER_FOUND_GEM         = 7594; -- Oh, found something! To safe place, must move this!
PLAYER_OBTAINS_TREASURE_ITEM = 7595; -- Obtained temporary item: <item>!
COFFER_ALREADY_EMPTY     = 7597; -- Some strange force is preventing you from taking the treasure out of the box.
STEAL_FAILED_FROM_ENEMY  = 7598; -- Some strange force prevented you from taking treasure from the enemy.
ALLY_OBTAINED_TREASURE   = 7599; -- One of your allies obtained <item> from a treasure box!
ALLY_TOOK_TREASURE       = 7600; -- One of your allies took <item> from the enemy!
ALLY_RECOVERED_TREASURE  = 7601; -- One of your allies successfully recovered <item>!
ENEMY_OBTAINED_TREASURE  = 7602; -- The enemy obtained <item> from a treasure box.
ENEMY_STEALS_TREASURE    = 7603; -- The enemy steals <item> from one of your allies.
RECOVERED_ALL_TREASURE   = 7605; -- You have recovered all the treasure.
-- Blitzkrieg (17) -- all dat-extractor-confirmed. Real capture confirms KILL_TALLY fires
-- every 5 kills and WAVE1_DECIMATED at 200 (the capture ends exactly there, "purely
-- optional" per the wiki past that point). WAVE2_DECIMATED/WAVE2_ADVANCING/prisoner
-- dialogue/GATE_LOCKED_NEED_ITEM are dialog-table-confirmed only, not capture-confirmed
-- (no available capture attempted the prisoner rescue or wave 2).
KILL_TALLY               = 7629; -- You have defeated <number> [opponent/opponents]!
WAVE1_ADVANCING          = 7625; -- The first wave of enemy forces is advancing...
WAVE1_DECIMATED          = 7627; -- You have decimated the first wave of enemy forces!
WAVE2_ADVANCING          = 7626; -- The second wave of enemy forces starts pouring in!
WAVE2_DECIMATED          = 7628; -- You have decimated the second wave of enemy forces!
GATE_LOCKED_NEED_ITEM    = 7624; -- The gate is locked. Maybe you could open it if you had temporary item: <item>...
-- Real escort-prisoner combat-reaction dialogue -- exact trigger conditions not
-- capture-confirmed, ordered by dat-extractor index as a reasonable escalation.
PRISONER_HELP_PLEA       = 7615; -- Well, are you gonna help me!?
PRISONER_CANT_GO_ON      = 7616; -- Can't...go on...
PRISONER_THANKS_1        = 7617; -- Thank ya kindly.
PRISONER_THANKS_2        = 7618; -- Thank ya very kindly!
PRISONER_HIT_1           = 7619; -- Ugh, and I just had my nails done!
PRISONER_HIT_2           = 7620; -- Ouch, that hurt! Hey, aren't you supposed to protect me!?
PRISONER_HIT_3           = 7621; -- Ouch! That's it! You're really starting to irritate me!
PRISONER_HIT_4           = 7622; -- How dare you attack a poor, defenseless lady... You'll pay for this...
PRISONER_LOW_HP          = 7623; -- The...pain... I don't think I can last much longer...
-- Lumaayu (Blitzkrieg's prisoner) -- dat-extractor-confirmed, matched via her name once
-- cross-checked against this file's own pre-existing note flagging her as unwired.
LUMAAYU_CAGE_1           = 7612; -- Heeey!
LUMAAYU_CAGE_2           = 7613; -- Is anyone out there...!?
LUMAAYU_CAGE_3           = 7614; -- This place stinks really bad...
LUMAAYU_GREET            = 7606; -- I'm Lumaayu of the Black Leopards. If you hadn't saved me...
LUMAAYU_ASK_ESCORT       = 7607; -- Why, this must be the workings of destiny!... bringing little ol' me to a safe place...
LUMAAYU_FOLLOW_NAG_1     = 7608; -- Wait uuup! You wouldn't leave a poor girl all alone...
LUMAAYU_FOLLOW_NAG_2     = 7609; -- Don't leave me! Whatever am I gonna do without you...?
LUMAAYU_RETURNED         = 7610; -- Oh, there you are!!! You had me so worried!...
LUMAAYU_ARRIVED_SAFE     = 7611; -- I should be fine here. The rest of my unit should be here soon. Thank ya kindly.
-- Sagelord Elimination (13): real dialogue from the same capture that confirmed Warm-Up and
-- Warp. SAGELORD_WARP_CAST fires the instant he starts casting Warp in the capture, wired
-- into his Warp escape below. SAGELORD_POST_WARP_1/2 fire 6s/9s later with combat clearly
-- still continuing -- read as an interim/non-final Warp in that playthrough rather than
-- this mechanic's true 20%-threshold escape, so NOT wired in (would fire after he's already
-- despawned). Kept for reference in case a cleaner capture surfaces later.
SAGELORD_WARP_CAST     = 7530; -- <Cough, cough>... Pay for...insulting the Sagelord...you shall...
SAGELORD_POST_WARP_1   = 7531; -- Your face...<gasp>...into our memory...we have burned...<cough>...
SAGELORD_POST_WARP_2   = 7532; -- Pay dearly...you shall...
-- The Double Agent -- rebuilt from 2 independent captures + a wiki walkthrough + dat-
-- extractor ground truth; every id below is dat-extractor-CONFIRMED, not capture-inferred
-- (the raw captures' own MesNum values were drifted +9 vs. the real client table, confirmed
-- independently on 2 different lines). The prior single-capture "-1 offset" version had
-- several ids actively wrong (e.g. old REAL_HINT=7582 decodes to unrelated gem-mission text).
--
-- Real mechanic (wiki-confirmed, matches both captures): each Qiqirn Spy opens a menu --
-- "capture" or "question" (7577). Question gives a real, position-dependent hint (distance
-- tier via 7560-7563, direction varies by the asked Qiqirn's position relative to the real
-- spy, since Qiqirns wander); the real spy's own hint is deliberately unreliable/sometimes
-- absent. Capture on the real spy completes the mission (7572); capture on a decoy
-- permanently locks that Qiqirn out and costs Assault points (~74 points/wrong guess,
-- derived from the wiki's "3 wrong: 1758pts" vs "0 wrong: 1980pts" solo data points).
QIQIRN_SPY_GREETING       = 7576; -- "What yooo want?" -- shown before the capture/question/nothing menu
QIQIRN_SPY_MENU           = 7577; -- the real 3-option Selection Dialog: "To capture yooo." / "To question yooo." / "Nooothing at all."
QIQIRN_SPY_DIST_VERY_CLOSE = 7560; -- question, decoy: "Shooold really really be close, okay?"
QIQIRN_SPY_DIST_CLOSE      = 7561; -- question, decoy: "Shooold be close, okay?"
QIQIRN_SPY_DIST_FAR        = 7562; -- question, decoy: "Shooold be far from here, okay?"
QIQIRN_SPY_DIST_VERY_FAR   = 7563; -- question, decoy: "Shooold really really be far, okay?"
-- User-provided real full dialog table dump (7547-7580) fills in the numeric-yalm hint
-- style and confirms the real spy's hint is randomly drawn from a pool, not one fixed line.
QIQIRN_SPY_DIST_YALMS      = 7547; -- question, decoy: "Just <N> yalm(s) over there, okay?" -- takes a numeric param, client handles singular/plural
-- Exact (8-way) and vague (4-way, cardinal only) direction hints, from the same dump. Keyed
-- by compass octant (0=N/1=NE/2=E/3=SE/4=S/5=SW/6=W/7=NW) -- see npcs/Qiqirn_Spy.lua for how
-- the octant is computed (npc:lookAt() + worldAngle()'s rotation-byte convention,
-- confirmed 0=N/64=E/128=S/192=W). Raw dump order (E/SE/S/SW/W/NW/N/NE) reordered here to
-- match the octant index directly.
QIQIRN_SPY_DIR_EXACT = { [0] = 7554, [1] = 7555, [2] = 7548, [3] = 7549, [4] = 7550, [5] = 7551, [6] = 7552, [7] = 7553 };
QIQIRN_SPY_DIR_VAGUE = { [0] = 7559, [2] = 7556, [4] = 7557, [6] = 7558 }; -- N/E/S/W only, snapped to nearest cardinal
QIQIRN_SPY_REAL_HINT      = 7568; -- question, REAL spy (unreliable/no real info): "Hooo hooo... Nooo listen... Laaa laaa..."
-- Wiki walkthrough quotes 3 different real-spy hint lines across playthroughs ("Noooo
-- Listen", "I know noooothing, yooo know?", "There nooo Qiqirn like that, yooo know?") --
-- match 7568/7564/7567 verbatim, so the real spy's hint is a random pick from this pool.
-- 7565/7566 are the same "unhelpful filler" family (same header text/era) with no wiki
-- quote confirming them specifically, but clearly part of the same set.
QIQIRN_SPY_REAL_HINT_POOL = { 7568, 7564, 7565, 7566, 7567 };
QIQIRN_SPY_CAPTURE_FAIL_A = 7571; -- capture, decoy (variant A): "Have nooo secret infooo, so very sad. Maybe cry, okay?"
QIQIRN_SPY_CAPTURE_FAIL_B = 7573; -- capture, decoy (variant B): "Have nooo secret infooo. Hm hm hm... sooo shock, no?"
QIQIRN_SPY_REAL_CAUGHT    = 7572; -- capture, REAL spy: "...How yooo know that?" -- completes the mission
QIQIRN_SPY_DECOY_TAUNT    = 7574; -- decoy, after mission completes: "Hoo hoo... Yooo catched double agent, nooo?"
QIQIRN_SPY_REAL_LEAVE     = 7575; -- real spy, after mission completes: "Yooo no staaare. Yooo leave alone!"
-- Azure Ailments: raw event/MesNum ids from an older Tacocat capture/client pairing than
-- the Thris set above -- this whole block's own header already flagged them as "not
-- cross-checked against a client dialog table dump -- best-effort, verify in-game."
-- 2026-09-12 CORRECTED: full project-wide ID-drift audit (mission_toolkit.py fresh
-- dat-extractor dump for this zone) confirmed real ids/structure. 3 real findings:
-- 1. AZURE_AILMENTS_INTRO (136) was wired as a startEvent() CSID (Garjham.lua) -- but this
--    zone's real event table (events.yml) has NO csid 136 at all. The real text
--    ("Ah, we've been waiting...") sits in the plain DIALOG table at 7638, immediately
--    followed by a second real line ("To gather proper data...expose yourself to at least
--    three...") at 7639 -- this is genuinely 2 plain dialog lines, not a cutscene. Garjham.lua
--    updated to showText() both instead of startEvent().
-- 2. AZURE_AILMENTS_REMINDER's real text ("There are seven all together...") is actually at
--    7640, not 7648 (7648 is a different, unrelated closing line -- "And that is all we
--    require from you today...").
-- 3. AZURE_AILMENTS_CHECK was a single id (7654, itself wrong content -- "no longer any
--    carriers in the vicinity", an unrelated line) standing in for what's really 7 DISTINCT,
--    individually-worded per-ailment lines (7641-7647), not one shared template with an
--    <Ailment> substitution as the old comment assumed. Split into a real per-effect table,
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
--    keyed by the same tpz.effect ids Garjham.lua's own TARGET_EFFECTS already uses.
AZURE_AILMENTS_INTRO    = 7638; -- Ah, we've been waiting for you, Subject...K-7.
AZURE_AILMENTS_INTRO2   = 7639; -- To gather proper data on how to combat the sickness, we will need you to expose yourself to at least three of the status ailments associated with the kraken flu.
AZURE_AILMENTS_REMINDER = 7640; -- There are seven all together: Amnesia, Bio, Disease, Slow, STR Down, Attack Down, and...ah, yes, Evasion Down.
AZURE_AILMENTS_CHECK =
{
    [EFFECT_DISEASE]      = 7641, -- Subject K-7. Disease... Check. High fever and pale facial coloring noted.
    [EFFECT_SLOW]         = 7642, -- Subject K-7. Slow... Check. Muscle deterioration resulting in lowered reflexes noted.
    [EFFECT_AMNESIA]      = 7643, -- Subject K-7. Amnesia... Check. Glazed eyes and blank expression noted.
    [EFFECT_BIO]          = 7644, -- Subject K-7. Bio... Check. Festering pustules and rancid odor noted.
    [EFFECT_STR_DOWN]     = 7645, -- Subject K-7. STR Down... Check. Severe loss of muscle mass noted.
    [EFFECT_ATTACK_DOWN]  = 7646, -- Subject K-7. Attack Down... Check. High levels of fatigue noted.
    [EFFECT_EVASION_DOWN] = 7647, -- Subject K-7. Evasion Down... Check. Loss of eye-to-hand coordination noted.
};
-- Imperial Agent Rescue: Brujeel's rescue dialogue. First guessed via the -1 offset that
-- worked for the ASSAULT_11..20_START block -- WRONG, confirmed live (showed unrelated
-- Supplies Recovery flavor text). Re-derived by extracting the real client dialog table
-- directly (this zone's actual DialogTable) and searching for "glad to see you" -- exact
-- match at 7524, rest of the sequence following at 7525-7529. The -1 offset does NOT apply
-- uniformly across this zone's whole message range -- don't assume it elsewhere without
-- extracting and checking directly.
BRUJEEL_GLAD_TO_SEE_YOU    = 7524; -- "Am I glad to see you!"
BRUJEEL_SORRY_TROUBLE      = 7525; -- "Sorry to put you to all this trouble. A professional like me should never have been caught in the first place..."
BRUJEEL_CANT_HANG_AROUND   = 7526; -- "Well, I can't be hanging around here."
BRUJEEL_LATE_ASSIGNMENT    = 7527; -- "I'll be late for my next assignment. I hate to be rescued and run, but I must be off."
BRUJEEL_DONT_MENTION       = 7528; -- "Oh, I'm sure I don't have to mention this, but..."
BRUJEEL_DIDNT_SEE_ANYTHING = 7529; -- "You didn't see anything. You didn't hear anything. Got it?"

-- Breaking Morale (mission 14): real text ids, same dialog table as the Brujeel block
-- above, extracted directly via dat-extractor -- no offset applied, ground truth. Full
-- mechanic per FFXIclopedia: loot 8 real Supplies Crates, turn each in to Quhaaja, avoid
-- being seen by Mamool Ja Trainers (true sight -- catches you, teleports to a "prison" next
-- to Viscous Liquid, strips any held item), can drink from Viscous Liquid for a Mamool Ja
-- costume disguise (breaks on opening a crate). Completion is player-choice via Quhaaja's
-- "give up" option once holding no items, not an automatic all-8 requirement.
VISCOUS_LIQUID_EXAMINE  = 7534; -- "There is a curious liquid here."
VISCOUS_LIQUID_PROMPT   = 7535; -- "Take a sip? [I'll try anything once! / I have a weak stomach...]"
VISCOUS_LIQUID_DECLINED = 7536; -- "Nothing happens."
VISCOUS_LIQUID_COSTUME  = 7537; -- "<Player Name> is overcome by a peculiar sensation."
QUHAAJA_GIVE_UP_ASK     = 7538; -- "Do you want to give up?"
QUHAAJA_GIVE_UP_PROMPT  = 7539; -- "End the mission? [Give up. / Not yet.]"
QUHAAJA_MISSION_INTRO   = 7540; -- "The time for this mission is limited. Get as many supplies as you can..."
QUHAAJA_ITEM_ACCEPTED   = 7541; -- "Great, you found some supplies! I'll hold on to them for you. Keep it up, soldier!"
QUHAAJA_SEIZED_COUNT    = 7542; -- "You managed to seize <N> supply package(s). Great work, soldier!"
QUHAAJA_WORK_DONE       = 7543; -- "Our work here is done. Time to leave this hellhole, soldier."
TRAINER_CAUGHT_TELEPORT = 7544; -- "You seem to have been brought here by some strange magic..."
TRAINER_ITEM_STRIPPED   = 7545; -- "The supplies you seized are missing!"
TRAINER_CAUGHT_TAUNT    = 7546; -- "Scaleless heathen... A taste of my wrath, you shall have!"
