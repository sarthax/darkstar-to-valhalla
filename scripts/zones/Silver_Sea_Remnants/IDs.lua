-----------------------------------
-- Area: Silver_Sea_Remnants
-----------------------------------
-- Real ids/positions below are from a real Silver Sea Remnants capture (Mission Toolkit capture
-- #113, "CapFFXI - Salvage II - Silver Sea Remnants +NPC - Mrohk Sahjuuli"). Cross-checked against
-- Topaz's own SQL first (same discipline as Bhaflau Remnants) -- 121 of 124 real captured entities
-- already had a real row in Topaz's own SQL, with ids AND names matching exactly (no drift found
-- here, unlike Bhaflau's door-naming issue).
-- The 3 RunicLamp npcs (17089354/17089355/17089367) were genuinely new to THIS capture, but
-- Topaz's SQL already had real "NC:" placeholders waiting for exactly these 3 ids (uncommented and
-- filled in, same pattern as Bhaflau's Slot/Socket) -- the capture's own filename says "Salvage II"
-- (BG Wiki: Silver Sea Remnants II is the real level-99 variant, with its own Runic Lamp mechanic,
-- distinct from the level-75 page this file otherwise matches) and Topaz has only ONE zoneid for
-- this zone (76, no separate "_II"), so these 3 ids are real but may be level-99-specific content
-- -- not fabricated, just flagged as an open question whether Topaz's implementation is meant to
-- include them for both level variants or not. 2 more Runic Lamp placeholders
-- (17089356/17089357) are still genuinely uncaptured.
-- Slot/Socket/Armoury Crate are NOT absent -- checked directly and Topaz's SQL already has real,
-- ACTIVE rows: ARMOURY_CRATE fixed crate (17088809, "Armoury crates seems to move and be reused in
-- other parts" per the SQL's own comment -- same repositionable-pool mechanic as Bhaflau), SOCKET
-- (17089352), SLOT (17089353) -- simply not observed in this one capture. 4 more Armoury Crate pool
-- ids (17088820-17088823) are still genuinely uncaptured (real "NC:" placeholders in Topaz's SQL,
-- zero position). This capture never reached the boss floor, so LONG_ARMED_CHARIOT's real id is
-- unconfirmed -- Topaz's own SQL has TWO real ids sharing that exact mobname (17088786 and
-- 17089250), and nothing in this capture disambiguates which is real for this zone's boss encounter
-- -- both listed, neither assumed. Floor/stage door-progression sequencing is also not built yet --
-- no event-sequence analysis done for this zone yet (see Bhaflau's IDs.lua for the methodology once
-- a second capture/video is available).
-----------------------------------
-----------------------------------

SilverSea =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED = 6380, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED           = 6388, -- Obtained: <item>.
        GIL_OBTAINED            = 6389, -- Obtained <number> gil.
        KEYITEM_OBTAINED        = 6391, -- Obtained key item: <keyitem>.
        CELL_OFFSET             = 7212, -- Main Weapon/Sub-Weapon restriction removed.
        -- text ids verified by TEXT against a fresh zone-76 dialog.yml pull (2026-10-09). Ids below verified by TEXT against a fresh same-session mission_toolkit dialog.yml
        TEMP_ITEM               = 7233, -- Obtained temporary item: <item>!
        HAVE_TEMP_ITEM          = 7234, -- You already have that temporary item.
        SALVAGE_START           = 7235, -- You feel an incredible pressure bearing down on you...
        TIME_TO_COMPLETE        = 7407, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED          = 7408, -- The mission has failed. Leaving area.
        TIME_REMAINING_MINUTES  = 7412, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS  = 7413, -- Time remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN            = 7415, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
        DOOR_IS_SEALED          = 7426, -- The door is sealed...
        NOT_RESPONDING          = 7429, -- The device doesn't respond...
        DOOR_IS_SEALED_MYSTERIOUS = 7428, -- The door is sealed by some mysterious force...
        SOCKET_TRIGGER          = 7430, -- You hear a ragged sighing from beneath the floor...
        SLOT_TRIGGER            = 7431, -- You hear a scuttering sound from beneath the floor...
        NOTHING_HAPPENS         = 119, -- Nothing happens...
    },
    mobs =
    {
        -- Boss floor -- see file header, two real ids share this mobname, neither confirmed yet
        LONG_ARMED_CHARIOT = { 17088786, 17089250 },
        -- Floor 1 trash mob roster (real, per BG Wiki: West/East branching, same pattern as Bhaflau)
        ASHU_TALIF_CREW    = { 17088949, 17088950, 17088951, 17088956, 17088957, 17088958, 17088966,
                                17088967, 17088968, 17088970, 17088971, 17088972, 17089083, 17089084,
                                17089085, 17089091, 17089092, 17089093 },
        -- Real, present across many rooms/floors per this capture -- role/floor not yet mapped in
        -- detail (BG Wiki mentions "Hammerblow Majanun" as a distinct NM, not observed here by name).
        ARCHAIC_RAMPART    = { 17088875, 17088878, 17088881, 17088884, 17088887, 17088890, 17088893,
                                17088896, 17088899, 17088904, 17088908, 17088910, 17088914, 17088918,
                                17088922, 17088926, 17088928, 17088934, 17088941, 17088948, 17088955,
                                17088962, 17088969, 17088976, 17088983, 17088990, 17089082, 17089086,
                                17089090, 17089094, 17089096, 17089101, 17089106, 17089111, 17089116,
                                17089125, 17089190, 17089194, 17089198, 17089202, 17089206 },
        APKALLU            = { 17088876, 17088877, 17088885, 17088888, 17088894, 17088895, 17088911,
                                17088912, 17088913, 17088919, 17088920, 17088921 },
        APKALLU_AVENGER    = 17088909, -- real NM
        QIQIRN             = { 17088879, 17088880, 17088882, 17088883, 17088886, 17088889, 17088891,
                                17088892, 17088897, 17088898, 17088930, 17088931 },
        IMP                = { 17088900, 17088901, 17088902, 17088903, 17088905, 17088906, 17088907,
                                17088915, 17088916, 17088917, 17088923, 17088924, 17088925, 17088929,
                                17088932, 17088933 },
        OROBON             = { 17089195, 17089196, 17089197 },
        FOMOR_WINDWALKER   = 17088991, -- real NM
        SEAFARER_PILIPROON = 17088927, -- real NM
        -- Real Socket NM per BG Wiki's route table (Silver Sea Remnants -> Gakke); real position
        -- (260,-0.449,513.5) is within a fraction of a unit of SOCKET's own real position below --
        -- confirmed real, already in Topaz's own sql/mob_spawn_points.sql.
        GAKKE              = 17088596,
        -- Real Slot NM per BG Wiki's route table (Silver Sea Remnants -> Don Poroggo, popped by a
        -- Zhayolm Card). Real position (-340,-0.449,-326.5) does NOT match SLOT's own currently
        -- active position below (-326.5,0.05,513.5) -- it instead matches an alternate position
        -- noted in a real comment right after that row in sql/npc_list.sql ("other pos -370 0.05
        -- -326"), suggesting a second real Slot location, same as Bhaflau's West/East Sockets. Not
        -- resolved -- see SLOT's own comment below.
        DON_POROGGO        = 17088668,
    },
    npcs =
    {
        -- Real, already active in Topaz's own SQL (not observed in this capture). Element 1 is the
        -- fixed Floor-1 crate (own onTrigger logic); the SQL's own comment confirms the same
        -- repositionable-pool mechanic as Bhaflau ("Armoury crates seems to move and be reused in
        -- other parts"). 4 more pool ids (17088820-17088823) are deliberately NOT listed here --
        -- still zero-position "NC:" placeholders in Topaz's own SQL, no real coordinates to fill in
        -- yet. Practical effect: salvageUtil.spawnTempChest's pool loop (`for i = 2,
        -- #ID.npcs.ARMOURY_CRATE`) silently no-ops for this zone until those 4 ids get real
        -- positions -- trash mobs here already call it (mobs/*.lua), it just won't produce a
        -- visible drop yet.
        ARMOURY_CRATE = { 17088809 },
        -- Real position (-326.5,0.05,513.5) does NOT match DON_POROGGO's real spawn position
        -- (-340,-0.449,-326.5) above -- an alternate position ("other pos -370 0.05 -326") is noted
        -- in a real comment right after this row in sql/npc_list.sql, closer to Don_Poroggo's real
        -- z -- unresolved, same open question as Bhaflau's two Sockets.
        SLOT   = 17089353,
        -- Real position (260,0.05,513.5) is within a fraction of a unit of GAKKE's own real spawn
        -- position (260,-0.449,513.5) above -- confirmed the real match.
        SOCKET = 17089352,
        -- Real, confirmed matching Topaz's own SQL exactly (no drift, unlike Bhaflau's doors)
        DOOR = {
            _240 = 17089385,
            _241 = 17089386,
            _242 = 17089387,
            _245 = 17089390,
            _246 = 17089391,
            _247 = 17089392,
            _248 = 17089393,
            _249 = 17089394,
            _24a = 17089395,
            _24h = 17089402,
            _24i = 17089403,
            _24j = 17089404,
            _24k = 17089405,
            _24q = 17089411,
            _24y = 17089419,
        },
        -- Real, confirmed via this capture, but genuinely absent from Topaz's own SQL (unlike
        -- everything else in this file) -- flagged as possibly level-99 "Salvage II" specific
        -- content, see file header. NOT yet wired into sql/npc_list.sql.
        RUNIC_LAMP = { 17089354, 17089355, 17089367 },
    },
}
