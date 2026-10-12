-----------------------------------
-- Area: Bhaflau_Remnants
-----------------------------------
-- Mob ids/positions are from real Bhaflau Remnants captures (Mission Toolkit captures #110/#111).
-- Door ids/names are NOT from those captures -- captures and LSB both showed drift against
-- Topaz's own established npc_list.sql numbering for the door range, so Topaz's own SQL is treated
-- as authoritative there; LSB's door-role labels (DOOR_1_0, etc.) are kept as comments for
-- reference only, never as a numeric source (see [[topaz_never_fabricate_ids]]).
-- KNOWN GAP: id 17084920 sits between _23v (17084919) and _23w (17084921) with no name ever
-- assigned in Topaz's own SQL -- a genuine gap in Topaz's numbering, not a missing label to guess.
--
-- REAL PROGRESSION FACTS (capture #110 cross-checked against a live playthrough video):
--   * Entrance: 3x Event Option (0x05B) csid 101 from the player, then CS Event (0x032) csid 300
--     on the first door (_230, 17084889) -- csid 101 is likely the teleport-in/registration
--     cutscene, separate from door-opening. Door-open csid 300 is shared by every "Gilded Doors"
--     entity, with a real yes/no confirm menu (0=decline, 1=confirm).
--   * _230 is the floor-1 branch point (teleport-in lands here); branches WEST -> _232 or
--     EAST -> _231 (opening one locks the other, per BG Wiki).
--   * West Reactionary Rampart room confirmed at (-340,-0.5,-515) = mob 17084692. Per BG Wiki's 1F
--     map, rosters split West (Wamouracampa/Bifrons/Troll Lapidarist) vs East (Carmine Eruca/
--     Bifrons/Troll Gemologist), each +Troll Ironworker in the 2nd large room -- confirmed
--     geometrically too (x=340 is the map's mirror line; Floor 2 sits on the negative-x side).
--   * Floor 2 (BG Wiki, live-confirmed via 4 teleporters): Central Area (4x Empathic Flan rooms,
--     clearing all 4 in "Angry" mode spawns a Dormant Rampart) -> splits West/East -> each side has
--     its own Socket room -> each splits again North/South -> each of the 4 resulting rooms has its
--     own teleporter to 3F. Same "open one door, lock its opposite" rule as Floor 1.
--   * Floor 2's East teleporter lands on Floor 3's South side (direction-only, not yet backed by
--     coordinates).
--
-- STILL OPEN: no teleporter-to-next-floor coordinates recovered for any floor (capture #110 has no
-- PC position tracking). The floor/stage event codes seen in capture #110
-- (0x00C8/0x00C9/0x00CD/0x00CF/0x00D0) aren't confidently mapped to specific transitions yet.
-- Reactionary_Rampart.lua's Reinforcements mechanic (12s summon timer, ~1%/summon HP loss, 5-summon
-- cap, death warps party to the Dormant Rampart) is only wired for Floor 2 (Hunting Wasp) and
-- Floor 3 (Colibri) -- Floor 1's Chigoe and Floor 4's Tragopan have no confirmed
-- Reactionary/Dormant Rampart id pair yet, and none of the 4 floors' "rare NM" summon variant (Gate
-- Widow/Skirmish Pephredo/Zebra Zachary/Peryton) has a confirmed pairing either. The Floor-2/
-- Floor-3 REACTIONARY_RAMPART[2]/[3] assignment is array-order-assumed, not independently confirmed
-- the way [1] (position-confirmed West Floor 1) is.
-----------------------------------
-----------------------------------

Bhaflau =
{
    text =
    {
        -- ids verified by TEXT against a fresh zone-75 dialog.yml pull (2026-10-09)
        ITEM_CANNOT_BE_OBTAINED = 6380, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED           = 6388, -- Obtained: <item>.
        GIL_OBTAINED            = 6389, -- Obtained <number> gil.
        KEYITEM_OBTAINED        = 6391, -- Obtained key item: <keyitem>.
        CELL_OFFSET             = 7212, -- Main Weapon/Sub-Weapon restriction removed.
        TEMP_ITEM               = 7233, -- Obtained temporary item: <item>!
        HAVE_TEMP_ITEM          = 7234, -- You already have that temporary item.
        SALVAGE_START           = 7235, -- You feel an incredible pressure bearing down on you...
        TIME_TO_COMPLETE        = 7407, -- You have <number> [minute/minutes] (Earth time) to complete this mission.
        MISSION_FAILED          = 7408, -- The mission has failed. Leaving area.
        TIME_REMAINING_MINUTES  = 7412, -- Time remaining: <number> [minute/minutes] (Earth time).
        TIME_REMAINING_SECONDS  = 7413, -- Time remaining: <number> [second/seconds] (Earth time).
        PARTY_FALLEN            = 7415, -- All party members have fallen in battle. Mission failure in <number> [minute/minutes].
        DOOR_IS_SEALED          = 7426, -- The door is sealed...
        NOT_RESPONDING          = 7428, -- The device doesn't respond...
        SOCKET_TRIGGER          = 7430, -- You hear a ragged sighing from beneath the floor...
        SLOT_TRIGGER            = 7431, -- You hear a scuttering sound from beneath the floor...
        NOTHING_HAPPENS         = 7432, -- Nothing happens...
        -- Real csid confirmed near the end of capture #110's event sequence, triangulated against
        -- Arrapago's own working onInstanceFailure (also csid 1) and LSB's xi.salvage.onFailure.
        MISSION_FAILED_CSID     = 1,
    },
    mobs =
    {
        -- Boss floor
        LONG_BOWED_CHARIOT = 17084687,
        -- Rampart-spawned adds. 17084692 confirmed real (-340,-0.5,-515) via video cross-check as
        -- the West Path floor-1 Reactionary Rampart. 17084691 (Floor 4) has a real position
        -- (-340,0,154) from the LSB-ported npc_list conversion; its REACTIONARY_RAMPART[4]
        -- (17084713) is still placeholder-positioned, so the pairing isn't usable yet.
        DORMANT_RAMPART    = { 17084688, 17084689, 17084690, 17084691 },
        REACTIONARY_RAMPART = { 17084692, 17084699, 17084706 },
        -- Floor 1 -- BIFRONS spawns on both West and East branches (unlike the branch-specific
        -- mobs below).
        BIFRONS            = { 17084429, 17084433, 17084444, 17084445, 17084447, 17084448, 17084449,
                                17084452, 17084456, 17084467, 17084468, 17084470, 17084471, 17084472 },
        -- East Path only (every reading sits at x>340, per BG Wiki's 1F map)
        CARMINE_ERUCA      = { 17084427, 17084428, 17084430, 17084431, 17084432, 17084434, 17084435,
                                17084436, 17084438, 17084439, 17084440, 17084441, 17084442, 17084443 },
        -- Can spawn at the end of either branch; mob_spawn_points.sql's default position is just
        -- its West fallback -- repositioned at runtime via the `pos.MAD_BOMBER` table below.
        MAD_BOMBER         = 17084481,
        -- BG Wiki lists "Sulfurous Scorpion" on Floor 3's Southeast room -- no such entity exists
        -- in this codebase's SQL, so this is the same mob under a wiki naming inconsistency.
        SULFUR_SCORPION    = { 17084478, 17084479, 17084480, 17084486, 17084487, 17084488, 17084493,
                                17084494, 17084495, 17084496, 17084497, 17084498, 17084505, 17084506,
                                17084507, 17084508, 17084511, 17084512, 17084513, 17084514, 17084518,
                                17084519, 17084520 },
        EMPATHIC_FLAN      = { 17084482, 17084483, 17084484, 17084485 },
        -- Floor 3, South Central area per BG Wiki roster (2x "4 Black Pudding" side rooms + 1x "12
        -- Black Pudding" center room). A second pair (17084725/17084726, groupid 34) exists with
        -- placeholder (0,0,0) positions -- purpose unconfirmed, not included here.
        BLACK_PUDDING      = { 17084603, 17084604, 17084605, 17084606, 17084607, 17084608, 17084609,
                                17084610, 17084611, 17084612, 17084613, 17084614, 17084615, 17084616,
                                17084617, 17084618, 17084619, 17084620, 17084621, 17084622, 17084623,
                                17084624, 17084625, 17084626, 17084627, 17084628, 17084629, 17084630,
                                17084631, 17084632, 17084633, 17084634, 17084635, 17084636 },
        -- Floor 2 (Troll workers). These 6 arrays are NOT the placeholder-(0,0,0) Floor 4
        -- trash-mob ids elsewhere in this file (17084739-750), which remain deliberately excluded.
        TROLL_CAMEIST      = { 17084504, 17084510, 17084517, 17084544, 17084550, 17084558, 17084562,
                                17084571, 17084581, 17084593 },
        TROLL_ENGRAVER     = { 17084524, 17084526, 17084536, 17084539, 17084541, 17084555, 17084573,
                                17084575, 17084577, 17084583, 17084588, 17084595, 17084600 },
        -- Real positions split into two clusters: x>410 (Floor 1 East Path room) and x<-220
        -- (Floor 2's own troll-worker roster) -- both real, same mob type.
        TROLL_GEMOLOGIST   = { 17084437, 17084446, 17084563, 17084569, 17084585, 17084590, 17084597, 17084602 },
        -- Appears on both Floor-1 branches' 2nd large room, plus Floor 2.
        TROLL_IRONWORKER   = { 17084473, 17084474, 17084491, 17084492, 17084500, 17084528, 17084529,
                                17084538, 17084572, 17084582, 17084594 },
        -- Real positions split into two clusters: x>220 (Floor 1 West Path room) and x<-220
        -- (Floor 2's own troll-worker roster) -- both real, same mob type.
        TROLL_LAPIDARIST   = { 17084460, 17084469, 17084565, 17084586, 17084598 },
        TROLL_SMELTER      = { 17084489, 17084490, 17084499, 17084501, 17084502, 17084515, 17084564,
                                17084570, 17084580, 17084592 },
        TROLL_STONEWORKER  = { 17084503, 17084509, 17084516, 17084543, 17084549, 17084557, 17084566,
                                17084567, 17084568, 17084579, 17084587, 17084591, 17084599 },
        HUNTING_WASP       = { 17084700, 17084701, 17084702, 17084703, 17084704 },
        -- Confirmed real via a fresh mission_toolkit.py pull of the client's entities.yml (ground
        -- truth, not wiki/capture) -- all have real mob_spawn_points rows but at placeholder
        -- (0,0,0), so not wired into their mob scripts yet (would visibly spawn broken).
        CHIGOE             = { 17084693, 17084694, 17084695, 17084696, 17084697 }, -- Floor 1 regular
        GATE_WIDOW         = 17084698,                                            -- Floor 1 rare NM
        TRAGOPAN           = { 17084714, 17084715, 17084716, 17084717, 17084718 }, -- Floor 4 regular
        PERYTON            = 17084719,                                            -- Floor 4 rare NM
        -- Same entities.yml confirmation, same placeholder-position caveat.
        SKIRMISH_PEPHREDO  = 17084705, -- Floor 2 rare NM
        ZEBRA_ZACHARY      = 17084712, -- Floor 3 rare NM
        -- Confirmed via entities.yml -- a Bhaflau-Remnants-specific Archaic Rampart, distinct from
        -- Nyzul Isle's own (different zone/id space). Role/floor not yet determined.
        ARCHAIC_RAMPART    = { 17084801, 17084819, 17084851, 17084852 },
        -- Confirmed via entities.yml -- BG Wiki: "kill Troll Smelter before opening the east door
        -- to spawn [this NM] in the SW wing," Floor 3 Northwest area. Placeholder position.
        TROLL_HUNTSMAN     = 17084756,
        -- Floor 3. Real Long-Bowed Chariot/Homing Missile weaken-effect ids (unrelated to Floor 3's
        -- own Archaic Gear mechanic below, which has its own ARCHAIC_GEAR_F3/ARCHAIC_GEARS_F3
        -- arrays split out by real position clustering).
        ARCHAIC_GEAR       = { 17084655, 17084656, 17084657, 17084658, 17084659,
                                17084660, 17084661, 17084662, 17084663, 17084664, 17084671, 17084672,
                                17084673, 17084674, 17084675, 17084676, 17084677, 17084678, 17084679,
                                17084680 },
        ARCHAIC_GEARS      = { 17084666, 17084667, 17084668, 17084669, 17084670,
                                17084682, 17084683, 17084684, 17084685, 17084686 },
        -- Floor 3's own Archaic Gear/Archaic Gears ids (dual-kill -> Dormant Rampart, per the user's
        -- Floor 3 wiki text -- a different mechanic than Floor 4's Long-Bowed Chariot weaken
        -- effect above). WEST/EAST determined against this floor's door-confirmed convention
        -- (_23l/_23n at x=-400 = West, _23o/_23q at x=-280 = East). 8 real ids per side confirmed
        -- (wiki says 10 -- not a clean confirmed subset, same known gap as Floor 4).
        ARCHAIC_GEAR_F3    = {
            WEST = { 17084647, 17084648, 17084649, 17084650, 17084651, 17084652, 17084653, 17084654 },
            EAST = { 17084638, 17084639, 17084640, 17084641, 17084642, 17084643, 17084644, 17084645 },
        },
        ARCHAIC_GEARS_F3   = { WEST = 17084646, EAST = 17084637 },
        -- Two real, positioned Archaic Chariots for Floor 4 (west/east), matching LSB's reference.
        ARCHAIC_CHARIOT    = { 17084665, 17084681 },
        -- West Path only on Floor 1 (every reading sits at x<340, per BG Wiki's 1F map) -- this
        -- same mob type also spawns for real on Floor 3, all ids below.
        WAMOURACAMPA       = { 17084450, 17084451, 17084453, 17084454, 17084455, 17084457, 17084458,
                                17084459, 17084461, 17084462, 17084463, 17084464, 17084465, 17084466 },
        WANDERING_WAMOURA  = { 17084475, 17084476, 17084477, 17084521, 17084522, 17084523, 17084530,
                                17084531, 17084532, 17084533, 17084534, 17084535, 17084545, 17084546,
                                17084547, 17084548, 17084551, 17084552, 17084553, 17084554, 17084559,
                                17084560, 17084561 },
        -- Slot NM (real, confirmed via capture + wiki: "Demented Jalaawa", spawned by trading an
        -- Arrapago Card to the 3rd floor Slot -- see [[topaz_strict_accuracy_rules]])
        DEMENTED_JALAAWA   = 17084721,
        -- Floor 4
        COLIBRI            = { 17084707, 17084708, 17084709, 17084710, 17084711 },
        -- Floor 2's Socket NM per BG Wiki (Floor 2 has TWO real Socket rooms, West and East, each
        -- with its own Flux Flan -- see SOCKET's own comment below). Not observed in either
        -- capture, but already a real row in Topaz's own SQL (17084720, 455.16,-0.497,260.095) --
        -- this is the EAST room's Flux Flan; the West room's own id is still unconfirmed.
        FLUX_FLAN          = 17084720,
    },
    -- Real, user-logged positions (!logpos, live walkthrough) for Mad Bomber's 4 possible pop rooms
    -- on the BG Wiki 1F map (2 per branch, mirrored around x~340 same as every other West/East pair
    -- in this zone). Rotation reuses mob_spawn_points.sql's default row (241) for all 4 -- not
    -- independently confirmed per-spot, but this NM's facing isn't mechanically significant.
    pos =
    {
        MAD_BOMBER = {
            WEST = {
                { 219.8378, 16.0000, -460.0621, 241 },
                { 259.9401, 16.0000, -300.0228, 241 },
            },
            EAST = {
                { 460.0284, 16.0000, -451.0123, 241 },
                { 419.9310, 16.0000, -300.0621, 241 },
            },
        },
        -- Real, user-logged positions (!logpos) for the one real Dormant Rampart entity's
        -- (DORMANT_RAMPART[1], 17084688) reveal spot -- index-matched to MAD_BOMBER.WEST/.EAST
        -- above (index 1 pop -> index 1 Dormant Rampart spot), not detected by proximity. WEST
        -- index 1 confirmed via an earlier live test and a retail video; the other 3 confirmed via
        -- live tests. WEST index 1's rot was live-confirmed wrong (spawned facing East, should face
        -- South) -- this engine's rot byte increases counter-clockwise, so a 90-degree clockwise
        -- turn from this reference point is -64 (192 mod 256), not +64. The other 3 entries are
        -- not independently confirmed either way yet.
        DORMANT_RAMPART = {
            WEST = {
                { 236.0000, 16.0000, -460.0000, 192 },
                { 259.9364, 16.0000, -282.9339, 0 },
            },
            EAST = {
                { 442.8786, 16.0000, -459.9404, 0 },
                { 419.8993, 16.0000, -283.1562, 0 },
            },
        },
    },
    npcs =
    {
        ARMOURY_CRATE = { 17084417, 17084418, 17084419, 17084420, 17084421, 17084422, 17084423,
                           17084426, 17084722 },
        SLOT          = 17084857,
        -- Floor 2 has TWO real Socket rooms (West and East per BG Wiki), each with its own Flux
        -- Flan. Captures #110 (Tacocat) and #111 (Foxmulder) each observed a different room --
        -- Tacocat: (222.5,0,260) = West; Foxmulder: (457.5,0,260) = East (confirmed ~2.3 units from
        -- FLUX_FLAN's own SQL position). This id is set to the East position since that one has
        -- independent corroboration; the West room's own Socket/Flux Flan ids are still unconfirmed.
        SOCKET        = 17084856,
        -- Door ids/names from Topaz's own real npc_list.sql (authoritative for this era/version --
        -- see file header), NOT this capture's raw packet names, which disagreed with Topaz's own
        -- established numbering. LSB's own role-label names kept as comments for reference only.
        DOOR = {
            _230 = 17084889, -- LSB: DOOR_1_0
            _231 = 17084890, -- LSB: DOOR_1_EAST_ENTRANCE
            _232 = 17084891, -- LSB: DOOR_1_WEST_ENTRANCE
            _233 = 17084892, -- LSB: DOOR_1_WEST_EXIT_1
            _234 = 17084893, -- LSB: DOOR_1_WEST_EXIT_2
            _235 = 17084894, -- LSB: DOOR_1_WEST_EXIT_3
            _236 = 17084895, -- LSB: DOOR_1_EAST_EXIT_1
            _237 = 17084896, -- LSB: DOOR_1_EAST_EXIT_2
            _238 = 17084897, -- LSB: DOOR_1_EAST_EXIT_3
            _239 = 17084898, -- LSB: DOOR_1_CENTER_1
            _23a = 17084899, -- LSB: DOOR_1_CENTER_2
            _23b = 17084900, -- LSB: DOOR_2_WEST_ENTRANCE
            _23c = 17084901, -- LSB: DOOR_2_EAST_ENTRANCE
            _23d = 17084902, -- LSB: DOOR_2_NW_ENTRANCE
            _23e = 17084903, -- LSB: DOOR_2_SW_ENTRANCE
            -- Was a documented gap (npc_list.sql's own NOT_CAPTURED placeholder). Confirmed real
            -- via FFXI-DATS' client dat-extraction (Info/Door or Objects.json, ZoneId 75) --
            -- position (500,-2.012,320) mirrors _23d (180,-2.012,320) exactly around this floor's
            -- x=340 center. This is LSB's own DOOR_2_NE_ENTRANCE role.
            _23f = 17084920, -- LSB: DOOR_2_NE_ENTRANCE
            _23g = 17084904, -- LSB: DOOR_2_SE_ENTRANCE
            _23h = 17084905, -- LSB: DOOR_2_NW_EXIT
            _23i = 17084906, -- LSB: DOOR_2_SW_EXIT
            _23j = 17084907, -- LSB: DOOR_2_NE_EXIT
            _23k = 17084908, -- LSB: DOOR_2_SE_EXIT
            _23l = 17084909, -- LSB: DOOR_3_SW_ENTRANCE
            _23m = 17084910, -- LSB: DOOR_3_WEST_EXIT
            _23n = 17084911, -- LSB: DOOR_3_NW_ENTRANCE
            _23o = 17084912, -- LSB: DOOR_3_NE_ENTRANCE
            _23p = 17084913, -- LSB: DOOR_3_EAST_EXIT
            _23q = 17084914, -- LSB: DOOR_3_SE_ENTRANCE
            _23r = 17084915, -- LSB: DOOR_3_SOUTH_CENTER
            _23s = 17084916, -- LSB: DOOR_3_NORTH_CENTER
            _23t = 17084917, -- LSB: DOOR_4_WEST_EXIT
            _23u = 17084918, -- LSB: DOOR_4_EAST_EXIT
            _23v = 17084919, -- LSB: DOOR_5_1
            -- 17084920: real gap in Topaz's own sequence, no name ever assigned -- see file header.
            _23w = 17084921, -- (not in LSB's list -- real, role unconfirmed)
            _23x = 17084922, -- LSB: DOOR_5_2
            _23y = 17084923, -- (not in LSB's list -- real, role unconfirmed)
        },
        -- Floor 1's real door-chain groups, built from this file's own header facts: entrance ->
        -- branch -> that side's own exit group -> center (video-confirmed), same "open one, lock
        -- the whole group, reveal the next" mechanic Arrapago's own door chain uses
        -- (npcs/_220.lua-_224.lua). WEST_EXIT/EAST_EXIT grouping is inferred from LSB's role labels
        -- (DOOR_1_WEST_EXIT_1/2/3 etc.), not independently video-confirmed like ENTRANCE/BRANCH.
        FLOOR1_GROUPS = {
            ENTRANCE  = { 17084889 },                          -- _230
            BRANCH    = { 17084890, 17084891 },                -- _231 (east), _232 (west)
            WEST_EXIT = { 17084892, 17084893, 17084894 },      -- _233, _234, _235
            EAST_EXIT = { 17084895, 17084896, 17084897 },      -- _236, _237, _238
            CENTER    = { 17084898, 17084899 },                -- _239, _23a
        },
        -- Floor 2's real entrance pair (LSB: DOOR_2_WEST_ENTRANCE/DOOR_2_EAST_ENTRANCE), revealed
        -- by whichever Floor 1 CENTER door advances the instance to stage 2. Deeper Floor 2
        -- structure isn't grouped here yet -- same LSB-label-inferred, capture-thin territory.
        FLOOR2_ENTRANCE = { 17084900, 17084901 },              -- _23b (west), _23c (east)
    },
}
