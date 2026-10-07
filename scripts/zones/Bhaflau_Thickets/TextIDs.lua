-- Variable TextID   Description text

-- General Texts
ITEM_CANNOT_BE_OBTAINED = 6382; -- You cannot obtain the item <item>. Come back after sorting your inventory.
          ITEM_OBTAINED = 6388; -- Obtained: <item>.
           GIL_OBTAINED = 6389; -- Obtained <number> gil.
       KEYITEM_OBTAINED = 6391; -- Obtained key item: <keyitem>.
 FISHING_MESSAGE_OFFSET = 7047; -- You can't fish here.
            HOMEPOINT_SET = 7690; -- Home point set!

-- Assault
CANNOT_ENTER = 7582; -- You cannot enter at this time.  Please wait a while before trying again.
AREA_FULL = 7583; -- This area is fully occupied. You were unable to enter.
MEMBER_NO_REQS = 7587; -- Not all of your party members meet the requirements for this objective.  Unable to enter area.
MEMBER_TOO_FAR = 7591; -- One or more party members are too far away from the entrance.  Unable to enter area.
 
-- Other Texts
NOTHING_HAPPENS = 7568; -- Nothing happens...
RESPONSE = 7327; -- There is no response...

--chocobo digging
DIG_THROW_AWAY = 7060; -- You dig up$, but your inventory is full. You regretfully throw the # away.
FIND_NOTHING = 7062; -- You dig and you dig, but find nothing.

-- Mercenary rank promotions / Assault backport additions (2026-09-13) -- confirmed absent from
-- this file natively (grep-verified codebase-wide), needed by npcs/{Warhorse_Hoofprint,
-- Mythralline_Wellspring,lance_corporal_common}.lua.
FELLOW_MESSAGE_OFFSET       = 6418; -- I'm ready. I suppose.
CARRIED_OVER_POINTS         = 7000; -- You have carried over <number> login point[/s].
LOGIN_CAMPAIGN_UNDERWAY     = 7001; -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
LOGIN_NUMBER                = 7002; -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
HARVESTING_IS_POSSIBLE_HERE = 7562; -- Harvesting is possible here if you have <item>.
WELLSPRING                  = 7645;
HOOFPRINT_FOUND             = 6398;
