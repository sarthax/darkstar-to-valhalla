-----------------------------------
-- Symphonic Curator (Mog House)
-- Ported from LSB globals/symphonic_curator.lua. Event 30034 is the Curator's own event in each
-- home-city Mog House (verified in FFXI-EventsDump for Windurst Waters entity 17752229).
-- Only "sheet of ... tunes" key items that exist in this DSP keyitems.lua are wired; the later
-- sheets (Shadow Lord, Mapitoto, Al'Taieu, Jeuno, ...) have no key item id here, so they are left
-- out rather than invented. Option -> song ids come from LSB captures and are NOT re-verified here.
-----------------------------------
require("scripts/globals/keyitems");

SYMPHONIC_CURATOR_EVENT = 30034;
MUSIC_SLOT_MOG_HOUSE    = 6;
local MOG_HOUSE_SONG    = 126;

-- DSP's `bit` library is the LuaBitOp one used elsewhere in scripts
local function packBit(value, position, on)
    if (on) then
        return bit.bor(value, bit.lshift(1, position));
    end
    return value;
end

function symphonicCuratorTrigger(player, npc)
    -- The first click you are always already listening to the Mog House song
    if (player:getLocalVar("Symphonic_Curator_Music") == 0) then
        player:setLocalVar("Symphonic_Curator_Music", MOG_HOUSE_SONG);
    end

    local songPacks = 0;
    songPacks = packBit(songPacks, 0, true); -- Mog House (126), Vana'diel March (108)
    songPacks = packBit(songPacks, 1, player:hasKeyItem(SHEET_OF_SAN_DORIAN_TUNES));
    songPacks = packBit(songPacks, 2, player:hasKeyItem(SHEET_OF_BASTOKAN_TUNES));
    songPacks = packBit(songPacks, 3, player:hasKeyItem(SHEET_OF_WINDURSTIAN_TUNES));
    songPacks = packBit(songPacks, 4, player:hasKeyItem(SHEET_OF_E_ADOULINIAN_TUNES));
    songPacks = packBit(songPacks, 5, player:hasKeyItem(SHEET_OF_W_ADOULINIAN_TUNES));
    songPacks = packBit(songPacks, 6, player:hasKeyItem(SHEET_OF_ZILART_TUNES));
    songPacks = packBit(songPacks, 7, player:hasKeyItem(SHEET_OF_CONFLICT_TUNES));
    songPacks = packBit(songPacks, 8, player:hasKeyItem(SHEET_OF_PROMATHIA_TUNES));
    songPacks = packBit(songPacks, 9, player:hasKeyItem(SHEET_OF_ADOULINIAN_TUNES));

    -- 0 bit = instrument shown, 1 bit = hidden; instrument must be installed in the Mog House
    local instruments = 0x0F;
    instruments = bit.band(instruments, bit.bnot(player:isFurnitureInstalled(426)  and 0x01 or 0)); -- Orchestrion
    instruments = bit.band(instruments, bit.bnot(player:isFurnitureInstalled(3677) and 0x02 or 0)); -- Spinet
    instruments = bit.band(instruments, bit.bnot(player:isFurnitureInstalled(286)  and 0x04 or 0)); -- Nanaa Mihgo Statue
    instruments = bit.band(instruments, bit.bnot(player:isFurnitureInstalled(287)  and 0x08 or 0)); -- Nanaa Mihgo Statue II

    player:startEvent(SYMPHONIC_CURATOR_EVENT, 0, 0xFFFF, songPacks, instruments);
end

-- The menu option does not line up with the song request, so map it
SYMPHONIC_CURATOR_SONGS =
{
    [1]=112, [2]=126, [3]=126, [4]=126, [17]=196, [18]=108, [19]=69, [20]=59,
    [33]=230, [34]=107, [49]=187, [50]=156, [65]=215, [66]=109, [81]=47, [82]=152,
    [97]=49, [98]=154, [113]=50, [114]=116, [129]=51, [130]=151, [145]=52, [146]=162,
    [161]=109, [162]=113, [177]=251, [178]=63, [193]=48, [194]=59, [209]=126, [210]=135,
    [226]=190, [242]=210,
    [258]=119, [274]=195, [290]=137, [306]=77, [322]=76, [338]=83, [354]=119, [370]=84,
    [386]=233, [402]=110, [418]=117, [434]=29, [450]=254, [466]=180, [482]=182, [498]=251,
    [514]=253, [530]=141, [546]=28, [562]=133, [578]=168, [594]=132, [610]=131, [626]=167,
    [642]=130, [558]=166, [674]=165, [690]=239, [706]=181, [722]=176, [738]=177, [754]=188,
    [770]=178, [786]=149, [802]=175, [818]=173, [834]=196,
};

function symphonicCuratorUpdate(player, csid, option)
    local song = SYMPHONIC_CURATOR_SONGS[option];
    if (song ~= nil) then
        player:ChangeMusic(MUSIC_SLOT_MOG_HOUSE, song);
    end
end

function symphonicCuratorFinish(player, csid, option)
    local song = SYMPHONIC_CURATOR_SONGS[option];
    if (option == 0 or song == nil) then
        player:ChangeMusic(MUSIC_SLOT_MOG_HOUSE, player:getLocalVar("Symphonic_Curator_Music")); -- cancel: restore
    else
        player:setLocalVar("Symphonic_Curator_Music", song);
        player:ChangeMusic(MUSIC_SLOT_MOG_HOUSE, song);
    end
end
