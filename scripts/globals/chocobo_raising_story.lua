-----------------------------------
-- Chocobo Raising (VCS) - telling a story (care action 50) and what the chocobo takes from it.
-- Ported from LandSandBoat hobbies/chocobo_raising event_vm.lua handleTellAStory / handleStoryUpdate and walks.lua tellStory.
--
-- EVIDENCE: the menu shape (care action 242 arg 50, story mask in p2, command 50 reply p0 = 0 interested / 1 learned /
-- 2 inspired) follows LSB's decoding of the client. EVERY NUMBER THAT DECIDES WHAT IS LEARNED IS AN LSB GUESS
-- ("Guess from guides; no capture shows a story being learned"): LEARN_CHANCE, STORY_DISCERNMENT, INSPIRED_STAT,
-- the +1 discernment per telling, the 10-100 energy refund and the +2 stat on inspiration. The 11/14 energy cost is
-- LSB's careActionEnergy, also uncaptured. If a capture of a story being told turns up, fix those tables first.
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

CR.TELL_STORY_ARG = 50; -- care action number (cmd 242 arg), also the cutscene number before the zone offset
CR.TELL_STORY_CMD = 50; -- the update command that carries the chosen story

local FAILED_CARE_ACTION = 2 ^ 31;
local STORY_COST         = { 11, 14 }; -- LSB guess: clear weather, other weather

-- LSB guess: percent chance a told story is taken in once the discernment is high enough.
CR.LEARN_CHANCE = 25;

-- Story number (as sent by the client) -> key item. Stories 4 to 9 teach abilities 1 to 6 in order.
local FIRST_STORY = 4;
local STORY_KEY_ITEMS =
{
    [4] = 837, -- STORY_OF_AN_IMPATIENT_CHOCOBO -> gallop
    [5] = 838, -- STORY_OF_A_CURIOUS_CHOCOBO    -> canter
    [6] = 839, -- STORY_OF_A_WORRISOME_CHOCOBO  -> burrow
    [7] = 840, -- STORY_OF_A_YOUTHFUL_CHOCOBO   -> bore
    [8] = 841, -- STORY_OF_A_HAPPY_CHOCOBO      -> auto regen
    [9] = 850, -- STORY_OF_A_DILIGENT_CHOCOBO   -> treasure finder
};

-- LSB guess: the discernment each ability needs (ability 1..6: gallop, canter, burrow, bore, auto regen, treasure finder).
local STORY_DISCERNMENT = { 64, 96, 64, 160, 64, 64 };

-- LSB guess: a story for an ability the chocobo already has (or has no slot for) raises this stat instead.
local INSPIRED_STAT = { "strength", "endurance", "discernment", "receptivity", "affection", "discernment" };
local INSPIRED_GAIN = 2; -- LSB statPerPlanArrow[1]

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v));
end

local function storyWeather(player)
    if (GetZoneWeather ~= nil) then
        return GetZoneWeather(player:getZoneID());
    end
    return 0;
end

-- Cmd 242 arg 50. Reply: cutscene, (after<<8)|before, p2 story mask (a set bit hides the story), 0, stage, 0, 0, weather.
function CR.handleTellStory(player, saved, csid)
    local weather = storyWeather(player);
    if (saved.stage < CR.stage.ADOLESCENT) then
        return; -- LSB offers it from adolescence on
    end

    local cost = (weather <= 1) and STORY_COST[1] or STORY_COST[2];
    if (saved.energy < STORY_COST[2]) then
        -- LSB: the failure needs the dearer cost even in clear weather
        player:updateEvent(csid, FAILED_CARE_ACTION + CR.TELL_STORY_ARG, 0, 0, saved.stage, 0, 0, weather);
        return;
    end

    local mask = 0xFFFFFFFE; -- bit 0 is chitchat, always offered
    for story = FIRST_STORY, FIRST_STORY + 5 do
        if (player:hasKeyItem(STORY_KEY_ITEMS[story])) then
            mask = mask - 2 ^ (story - FIRST_STORY + 1);
        end
    end

    local before = saved.energy;
    saved.energy = before - cost;
    player:setLocalVar("ChocoboRaisingStoryPending", 1);
    player:setChocoboRaisingInfo(saved);
    player:updateEvent(csid, saved.energy * 256 + before, mask, 0, saved.stage, 0, 0, weather);
end

-- Cmd 50, arg = story number. Reply p0: 0 interested, 1 learned, 2 inspired.
function CR.handleStoryUpdate(player, saved, story)
    if (player:getLocalVar("ChocoboRaisingStoryPending") == 0) then
        return;
    end
    player:setLocalVar("ChocoboRaisingStoryPending", 0);

    local keyItem = STORY_KEY_ITEMS[story];
    if (keyItem == nil or not player:hasKeyItem(keyItem)) then
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0); -- chitchat or a story the player does not hold
        return;
    end

    saved.discernment = clamp(saved.discernment + 1, 0, 255);

    local ability = story - FIRST_STORY + 1;
    local result  = 0;
    if (saved.discernment >= STORY_DISCERNMENT[ability] and math.random(1, 100) <= CR.LEARN_CHANCE) then
        player:delKeyItem(keyItem);
        saved.energy = clamp(saved.energy + math.random(10, 100), 0, 100); -- LSB guess

        if (saved.ability1 == 0 and saved.ability2 ~= ability) then
            saved.ability1 = ability;
            result = 1;
        elseif (saved.ability2 == 0 and saved.ability1 ~= ability) then
            saved.ability2 = ability;
            result = 1;
        else
            local field = INSPIRED_STAT[ability];
            saved[field] = clamp(saved[field] + INSPIRED_GAIN, 0, 255);
            result = 2;
        end
    end

    player:setChocoboRaisingInfo(saved);
    player:updateEvent(result, 0, 0, 0, 0, 0, 0, 0);
end
