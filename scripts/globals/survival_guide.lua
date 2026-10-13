-----------------------------------
-- Survival Guide network (backported from LandSandBoat teleports/survival_guide.lua)
-- State is kept in player vars (home point pattern); no C++ or database changes.
--   SG_Reg<group>a / SG_Reg<group>b : registered guides of a group, low/high 16 bits (bit = index-1)
--   SG_Fav1..9 : favorite guide id + 1 (0 = empty);  SG_Layout : menu layout (0 region, 1 content)
-----------------------------------
require("scripts/globals/settings");
require("scripts/globals/keyitems");
require("scripts/globals/survival_guide_map");

SURVIVAL_GUIDE = {};

SURVIVAL_GUIDE.EVENT = 8500;
-- Expansion mask sent to the client. Retail capture sends 0xFFF; gating by ENABLE_* hid group-2 entries (Carpenters Landing, Bibiki Bay) after registering. Only registered guides are selectable anyway.
SURVIVAL_GUIDE.EXPANSIONS = 0xFFF;
SURVIVAL_GUIDE.OPT = { TELEPORT = 1, SET_LAYOUT = 3, ADD_FAV = 4, REMOVE_FAV = 5, REPLACE_FAV = 6, MENU = 7 };

SURVIVAL_GUIDE.COST_GIL  = 1000;
SURVIVAL_GUIDE.COST_TABS = 50;

local function groupMask(player, group)
    return bit.bor(bit.lshift(player:getVar("SG_Reg"..group.."b"), 16), player:getVar("SG_Reg"..group.."a"));
end

function SURVIVAL_GUIDE.isRegistered(player, group, index)
    return bit.band(groupMask(player, group), bit.lshift(1, index - 1)) ~= 0;
end

function SURVIVAL_GUIDE.register(player, group, index)
    local mask = bit.bor(groupMask(player, group), bit.lshift(1, index - 1));
    player:setVar("SG_Reg"..group.."a", bit.band(mask, 0xFFFF));
    player:setVar("SG_Reg"..group.."b", bit.band(bit.rshift(mask, 16), 0xFFFF));
end

-- unsigned 32-bit mask as the client expects it
local function groupParam(player, group)
    local m = groupMask(player, group);
    if (m < 0) then m = m + 4294967296; end
    return m;
end

local function getFavorites(player)
    local f = {};
    for i = 1, 9 do f[i] = player:getVar("SG_Fav"..i) - 1; end   -- -1 = empty
    return f;
end

local function setFavorites(player, f)
    for i = 1, 9 do player:setVar("SG_Fav"..i, f[i] + 1); end
end

local function thriftyTransit(player)
    return MOG_TABLET ~= nil and MOG_TABLET.hasPower ~= nil and MOG_TABLET.POWERS ~= nil
        and MOG_TABLET.hasPower(MOG_TABLET.POWERS.THRIFTY_TRANSIT, player:getZoneID());
end

local function costs(player)
    if (thriftyTransit(player)) then return 0, 0; end
    if (player:hasKeyItem(RHAPSODY_IN_WHITE)) then
        return math.floor(SURVIVAL_GUIDE.COST_GIL / 5), math.floor(SURVIVAL_GUIDE.COST_TABS / 5);
    end
    return SURVIVAL_GUIDE.COST_GIL, SURVIVAL_GUIDE.COST_TABS;
end

local function findCurrent(zoneId)
    for id, g in pairs(SURVIVAL_GUIDE_MAP) do
        if (g.zone == zoneId) then return id, g; end
    end
end

function SURVIVAL_GUIDE.onTrigger(player, registerText)
    local tableIndex, guide = findCurrent(player:getZoneID());
    if (guide == nil) then return; end

    if (not SURVIVAL_GUIDE.isRegistered(player, guide.group, guide.index)) then
        SURVIVAL_GUIDE.register(player, guide.group, guide.index);
        if (registerText ~= nil) then player:messageSpecial(registerText); end
        return;
    end

    local param = bit.bor(tableIndex, bit.lshift(player:getCurrency("valor_point"), 16));
    param = bit.bor(param, 0x4000);                       -- set = no tutorial free warp
    if (thriftyTransit(player)) then param = bit.bor(param, 0x0400); end   -- free travel
    if (player:getVar("SG_Layout") == 1) then param = bit.bor(param, 0x0800); end
    if (player:hasKeyItem(RHAPSODY_IN_WHITE)) then param = bit.bor(param, 0x2000); end

    local expansions = SURVIVAL_GUIDE.EXPANSIONS;
    player:startEvent(SURVIVAL_GUIDE.EVENT, 0, param, player:getGil(),
        groupParam(player, 1), groupParam(player, 2), groupParam(player, 3), groupParam(player, 4), expansions);
end

local function packed(f, layout)
    local function b(v) return bit.band(v, 0xFF); end
    local w1 = b(f[1]) + b(f[2]) * 256 + b(f[3]) * 65536 + b(f[4]) * 16777216;
    local w2 = b(f[5]) + b(f[6]) * 256 + b(f[7]) * 65536 + b(f[8]) * 16777216;
    local w3 = b(f[9]) + layout * 256;
    return w1, w2, w3;
end

function SURVIVAL_GUIDE.onEventUpdate(player, csid, option)
    if (csid ~= SURVIVAL_GUIDE.EVENT) then return; end
    local choice = bit.band(option, 0xFF);
    if (choice < SURVIVAL_GUIDE.OPT.SET_LAYOUT or choice > SURVIVAL_GUIDE.OPT.MENU) then return; end

    local f = getFavorites(player);
    local layout = player:getVar("SG_Layout");
    local index = bit.rshift(bit.band(option, 0xFF0000), 16);

    if (choice == SURVIVAL_GUIDE.OPT.ADD_FAV) then
        for x = 1, 9 do f[x], index = index, f[x]; end
    elseif (choice == SURVIVAL_GUIDE.OPT.REMOVE_FAV) then
        for x = 1, 9 do
            if (f[x] == index) then
                for y = x, 8 do f[y] = f[y + 1]; end
                f[9] = -1;
                break;
            end
        end
    elseif (choice == SURVIVAL_GUIDE.OPT.REPLACE_FAV) then
        f[bit.rshift(option, 24) + 1] = index;
    elseif (choice == SURVIVAL_GUIDE.OPT.SET_LAYOUT) then
        layout = bit.rshift(option, 16);
        player:setVar("SG_Layout", layout);
    end

    if (choice ~= SURVIVAL_GUIDE.OPT.MENU) then setFavorites(player, f); end
    local w1, w2, w3 = packed(f, layout);
    player:updateEvent(w1, w2, w3);
end

function SURVIVAL_GUIDE.onEventFinish(player, csid, option)
    if (csid ~= SURVIVAL_GUIDE.EVENT) then return; end
    if (bit.band(option, 0xFF) ~= SURVIVAL_GUIDE.OPT.TELEPORT) then return; end

    local dest = SURVIVAL_GUIDE_MAP[bit.rshift(option, 16)];
    if (dest == nil or dest.zone == player:getZoneID()) then return; end
    if (not SURVIVAL_GUIDE.isRegistered(player, dest.group, dest.index)) then return; end

    local gil, tabs = costs(player);
    local viaTabs = bit.band(bit.rshift(option, 8), 1) == 1;
    if (viaTabs) then
        if (player:getCurrency("valor_point") < tabs) then return; end
        if (tabs > 0) then player:delCurrency("valor_point", tabs); end
    elseif (bit.band(bit.rshift(option, 9), 1) == 1) then
        return;   -- tutorial one-time free warp is not supported
    else
        if (player:getGil() < gil) then return; end
        if (gil > 0) then player:delGil(gil); end
    end

    player:setPos(dest.x, dest.y, dest.z, dest.rot, dest.zone);
end
