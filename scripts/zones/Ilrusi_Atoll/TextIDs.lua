-----------------------------------
-- Area: Ilrusi_Atoll
-- Text message ids only -- old-dsp-reference (DarkstarProject/darkstar) convention confirmed by
-- reading scripts/zones/Ilrusi_Atoll/TextIDs.lua directly: flat bare globals at the top level, no
-- wrapping table of any kind, and NO MobIDs.lua exists for this zone at all (see mob/npc ids
-- hardcoded directly in each consumer script instead, same as the real Rune_of_Release.lua/
-- Ancient_Lockbox.lua convention).
-----------------------------------

ITEM_CANNOT_BE_OBTAINED = 6382; -- You cannot obtain the <item>. Come back after sorting your inventory.
-- Shadow Western_Adoulin's leaked _1/_2/_3 variants (npcUtil.giveItem prefers them; _2=6379 is the 'token of thanks' text)
ITEM_CANNOT_BE_OBTAINED_1 = 6382
ITEM_CANNOT_BE_OBTAINED_2 = 6382
ITEM_CANNOT_BE_OBTAINED_3 = 6382
ITEM_OBTAINED           = 6389; -- Obtained: <item>.
GIL_OBTAINED            = 6390; -- Obtained <number> gil.
KEYITEM_OBTAINED        = 6391; -- Obtained key item: <keyitem>.
CARRIED_OVER_POINTS     = 7000; -- You have carried over <number> login point[/s].
LOGIN_CAMPAIGN_UNDERWAY = 7001; -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
LOGIN_NUMBER            = 7002; -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
-- Block below was off by +1 (verified against this zone's own dialog table dump), AND the
-- ASSAULT_41-50_START comments/values were copy-pasted from Mamool Ja Training Grounds and
-- never corrected for this zone -- fixed both at once using this zone's real objective
-- text ("Find the figurehead", "Eliminate Lamia No.13", etc., at 7487-7496, not 7458-7467).
ASSAULT_41_START        = 7487; -- Commencing <assault>! Objective: Find the figurehead
ASSAULT_42_START        = 7488; -- Commencing <assault>! Objective: Eliminate Lamia No.13
ASSAULT_43_START        = 7489; -- Commencing <assault>! Objective: Exterminate all monsters
ASSAULT_44_START        = 7490; -- Commencing <assault>! Objective: Demolish the shipwrecks
-- Demolition Duty (mission 44) real dat-extractor-confirmed text, replacing the instance
-- file's earlier wrong guess (7561, which belongs to an unrelated Apkallu Seizure line).
UZHAHN_ASSIGN_AUTOMATON = 7540; -- You lot are the mercenary reinforcements? Great. Take this construction automaton...
AUTOMATON_TARGET_ACQUIRED = 7538; -- Target acquired. Initiating demoliton mode.
AUTOMATON_MASTER_NOT_FOUND = 7527; -- Master not found... Initiating safety program...
AUTOMATON_MASTER_DESTROYED = 7528; -- Master destroyed... Initiating safety program...
AUTOMATON_MASTER_PROFILE_LOST = 7529; -- Master profile lost. Initiating safety program...
AUTOMATON_SHUTDOWN_COUNTDOWN = 7530; -- Initiating safety program shutdown in...
AUTOMATON_COUNTDOWN_5 = 7531;
AUTOMATON_COUNTDOWN_4 = 7532;
AUTOMATON_COUNTDOWN_3 = 7533;
AUTOMATON_COUNTDOWN_2 = 7534;
AUTOMATON_COUNTDOWN_1 = 7535;
AUTOMATON_DELETE      = 7536;
AUTOMATON_SAFETY_SHUTDOWN = 7537; -- Safety program has been shut down. New master profile registered.
AUTOMATON_MALFUNCTION  = 7539; -- Danger. Danger. Malfunction. Malfun... <Beeeeeeeep> -- destruction cry, user-confirmed real
UZHAHN_REPAIR_START    = 7541; -- I told you to take it easy with this thing. Anyway, lemme fix 'er up...
UZHAHN_REPAIR_SUCCESS  = 7542; -- Everything seems to be in working order. You can get back to your demolition duty.
UZHAHN_REPAIR_NO_AUTOMATON = 7543; -- Eh? Where's the automaton? If you want me to fix 'er, you gotta bring 'er with you.
UZHAHN_AUTOMATON_BROKEN = 7544; -- What! You broke the automaton!? ...Hang on, I think I have a spare...
UZHAHN_AUTOMATON_LOST   = 7545; -- What! You lost the automaton!? ...Take this replacement and get back to work!
UZHAHN_DEMOLITION_COMPLETE = 7546; -- Looks like you're done with demolition duty. I've given you a score of <N> point(s)...
UZHAHN_COMPLETE_OTHER  = 7547; -- My unit will take care of the rest. Head on home. -- user-confirmed real, likely for party members who didn't personally trigger completion
ASSAULT_45_START        = 7491; -- Commencing <assault>! Objective: Save the Qiqirn divers
ASSAULT_46_START        = 7492; -- Commencing <assault>! Objective: Capture the apkallu
ASSAULT_47_START        = 7493; -- Commencing <assault>! Objective: Find the ring
ASSAULT_48_START        = 7494; -- Commencing <assault>! Objective: Locate the agents
ASSAULT_49_START        = 7495; -- Commencing <assault>! Objective: Collect ahtapot
ASSAULT_50_START        = 7496; -- Commencing <assault>! Objective: Defeat Khimaira 14X

-- Searat Salvation (mission 45): dat-extractor confirmed against a -8 offset (verified
-- exact against 6 independent NPC Chat events in the Siknawz capture -- raw MesNum minus 8
-- = real client table index).
SEARAT_CHIEF_INITIAL    = 7548; -- Yooo bring friends here tooo me. Theyy scared of orobooon.
SEARAT_CHIEF_INCOMPLETE = 7549; -- Hmmm, still not everybooody. Yooo bring everyboody!
SEARAT_CHIEF_ALL_SAVED  = 7550; -- Thank yooo! Yooo save everybooody!
SEARAT_DIVER_GREET      = 7551; -- Orobooon! Everybooody be eeeten by orobooon! Can yooo take me to boooss?
SEARAT_DIVER_LOST_BOSS  = 7552; -- Where did booosss get tooo...?
SEARAT_DIVER_READY      = 7553; -- Ready tooo gooo tooo boooss nooow.
SEARAT_DIVER_SCARED     = 7554; -- Aaahhh! Dooon't eeet meee!
SEARAT_DIVER_FLEEING    = 7555; -- Goootta run, goootta run, goootta run...
SEARAT_DIVER_ARRIVED    = 7556; -- Boooss!
SEARAT_DIVER_THANKS     = 7557; -- Thank yooo! Nasty orobooon...
SEARAT_OROBON_GROWL     = 7558; -- Glurp...
TIME_TO_COMPLETE        = 7507; -- You have <number> [minute/minutes] (Earth time) to complete this mission.
MISSION_FAILED          = 7508; -- The mission has failed. Leaving area.
RUNE_UNLOCKED_POS       = 7509; -- Mission objective completed. Unlocking Rune of Release ([A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z]-#).
RUNE_UNLOCKED           = 7510; -- Mission objective completed. Unlocking Rune of Release.
ASSAULT_POINTS_OBTAINED = 7511; -- You gain <number> [Assault point/Assault points]!
TIME_REMAINING_MINUTES  = 7512; -- Time remaining: <number> [minute/minutes] (Earth time).
-- Apkallu Seizure (mission 46): real text confirmed via dat-extractor, matched by exact
-- phrase against a real WIN capture's CapLog (Siknawz, "Ilrusi Atoll S - Apkallu Seizure (Win)").
APKALLU_CAPTURED     = 7559; -- You successfully capture the fairy apkallu!
APKALLU_STARING      = 7560; -- The fairy apkallu is staring at you.
APKALLU_RUNS_AWAY    = 7561; -- The fairy apkallu runs away!
APKALLU_WARY         = 7562; -- The fairy apkallu is wary of your presence.
APKALLU_GUARD_DOWN   = 7563; -- The fairy apkallu seems to have let down its guard a bit.
APKALLU_CURIOUS      = 7564; -- The fairy apkallu seems curious about you.
APKALLU_LIKES_YOU    = 7565; -- The fairy apkallu seems to like you.
APKALLU_KEEPS_STARING = 7566; -- The fairy apkallu keeps staring at you!
APKALLU_GIVE_ITEM    = 7568; -- You give the <item> to the fairy apkallu.
TIME_REMAINING_SECONDS  = 7513; -- Time remaining: <number> [second/seconds] (Earth time).
FADES_INTO_NOTHINGNESS  = 7514; -- The <keyitem> fades into nothingness...
PARTY_FALLEN            = 7515; -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
TOO_FAR_FROM_CHEST      = 7524; -- You must be closer to the chest to open it.
CHEST                   = 7525; -- The chest contains...
GOLDEN                  = 7526; -- ...a golden figurehead!
-- Lost and Found (mission 47): real dialogue/proximity-hint block confirmed from "Ilrusi
-- Atoll SM - Lost and Found (2)" (Giichi capture -- covers a full search-to-win run the
-- other 2 captures for this mission don't). Tian Tian's hint-cycle message IDs and the
-- win-trigger's own text read directly off the capture's decoded NPC Chat (0x036) lines --
-- not cross-checked against dat-extractor's table dump. Multi-tier hot/cold escalation is
-- confirmed real (progresses through "not think we will find anything" -> "let's try
-- somewhere else" -> "perhaps somewhere around here" -> "no mistake about it, something
-- nearby" -> "very close" as the player nears the real ring site) but the exact
-- distance-to-tier mapping isn't confirmed from one run -- NOT wired into a proximity
-- system this pass, text IDs only.
-- 2026-09-12 CORRECTED: full project-wide ID-drift audit (mission_toolkit.py fresh
-- dat-extractor dump, cross-checked against every entry's own comment text) found this
-- entire block off by a uniform +1 -- the original capture-only read above was never
-- cross-checked against the real dialog table, exactly the gap its own header already
-- flagged. Every id below shifted -1 to match the real table (e.g. TIAN_TIAN_GREET's own
-- comment text is the REAL text at 7573, not 7574; confirmed for the whole chain).
TIAN_TIAN_GREET       = 7573; -- You are the mercenary who has come to protect me, yes? Well then...shall we be on our way?
TIAN_TIAN_WAIT        = 7574; -- Please wait a moment. I must examine the energy flows here.
TIAN_TIAN_EXAMINING   = 7575; -- ......
TIAN_TIAN_COULD_WAIT  = 7576; -- Could you wait...?
TIAN_TIAN_IMAGE_COMING = 7577; -- It's coming... I'm getting an image! I need to concentrate just a little more!
TIAN_TIAN_VERY_CLOSE  = 7587; -- Ohhh yes, it is close...very close...
TIAN_TIAN_SOMETHING_NEARBY = 7588; -- No mistake about it... There is something nearby.
TIAN_TIAN_MAYBE_HERE  = 7589; -- Hmmm... Perhaps we can find it somewhere around here...
TIAN_TIAN_TRY_ELSEWHERE = 7590; -- Let's try somewhere else, shall we?
TIAN_TIAN_NOTHING_HERE = 7591; -- I do not think we will find anything around here...
TIAN_TIAN_VALUABLE_HINT = 7592; -- That may prove to be a valuable hint.
-- "I'm getting an image... The person closest to the ring is...<name>!" and "I get the
-- feeling that we should move our search <direction>..." are both real (same capture) but
-- their message IDs never appeared as their own distinct NPC Chat (0x036) line -- open gap,
-- not guessed here.
TIAN_TIAN_NO_HINTS_YET = 7596; -- We still have not found any hints...
EYE_OF_ZAHAK_FOUND    = 7579; -- This is it! The Eye of Zahak! (NPC-attributed to the pickup entity itself, id 17002672)
TIAN_TIAN_EXCITED     = 7601; -- Oh, this is most excellent! Now my powers will be even more renowned in Aht Urhgan!
