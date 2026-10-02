-- Lebros Cavern: Variable TextID Definitions

-- Assault start messages - must be flat globals to be accessible after
-- require("scripts/zones/Lebros_Cavern/TextIDs"). See Mamool_Ja_Training_Grounds/TextIDs.lua
-- convention for this pattern.
ASSAULT_21_START        = 7367; -- Commencing <assault>! Objective: Remove the obstructions
ASSAULT_22_START        = 7368; -- Commencing <assault>! Objective: Deliver the provisions
ASSAULT_23_START        = 7369; -- Commencing <assault>! Objective: Destroy the Troll fugitives
ASSAULT_24_START        = 7370; -- Commencing <assault>! Objective: Discover alternate route
ASSAULT_25_START        = 7371; -- Commencing <assault>! Objective: Assassinate Borgerlur
ASSAULT_26_START        = 7372; -- Commencing <assault>! Objective: Match the Apkallu
ASSAULT_27_START        = 7373; -- Commencing <assault>! Objective: Remove the threat
ASSAULT_28_START        = 7374; -- Commencing <assault>! Objective: Drive out the hunters
ASSAULT_29_START        = 7375; -- Commencing <assault>! Objective: Rescue Princess Kadjaya
ASSAULT_30_START        = 7376; -- Commencing <assault>! Objective: Defeat Black Shuck

-- Instance messaging texts (must be flat globals for the same reason)
TIME_TO_COMPLETE        = 7407; -- You have <number> [minute/minutes] (Earth time) to complete this mission.
MISSION_FAILED          = 7408; -- The mission has failed. Leaving area.
RUNE_UNLOCKED_POS       = 7409; -- Mission objective completed. Unlocking Rune of Release ([A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-T-U-V-W-X-Y-Z]-#).
RUNE_UNLOCKED           = 7410; -- Mission objective completed. Unlocking Rune of Release.
ASSAULT_POINTS_OBTAINED = 7411; -- You gain <number> [Assault point/Assault points]!
TIME_REMAINING_MINUTES  = 7412; -- Time remaining: <number> [minute/minutes] (Earth time).
TIME_REMAINING_SECONDS  = 7413; -- Time remaining: <number> [second/seconds] (Earth time).
FADES_INTO_NOTHINGNESS  = 7414; -- The <keyitem> fades into nothingness...
PARTY_FALLEN            = 7415; -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].

-- Evade and Escape (24) Switch messages
SWITCH_ACTIVATED        = 7436; -- A switch lights up on the device...It is flickering faintly...
SWITCH_EXPIRING         = 7437; -- The switch looks like it may cut out at any moment...
SWITCH_NOTHING          = 7438; -- Nothing happens... The other switches appear to have shut down as well...
SWITCH_REFRESHED        = 7439; -- The switch on the device is glowing brightly.\nYou don't think it will fade any time soon.

-- General Texts (used by giveitem and other GM commands)
ITEM_CANNOT_BE_OBTAINED    = 6382; -- You cannot obtain the <item>. Come back after sorting your inventory.
-- Shadow Western_Adoulin's leaked _1/_2/_3 variants (npcUtil.giveItem prefers them; _2=6379 is the 'token of thanks' text)
ITEM_CANNOT_BE_OBTAINED_1 = 6382
ITEM_CANNOT_BE_OBTAINED_2 = 6382
ITEM_CANNOT_BE_OBTAINED_3 = 6382
          ITEM_OBTAINED = 6389; -- Obtained: <item>.
           GIL_OBTAINED = 6390; -- Obtained <number> gil.
       KEYITEM_OBTAINED = 6391; -- Obtained key item: <keyitem>.
