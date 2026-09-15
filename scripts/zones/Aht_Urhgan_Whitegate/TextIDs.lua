-- Variable TextID   Description text

-- 2026-09-14, drift found (user-reported "Whitegate zone/id lua appears to have drift") and fixed:
-- this whole block below was DSP's original, never-audited baseline dump (raw/garbled comment text,
-- "?Prompt?"/"?BAD CHAR?" placeholders included) -- Topaz's own copy of this same block went
-- through a full dat-extractor re-audit on 2026-09-03 (every id individually text-verified against
-- a real client dialog dump, see that file's own header). Almost every id here was off by exactly
-- +2 from Topaz's corrected value (a real content-insertion offset, same class of bug as this
-- project's other zones) -- ITEM_OBTAINEDX and NOT_HAVE_ENOUGH_GIL were worse than a simple offset,
-- outright swapped with each other's real text. Mirrored Topaz's current, audited values below.

-- General Texts
ITEM_CANNOT_BE_OBTAINED = 220; -- You cannot obtain the <item>. Come back after sorting your inventory.
ITEM_CANNOT_BE_OBTAINEDX = 223; -- You cannot obtain the <item>. Try trading again after sorting your inventory.
          ITEM_OBTAINED = 225; -- Obtained: <item>.
         ITEM_OBTAINEDX = 1497; -- You obtain <item>!
           GIL_OBTAINED = 227; -- Obtained <number> gil.
       KEYITEM_OBTAINED = 228; -- Obtained key item: <keyitem>.
    NOT_HAVE_ENOUGH_GIL = 232; -- You do not have enough gil.
 FISHING_MESSAGE_OFFSET = 886; -- You can't fish here.
          HOMEPOINT_SET = 1366; -- Home point set!
          IMAGE_SUPPORT = 1407; -- Your [fishing/woodworking/smithing/goldsmithing/clothcraft/leatherworking/bonecraft/alchemy/cooking] skills went up [a little/ever so slightly/ever so slightly].

-- Conquest system
SANCTION = 9801; -- You have received the Empire's Sanction.

-- Quest dialogs
 ZASSHAL_DIALOG = 10995; -- 'ang about. Looks like the permit you got was the last one I 'ad, so it might take me a bit o' time to scrounge up some more. 'ere, don't gimme that look. I'll be restocked before you know it.
MUSHAYRA_DIALOG = 4964; -- Sorry for all the trouble. Please ignore Hadahda the next time he asks you to do something.
 HADAHDA_DIALOG = 4915; -- Hey, think you could help me out?
 PAY_DIVINATION = 8767; -- You pay 1000 gil for the divination.

 -- Other Dialogs
ITEM_DELIVERY_DIALOG = 9351; -- You have something you want delivered?
        RUNIC_PORTAL = 4584; -- You cannot use the runic portal without the Empire's authorization.
IMAGE_SUPPORT_ACTIVE = 1405; -- You have to wait a bit longer before asking for synthesis image support again.

-- Shop Texts
UGRIHD_PURCHASE_DIALOGUE = 4645; -- Salaheem's Sentinels values your contribution to the success of the company. Please come again!

      GAVRIE_SHOP_DIALOG = 9265; -- Remember to take your medicine in small doses... Sometimes you can get a little too much of a good thing!
      MALFUD_SHOP_DIALOG = 9266; -- Welcome, welcome! Flavor your meals with Malfud's ingredients!
     RUBAHAH_SHOP_DIALOG = 9267; -- Flour! Flooour! Corn! Rice and beans! Get your rice and beans here! If you're looking for grain, you've come to the right place!
     MULNITH_SHOP_DIALOG = 9268; -- Drawn in by my shop's irresistible aroma, were you? How would you like some of the Near East's famous skewers to enjoy during your journeys?
     SALUHWA_SHOP_DIALOG = 9269; -- Looking for undentable shields? This shop's got the best of 'em! These are absolute must-haves for a mercenary's dangerous work!
       DWAGO_SHOP_DIALOG = 9270; -- Buy your goods here...or you'll regret it!
 KULHAMARIYO_SHOP_DIALOG = 9271; -- Some fish to savorrr while you enjoy the sights of Aht Urhgan?
 KHAFJHIFANM_SHOP_DIALOG = 9272; -- How about a souvenir for back home? There's nothing like dried dates to remind you of good times in Al Zahbi!
    HAGAKOFF_SHOP_DIALOG = 9273; -- Welcome! Fill all your destructive needs with my superb weaponry! No good mercenary goes without a good weapon!
      BAJAHB_SHOP_DIALOG = 9274; -- Good day! If you want to live long, you'll buy your armor here.
     MAZWEEN_SHOP_DIALOG = 9275; -- Magic scrolls! Get your magic scrolls here!
    FAYEEWAH_SHOP_DIALOG = 9276; -- Why not sit back a spell and enjoy the rich aroma and taste of a cup of chai?
      YAFAAF_SHOP_DIALOG = 9277; -- There's nothing like the mature taste and luxurious aroma of coffee... Would you like a cup?

      WAHNID_SHOP_DIALOG = 9278; -- All the fishing gear you'll ever need, here in one place!
     WAHRAGA_SHOP_DIALOG = 9279; -- Welcome to the Alchemists' Guild. We open ourselves to the hidden secrets of nature in order to create wonders. Are you looking to buy one of them?

-- Automaton
      AUTOMATON_RENAME = 5830; -- Your automaton has a new name.
      AUTOMATON_VALOREDGE_UNLOCK = 9589; -- You obtain the Valoredge X-900 head and frame!
      AUTOMATON_SHARPSHOT_UNLOCK = 9594; -- You obtain the Sharpshot Z-500 head and frame!
      AUTOMATON_STORMWAKER_UNLOCK = 9599; -- You obtain the Stormwaker Y-700 head and frame!
      AUTOMATON_SOULSOOTHER_UNLOCK = 9631; -- You obtain the Soulsoother C-1000 head!
      AUTOMATON_SPIRITREAVER_UNLOCK = 9632; -- You obtain the Spiritreaver M-400 head!
      AUTOMATON_ATTACHMENT_UNLOCK = 9648; -- You can now equip your automaton with <item>.

-- Assault
    RYTAAL_MISSION_COMPLETE = 5652; -- Congratulations. You have been awarded Assault Points for the successful completion of your mission.
    RYTAAL_MISSION_FAILED = 5653; -- Your mission was not successful; however, the Empire recognizes your contribution and has awarded you Assault Points.

-- Porter Moogle
    RETRIEVE_DIALOG_ID = 13514; -- You retrieve <item> from the porter moogle's care.

-- 2026-09-14, real naming-collision bug found while auditing this file for drift: Abquhbah.lua
-- called player:messageSpecial(LANCE_CORPORAL) expecting the real "<player> has been promoted to
-- Lance Corporal!" TEXT id (6664, confirmed via Topaz's IDs.lua dat-extractor audit), but
-- globals/titles.lua ALSO defines a bare global named LANCE_CORPORAL = 490 (the unrelated TITLE
-- id) -- this codebase has no namespacing to keep those separate (unlike Topaz's ID.text.X vs
-- tpz.title.X), so messageSpecial was silently being called with the wrong id (490, not 6664).
-- Named distinctly here to avoid the collision -- see Abquhbah.lua's matching fix.
PROMOTED_TO_LANCE_CORPORAL = 6664; -- <player> has been promoted to Lance Corporal!

-- Mercenary rank promotions / Assault backport additions (2026-09-13) -- confirmed absent from
-- this file natively (grep-verified codebase-wide), needed by npcs/{Abquhbah,Naja_Salaheem,
-- lance_corporal_common}.lua and Assault mission-giver reward/dialogue flows.
YOU_MUST_WAIT_ANOTHER_N_DAYS  = 833; -- You must wait another <number> [day/days] to perform that action.
CARRIED_OVER_POINTS           = 836; -- You have carried over <number> login point[/s].
LOGIN_CAMPAIGN_UNDERWAY       = 837; -- The [/January/.../December] <number> Login Campaign is currently underway!<space>
LOGIN_NUMBER                  = 838; -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
MOG_LOCKER_OFFSET             = 1225; -- Your Mog Locker lease is valid until <timestamp>, kupo.
GATE_IS_FIRMLY_CLOSED         = 1424; -- The gate is firmly closed...
REGIME_CANCELED               = 1466; -- Current training regime canceled.
HUNT_ACCEPTED                 = 1484; -- Hunt accepted!
USE_SCYLDS                    = 1485; -- You use <number> [scyld/scylds]. Scyld balance: <number>.
HUNT_RECORDED                 = 1496; -- You record your hunt.
OBTAIN_SCYLDS                 = 1498; -- You obtain <number> [scyld/scylds]! Current balance: <number> [scyld/scylds].
HUNT_CANCELED                 = 1502; -- Hunt canceled.
YOU_CAN_BECOME_PUP            = 5833; -- You can now become a puppetmaster!
GATHWEEDA_SHOP_DIALOG         = 9280; -- Only members of the Alchemists' Guild have the vision to create such fine products... Would you like to purchase something?
COMMON_SENSE_SURVIVAL         = 14380; -- It appears that you have arrived at a new survival guide provided by the Adventurers' Mutual Aid Network. Common sense dictates that you should now be able to teleport here from similar tomes throughout the world.
