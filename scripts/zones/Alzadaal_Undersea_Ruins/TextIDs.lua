-- DSP-PORT-MERGE: DSP's own pre-existing values kept below where Topaz has no equivalent key.
-- For the 4 keys both files define (CANNOT_ENTER/MEMBER_NO_REQS/MEMBER_TOO_FAR/KEYITEM_OBTAINED),
-- DSP's numbers were consistently 2 lower than Topaz's re-verified numbers (confirmed against a
-- real client dialog table dump this session) -- using Topaz's values below. NOTHING_HAPPENS=119
-- matched exactly between both sources (a stable cross-zone system message id), which is the one
-- data point suggesting the +2 pattern is real drift in DSP's file, not a different client
-- generation -- but **not live-tested against the actual target DSP client**, verify before
-- treating as final. See MERGE_DECISIONS.md.

-- Variable TextID   Description text

-- General Texts
ITEM_CANNOT_BE_OBTAINED = 6380; -- You cannot obtain the item <item> come back again after sorting your inventory
          ITEM_OBTAINED = 6386; -- Obtained: <item>
           GIL_OBTAINED = 6387; -- Obtained <number> gil
       KEYITEM_OBTAINED = 6391; -- Obtained key item: <keyitem>. -- was 6389 in DSP's own file, +2 per Topaz's re-verified value

-- Assault / Salvage
CANNOT_ENTER = 7441; -- You cannot enter at this time.  Please wait a while before trying again. -- was 7439
AREA_FULL = 7440; -- This area is fully occupied. You were unable to enter.
MEMBER_NO_REQS = 7446; -- Not all of your party members meet the requirements for this objective.  Unable to enter area. -- was 7444
MEMBER_TOO_FAR = 7450; -- One or more party members are too far away from the entrance.  Unable to enter area. -- was 7448
MEMBER_IMBUED_ITEM = 7449; -- One or more party members are carrying imbued items. Unable to enter area
IMBUED_ITEM = 7450; -- You are carrying imbued items. Unable to enter area
MYTHIC_REQUIRED = 7452; -- You do not have the appropriate mythic weapon equipped. Unable to enter area.

-- Nyzul Isle Investigation (mission 51) entry gating -- genuinely new, Topaz's addition. DSP had
-- none of these; needed by _20c.lua/_20d.lua/_20m.lua/Shahayl.lua.
MOVE_CLOSER             = 7209; -- You must move closer.
IMPERIAL_CONTROL        = 7210; -- This gate guards an area under Imperial control.
STAGING_POINT_NYZUL     = 7216; -- Nyzul Isle Staging Point.
CANNOT_LEAVE            = 7220; -- You cannot leave this area while in the possession of <keyitem>.

-- Other Texts
      NOTHING_HAPPENS = 119; -- Nothing happens...
             RESPONSE = 7227; -- There is no response...
DEVICE_MALFUNCTIONING = 7243; -- The device appears to be malfunctioning...
