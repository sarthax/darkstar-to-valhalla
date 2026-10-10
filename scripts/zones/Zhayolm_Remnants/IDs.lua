-----------------------------------
-- Area: Zhayolm_Remnants
-----------------------------------
-- Real ids/positions below are from Topaz's own sql/mob_spawn_points.sql and sql/npc_list.sql
-- "Zhayolm Remnants (Zone 73)" sections -- unlike Bhaflau/Silver Sea, this zone had NO capture to
-- cross-reference yet, so everything here comes directly from Topaz's own already-registered SQL
-- rows (same discipline: Topaz's own data is authoritative, LSB used only for real mob NAMES to
-- group these ids under, never for ids themselves).
-- Real entrance @ 340,0,-593,191 (matches instance_list.sql, already wired to !warpassault).
-- Real Socket NM = Poroggo Madame, real Slot NM = Jakko (BG Wiki route table, confirmed earlier
-- this session: Zhayolm's own Socket pops Poroggo Madame, Slot pops Jakko, per the real per-zone
-- NM table). Both SOCKET (17076916) and SLOT (17076917) and all 12 RUNIC_LAMP ids
-- (17076918-17076929) are still genuine "NC:" zero-position placeholders in Topaz's own SQL --
-- not fabricated, just unresolved until a real capture/video gives coordinates.
-- Real ARMOURY_CRATE fixed Floor-1 crate (17076579) is positioned; 4 pool ids (17076586-589) are
-- still genuine NC placeholders, same as Silver Sea's -- spawnTempChest's pool loop will no-op
-- here until they get real positions.
-- Real DOOR table (_210 through _21j, ids 17076949-17076968) is fully positioned in Topaz's own
-- SQL already -- no drift/gap issue like Bhaflau's. One more NC placeholder (17076969) has a
-- blank name in SQL, real identity unknown.
-- Real mob rosters below use LSB's own real names (Puk, Mamool Ja Zenist/Spearman/Strapper/
-- Bounder/Savant/Sophist/Mimicker/Wyvern/Lizard subtypes, Poroggo Gent/Madame, Ziz, Vagrant
-- Lindwurm, Bull Bugard, Draco Lizard, First/Second/Third/Fourth Rampart, Rogue Marid, Archaic
-- Gear/Gears/Rampart/Chariot, Wajaom Tiger, Slime Mold, Mindgazer, Torama, Greater Manticore,
-- Battleclad Chariot, Jakko) -- ALL cross-checked by exact name match against Topaz's own real
-- mob_spawn_points.sql rows (not assumed from LSB). Note: Ziz, Wyvern, Wajaom Tiger, Rogue Marid,
-- Slime Mold, Mindgazer, Torama, and Greater Manticore are real Zhayolm Remnants mobs NOT in LSB's
-- own IDs.lua mob list -- included here since they're genuinely present in Topaz's own SQL.

Zhayolm =
{
    text =
    {
        -- ids verified by TEXT against a fresh same-session mission_toolkit dialog.yml pull of zone 73 (2026-10-09)
        ITEM_CANNOT_BE_OBTAINED = 6380, -- You cannot obtain the <item>.
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
        DOOR_IS_SEALED_MYSTERIOUS = 7433, -- The door is sealed by some mysterious force...
        SOCKET_TRIGGER          = 7434, -- You hear a ragged sighing from beneath the floor...
        SLOT_TRIGGER            = 7435, -- You hear a scuttering sound from beneath the floor...
        NOTHING_HAPPENS         = 119, -- Nothing happens...
    },
    mobs =
    {
        PUK                = { 17076225, 17076226, 17076227, 17076228, 17076229, 17076230, 17076231,
                                17076232, 17076233, 17076234, 17076235, 17076236, 17076237, 17076238,
                                17076239, 17076240 },
        MAMOOL_JA_ZENIST   = { 17076241, 17076259, 17076277, 17076295, 17076306, 17076337, 17076338,
                                17076339, 17076340, 17076357, 17076363, 17076369, 17076412 },
        POROGGO_GENT       = { 17076242, 17076260, 17076278, 17076296, 17076426, 17076427, 17076428,
                                17076429, 17076430, 17076431, 17076432, 17076433, 17076462, 17076463,
                                17076464, 17076465, 17076466, 17076467, 17076468, 17076469, 17076470,
                                17076471, 17076472, 17076473 },
        -- Real Zhayolm mob, not in LSB's own list (present in Topaz's own SQL)
        ZIZ                = { 17076243, 17076244, 17076245, 17076246, 17076247, 17076248, 17076249,
                                17076250, 17076251, 17076252, 17076253, 17076254, 17076255, 17076256,
                                17076257, 17076258 },
        VAGRANT_LINDWURM   = { 17076261, 17076262, 17076263, 17076264, 17076265, 17076266, 17076267,
                                17076268, 17076269, 17076270, 17076271, 17076272, 17076273, 17076274,
                                17076275, 17076276 },
        BULL_BUGARD        = { 17076279, 17076280, 17076281, 17076282, 17076283, 17076284, 17076285,
                                17076286, 17076287, 17076288, 17076289, 17076290, 17076291, 17076292,
                                17076293, 17076294 },
        -- Real Socket NM per BG Wiki's route table (Zhayolm Remnants -> Poroggo Madame); appears
        -- repeatedly across floors, real SOCKET npc position still unresolved (see npc.SOCKET).
        POROGGO_MADAME     = { 17076297, 17076336, 17076411, 17076486, 17076487, 17076558, 17076559,
                                17076577 },
        DRACO_LIZARD       = { 17076298, 17076299, 17076300, 17076301, 17076302, 17076303, 17076304,
                                17076305, 17076307, 17076308, 17076309, 17076310, 17076311, 17076312,
                                17076313, 17076314 },
        MAMOOL_JA_SAVANT   = { 17076315, 17076377, 17076378, 17076379, 17076380, 17076389, 17076390,
                                17076397, 17076398, 17076403, 17076404, 17076434, 17076435, 17076440,
                                17076441 },
        -- Real Zhayolm mob, not in LSB's own list
        WYVERN             = { 17076316, 17076317, 17076318, 17076319, 17076320, 17076321, 17076322,
                                17076323, 17076325, 17076326, 17076327, 17076328, 17076329, 17076330,
                                17076331, 17076332 },
        MAMOOL_JA_BOUNDER  = { 17076324, 17076359, 17076365, 17076371, 17076414 },
        MAMOOL_JA_SPEARMAN = { 17076333, 17076341, 17076343, 17076345, 17076347, 17076358, 17076364,
                                17076370, 17076413 },
        MAMOOL_JAS_WYVERN  = { 17076334, 17076342, 17076344, 17076346, 17076348, 17076361, 17076367,
                                17076373, 17076416 },
        -- Real Slot NM per BG Wiki's route table (Zhayolm Remnants -> Jakko, popped by a Silver
        -- Sea Card). Real position (260,-0.5,65) still unresolved vs. real npc.SLOT (see below).
        JAKKO              = 17076335,
        MAMOOL_JA_STRAPPER = { 17076349, 17076350, 17076351, 17076352, 17076360, 17076366, 17076372,
                                17076415 },
        MAMOOL_JAS_LIZARD  = { 17076353, 17076354, 17076355, 17076356, 17076362, 17076368, 17076374,
                                17076417 },
        MAMOOL_JA_SOPHIST  = { 17076381, 17076382, 17076383, 17076384, 17076391, 17076392, 17076399,
                                17076400, 17076405, 17076406, 17076436, 17076437, 17076442, 17076443 },
        MAMOOL_JA_MIMICKER = { 17076385, 17076386, 17076387, 17076388, 17076393, 17076394, 17076395,
                                17076396, 17076401, 17076402, 17076407, 17076408, 17076438, 17076439,
                                17076444, 17076445 },
        ARCHAIC_RAMPART    = { 17076375, 17076409, 17076496, 17076497, 17076498, 17076515, 17076529,
                                17076530, 17076531, 17076556, 17076573, 17076575 },
        -- Real Zhayolm mob, not in LSB's own list
        WAJAOM_TIGER       = { 17076376, 17076410, 17076516 },
        FIRST_RAMPART      = { 17076418, 17076446, 17076454 },
        SECOND_RAMPART     = { 17076419, 17076447, 17076455 },
        THIRD_RAMPART      = { 17076420, 17076448, 17076456 },
        FOURTH_RAMPART     = { 17076421, 17076449, 17076457 },
        -- Real Zhayolm mob, not in LSB's own list
        ROGUE_MARID        = { 17076422, 17076423, 17076424, 17076425, 17076450, 17076451, 17076452,
                                17076453, 17076458, 17076459, 17076460, 17076461 },
        ARCHAIC_GEAR       = { 17076488, 17076489, 17076490, 17076491, 17076492, 17076493, 17076494,
                                17076495, 17076503, 17076504, 17076505, 17076506, 17076507, 17076508,
                                17076509, 17076510, 17076571, 17076572 },
        -- Real Zhayolm mob, not in LSB's own list
        SLIME_MOLD         = { 17076499, 17076500, 17076501 },
        ARCHAIC_CHARIOT    = { 17076502, 17076535, 17076560 },
        ARCHAIC_GEARS      = { 17076517, 17076518, 17076519, 17076520, 17076521, 17076522, 17076523,
                                17076524, 17076525, 17076526, 17076527, 17076528, 17076536, 17076537,
                                17076538, 17076539, 17076540, 17076541, 17076542, 17076543, 17076544,
                                17076545, 17076546, 17076547, 17076548, 17076549, 17076550, 17076551,
                                17076552, 17076553, 17076554, 17076555, 17076561, 17076562, 17076563,
                                17076564, 17076565, 17076566, 17076567, 17076568, 17076569, 17076570 },
        -- Real Zhayolm mob, not in LSB's own list
        MINDGAZER          = { 17076532, 17076533, 17076534 },
        -- Real Zhayolm mob, not in LSB's own list
        TORAMA             = 17076557,
        -- Real Zhayolm mob, not in LSB's own list
        GREATER_MANTICORE  = { 17076574, 17076576 },
        -- Real boss floor mob, matches Topaz's own pre-existing mobs/Battleclad_Chariot.lua
        BATTLECLAD_CHARIOT = 17076578,
    },
    npcs =
    {
        -- Real fixed Floor-1 crate, matches Bhaflau/Silver Sea's own repositionable-pool
        -- mechanic ("Armoury crates seems to move and be reused in other parts"). 4 real pool ids
        -- (17076586-589) are still genuine NC placeholders in Topaz's own SQL -- deliberately not
        -- listed here, same as Silver Sea's uncaptured pool ids. spawnTempChest's pool loop will
        -- no-op here until they get real positions.
        ARMOURY_CRATE = { 17076579 },
        -- Real, but still a genuine NC zero-position placeholder in Topaz's own SQL -- real NM
        -- (Jakko) position is 260,-0.5,65 above, unresolved against this row, same open question
        -- as Bhaflau/Silver Sea's Socket/Slot ambiguity.
        SLOT   = 17076917,
        -- Real, but still a genuine NC zero-position placeholder in Topaz's own SQL -- real NM
        -- (Poroggo Madame) appears at several positions above, unresolved against this row.
        SOCKET = 17076916,
        -- Real, confirmed matching Topaz's own SQL exactly, fully positioned (no drift/gap issue
        -- like Bhaflau's doors)
        DOOR = {
            _210 = 17076949,
            _211 = 17076950,
            _212 = 17076951,
            _213 = 17076952,
            _214 = 17076953,
            _215 = 17076954,
            _216 = 17076955,
            _217 = 17076956,
            _218 = 17076957,
            _219 = 17076958,
            _21a = 17076959,
            _21b = 17076960,
            _21c = 17076961,
            _21d = 17076962,
            _21e = 17076963,
            _21f = 17076964,
            _21g = 17076965,
            _21h = 17076966,
            _21i = 17076967,
            _21j = 17076968,
        },
        -- Real, but still 12 genuine NC zero-position placeholders in Topaz's own SQL -- not
        -- fabricated, just unresolved until a real capture/video gives coordinates.
        RUNIC_LAMP = { 17076918, 17076919, 17076920, 17076921, 17076922, 17076923, 17076924, 17076925,
                        17076926, 17076927, 17076928, 17076929 },
    },
}
