-----------------------------------
-- Area: Ilrusi_Atoll
-- Golden Salvage chest-slot position/id data.
--
-- This is this project's OWN added-content data table, not a real old-dsp-reference file -- there
-- is no old-dsp-reference equivalent to check this shape against (old-dsp-reference has no chest
-- position/id data structure of any kind for this zone; this whole mechanic is project-original).
-- Previously lived inline in the LandSandBoat-targeted IDs.lua's ID.mob.CURSED_CHEST_SLOTS; moved
-- to its own module during the zones[xi.zone.X] -> flat-TextIDs.lua restructuring (2026-09-13)
-- since old-dsp-reference's real per-zone id file only holds text message ids for this zone (see
-- TextIDs.lua's own header), and this table isn't a text id or a single-mob PH entry.
-----------------------------------

local GoldenSalvageData = {}

-- Golden Salvage chest slots: real position map shows 20 possible chest spawn points around
-- the cave, 12 populate per instance, 11 of those are live non-sleepable Mimics (draw-in
-- range ~22'+, see mobs/Cursed_Chest.lua) and 1 is the real chest. 18 of the 20 real-world
-- positions confirmed across 4 independent captures (see Assault_Fix_Log.md). `id` is the
-- static npc_list chest, `mob` is a DELIBERATELY separate mob_spawn_points id -- an earlier
-- pass shared one numeric id between the two, which turned out to be the actual bug:
-- src/map/instance_loader.cpp computes both CNpcEntity and CMobEntity targid the same way
-- (`id & 0xFFF`), and while server-side NPC/MOB are separate containers, the FFXI client has
-- one flat targid slot per zone -- sharing an id meant the chest and its mimic fought over
-- the same client-visible slot (mimic invisible until a TP move forced a fresh packet,
-- lid/box model mismatch). treasure.lua's retail roaming-chest Mimic system avoids this by
-- using a separate mob id from its chest npc -- matched here. 4 of the 19 are the boat
-- chests (user confirmed live via !pos) -- these always spawn every instance; the other 8
-- active slots are drawn randomly from the remaining 15. See golden_salvage.lua for the
-- runtime selection logic.
-- Later updated with LSB region-based chest spawn data (18 regions, 48+ spawn points) --
-- retail capture confirmed: 4 boat chests (fixed) + 8 random from other regions = 12 total.
GoldenSalvageData.CURSED_CHEST_SLOTS =
{
    -- Chest ID mappings (18 chests, numbered 1-18)
    chestIds = {
        17002505, 17002506, 17002507, 17002508, 17002509, 17002510,
        17002511, 17002512, 17002513, 17002514, 17002515, 17002516,
        17002900, 17002902, 17002903, 17002904, 17002905, 17002906,
    },
    -- Boat chests that always spawn (indices into region list)
    -- These correspond to regions 4, 12, 14, 15 based on boat spawn patterns
    boatChestRegions = { 4, 12, 14, 15 },

    -- Spawn regions: 18 regions with multiple spawn points per region (48+ total positions)
    -- Real retail capture-confirmed positions from LSB
    regions = {
        -- Region 1: NW shallow area (4 points)
        {
            { x = 222.815, y = -2.598, z = -26.028 },
            { x = 222.981, y = -2.374, z = -31.139 },
            { x = 228.292, y = -2.156, z = -25.363 },
            { x = 228.597, y = -2.288, z = -31.253 },
        },
        -- Region 2: North central shallow (3 points)
        {
            { x = 254.253, y = -1.000, z = 29.583 },
            { x = 259.472, y = -2.000, z = 24.611 },
            { x = 259.739, y = -1.528, z = 30.681 },
        },
        -- Region 3: North shallow (2 points)
        {
            { x = 287.048, y = -2.724, z = 49.817 },
            { x = 290.109, y = -3.000, z = 47.068 },
        },
        -- Region 4: South boat area (5 points) - BOAT CHEST
        {
            { x = 302.973, y = -7.000, z = -53.250 },
            { x = 303.300, y = -7.500, z = -56.050 },
            { x = 304.196, y = -7.500, z = -59.205 },
            { x = 306.678, y = -7.000, z = -55.765 },
            { x = 308.197, y = -7.500, z = -58.652 },
        },
        -- Region 5: South shallow (2 points)
        {
            { x = 317.109, y = -4.491, z = -22.393 },
            { x = 318.279, y = -7.347, z = -16.922 },
        },
        -- Region 6: SW deep area (5 points)
        {
            { x = 333.867, y = -16.287, z = -148.647 },
            { x = 336.613, y = -16.294, z = -150.729 },
            { x = 339.151, y = -16.018, z = -187.016 },
            { x = 340.843, y = -16.219, z = -152.912 },
            { x = 342.024, y = -16.797, z = -144.020 },
        },
        -- Region 7: North central elevated (3 points)
        {
            { x = 345.358, y = -3.305, z = 107.569 },
            { x = 347.173, y = -2.837, z = 112.185 },
            { x = 351.337, y = -3.550, z = 107.287 },
        },
        -- Region 8: SE deep (2 points)
        {
            { x = 347.386, y = -16.302, z = -13.217 },
            { x = 349.759, y = -16.028, z = -10.616 },
        },
        -- Region 9: Central deep (3 points)
        {
            { x = 368.781, y = -16.276, z = -132.078 },
            { x = 372.355, y = -16.502, z = -127.022 },
            { x = 378.170, y = -15.000, z = -126.916 },
        },
        -- Region 10: East deep (3 points)
        {
            { x = 433.062, y = -7.499, z = -121.791 },
            { x = 436.278, y = -7.500, z = -122.607 },
            { x = 438.778, y = -7.500, z = -122.998 },
        },
        -- Region 11: E-NE elevated (3 points)
        {
            { x = 454.148, y = -7.000, z = 131.891 },
            { x = 455.183, y = -7.740, z = 124.322 },
            { x = 461.871, y = -4.575, z = 123.948 },
        },
        -- Region 12: East boat area (5 points) - BOAT CHEST
        {
            { x = 467.187, y = -7.499, z = 225.479 },
            { x = 468.074, y = -7.499, z = 229.404 },
            { x = 469.415, y = -7.499, z = 222.882 },
            { x = 471.071, y = -7.000, z = 231.699 },
            { x = 475.257, y = -7.500, z = 226.042 },
        },
        -- Region 13: E shallow (2 points)
        {
            { x = 463.875, y = -2.305, z = 187.548 },
            { x = 470.484, y = -2.239, z = 187.388 },
        },
        -- Region 14: SE boat area (3 points) - BOAT CHEST
        {
            { x = 506.696, y = -7.500, z = 101.896 },
            { x = 508.958, y = -7.500, z = 106.356 },
            { x = 511.790, y = -7.500, z = 101.802 },
        },
        -- Region 15: NE boat area (4 points) - BOAT CHEST
        {
            { x = 529.484, y = -5.110, z = 254.873 },
            { x = 530.257, y = -6.640, z = 260.204 },
            { x = 541.296, y = -7.999, z = 257.660 },
            { x = 541.307, y = -5.643, z = 253.104 },
        },
        -- Region 16: Far NE deep (4 points)
        {
            { x = 536.697, y = -4.337, z = 165.781 },
            { x = 539.176, y = -4.912, z = 171.565 },
            { x = 544.142, y = -7.035, z = 164.850 },
            { x = 545.364, y = -6.736, z = 171.748 },
        },
        -- Region 17: Far NE deep isolated (1 point)
        {
            { x = 545.765, y = -16.104, z = 131.891 },
        },
        -- Region 18: Far E deep isolated (1 point)
        {
            { x = 578.367, y = -15.782, z = 97.985 },
        },
    },
}

return GoldenSalvageData
