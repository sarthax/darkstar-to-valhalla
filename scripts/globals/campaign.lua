

-----------------------------------------------------------------
-- Variable for getNationTeleport and getPoint
-----------------------------------------------------------------

ALLIED_NOTES = 11;
MAW = 4;
PAST_SANDORIA = 5;
PAST_BASTOK = 6;
PAST_WINDURST = 7;

-- -------------------------------------------------------------------
-- getMedalRank()
-- Returns the numerical Campaign Medal of the player.
-- -------------------------------------------------------------------

function getMedalRank(player)
    local rank = 0;
    local medals =
    {
         0x039C, 0x039D, 0x039E, 0x039F, 0x03A0, 0x03A1, 0x03A2,
         0x03A3, 0x03A4, 0x03A5, 0x03A6, 0x03A7, 0x03A8, 0x03A9,
         0x03AA, 0x03AB, 0x03AC, 0x03AD, 0x03AE, 0x03AF
    }
    while (player:hasKeyItem(medals[rank + 1]) == true) do
        rank = rank + 1;
    end;
    return rank;
end;

-- -------------------------------------------------------------------
-- get[nation]NotesItem()
-- Returns the item ID and cost of the Allied Notes indexed item
-- (the same value as that used by the vendor event)
-- Format:
-- ListName_AN_item[optionID] = itemID; -- ItemName
-- ListName_AN_price[optionID] = cost; -- ItemName
-- -------------------------------------------------------------------

function getSandOriaNotesItem(i)
    local SandOria_AN =
    {
        [2] = {id = 15754, price = 980}, -- Sprinter's Shoes
        [258] = {id = 5428, price = 10}, -- Scroll of Instant Retrace
        [514] = {id = 14584, price = 1500}, -- Iron Ram jack coat
        [770] = {id = 14587, price = 1500}, -- Pilgrim Tunica
        [1026] = {id = 16172, price = 4500}, -- Iron Ram Shield
        [1282] = {id = 15841, price = 5000}, -- Recall Ring: Jugner
        [1538] = {id = 15842, price = 5000}, -- Recall Ring: Pashow
        [1794] = {id = 15843, price = 5000}, -- Recall Ring: Meriphataud
        [2050] = {id = 10116, price = 2000} -- Cipher: Valaineral
    }
    local item = SandOria_AN[i];
    if (item == nil) then return nil, nil; end
    return item.id, item.price;
end;

function getBastokNotesItem(i)
    local Bastok_AN =
    {
        [2] = {id = 15754, price = 980}, -- Sprinter's Shoes
        [258] = {id = 5428, price = 10}, -- Scroll of Instant Retrace
        -- [514] = {id = ?, price = ?}, --
        -- [770] = {id = ?, price = ?}, --
        -- [1026] = {id = ?, price = ?}, --
        [1282] = {id = 15841, price = 5000}, -- Recall Ring: Jugner
        [1538] = {id = 15842, price = 5000}, -- Recall Ring: Pashow
        [1794] = {id = 15843, price = 5000}, -- Recall Ring: Meriphataud
        [2050] = {id = 10116, price = 2000} -- Cipher: Valaineral
    }
    local item = Bastok_AN[i];
    if (item == nil) then return nil, nil; end
    return item.id, item.price;
end;

function getWindurstNotesItem(i)
    local Windurst_AN =
    {
        [2] = {id = 15754, price = 980}, -- Sprinter's Shoes
        [258] = {id = 5428, price = 10}, -- Scroll of Instant Retrace
        -- [514] = {id = ?, price = ?}, --
        -- [770] = {id = ?, price = ?}, --
        -- [1026] = {id = ?, price = ?}, --
        [1282] = {id = 15841, price = 5000}, -- Recall Ring: Jugner
        [1538] = {id = 15842, price = 5000}, -- Recall Ring: Pashow
        [1794] = {id = 15843, price = 5000}, -- Recall Ring: Meriphataud
        [2050] = {id = 10116, price = 2000} -- Cipher: Valaineral
    }
    local item = Windurst_AN[i];
    if (item == nil) then return nil, nil; end
    return item.id, item.price;
end;

-- -------------------------------------------------------------------
-- getSigilTimeStamp(player)
-- This is for the time-stamp telling player what day/time the
-- effect will last until, NOT the actual status effect duration.
-- -------------------------------------------------------------------

function getSigilTimeStamp(player)
    local timeStamp = VanadielTime();
    local sigil = player:getStatusEffect(EFFECT_SIGIL);

    if (sigil ~= nil) then
        timeStamp = timeStamp + sigil:getTimeRemaining() / 1000;
    end

    return timeStamp;
end;

-----------------------------------
-- hasMawActivated Action
-----------------------------------

-- 1st number for hasMawActivated()
-- 2nd number for player:addNationTeleport();

-- 0    1   Batallia Downs (S) (H-5)
-- 1    2   Rolanberry Fields (S) (H-6)
-- 2    4   Sauromugue Champaign (S) (K-9)
-- 3    8   Jugner Forest (S) (H-11)
-- 4    16  Pashhow Marshlands (S) (K-8)
-- 5    32  Meriphataud Mountains (S) (K-6)
-- 6    64  East Ronfaure (S) (H-5)
-- 7    128 North Gustaberg (S) (K-7)
-- 8    256 West Sarutabaruta (S) (H-9)

function hasMawActivated(player,portal)
    local mawActivated = player:getNationTeleport(MAW);
    local bit = {};

    for i = 8,0,-1 do
        twop = 2^i

        if (mawActivated >= twop) then
            bit[i]=true; mawActivated = mawActivated - twop;
        else
            bit[i]=false;
        end
    end;

    return bit[portal];
end;

-- TODO:
-- Past nation teleport
-- -------------------------------------------------------------------
-- Shared Sigil NPC hooks (ported from LSB xi.campaign.sigilOn*)
-- Event params 0-3 verified by decompiling event 110 (San d'Oria [S]):
--   0 = allegiance, 1 = allied notes, 2 = freelance mask, 3 = menu bits.
-- Params 4-7 (rank, 0, timestamp, 0) follow LSB; not independently decoded.
-- zoneid = { base csid, nation allegiance }
-- -------------------------------------------------------------------

local SIGIL_NPC_INFO =
{
    [80] = { 110, 1 }, -- Southern San d'Oria [S] (Miliart, T.K.)
    [87] = {  13, 2 }, -- Bastok Markets [S] (Millard, I.M.)
    [94] = {  13, 3 }, -- Windurst Waters [S] (Mindala-Andola, C.C.)
};

local function getSigilRank(player)
    for ki = 0x03AF, 0x039C, -1 do
        if (player:hasKeyItem(ki) == true) then
            return 1 + ki - 0x039C;
        end
    end
    return 0;
end;

local function getSigilMenuOptions(player)
    -- bit 0: medal expired, bit 1: no Sigil active, bit 2: Valaineral available, bit 3: Adelheid available
    local mask = 0; -- campaign event flags (bits 2/3) not implemented
    if (player:hasStatusEffect(EFFECT_SIGIL) == false) then
        mask = mask + 2;
    end
    return mask;
end;

local function getNotesItemByZone(zoneid, option)
    if (zoneid == 80) then return getSandOriaNotesItem(option);
    elseif (zoneid == 87) then return getBastokNotesItem(option);
    else return getWindurstNotesItem(option); end
end;

function sigilOnTrigger(player, npc)
    local info = SIGIL_NPC_INFO[player:getZoneID()];

    if (getMedalRank(player) == 0) then
        player:startEvent(info[1] + 1);
    else
        player:startEvent(info[1],
            player:getCampaignAllegiance(),
            player:getCurrency("allied_notes"),
            0, -- freelance mask (bit 0 enables reduced EXP loss), not implemented
            getSigilMenuOptions(player),
            getSigilRank(player),
            0,
            getSigilTimeStamp(player),
            0);
    end
end;

function sigilOnEventUpdate(player, csid, option)
    local info = SIGIL_NPC_INFO[player:getZoneID()];

    if (csid == info[1] and option % 16 == 2) then
        local canEquip = 2; -- 0 = wrong job, 1 = wrong level, 2 = ok, 3+ = exit menu
        local itemid = getNotesItemByZone(player:getZoneID(), option);

        -- canEquipItem assumes armor/weapon data; only call it for equipment ids
        if (itemid ~= nil and itemid >= 12000) then
            if (player:canEquipItem(itemid) == false) then
                canEquip = 0;
            elseif (player:canEquipItem(itemid, true) == false) then
                canEquip = 1;
            end
        end

        player:updateEvent(0, 0, 0, 0, 0, 0, 0, canEquip);
    end
end;

function sigilOnEventFinish(player, csid, option)
    local zoneid = player:getZoneID();
    local info = SIGIL_NPC_INFO[zoneid];

    if (csid ~= info[1] or option == 0 or option == 1073741824) then
        return;
    end

    if (option % 16 == 1) then
        local selected = math.floor((option - 1) / 4096); -- bit0 Regen, bit1 Refresh, bit2 Meal, bit3 EXP loss
        local cost = 0;
        for i = 0, 3 do
            if (math.floor(selected / 2^i) % 2 == 1) then
                cost = cost + 50;
            end
        end

        if (player:getCurrency("allied_notes") < cost) then
            return;
        end

        local duration = 10800 + ((15 * getMedalRank(player)) * 60); -- 3hrs + 15 min per medal
        local subPower = 35; -- regen/refresh trigger %, static minimum

        player:delStatusEffect(EFFECT_SIGIL);
        player:delStatusEffect(EFFECT_SANCTION);
        player:delStatusEffect(EFFECT_SIGNET);
        player:addStatusEffect(EFFECT_SIGIL, selected, 0, duration, 0, subPower, 0);
        player:messageSpecial(ALLIED_SIGIL);

        if (cost > 0) then
            player:delCurrency("allied_notes", cost);
        end

    elseif (option % 16 == 2) then
        local item, price = getNotesItemByZone(zoneid, option);

        if (item == nil) then
            return;
        end

        if (player:getCurrency("allied_notes") < price) then
            return;
        end

        if (player:getFreeSlotsCount() >= 1) then
            player:delCurrency("allied_notes", price);
            player:addItem(item);
            player:messageSpecial(ITEM_OBTAINED, item);
        else
            player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, item);
        end
    end
end;

-----------------------------------
-- Campaign Ops overseer menu (csid 307 San d'Oria/Windurst, 316 Bastok)
-- Wire protocol decoded from retail captures (docs/campaign/OPS_NPC_EVENTS.md):
--   start params = {credits, 1, 0, 1, 0, 0, 0, 0}
--   client option 9           -> ack, server echoes the previous reply
--   client option (n<<8)|5    -> op at menu slot n picked, server answers a status update
-- The reply values are a snapshot of what retail sent with every op open; retail derives them
-- from live campaign state which this server does not have, so the semantics of the mask/count
-- fields are NOT decoded. Op credits are not regenerated (no retail timer data); a new player gets 1.
-----------------------------------

function opsOnTrigger(player, csid)
    local credits = player:getVar("CampaignOpCredits");
    if (credits == 0) then
        credits = 1;
        player:setVar("CampaignOpCredits", credits);
    end
    local reply = {credits, 1, 0, 1, 0, 0, 0, 0};
    for i = 1, 8 do
        player:setLocalVar("opsReply" .. i, reply[i]);
    end
    player:startEvent(csid, reply[1], reply[2], reply[3], reply[4], reply[5], reply[6], reply[7], reply[8]);
end;

function opsOnEventUpdate(player, csid, option)
    local reply;
    if (option == 9) then
        -- ack: retail echoes {9, <p1>, <p2>, ...} of the previous status reply
        reply = {9, player:getLocalVar("opsReply2"), player:getLocalVar("opsReply3"), player:getLocalVar("opsReply4"), 0, 0, 0, 0};
    elseif (option % 256 == 5) then
        local slot = math.floor(option / 256);
        if (slot == 8) then
            reply = {1047550, 4, 1024, 0, 0, 0, 0, 0};
        else
            reply = {1048574, 4, 0, 0, 0, 0, 0, 0};
        end
    else
        return;
    end
    for i = 1, 8 do
        player:setLocalVar("opsReply" .. i, reply[i]);
    end
    player:updateEvent(reply[1], reply[2], reply[3], reply[4], reply[5], reply[6], reply[7], reply[8]);
end;

-- Campaign state accessors (engine: GetCampaignValue / SetCampaignValue, tables campaign_nation / campaign_map).
-- Nation ids: 0 Sandoria, 1 Bastok, 2 Windurst, 3 Orc, 4 Quadav, 5 Yagudo, 6 Dark Kindred.
function getCampaignNationState(nationId)
    return {
        recon      = GetCampaignValue("nation", nationId, "reconnaissance"),
        morale     = GetCampaignValue("nation", nationId, "morale"),
        prosperity = GetCampaignValue("nation", nationId, "prosperity"),
    };
end;

function setCampaignNationValue(nationId, column, value)
    SetCampaignValue("nation", nationId, column, value);
end;

-- Region rows follow campaign_map.id order; nation is the packet owner value (army index + 1).
function getCampaignRegionState(regionId)
    return {
        owner      = GetCampaignValue("map", regionId, "nation"),
        heroism    = GetCampaignValue("map", regionId, "heroism"),
        fort       = GetCampaignValue("map", regionId, "current_fortifications"),
        resources  = GetCampaignValue("map", regionId, "current_resources"),
        maxFort    = GetCampaignValue("map", regionId, "max_fortifications"),
        maxRes     = GetCampaignValue("map", regionId, "max_resources"),
    };
end;
