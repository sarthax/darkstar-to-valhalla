-----------------------------------
-- Chocobo Raising (VCS) - P1b slice 5: day rollover model, growth report (248), playout (246), skip.
-- Ported from LandSandBoat hobbies/chocobo_raising model.lua, care_plan.lua, condense_events.lua,
-- event_playout.lua and event_vm.lua (handleReport/handlePlayout).
-- Scene ids (location * 256 + offset) were checked against every 246 reply in the Chocobo Raising captures:
-- offsets 0,2,3,8,33-38,53,59,62,64-66,69-71,74,77,79,80,84-86 all match the table below.
-- Not ported yet: handkerchief (crying), whistle recharge (quest: chocobo_raising_whistle.lua, card menu: chocobo_raising_whistle_trade.lua), random name at adult 3, retirement. Odds marked "guess" are
-- LSB guesses with no capture behind them.
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

CR.conditions =
{
    INJURED = 0, SICK = 1, STOMACHACHE = 2, LONELY = 3, HIGH_SPIRITS = 4, SLEEPING = 5, VERY_ILL = 6,
    BORED = 7, SPOILED = 8, RUN_AWAY = 9, LOVESICK = 10, CRYING_AT_NIGHT = 11, FULL_OF_ENERGY = 12,
    BRIGHT_AND_FOCUSED = 13,
};
local cond = CR.conditions;

CR.cutscenes =
{
    EGG_HATCHING = 33, CHICK_TO_ADOLESCENT = 34, ADOLESCENT_TO_ADULT_1 = 35, ADULT_1_TO_ADULT_2 = 36,
    ADULT_2_TO_ADULT_3 = 37, ADULT_3_TO_ADULT_4 = 38,
    IS_INJURED = 58,           -- + condition bit
    INJURY_HAS_HEALED = 73,    -- + condition bit
};
local cs = CR.cutscenes;

local CONDITION_MASK     = 0x3FFF;
local PENDING_CURE_SHIFT = 16;
local FORCED_FEED_FLAG   = 30;
local STAT_FIELDS        = { "strength", "endurance", "discernment", "receptivity" };
local STAGE              = CR.stage;
local MAX_RECORD_DAYS    = 7;
local AVERAGE_STAT       = 96;
local CHICK_HUNGER_PER_ENERGY = 2.25; -- LSB: fitted to 20 captured nights
local STAT_PER_ARROW     = { 2, 3 };   -- guess
local AFFECTION_PER_ARROW = 2;         -- guess
local STAT_GROWTH_CAP    = 639;
local SKIP_REPORT_ARG    = 1;

-- stats are arrows of STR, END, DSC, RCP; pay is gil for a good day then a poor day.
local CARE_PLANS =
{
    [0]  = { stats = {  1,  1,  1,  1 }, affection = -1, energy =  2, poorEnergy = 0, difficulty = 1, success = { "affection" } },
    [1]  = { stats = {  0,  0,  0,  0 }, affection =  1, energy =  0, poorEnergy = 0, difficulty = 1, success = { "endurance" } },
    [2]  = { stats = {  2,  2, -1, -1 }, affection = -2, energy =  3, poorEnergy = 0, difficulty = 2, success = { "strength", "endurance" } },
    [3]  = { stats = { -1, -1,  2,  2 }, affection = -2, energy =  3, poorEnergy = 0, difficulty = 2, success = { "discernment", "receptivity" } },
    [4]  = { stats = {  2,  0, -2, -1 }, affection = -3, energy =  4, poorEnergy = 0, difficulty = 2, success = { "strength" } },
    [5]  = { stats = {  0,  2, -1, -2 }, affection = -3, energy =  4, poorEnergy = 0, difficulty = 3, success = { "endurance" } },
    [6]  = { stats = { -2, -1,  2,  0 }, affection = -3, energy =  4, poorEnergy = 0, difficulty = 2, success = { "discernment" } },
    [7]  = { stats = { -1, -2,  0,  2 }, affection = -3, energy =  4, poorEnergy = 0, difficulty = 3, success = { "receptivity" } },
    [8]  = { stats = {  3,  3, -3, -3 }, affection = -3, energy = 13, poorEnergy = 3, difficulty = 4, success = { "endurance", "strength" },       pay = { 200, 100 } },
    [9]  = { stats = { -3, -3,  3,  3 }, affection = -4, energy = 13, poorEnergy = 3, difficulty = 4, success = { "discernment", "receptivity" }, pay = { 200, 100 } },
    [10] = { stats = {  4,  0,  0, -3 }, affection = -5, energy = 26, poorEnergy = 6, difficulty = 5, success = { "strength", "discernment" },    pay = { 400, 200 } },
    [11] = { stats = {  0, -3,  4,  0 }, affection = -5, energy = 26, poorEnergy = 6, difficulty = 5, success = { "discernment", "strength" },    pay = { 400, 200 } },
    [12] = { stats = { -3,  0,  0,  4 }, affection = -5, energy = 26, poorEnergy = 6, difficulty = 5, success = { "receptivity", "discernment" }, pay = { 400, 200 } },
};
local PLAN_RESTING = 1;

local ODDS =
{
    happyHatch = 90, happyChick = 20, happyAdolescent = 10, sickChick = 5, sick = 10, sickWorsens = 21,
    injuredPaidPlan = 6, stomachacheForced = 10, lonely = 25, runAway = 4, boredAdolescent = 10, boredAdult = 21,
    lovesick = 8, spoiled = 1, afterHappy = 3,
};

local END_ODDS =
{
    [cond.INJURED] = 33, [cond.SICK] = 40, [cond.STOMACHACHE] = 65, [cond.LONELY] = 33, [cond.HIGH_SPIRITS] = 50,
    [cond.SLEEPING] = 100, [cond.VERY_ILL] = 33, [cond.BORED] = 25, [cond.SPOILED] = 100, [cond.RUN_AWAY] = 100,
    [cond.LOVESICK] = 50, [cond.CRYING_AT_NIGHT] = 100, [cond.FULL_OF_ENERGY] = 50, [cond.BRIGHT_AND_FOCUSED] = 50,
};

local BAD_CONDITIONS = { cond.INJURED, cond.SICK, cond.STOMACHACHE, cond.LONELY, cond.VERY_ILL, cond.BORED, cond.SPOILED, cond.LOVESICK };

-- Report order when several conditions change on one rollover.
local CONDITION_ORDER =
{
    cond.CRYING_AT_NIGHT, cond.RUN_AWAY, cond.LONELY, cond.HIGH_SPIRITS, cond.INJURED, cond.SICK, cond.VERY_ILL,
    cond.STOMACHACHE, cond.FULL_OF_ENERGY, cond.BORED, cond.SPOILED, cond.LOVESICK, cond.BRIGHT_AND_FOCUSED,
    cond.SLEEPING,
};

-- No scene marks these starting or ending.
local SILENT = { [cond.SLEEPING] = true, [cond.CRYING_AT_NIGHT] = true };

-- Temperament by highest stat (STR, END, DSC, RCP): ill tempered, very patient, quite sensitive, enigmatic.
local DOMINANT_PERSONALITY = { 1, 2, 3, 4 };
local VERY_EASYGOING = 0;
local APPEARANCE_FLAGS = { 0x01, 0x02, 0x04 }; -- talons (STR), tail (END), beak (DSC)

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v));
end

local function getBit(value, index)
    return bit.band(bit.rshift(value, index), 1) == 1;
end

local function getCondition(state, condition)
    return getBit(state.conditions, condition);
end

local function setCondition(state, condition, value)
    local mask = bit.lshift(1, condition);
    if (value) then
        state.conditions = bit.bor(state.conditions, mask);
    else
        state.conditions = bit.band(state.conditions, bit.bnot(mask));
    end
end

local function rolls(percent)
    return math.random(1, 100) > 100 - percent;
end

local function rank(value)
    return math.min(7, math.floor(value / 32));
end

local function ageBoundaries()
    return
    {
        { STAGE.EGG,        CR.daysToChick,      cs.EGG_HATCHING,          STAGE.CHICK },
        { STAGE.CHICK,      CR.daysToAdolescent, cs.CHICK_TO_ADOLESCENT,   STAGE.ADOLESCENT },
        { STAGE.ADOLESCENT, CR.daysToAdult1,     cs.ADOLESCENT_TO_ADULT_1, STAGE.ADULT_1 },
        { STAGE.ADULT_1,    CR.daysToAdult2,     cs.ADULT_1_TO_ADULT_2,    STAGE.ADULT_2 },
        { STAGE.ADULT_2,    CR.daysToAdult3,     cs.ADULT_2_TO_ADULT_3,    STAGE.ADULT_3 },
        { STAGE.ADULT_3,    CR.daysToAdult4,     cs.ADULT_3_TO_ADULT_4,    STAGE.ADULT_4 },
    };
end

-----------------------------------
-- Care plan schedule (4 bytes, plan 1 in the high byte: days high nibble, plan low)
-----------------------------------

local function readSchedule(state)
    local plans = {};
    for i = 0, 3 do
        local offset = 24 - i * 8;
        local length = bit.band(bit.rshift(state.care_plan, offset + 4), 0xF);
        local kind   = bit.band(bit.rshift(state.care_plan, offset), 0xF);
        if (length == 0) then
            length, kind = 7, 0;
        end
        table.insert(plans, { length = length, kind = kind });
    end
    return plans;
end

local function writeSchedule(state, plans)
    local value = 0;
    for i = 0, 3 do
        local offset = 24 - i * 8;
        value = bit.bor(value, bit.lshift(plans[i + 1].length, offset + 4), bit.lshift(plans[i + 1].kind, offset));
    end
    state.care_plan = value;
end

-- Returns plan 1 and takes a day from it. Empty slots refill with 7 days of Basic Care.
local function consumeCarePlanDay(state)
    local plans = readSchedule(state);
    local kind  = plans[1].kind;
    plans[1].length = plans[1].length - 1;
    if (plans[1].length == 0) then
        table.remove(plans, 1);
        table.insert(plans, { length = 7, kind = 0 });
    end
    writeSchedule(state, plans);
    return kind;
end

local function addToStat(state, field, change)
    if (change == 0) then
        return;
    end
    if (change > 0) then
        local total = 0;
        for _, f in ipairs(STAT_FIELDS) do
            total = total + state[f];
        end
        change = math.min(change, math.max(STAT_GROWTH_CAP - total, 0));
    end
    state[field] = clamp(state[field] + change, 0, 255);
end

local function successChance(state, data)
    local statRank = 0;
    for _, field in ipairs(data.success) do
        statRank = statRank + rank(state[field]);
    end
    statRank = statRank / #data.success;
    -- Guess taken from guides; no capture behind it (LSB).
    return clamp(60 + rank(state.affection) * 5 + math.floor(statRank * 3) - data.difficulty * 5, 5, 95);
end

local function runCarePlan(state, plan, day)
    local data = CARE_PLANS[plan];
    local outcome = { gil = 0, good = 0, poor = 0 };
    if (data == nil) then
        return outcome;
    end

    local succeeded = math.random(1, 100) <= successChance(state, data);
    local stable    = day >= CR.daysToAdult3; -- guess: plans stop lowering stats on day 64

    for index, field in ipairs(STAT_FIELDS) do
        local arrows = data.stats[index];
        local change = 0;
        if (plan == 0) then
            if (math.random(1, 6) == 1) then -- guess: one day in six
                change = 1;
            end
        elseif (arrows ~= 0) then
            for _ = 1, math.abs(arrows) do
                change = change + math.random(STAT_PER_ARROW[1], STAT_PER_ARROW[2]);
            end
            if (arrows < 0) then
                change = -change;
            end
        end

        if (not succeeded) then -- guess: a poor day halves the change toward zero
            local halved = math.floor(math.abs(change) / 2);
            change = change < 0 and -halved or halved;
        end

        if (change > 0 or not stable) then
            addToStat(state, field, change);
        end
    end

    state.affection = clamp(state.affection + data.affection * AFFECTION_PER_ARROW, 0, 255);
    state.energy    = clamp(100 - (succeeded and data.energy or data.energy + data.poorEnergy), 0, 100);

    if (plan == PLAN_RESTING) then -- rest cures each bad condition half the time
        for _, condition in ipairs(BAD_CONDITIONS) do
            if (getCondition(state, condition) and math.random(1, 2) == 1) then
                setCondition(state, condition, false);
            end
        end
    end

    if (succeeded) then
        outcome.good = 1;
    else
        outcome.poor = 1;
    end
    if (data.pay) then
        outcome.gil = succeeded and data.pay[1] or data.pay[2];
    end
    return outcome;
end

-----------------------------------
-- Day model
-----------------------------------

local function highestStats(state)
    local highest, indexes = -1, {};
    for index, field in ipairs(STAT_FIELDS) do
        if (state[field] > highest) then
            highest, indexes = state[field], { index };
        elseif (state[field] == highest) then
            table.insert(indexes, index);
        end
    end
    return indexes, highest;
end

local function afterHappy(state, today)
    if (state.stage >= STAGE.ADOLESCENT and getBit(today.held, cond.HIGH_SPIRITS)) then
        return ODDS.afterHappy;
    end
    return 0;
end

local function advanceStage(state, day, cutscenes)
    for _, entry in ipairs(ageBoundaries()) do
        if (state.stage == entry[1] and day >= entry[2]) then
            table.insert(cutscenes, entry[3]);
            state.stage = entry[4];
            state.conditions = 0; -- growing up cures every condition
            return state.stage;
        end
    end
    return nil;
end

-- Cures fed today apply at the next rollover (bits 16 up). Returns the cured conditions.
local function applyPendingCures(state, cutscenes)
    local pending = bit.rshift(state.conditions, PENDING_CURE_SHIFT);
    local cured   = 0;
    for condition = 0, cond.BRIGHT_AND_FOCUSED do
        if (getBit(pending, condition) and getCondition(state, condition)) then
            setCondition(state, condition, false);
            table.insert(cutscenes, cs.INJURY_HAS_HEALED + condition);
            cured = bit.bor(cured, bit.lshift(1, condition));
        end
    end
    state.conditions = bit.band(state.conditions, CONDITION_MASK);
    return cured;
end

-- Returns the conditions that ended with a scene. A minor illness may turn serious instead.
local function endConditions(state, held, scenes)
    local shown = 0;
    for _, condition in ipairs(CONDITION_ORDER) do
        if (getBit(held, condition)) then
            if (condition == cond.SICK and rolls(ODDS.sickWorsens)) then
                setCondition(state, cond.SICK, false);
                setCondition(state, cond.VERY_ILL, true);
                scenes[cond.VERY_ILL] = cs.IS_INJURED + cond.VERY_ILL;
                shown = bit.bor(shown, bit.lshift(1, cond.SICK));
            elseif (rolls(END_ODDS[condition])) then
                setCondition(state, condition, false);
                if (not SILENT[condition]) then
                    scenes[condition] = cs.INJURY_HAS_HEALED + condition;
                    shown = bit.bor(shown, bit.lshift(1, condition));
                end
            end
        end
    end
    return shown;
end

-- Each returns the onset chance in percent. Crying at night needs the handkerchief (not ported): never starts.
local ONSET =
{
    [cond.CRYING_AT_NIGHT] = function(state, today) return 0; end,

    [cond.RUN_AWAY] = function(state, today)
        return rank(state.affection) == 0 and ODDS.runAway or 0;
    end,

    [cond.LONELY] = function(state, today)
        return (state.stage >= STAGE.ADULT_1 and rank(state.affection) == 0) and ODDS.lonely or 0;
    end,

    [cond.HIGH_SPIRITS] = function(state, today)
        if (state.stage == STAGE.ADOLESCENT) then
            return ODDS.happyAdolescent;
        end
        if (state.stage ~= STAGE.CHICK) then
            return 0;
        end
        if (today.day == 5 or today.day == 6) then
            return ODDS.happyHatch;
        end
        return ODDS.happyChick;
    end,

    [cond.INJURED] = function(state, today)
        local data = today.plan ~= nil and CARE_PLANS[today.plan] or nil;
        return (data ~= nil and data.pay ~= nil) and ODDS.injuredPaidPlan or 0;
    end,

    [cond.SICK] = function(state, today)
        if (getBit(bit.bor(today.held, state.conditions), cond.VERY_ILL)) then
            return 0;
        end
        return state.stage == STAGE.CHICK and ODDS.sickChick or ODDS.sick;
    end,

    [cond.STOMACHACHE] = function(state, today)
        return today.forcedFed and ODDS.stomachacheForced or 0;
    end,

    [cond.FULL_OF_ENERGY] = afterHappy,

    [cond.BORED] = function(state, today)
        if (state.stage == STAGE.ADOLESCENT) then
            return ODDS.boredAdolescent;
        end
        return state.stage >= STAGE.ADULT_1 and ODDS.boredAdult or 0;
    end,

    [cond.SPOILED] = function(state, today)
        return ODDS.spoiled;
    end,

    [cond.LOVESICK] = function(state, today)
        return state.stage >= STAGE.ADULT_2 and ODDS.lovesick or 0;
    end,

    [cond.BRIGHT_AND_FOCUSED] = afterHappy,

    [cond.SLEEPING] = function(state, today)
        return today.plan == PLAN_RESTING and 100 or 0;
    end,
};

local function startConditions(state, today, scenes)
    if (state.stage == STAGE.EGG or state.stage == STAGE.ADULT_4) then
        return;
    end
    for _, condition in ipairs(CONDITION_ORDER) do
        local chance = ONSET[condition];
        if (chance ~= nil and not getCondition(state, condition)
            and (SILENT[condition] or not getBit(today.held, condition))
            and rolls(chance(state, today))) then
            setCondition(state, condition, true);
            if (not SILENT[condition]) then
                scenes[condition] = cs.IS_INJURED + condition;
            end
        end
    end
end

-- The plan locked yesterday runs today, so a plan set on day N first runs on day N + 2.
local function advanceDay(state, day, events, effects)
    local plan = state.locked_plan;
    local away = getCondition(state, cond.RUN_AWAY);

    -- A day spent away uses up the plan day but carries out nothing.
    local cutscenes = away and {} or { plan };

    local forcedFed = getBit(state.conditions, FORCED_FEED_FLAG);
    local shown     = applyPendingCures(state, cutscenes);

    local outcome   = { gil = 0, good = 0, poor = 0 };
    local endEnergy = state.energy;
    if (not away) then
        outcome = runCarePlan(state, plan, day);
    end

    state.locked_plan = consumeCarePlanDay(state);

    if (outcome.gil > 0) then
        table.insert(effects, { "addGil", outcome.gil });
    end

    -- Personality follows the highest stat from hatching until day 19, then stays. A tie is easygoing.
    if (state.stage ~= STAGE.EGG and day <= CR.daysToAdolescent) then
        local indexes = highestStats(state);
        if (#indexes == 1) then
            state.personality = DOMINANT_PERSONALITY[indexes[1]];
        else
            state.personality = VERY_EASYGOING;
        end
    end

    local held   = state.conditions;
    local scenes = {};

    shown = bit.bor(shown, endConditions(state, held, scenes));

    local grewTo = advanceStage(state, day, cutscenes);

    -- An egg, and a chick on the day it hatches, are completely full; older chocobos start every day starving.
    if (state.stage == STAGE.EGG or grewTo == STAGE.CHICK) then
        state.hunger = 255;
    elseif (state.stage == STAGE.CHICK) then
        state.hunger = math.max(state.hunger - math.floor(CHICK_HUNGER_PER_ENERGY * (100 - endEnergy)), 0);
    else
        state.hunger = 0;
    end

    -- Growing up clears every condition, so nothing queued above plays.
    if (grewTo) then
        scenes = {};
        shown  = 0;
    end

    if (grewTo == STAGE.ADULT_1) then
        -- The whistle quest starts whatever else happens (LSB model.lua); applied in CR.initState.
        table.insert(effects, { "whistleQuest", state.location });
        local indexes, highest = highestStats(state);
        state.appearance = 0;
        if (highest >= AVERAGE_STAT) then
            for _, index in ipairs(indexes) do
                if (APPEARANCE_FLAGS[index] ~= nil) then
                    state.appearance = bit.bor(state.appearance, APPEARANCE_FLAGS[index]);
                end
            end
        end
    end

    local today =
    {
        day = day, plan = (not away) and plan or nil, held = held, forcedFed = forcedFed,
    };
    startConditions(state, today, scenes);

    for _, condition in ipairs(CONDITION_ORDER) do
        if (scenes[condition] ~= nil) then
            table.insert(cutscenes, scenes[condition]);
        end
    end

    table.insert(events, { day, cutscenes, outcome, bit.bor(shown, state.conditions) });
end

-- Records are { firstDay, lastDay, cutscenes, { gil, good, poor }, conditions shown }.
-- Days showing only the same plan scene share a record of up to 7 days; a day with more scenes closes it.
local function condenseEvents(events)
    local out, span, spanOpen = {}, nil, false;

    for _, entry in ipairs(events) do
        local day, list, outcome, conditions = entry[1], entry[2], entry[3], entry[4];

        if (span ~= nil and spanOpen and day == span[2] + 1 and day - span[1] < MAX_RECORD_DAYS and list[1] == span[3][1]) then
            span[2] = day;
            for i = 2, #list do
                table.insert(span[3], list[i]);
            end
        else
            span = { day, day, {}, { gil = 0, good = 0, poor = 0 }, 0 };
            table.insert(out, span);
            for _, scene in ipairs(list) do
                table.insert(span[3], scene);
            end
        end

        span[5] = bit.bor(span[5], conditions or 0);
        if (outcome ~= nil) then
            span[4].gil  = span[4].gil + outcome.gil;
            span[4].good = span[4].good + outcome.good;
            span[4].poor = span[4].poor + outcome.poor;
        end

        spanOpen = #list <= 1;

        local retired = false;
        for _, scene in ipairs(list) do
            if (scene == cs.ADULT_3_TO_ADULT_4) then
                retired = true;
            end
        end
        if (retired) then
            break;
        end
    end
    return out;
end

-- Day 1 ends one day after the egg trade.
function CR.advance(state, now)
    local lastDay = clamp(math.floor((now - state.created) / CR.dayLength), 0, CR.daysToAdult4);
    local events, effects = {}, {};
    for day = state.last_update_age, lastDay do
        advanceDay(state, day, events, effects);
    end
    state.last_update_age = math.max(state.last_update_age, lastDay + 1);
    return condenseEvents(events), effects;
end

-----------------------------------
-- Session (per character, transient): the pending report and playout queue. The chocobo row stays in the DB.
-----------------------------------

CR.session = {};

local function hasRetirement(records)
    for _, record in ipairs(records) do
        for _, scene in ipairs(record[3]) do
            if (scene == cs.ADULT_3_TO_ADULT_4) then
                return true;
            end
        end
    end
    return false;
end

-- Applies every rollover since the last visit, saves the row, then pays out. Returns the row and the session.
function CR.initState(player, saved)
    saved = saved or player:getChocoboRaisingInfo();
    if (saved == nil) then
        return nil;
    end

    local changed = false;
    if (CARE_PLANS[saved.locked_plan] == nil) then
        saved.locked_plan = 0;
        changed = true;
    end

    local nextDay = saved.last_update_age;
    local records, effects = CR.advance(saved, os.time());

    if (saved.stage == STAGE.ADULT_4 and not hasRetirement(records)) then
        local last = CR.daysToAdult4;
        table.insert(records, { last, last, { cs.ADULT_3_TO_ADULT_4 }, { gil = 0, good = 1, poor = 0 }, 0 });
    end

    local session = { report = records, csList = {}, skipping = false, reportStage = nil };
    if (#records > 0) then
        session.reportStage = CR.ageToStage(records[1][1]);
    end
    CR.session[player:getID()] = session;

    if (saved.last_update_age ~= nextDay or changed) then
        -- Saved first: a failed save must not pay the same days' gil twice.
        if (not player:setChocoboRaisingInfo(saved)) then
            return nil;
        end
        for _, effect in ipairs(effects) do
            if (effect[1] == "addGil") then
                player:addGil(effect[2]);
            elseif (effect[1] == "whistleQuest") then
                CR.startWhistleQuest(player, effect[2]);
            end
        end
    end

    return saved, session;
end

-- 1 opens the main menu with the report greeting.
function CR.reportInfoFlag(session)
    return #session.report > 0 and 1 or 0;
end

local function shownStage(saved, session)
    if (session == nil or (#session.report == 0 and #session.csList == 0)) then
        return saved.stage;
    end
    return session.reportStage or saved.stage;
end

-- 208: is there a report to show?
function CR.handleCheckReport(player, saved)
    local session = CR.session[player:getID()];
    if (session ~= nil and #session.report > 0) then
        player:updateEvent(0xFFFFFFFF, 208, 0, 0, shownStage(saved, session), 0, 0, 0);
    else
        player:updateEvent(0, 0, 0, 0, saved.stage, 0, 0, 0);
    end
end

local function isNamed(saved)
    return (saved.first_name ~= "Chocobo" or saved.last_name ~= "Chocobo") and 1 or 0;
end

-- 248. Header: first day in bits 0-9, day count in 10-19, last day in 20-29, bit 31 when more follow.
function CR.handleReport(player, saved, arg)
    local session = CR.session[player:getID()];
    if (session == nil) then
        session = { report = {}, csList = {}, skipping = false };
        CR.session[player:getID()] = session;
    end
    session.skipping = arg == SKIP_REPORT_ARG;

    if (#session.report == 0) then
        local nextDay = saved.last_update_age;
        local header  = nextDay + (nextDay - 1) * 1048576; -- << 20
        player:updateEvent(248, header, 0, 0, saved.stage, isNamed(saved), 0, 0);
        return;
    end

    local record = table.remove(session.report, 1);
    local first, last = record[1], record[2];
    local days = last - first + 1;

    session.reportStage = CR.ageToStage(first);

    for _, scene in ipairs(record[3]) do
        table.insert(session.csList, { scene, days, #record[3] });
    end

    local header = first + days * 1024 + last * 1048576;
    if (#session.report > 0) then
        header = header + 0x80000000;
    end

    -- p3: gil in bits 0-15, good days in 16-23, poor days in 24-31. p6: the record's conditions shown.
    local totals  = record[4];
    local outcome = bit.band(totals.gil, 0xFFFF) + totals.good * 65536 + totals.poor * 16777216;

    local retirement = hasRetirement({ record }) and 1 or 0;
    if (retirement == 1) then
        session.retiring   = true;
        session.rewardCard = true;
    end
    local named = isNamed(saved);
    if (saved.last_name == "" and session.reportStage < STAGE.ADULT_3) then
        named = 0;
    end

    player:updateEvent(248, header, #session.csList, outcome, session.reportStage, named, record[5], retirement);
end

local MANDATORY = { [cs.ADULT_2_TO_ADULT_3] = true, [cs.ADULT_3_TO_ADULT_4] = true };

-- 246. csList entries are { cutscene, days in the record, cutscenes in the record }.
function CR.handlePlayout(player, saved, arg)
    local session = CR.session[player:getID()];
    if (session == nil or #session.csList == 0) then
        player:updateEvent(0xFFFFFFFF, 0, 0, 0, session and session.reportStage or saved.stage, 0, 0, 0);
        return;
    end

    if (session.skipping) then
        while (#session.csList > 0 and not MANDATORY[session.csList[1][1]]) do
            table.remove(session.csList, 1);
        end
        if (#session.csList == 0) then
            player:updateEvent(0xFFFFFFFF, 0, 0, 0, session.reportStage or saved.stage, 0, 0, 0);
            return;
        end
    end

    local entry    = table.remove(session.csList, 1);
    local csOffset = entry[1];
    local location = saved.location;

    -- A growth scene and the rest of its record show the new stage.
    for _, boundary in ipairs(ageBoundaries()) do
        if (boundary[3] == csOffset) then
            session.reportStage = boundary[4];
        end
    end

    -- p2 makes the adult 1 scene mention the open whistle quest.
    local whistleOpen = (csOffset == cs.ADOLESCENT_TO_ADULT_1) and CR.whistleQuestOpen(player) or 0;
    -- Unnamed by adult 3: the trainer picks a 5-8 letter first name (indices 168-762, gaps skipped).
    if (csOffset == cs.ADULT_2_TO_ADULT_3 and saved.first_name == "Chocobo" and saved.last_name == "Chocobo") then
        local name = nil;
        while (name == nil) do
            name = CHOCOBO_NAMES[math.random(168, 762)];
        end
        saved.first_name = name;
        saved.last_name  = "";
        player:setChocoboRaisingInfo(saved);
    end
    local fullName = saved.first_name .. saved.last_name;
    if (saved.first_name == "Chocobo" and saved.last_name == "Chocobo") then
        fullName = "Chocobo";
    end
    player:updateEventString(fullName, saved.first_name, saved.last_name, saved.last_name, 0, 0, 0, 0, 0, 0, 0, 0);

    -- p6 is a byte that changes on egg days and p7 looks like the weather (captures vary); LSB sends 0 and 3.
    player:updateEvent(#session.csList, location * 256 + csOffset, whistleOpen, entry[3], session.reportStage or saved.stage, 0, 0, 3);
end

-----------------------------------
-- Retirement (capture "Detailed report 22-52 ... retire": San d'Oria, option 24672 = command 96, arg 96).
-- Hands over a VCS registration card (2313) and the plaque of the chocobo's colour (309-313), both confirmed by
-- the 0x020/0x02A packets of that capture (2313 and 309 for a yellow chocobo). The card's extra data (stats) is
-- The "Complete Timeline [SandOria]" capture (Day 119-126 + Retire) shows no hand-over event: each item arrives as a
-- bare 0x020 straight after an outgoing 0x05B option (card 2313 at 07:21:09, plaque 309 at 07:21:31), so 843/518/751
-- do not exist for this flow. The next trainer click is the plain intro (0x034 csid 817, params 1,0,5,0,0,0,3,1).
-----------------------------------

-- VCS registration card extra data (24 bytes), laid out as LSB's Exdata::ChocoboCard and verified byte for byte
-- against the 0x020 packet of the San d'Oria retire capture (see tests/live/chocobo_raising in the mission toolkit).
--   bytes 0-3: STR, END, DSC (trait:1 rp:4 rank:3), RCP (rp:5 rank:3)
--   bytes 4-7: dna1:3 dna2:3 dna3:3 ability1:4 ability2:4 temperament:3 weather:4 gender:1 color:3 size:3 unknown:1
--   bytes 12-23: name signature, 6 bits per character, little endian
-- The card's size is the owner's jockey size: Galka 0, Hume M 1 ... Mithra 7, which is the race id except Galka (8).
local APPEARANCE_TALONS, APPEARANCE_TAIL, APPEARANCE_BEAK = 0x01, 0x02, 0x04;
local CARD_BYTES = 24;

local function statByte(value, trait)
    return bit.band(bit.rshift(value, 5) * 32 + bit.band(value, 0x1E) + (trait and 1 or 0), 0xFF);
end

-- Name signature: 0-9 -> 1-10, A-Z -> 11-36, a-z -> 37-62, anything else 0.
function CR.encodeSignature(name)
    local bytes = {};
    for i = 1, 12 do bytes[i] = 0; end
    for i = 1, math.min(15, #name) do
        local c = string.byte(name, i);
        local v = 0;
        if (c >= 48 and c <= 57) then v = c - 48 + 1;
        elseif (c >= 65 and c <= 90) then v = c - 65 + 11;
        elseif (c >= 97 and c <= 122) then v = c - 97 + 37; end
        for b = 0, 5 do
            if (bit.band(bit.rshift(v, b), 1) == 1) then
                local pos = (i - 1) * 6 + b;
                local idx = math.floor(pos / 8) + 1;
                bytes[idx] = bytes[idx] + 2 ^ (pos % 8);
            end
        end
    end
    return bytes;
end

function CR.packCard(saved, race)
    local appearance = saved.appearance or 0;
    local named = saved.first_name ~= "Chocobo" or saved.last_name ~= "Chocobo";
    local size = (race == 8) and 0 or race;
    local word = saved.allele1 + saved.allele2 * 8 + saved.allele3 * 64 + saved.ability1 * 512 + saved.ability2 * 8192
        + saved.personality * 131072 + saved.weather_preference * 1048576 + saved.sex * 16777216
        + saved.color * 33554432 + size * 268435456;
    local card =
    {
        statByte(saved.strength,    bit.band(appearance, APPEARANCE_TALONS) ~= 0),
        statByte(saved.endurance,   bit.band(appearance, APPEARANCE_TAIL) ~= 0),
        statByte(saved.discernment, bit.band(appearance, APPEARANCE_BEAK) ~= 0),
        saved.receptivity,
    };
    for i = 0, 3 do card[#card + 1] = math.floor(word / 2 ^ (8 * i)) % 256; end
    for i = 1, 4 do card[#card + 1] = 0; end
    for _, b in ipairs(CR.encodeSignature(named and (saved.first_name .. saved.last_name) or "Chocobo")) do
        card[#card + 1] = b;
    end
    return card;
end

local OWED_VAR      = "ChocoRetireItems";
local OWED_CARD     = 1;
local OWED_PLAQUE   = 2;
local ITEM_CARD     = 2313;
local PLAQUES       = { [0] = 309, [1] = 310, [2] = 312, [3] = 311, [4] = 313 }; -- yellow, black, blue, red, green
local RETIRE_ARG    = 96;

-- Zone TextIDs, read from scripts/zones/<zone>/TextIDs.lua: { ITEM_OBTAINED, ITEM_CANNOT_BE_OBTAINED }.
local ITEM_TEXT =
{
    [230] = { 6432, 6426 },
    [234] = { 6388, 6382 },
    [241] = { 6547, 6541 },
};

function CR.hasOwedItems(player)
    return player:getVar(OWED_VAR) ~= 0;
end

-- Gives what fits, card first. The chocobo stays until both are handed over.
function CR.handOver(player)
    local saved = player:getChocoboRaisingInfo();
    local owed  = player:getVar(OWED_VAR);
    local text  = ITEM_TEXT[player:getZoneID()];
    if (saved == nil or owed == 0 or text == nil) then
        return;
    end

    for _, entry in ipairs({ { OWED_CARD, ITEM_CARD }, { OWED_PLAQUE, PLAQUES[saved.color] } }) do
        if (bit.band(owed, entry[1]) ~= 0) then
            if (player:getFreeSlotsCount() == 0) then
                player:messageSpecial(text[2], entry[2]);
                return;
            end
            owed = bit.band(owed, bit.bnot(entry[1]));
            player:setVar(OWED_VAR, owed);
            if (entry[2] == ITEM_CARD) then
                player:addItemExData(ITEM_CARD, CR.packCard(saved, player:getRace()), false);
            else
                player:addItem(entry[2]);
            end
            player:messageSpecial(text[1], entry[2]);
        end
    end

    player:setVar(OWED_VAR, 0);
    player:deleteRaisedChocobo();
    CR.session[player:getID()] = nil;
end

-- 239: buy a chococard (300 gil, item 2339 male / 2342 female) from the trainer. The capture shows no
-- Event Update reply, only the obtained message, and the same 24 exdata bytes as the retirement card.
local CHOCOCARDS      = { [0] = 2339, [1] = 2342 };
local CHOCOCARD_PRICE = 300;

function CR.handleChococard(player, saved)
    local text = ITEM_TEXT[player:getZoneID()];
    local item = CHOCOCARDS[saved.sex];
    if (text == nil or item == nil or player:getGil() < CHOCOCARD_PRICE) then
        return;
    end
    if (player:getFreeSlotsCount() == 0) then
        player:messageSpecial(text[2], item);
        return;
    end
    player:delGil(CHOCOCARD_PRICE);
    player:addItemExData(item, CR.packCard(saved, player:getRace()), false);
    player:messageSpecial(text[1], item);
end

-- 96: the player chose to retire an adult chocobo.
function CR.handleRetire(player, saved)
    local session = CR.session[player:getID()];
    if (session == nil) then
        session = { report = {}, csList = {}, skipping = false };
        CR.session[player:getID()] = session;
    end
    session.retiring   = true;
    session.rewardCard = true;
    player:updateEvent(0, saved.location * 256 + RETIRE_ARG, 0, 0, STAGE.ADULT_4, 0, 0, 0);
end

-- 40: after the retirement scene; p1 is the chocobo's colour (0 for yellow in the capture).
function CR.handleAfterRetirement(player, saved)
    player:updateEvent(saved.color, 0, 0, 0, 0, 0, 0, 0);
end

-- Menu event finished: complete a retirement started by 96 or by the retirement report scene.
function CR.onMenuFinish(player)
    local session = CR.session[player:getID()];
    if (session == nil or not session.retiring) then
        return;
    end
    local saved = player:getChocoboRaisingInfo();
    if (saved == nil) then
        return;
    end
    session.retiring = false;
    if (session.rewardCard and not CR.hasOwedItems(player)) then
        saved.stage = STAGE.ADULT_4;
        player:setChocoboRaisingInfo(saved);
        player:setVar(OWED_VAR, OWED_CARD + OWED_PLAQUE);
    end
    CR.handOver(player);
end

return CR;
