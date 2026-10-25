-----------------------------------
-- Chocobo Raising (VCS) - Phase 1a: intro, egg trade, rejection, chocobo creation
-- Ported from LandSandBoat scripts/globals/hobbies/chocobo_raising. Unbred eggs only.
-- Main menu (csid main), care plan and growth are Phase 1b/2 and are not handled here.
-----------------------------------

require("scripts/globals/status");

CHOCOBO_RAISING = {};

-- { intro, main, trade, rejection } per trainer zone (LSB csidTable; trainer csids verified on this client)
CHOCOBO_RAISING.csids =
{
    [230] = { 817, 823, 826, 831 }, -- Southern San d'Oria, Hantileon
    [234] = { 508, 509, 512, 515 }, -- Bastok Mines, Zopago
    [241] = { 741, 742, 745, 748 }, -- Windurst Woods, Pulonono
};

CHOCOBO_RAISING.location = { [230] = 1, [234] = 2, [241] = 3 };

-- Option values confirmed by retail captures 824/825 (LSB agrees)
CHOCOBO_RAISING.OPT_TRADE     = 252;
CHOCOBO_RAISING.OPT_REJECTION = 244;

-- Growth constants (LSB scripts/globals/chocobo_raising.lua + hobbies/chocobo_raising/constants.lua)
CHOCOBO_RAISING.stage =
{
    EGG = 1, CHICK = 2, ADOLESCENT = 3, ADULT_1 = 4, ADULT_2 = 5, ADULT_3 = 6, ADULT_4 = 7, -- ADULT_4 = retired
};

CHOCOBO_RAISING.dayLength        = 86400;
CHOCOBO_RAISING.daysToChick      = 4;
CHOCOBO_RAISING.daysToAdolescent = 19;
CHOCOBO_RAISING.daysToAdult1     = 29;
CHOCOBO_RAISING.daysToAdult2     = 43;
CHOCOBO_RAISING.daysToAdult3     = 64;
CHOCOBO_RAISING.daysToAdult4     = 129;

local STAGE_EGG  = CHOCOBO_RAISING.stage.EGG;
local MAX_HUNGER = 255;
local COLOR_YELLOW, COLOR_BLACK, COLOR_BLUE, COLOR_RED, COLOR_GREEN = 0, 1, 2, 3, 4;
local ALL_COLORS = { COLOR_YELLOW, COLOR_BLACK, COLOR_BLUE, COLOR_RED, COLOR_GREEN };

local TRADED_EGG_VAR = "ChocoboRaisingTradedEgg";

-- Egg item ids (LSB enum item.lua, same ids as DSP item_basic)
local EGG_GENETICS =
{
    [2312] = { colors = { 95,  3,  1,   0.5, 0.5 }, pattern = { 25,   50, 25   } }, -- faintly warm
    [2314] = { colors = { 85,  5,  3.4, 3.3, 3.3 }, pattern = { 17.5, 60, 22.5 } }, -- slightly warm
    [2317] = { colors = { 75, 10,  5,   5,   5   }, pattern = { 16,   65, 19   } }, -- a bit warm
    [2318] = { colors = { 32, 18, 18,  16,  16   }, pattern = { 15,   70, 15   } }, -- a little warm
    [2319] = { colors = { 12, 22, 22,  22,  22   }, pattern = { 10,   75, 15   } }, -- somewhat warm
};

local function randomInt(lo, hi)
    return math.random(lo, hi);
end

local function weightedPick(weights)
    local total = 0;
    for _, w in ipairs(weights) do
        total = total + w;
    end

    local roll = randomInt(1, 1000) * total / 1000;
    for i, w in ipairs(weights) do
        roll = roll - w;
        if (roll <= 0) then
            return i;
        end
    end
    return #weights;
end

function CHOCOBO_RAISING.allelesToColor(dna)
    local counts = {};
    for i = 1, 3 do
        local gene = dna[i] or COLOR_YELLOW;
        counts[gene] = (counts[gene] or 0) + 1;
    end

    for gene, count in pairs(counts) do
        if (count >= 2) then
            return gene;
        end
    end

    if (counts[COLOR_YELLOW] or not counts[COLOR_BLACK]) then
        return COLOR_YELLOW;
    end
    return COLOR_BLACK;
end

function CHOCOBO_RAISING.rollEggAlleles(itemId)
    local genetics = EGG_GENETICS[itemId] or EGG_GENETICS[2312];
    local shown    = ALL_COLORS[weightedPick(genetics.colors)];
    local pattern  = weightedPick(genetics.pattern);

    if (pattern == 1) then
        return { shown, shown, shown };
    end

    if (pattern == 3 and (shown == COLOR_YELLOW or shown == COLOR_BLACK)) then
        local genes = { shown };
        while (#genes < 3) do
            local gene = ALL_COLORS[randomInt(1, #ALL_COLORS)];
            -- a black egg must not carry yellow, or it would show yellow
            local allowed = gene ~= shown and not (shown == COLOR_BLACK and gene == COLOR_YELLOW);
            for _, existing in ipairs(genes) do
                allowed = allowed and gene ~= existing;
            end
            if (allowed) then
                table.insert(genes, gene);
            end
        end
        return genes;
    end

    local others = {};
    for _, gene in ipairs(ALL_COLORS) do
        if (gene ~= shown) then
            table.insert(others, gene);
        end
    end

    local genes = { shown, shown, others[randomInt(1, #others)] };
    local odd   = randomInt(1, 3);
    genes[3], genes[odd] = genes[odd], genes[3];
    return genes;
end

function CHOCOBO_RAISING.newChocobo(player, eggId, location)
    local dna = CHOCOBO_RAISING.rollEggAlleles(eggId);

    -- Basic care for all four slots: (7 << 4) + 0 == 0x70 per byte
    local plan = 0x70;

    return
    {
        first_name = "Chocobo",
        last_name  = "Chocobo",
        sex        = randomInt(1, 100) <= 50 and 0 or 1,
        last_update_age = 1,
        stage      = STAGE_EGG,
        location   = location,
        allele1    = dna[1],
        allele2    = dna[2],
        allele3    = dna[3],
        color      = CHOCOBO_RAISING.allelesToColor(dna),
        strength = 0, endurance = 0, discernment = 0, receptivity = 0,
        affection  = 255,
        energy     = 100,
        satisfaction = 0,
        conditions = 0,
        ability1 = 0, ability2 = 0,
        personality = 0,
        weather_preference = 0,
        hunger     = MAX_HUNGER,
        care_plan  = plan * 0x1000000 + plan * 0x10000 + plan * 0x100 + plan,
        held_item  = 0,
        locked_plan = 0,
        appearance = 0,
        walk_progress = 0,
    };
end

-- Age in days: the day the egg was handed in is day 1, capped at retirement.
function CHOCOBO_RAISING.ageOf(saved)
    local age = math.floor((os.time() - saved.created) / CHOCOBO_RAISING.dayLength) + 1;
    return math.min(age, CHOCOBO_RAISING.daysToAdult4 + 1);
end

function CHOCOBO_RAISING.ageToStage(age)
    local limits = { CHOCOBO_RAISING.daysToChick, CHOCOBO_RAISING.daysToAdolescent, CHOCOBO_RAISING.daysToAdult1,
                     CHOCOBO_RAISING.daysToAdult2, CHOCOBO_RAISING.daysToAdult3, CHOCOBO_RAISING.daysToAdult4 };
    for stage, limit in ipairs(limits) do
        if (age <= limit) then
            return stage;
        end
    end
    return CHOCOBO_RAISING.stage.ADULT_4;
end

local function isEgg(trade)
    if (trade:getSlotCount() ~= 1 or trade:getItemCount() ~= 1) then
        return false;
    end
    return EGG_GENETICS[trade:getItemId(0)] ~= nil;
end

-----------------------------------
-- Trainer hooks
-----------------------------------

function CHOCOBO_RAISING.onTrade(player, npc, trade)
    local zone  = player:getZoneID();
    local csids = CHOCOBO_RAISING.csids[zone];
    if (csids == nil or not isEgg(trade)) then
        return false;
    end

    local location = CHOCOBO_RAISING.location[zone];
    local saved    = player:getChocoboRaisingInfo();

    if (saved == nil) then
        player:setLocalVar(TRADED_EGG_VAR, trade:getItemId(0));
        player:startEvent(csids[3], VanadielTime(), 0, 0, 0, 0, 0, 0, location);
    else
        player:startEvent(csids[4], saved.location, 0, 0, 0, 0, 0, 0, location);
    end
    return true;
end

-- Returns true when the chocobo trainer logic handled the click.
function CHOCOBO_RAISING.onTrigger(player, npc)
    local zone  = player:getZoneID();
    local csids = CHOCOBO_RAISING.csids[zone];
    local saved = player:getChocoboRaisingInfo();

    if (saved == nil) then
        player:startEvent(csids[1], 1);
        return true;
    end

    if (saved.location ~= CHOCOBO_RAISING.location[zone]) then
        player:startEvent(csids[1], 1, 1, 1, 1);
        return true;
    end

    -- Main menu. P1b slice 1 shows the state only: no growth report (infoFlag 0) and no menu VM yet.
    -- Params follow LSB onTrigger: strings, isTradeEvent, infoFlag, sex.
    local infoFlag = 0;
    player:startEventString(csids[2], saved.first_name, saved.last_name, saved.first_name, saved.last_name,
        0, infoFlag, saved.sex, 0, 0, 0, 0, 0);
    return true;
end

function CHOCOBO_RAISING.onEventUpdate(player, csid, option)
    local zone  = player:getZoneID();
    local csids = CHOCOBO_RAISING.csids[zone];
    if (csids == nil) then
        return;
    end

    if (csid == csids[3] and option == CHOCOBO_RAISING.OPT_TRADE) then
        player:updateEvent(0, CHOCOBO_RAISING.location[zone], 0, 0, 0, 0, 0, 0);
    elseif (csid == csids[4] and option == CHOCOBO_RAISING.OPT_REJECTION) then
        local saved = player:getChocoboRaisingInfo();
        if (saved ~= nil) then
            player:updateEvent(0, 0, 0, 0, saved.stage, 1, 0, 0);
        end
    end
end

function CHOCOBO_RAISING.onEventFinish(player, csid, option, trade)
    local zone  = player:getZoneID();
    local csids = CHOCOBO_RAISING.csids[zone];
    if (csids == nil) then
        return;
    end

    if (csid == csids[3] and option == CHOCOBO_RAISING.OPT_TRADE) then
        local eggId = player:getLocalVar(TRADED_EGG_VAR);
        player:setLocalVar(TRADED_EGG_VAR, 0);

        if (eggId == 0 or player:getChocoboRaisingInfo() ~= nil) then
            return;
        end

        local newChoco = CHOCOBO_RAISING.newChocobo(player, eggId, CHOCOBO_RAISING.location[zone]);
        -- tradeComplete takes the whole trade; onTrade already required exactly one egg.
        -- It returns nothing, so there is no failure branch to roll the row back on.
        if (player:setChocoboRaisingInfo(newChoco)) then
            player:tradeComplete();
            local data = player:getChocoboUserData();
            player:setChocoboUserData({ chocobosRaised = data.chocobosRaised + 1 });
        end
    end
end
