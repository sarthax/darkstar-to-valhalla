-----------------------------------
-- Treasure Casket per-zone data (generated, see docs/slices/treasure-caskets/README.md)
--  base : npc id of the first of the 16 Treasure_Casket npcs in the zone (sql/npc_list.sql)
--  full : ITEM_CANNOT_BE_OBTAINED (zone TextIDs.lua, verified against client dialog; kept here because bare TextIDs globals can belong to another zone)
--  text : PLAYER_OBTAINS_TEMP_ITEM message id taken from the client dialog table (dat-extractor / mission_toolkit dialog.yml);
--         PLAYER_OBTAINS_ITEM = text-2, UNABLE_TO_OBTAIN_ITEM = text-1, ALREADY_POSSESS_TEMP = text+1
-----------------------------------

casket_zone_data =
{
    [100] = { base = 17187467, text = 8050, full = 6404 }, -- West_Ronfaure
    [101] = { base = 17191482, text = 7499, full = 6404 }, -- East_Ronfaure
    [102] = { base = 17195585, text = 7901, full = 6382 }, -- La_Theine_Plateau
    [103] = { base = 17199672, text = 8076, full = 6404 }, -- Valkurm_Dunes
    [104] = { base = 17203797, text = 8641, full = 6404 }, -- Jugner_Forest
    [105] = { base = 17207794, text = 7692, full = 6404 }, -- Batallia_Downs
    [106] = { base = 17212023, text = 8066, full = 6563 }, -- North_Gustaberg
    [107] = { base = 17216140, text = 7527, full = 6404 }, -- South_Gustaberg
    [108] = { base = 17220112, text = 7596, full = 6382 }, -- Konschtat_Highlands
    [109] = { base = 17224275, text = 8459, full = 6404 }, -- Pashhow_Marshlands
    [110] = { base = 17228319, text = 7583, full = 6404 }, -- Rolanberry_Fields
    [111] = { base = 17232175, text = 8560, full = 6565 }, -- Beaucedine_Glacier
    [112] = { base = 17236255, text = 8162, full = 6395 }, -- Xarcabard
    [113] = { base = 17240445, text = 7922, full = 6382 }, -- Cape_Teriggan
    [114] = { base = 17244595, text = 7761, full = 6382 }, -- Eastern_Altepa_Desert
    [115] = { base = 17248765, text = 7857, full = 6382 }, -- West_Sarutabaruta
    [116] = { base = 17253000, text = 7553, full = 6382 }, -- East_Sarutabaruta
    [117] = { base = 17257008, text = 7560, full = 6563 }, -- Tahrongi_Canyon
    [118] = { base = 17261113, text = 8102, full = 6417 }, -- Buburimu_Peninsula
    [119] = { base = 17265219, text = 8339, full = 6404 }, -- Meriphataud_Mountains
    [120] = { base = 17269190, text = 7499, full = 6404 }, -- Sauromugue_Champaign
    [121] = { base = 17273338, text = 8079, full = 6382 }, -- The_Sanctuary_of_ZiTah
    [122] = { base = 17277171, text = 7428, full = 6382 }, -- RoMaeve
    [123] = { base = 17281559, text = 7862, full = 6382 }, -- Yuhtunga_Jungle
    [124] = { base = 17285619, text = 7813, full = 6382 }, -- Yhoator_Jungle
    [125] = { base = 17289721, text = 7623, full = 6382 }, -- Western_Altepa_Desert
    [126] = { base = 17293678, text = 8046, full = 6382 }, -- Qufim_Island
    [127] = { base = 17297460, text = 7345, full = 6382 }, -- Behemoths_Dominion
    [128] = { base = 17301544, text = 7500, full = 6382 }, -- Valley_of_Sorrows
    [130] = { base = 17310003, text = 7564, full = 6382 }, -- RuAun_Gardens
    [153] = { base = 17404423, text = 11390, full = 6382 }, -- The_Boyahda_Tree
    [157] = { base = 17420683, text = 7370, full = 6545 }, -- Middle_Delkfutts_Tower
    [158] = { base = 17424575, text = 7376, full = 6417 }, -- Upper_Delkfutts_Tower
    [159] = { base = 17429046, text = 8439, full = 6382 }, -- Temple_of_Uggalepih
    [160] = { base = 17433024, text = 7403, full = 6382 }, -- Den_of_Rancor
    [166] = { base = 17457389, text = 10572, full = 6382 }, -- Ranguemont_Pass
    [167] = { base = 17461596, text = 10586, full = 6541 }, -- Bostaunieux_Oubliette
    [169] = { base = 17469861, text = 7533, full = 6428 }, -- Toraimarai_Canal
    [172] = { base = 17481850, text = 7406, full = 6541 }, -- Zeruhn_Mines
    [173] = { base = 17486215, text = 10511, full = 6382 }, -- Korroloka_Tunnel
    [174] = { base = 17490333, text = 11389, full = 6382 }, -- Kuftal_Tunnel
    [176] = { base = 17498681, text = 7598, full = 6382 }, -- Sea_Serpent_Grotto
    [177] = { base = 17502716, text = 11213, full = 6382 }, -- VeLugannon_Palace
    [178] = { base = 17506838, text = 11393, full = 6382 }, -- The_Shrine_of_RuAvitau
    [184] = { base = 17531243, text = 8623, full = 6571 }, -- Lower_Delkfutts_Tower
    [190] = { base = 17555907, text = 8247, full = 6541 }, -- King_Ranperres_Tomb
    [191] = { base = 17559944, text = 8367, full = 6541 }, -- Dangruf_Wadi
    [192] = { base = 17563838, text = 7403, full = 6551 }, -- Inner_Horutoto_Ruins
    [193] = { base = 17568213, text = 8379, full = 6541 }, -- Ordelles_Caves
    [194] = { base = 17572319, text = 8259, full = 6587 }, -- Outer_Horutoto_Ruins
    [195] = { base = 17576280, text = 7590, full = 6541 }, -- The_Eldieme_Necropolis
    [196] = { base = 17580429, text = 8299, full = 6382 }, -- Gusgen_Mines
    [197] = { base = 17584514, text = 7344, full = 6572 }, -- Crawlers_Nest
    [198] = { base = 17588799, text = 8265, full = 6382 }, -- Maze_of_Shakhrami
    [200] = { base = 17596738, text = 7521, full = 6541 }, -- Garlaige_Citadel
    [204] = { base = 17613285, text = 7509, full = 6561 }, -- FeiYin
    [205] = { base = 17617284, text = 11476, full = 6382 }, -- Ifrits_Cauldron
    [208] = { base = 17629663, text = 8278, full = 6382 }, -- Quicksand_Caves
    [212] = { base = 17645851, text = 10632, full = 6382 }, -- Gustav_Tunnel
    [213] = { base = 17649910, text = 10442, full = 6382 }, -- Labyrinth_of_Onzozo
};
