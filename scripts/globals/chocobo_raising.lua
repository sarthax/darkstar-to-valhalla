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
    if (csids == nil) then
        return false;
    end
    if (not isEgg(trade)) then
        return CHOCOBO_RAISING.onFoodTrade(player, csids, trade);
    end

    local location = CHOCOBO_RAISING.location[zone];
    local saved    = player:getChocoboRaisingInfo();

    if (saved == nil) then
        player:setLocalVar(TRADED_EGG_VAR, trade:getItemId(0));
        CHOCOBO_RAISING.stashEgg(player, trade);
        player:startEvent(csids[3], VanadielTime(), 0, 0, 0, 0, 0, 0, location);
    else
        player:startEvent(csids[4], saved.location, 0, 0, 0, 0, 0, 0, location);
    end
    return true;
end

-- Returns true when the chocobo trainer logic handled the click.
function CHOCOBO_RAISING.onTrigger(player, npc)
    if (CHOCOBO_RAISING.reportTrigger(player)) then
        return true;
    end
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
    if (CHOCOBO_RAISING.hasOwedItems(player)) then
        CHOCOBO_RAISING.handOver(player);
        return true;
    end

    local session;
    saved, session = CHOCOBO_RAISING.initState(player, saved);
    if (saved == nil) then
        return true;
    end
    local infoFlag = CHOCOBO_RAISING.reportInfoFlag(session);
    player:startEventString(csids[2], saved.first_name, saved.last_name, saved.first_name, saved.last_name,
        0, infoFlag, saved.sex, 0, 0, 0, 0, 0);
    return true;
end

-----------------------------------
-- Main menu VM (P1b slice 2): commands arrive as option & 0xFF, arg = option >> 8.
-- Reply shapes follow LSB event_vm.lua and agree with retail captures 824/825.
-----------------------------------

local VM_CHECK_REPORT = 208;
local VM_INTRO_PT_2   = 214;
local VM_INTRO_PT_3   = 215;
local VM_INTRO_PT_1   = 248;
local VM_PLAYOUT      = 246;
local VM_RETIRE       = 96;
local VM_AFTER_RETIREMENT = 40;
local VM_CHOCOCARD = 239;
local VM_CARE_MENU    = 250;
local VM_UNKNOWN_252  = 252;
local VM_CARE_PLAN_ACKS = { [254] = true, [510] = true, [766] = true, [1022] = true };

local VM_APPEARANCE = 244;
local VM_CONDITION  = 251;

-- LSB's numberToRank never leaves rank 0 (ipairs over a keyed table), so the
-- intended 32-points-per-rank mapping is used here. Unverified against retail.
local function numberToRank(value)
    return math.min(7, math.floor(value / 32));
end

local function affectionRank(value)
    return math.min(7, math.floor(value / 32));
end

local function hasBit(value, bitIndex)
    return math.floor(value / 2 ^ bitIndex) % 2 == 1;
end

-- condition bit (constants.lua conditions) -> condition reply bit
local CONDITION_REPLY_BITS = { [3] = 0, [2] = 1, [0] = 2, [8] = 4, [1] = 6, [5] = 7, [4] = 8, [7] = 9, [6] = 10, [11] = 12, [12] = 12, [13] = 13 };

local function conditionReply(saved)
    local arg1 = numberToRank(saved.strength) + numberToRank(saved.endurance) * 256 +
        numberToRank(saved.discernment) * 65536 + numberToRank(saved.receptivity) * 16777216;
    local arg2 = affectionRank(saved.affection) + saved.hunger * 65536;
    local arg3 = saved.personality + saved.weather_preference * 16 + saved.ability1 * 256 +
        saved.ability2 * 4096 + saved.stage * 65536;
    local arg4 = 0;
    local seen = {};
    for cond, replyBit in pairs(CONDITION_REPLY_BITS) do
        if (hasBit(saved.conditions, cond) and not seen[replyBit]) then
            seen[replyBit] = true;
            arg4 = arg4 + 2 ^ replyBit;
        end
    end
    return arg1, arg2, arg3, arg4;
end

local function appearanceReply(player, saved)
    local stage = saved.stage;
    if (stage == CHOCOBO_RAISING.stage.EGG) then
        player:updateEvent(COLOR_YELLOW, 0, 0, 0, stage, 0, 0, 0);
    elseif (stage < CHOCOBO_RAISING.stage.ADOLESCENT) then
        player:updateEvent(COLOR_YELLOW, 0, 0, 0, stage, saved.sex, 0, 0);
    elseif (stage < CHOCOBO_RAISING.stage.ADULT_1) then
        player:updateEvent(saved.color, 0, 0, 0, stage, saved.sex, 0, 0);
    else
        player:updateEvent(saved.color, saved.discernment >= 128 and 1 or 0,
            saved.strength >= 128 and 1 or 0, saved.endurance >= 128 and 1 or 0, stage, saved.sex, 0, 0);
    end
end

-- Feeding (P1b slice 4). Ids resolved by name from item_basic in dspdb_fresh;
-- gysahl greens 4545 also matches the retail capture's 241 menu reply.
-- { hunger, energy, glow }; glow ids are LSB chocoboRaising.glow (RED 96..GREEN 99).
local GLOW_RED, GLOW_BLUE, GLOW_YELLOW, GLOW_GREEN = 96, 97, 98, 99;
local VALID_FOODS =
{
    [4545] = { 25, 0, GLOW_RED },    [5605] = { 25, 0, GLOW_RED },    [5606] = { 25, 0, GLOW_RED },
    [2211] = { 25, 0, GLOW_RED },    [2208] = { 25, 0, GLOW_RED },    [2210] = { 25, 0, GLOW_RED },
    [2209] = { 25, 0, GLOW_RED },    [5607] = { 25, 0, GLOW_RED },    [4389] = { 25, 0, GLOW_RED },
    [5608] = { 25, 0, GLOW_BLUE },   [534]  = { 25, 0, GLOW_YELLOW }, [2202] = { 25, 0, GLOW_YELLOW },
    [2201] = { 25, 0, GLOW_YELLOW }, [2206] = { 50, 100, GLOW_YELLOW }, [2345] = { 25, 100, GLOW_YELLOW },
    [2197] = { 25, 0, GLOW_YELLOW }, [2203] = { 25, 0, GLOW_BLUE },   [2205] = { 25, 0, GLOW_YELLOW },
    [2204] = { 25, 0, GLOW_BLUE },   [2346] = { 25, 0, GLOW_GREEN },  [2207] = { 25, 0, GLOW_GREEN },
    [2569] = { 25, 0, GLOW_GREEN },  [2568] = { 25, 0, GLOW_GREEN },  [2343] = { 25, 0, GLOW_GREEN },
};

-- condition bit -> foods that cure it (LSB conditionsHealedByItems)
local CURE_FOODS =
{
    [0] = { 2201, 2207 }, [1] = { 2201, 2207 }, [2] = { 2202, 2207 }, [3] = { 534, 2207 },
    [4] = { 2207 }, [5] = { 2207 }, [6] = { 2207 },
};

-- Message ids verified by text against dialog.yml pulled with mission_toolkit.py for each zone
-- (LSB ids drift on this client): STILL_EGG "You cannot feed a chocobo that has not hatched yet.",
-- ITEM "${number: 1}: ${item-singular: 0[2]}" (param0 = item id, param1 = list position).
local FEED_TEXT =
{
    [230] = { STILL_EGG = 10708, ITEM = 11791 }, -- Southern San d'Oria
    [234] = { STILL_EGG = 12822, ITEM = 13905 }, -- Bastok Mines
    [241] = { STILL_EGG = 10596, ITEM = 11679 }, -- Windurst Woods
};

local VM_FEED = 241;
local foodGiven = {}; -- charid -> list of item ids, set by onTrade, used by the 241 option

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v));
end

local function handleFeed(player, saved)
    local list = foodGiven[player:getID()];
    if (list == nil or #list == 0) then
        return;
    end
    player:confirmTrade();
    for idx, itemId in ipairs(list) do
        local food = VALID_FOODS[itemId];
        local text = FEED_TEXT[player:getZoneID()];
        if (text ~= nil) then
            player:messageSpecial(text.ITEM, itemId, idx);
        end
        for cond, cures in pairs(CURE_FOODS) do
            if (hasBit(saved.conditions, cond)) then
                for _, cure in ipairs(cures) do
                    if (cure == itemId) then
                        saved.conditions = saved.conditions - 2 ^ cond;
                    end
                end
            end
        end
        saved.hunger = clamp(saved.hunger + food[1], 0, 255);
        saved.energy = clamp(saved.energy + food[2], 0, 100);
        local glow = #list > 1 and GLOW_GREEN or food[3];
        player:updateEvent(10, glow, 0, 0, 0, numberToRank(saved.hunger), 0, 0);
    end
    foodGiven[player:getID()] = nil;
    player:setChocoboRaisingInfo(saved);
end

-- Food trade to a chocobo that already exists: valid foods are confirmed and the main menu opens
-- with isTradeEvent = 8; the 241 option then feeds. Invalid items are returned untouched.
function CHOCOBO_RAISING.onFoodTrade(player, csids, trade)
    local zone  = player:getZoneID();
    local saved = player:getChocoboRaisingInfo();
    if (saved == nil or saved.location ~= CHOCOBO_RAISING.location[zone]) then
        return false;
    end
    if (saved.stage == CHOCOBO_RAISING.stage.EGG) then
        local text = FEED_TEXT[zone];
        if (text ~= nil) then
            player:messageSpecial(text.STILL_EGG);
        end
        return true;
    end

    local list = {};
    for slot = 0, trade:getSlotCount() - 1 do
        local id = trade:getItemId(slot);
        if (VALID_FOODS[id] ~= nil) then
            local qty = trade:getSlotQty(slot);
            trade:confirmItem(slot, qty);
            for _ = 1, qty do
                table.insert(list, id);
            end
        end
    end
    if (#list == 0) then
        return false;
    end

    foodGiven[player:getID()] = list;
    player:startEventString(csids[2], saved.first_name, saved.last_name, saved.first_name, saved.last_name,
        8, 0, saved.sex, 0, 0, 0, 0, 0);
    return true;
end

-- Menu bits are cleared (by subtracting 2^n) to enable an entry.
local function enable(mask, bitIndex)
    return mask - 2 ^ bitIndex;
end

local function introMenuFlags(saved)
    local flags = 0xFFFFFFFF;
    for i = 0, 2 do -- ask about condition, care for chocobo, set up care schedule
        flags = enable(flags, i);
    end

    if (saved.stage > CHOCOBO_RAISING.stage.EGG and saved.first_name == "Chocobo" and saved.last_name == "Chocobo") then
        flags = enable(flags, 3); -- name your chocobo
    end

    if (saved.stage >= CHOCOBO_RAISING.stage.ADULT_1) then
        flags = enable(flags, 29); -- retire (not handled yet)
    else
        flags = enable(flags, 30); -- give up (not handled yet)
    end

    return enable(flags, 31); -- exit
end

local function careScheduleReply(saved)
    local plan = saved.care_plan;
    local info = 0;
    for i = 0, 3 do
        local byte = math.floor(plan / 2 ^ (24 - i * 8)) % 256;
        local length, kind = math.floor(byte / 16), byte % 16;
        info = info + length * 2 ^ (i * 8) + kind * 2 ^ (i * 8 + 3);
    end

    local mask = 0x7FFFFFFF;
    local entries; -- basic care (0) always, more by stage
    if (saved.stage >= CHOCOBO_RAISING.stage.CHICK) then
        entries = { 0, 1, 2, 3 };
    else
        entries = { 0 };
    end
    if (saved.stage >= CHOCOBO_RAISING.stage.ADOLESCENT) then
        for _, i in ipairs({ 4, 5, 6, 7, 8, 9 }) do table.insert(entries, i); end
    end
    if (saved.stage >= CHOCOBO_RAISING.stage.ADULT_1) then
        for _, i in ipairs({ 10, 11, 12 }) do table.insert(entries, i); end
    end
    for _, i in ipairs(entries) do
        mask = enable(mask, i);
    end

    return info, mask;
end

-- Option 0xFE: slot = bits 8-11, length = bits 16-18, type = bits 19-22. Persists the new plan.
local function handleCarePlanUpdate(player, saved, option)
    local slot   = math.floor(option / 2 ^ 8) % 16;
    local length = math.floor(option / 2 ^ 16) % 8;
    local kind   = math.floor(option / 2 ^ 19) % 16;

    local shift  = 24 - slot * 8;
    local byte   = length * 16 + kind;
    local plan   = saved.care_plan;
    local old    = math.floor(plan / 2 ^ shift) % 256;
    saved.care_plan = plan - old * 2 ^ shift + byte * 2 ^ shift;

    player:setChocoboRaisingInfo(saved);
end

local function handleMenuVM(player, option)
    local saved = player:getChocoboRaisingInfo();
    if (saved == nil) then
        return;
    end

    local command = option % 256;
    if (command == 0xFE) then
        handleCarePlanUpdate(player, saved, option);
        return;
    end

    if (option == VM_CHECK_REPORT) then
        CHOCOBO_RAISING.handleCheckReport(player, saved);
    elseif (option == VM_UNKNOWN_252) then
        player:updateEvent(0, 1, 1, 1, saved.stage, 1, 1, 1);
    elseif (command == VM_INTRO_PT_1) then -- 248 = next report record, 504 (arg 1) = skip
        CHOCOBO_RAISING.handleReport(player, saved, math.floor(option / 256));
    elseif (command == VM_RETIRE) then
        CHOCOBO_RAISING.handleRetire(player, saved);
    elseif (command == VM_CHOCOCARD) then
        CHOCOBO_RAISING.handleChococard(player, saved);
    elseif (command == VM_AFTER_RETIREMENT) then
        CHOCOBO_RAISING.handleAfterRetirement(player, saved);
    elseif (command == VM_PLAYOUT) then
        CHOCOBO_RAISING.handlePlayout(player, saved, math.floor(option / 256));
    elseif (option == VM_INTRO_PT_2) then
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0);
    elseif (option == VM_INTRO_PT_3) then
        player:updateEvent(introMenuFlags(saved), 0, 0, 0, 0, 0, 0, 0);
    elseif (option == VM_CARE_MENU) then
        local info, mask = careScheduleReply(saved);
        player:updateEvent(250, info, 0, 0, 0, 0, 0, mask);
    elseif (command == CHOCOBO_RAISING.WHISTLE_SEARCH_CMD) then
        CHOCOBO_RAISING.handleWhistleSearch(player, saved, math.floor(option / 256));
    elseif (command == CHOCOBO_RAISING.TELL_STORY_CMD) then
        CHOCOBO_RAISING.handleStoryUpdate(player, saved, math.floor(option / 256));
    elseif (command == CHOCOBO_RAISING.WALK_CMD and math.floor(option / 256) == CHOCOBO_RAISING.TELL_STORY_ARG) then
        -- care action cutscenes are the action number plus 256 per location (298 = 42 + 256 in San d'Oria)
        CHOCOBO_RAISING.handleTellStory(player, saved, CHOCOBO_RAISING.TELL_STORY_ARG + 256 * saved.location);
    elseif (command == CHOCOBO_RAISING.WALK_CMD) then
        CHOCOBO_RAISING.handleWalk(player, saved, math.floor(option / 256));
    elseif (command == VM_FEED) then
        handleFeed(player, saved);
    elseif (command == VM_APPEARANCE) then
        appearanceReply(player, saved);
    elseif (command == VM_CONDITION) then
        local a1, a2, a3, a4 = conditionReply(saved);
        player:updateEvent(VM_CONDITION, a1, a2, a3, a4, 0, 0, 0);
    elseif (VM_CARE_PLAN_ACKS[option]) then
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0);
    end
end

function CHOCOBO_RAISING.onEventUpdate(player, csid, option)
    CHOCOBO_RAISING.whistleUpdate(player, csid, option);
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
    elseif (csid == csids[2]) then
        handleMenuVM(player, option);
    end
end

function CHOCOBO_RAISING.onEventFinish(player, csid, option, trade)
    CHOCOBO_RAISING.whistleFinish(player, csid, option);
    CHOCOBO_RAISING.reportFinish(player, csid);
    local zone  = player:getZoneID();
    local csids = CHOCOBO_RAISING.csids[zone];
    if (csids == nil) then
        return;
    end

    if (csid == csids[2]) then
        CHOCOBO_RAISING.onMenuFinish(player);
    elseif (csid == csids[3] and option == CHOCOBO_RAISING.OPT_TRADE) then
        local eggId = player:getLocalVar(TRADED_EGG_VAR);
        player:setLocalVar(TRADED_EGG_VAR, 0);

        if (eggId == 0 or player:getChocoboRaisingInfo() ~= nil) then
            return;
        end

        local newChoco = CHOCOBO_RAISING.newChocobo(player, eggId, CHOCOBO_RAISING.location[zone]);
        CHOCOBO_RAISING.applyBredEgg(player, newChoco);
        -- tradeComplete takes the whole trade; onTrade already required exactly one egg.
        -- It returns nothing, so there is no failure branch to roll the row back on.
        if (player:setChocoboRaisingInfo(newChoco)) then
            player:tradeComplete();
            local data = player:getChocoboUserData();
            player:setChocoboUserData({ chocobosRaised = data.chocobosRaised + 1 });
        end
    end
end

require("scripts/globals/chocobo_raising_day")
require("scripts/globals/chocobo_raising_walk")
require("scripts/globals/chocobo_raising_chick")
require("scripts/globals/chocobo_raising_story")
require("scripts/globals/chocobo_raising_whistle")
require("scripts/globals/chocobo_raising_breeding")
