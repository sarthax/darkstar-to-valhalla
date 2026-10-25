-----------------------------------
-- Chocobo Raising (VCS) - trainer meetings on walks, and the Lost Chick search.
-- Ported from LandSandBoat hobbies/chocobo_raising/walks.lua and hiddenQuests/Lost_Chick.lua. No capture shows a meeting
-- or the clerk, so the odds, clue order and csids are LSB's (see TEST_PLAN.md). Key item 850 (Story of a Diligent
-- Chocobo) is checked against the client's ROM/175/35.DAT.
-- A short walk can find a lost chick, trainers met on later walks give clues to its owner, the stable clerk
-- reviews them, and a guess at the owner ends the search; the right owner teaches the diligent story.
-- Lost chick state is one char var, packed: owner 0-3, clues 4-5, location 6-7, 2 bits of clues per trainer from bit 8,
-- result 16-17 (1 returned, 2 wrong owner), solved 18.
-- Walk meetings are stored in the chocobo's walk_progress: 2 bits of meeting count per trainer.
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

CR.CHICK_VAR = "ChocoboRaisingLostChick";

CR.trainer = { PULONONO = 1, ZOPAGO = 2, HANTILEON = 3, BRUTUS = 4, RIVALS = 5 };
local T = CR.trainer;

-- walk reply p2 values
CR.walkEvent = { LOST_CHICK = 2, LETTER = 3, RACE = 4, JOB = 5, ALL_CLUES = 6, ITEM = 7 };
local E = CR.walkEvent;

CR.chickResult = { NONE = 0, RETURNED = 1, WRONG_OWNER = 2 };

local MAX_MEETINGS  = 3;
local STORY_MEETING = 2;

-- walk arg -> { meeting chance %, item chance % }; LSB
local CHANCE = { [42] = { 21, 18 }, [43] = { 15, 26 }, [44] = { 18, 15 } };

-- location -> walk arg -> trainers that can be met
local TRAINERS =
{
    [1] = { [42] = { T.HANTILEON }, [43] = { T.ZOPAGO },    [44] = { T.PULONONO, T.BRUTUS } },
    [2] = { [42] = { T.ZOPAGO },    [43] = { T.HANTILEON }, [44] = { T.PULONONO, T.BRUTUS } },
    [3] = { [42] = { T.PULONONO },  [43] = { T.HANTILEON }, [44] = { T.ZOPAGO,   T.BRUTUS } },
};

-- Rivals give no clues.
local CLUE_TRAINERS = { [T.PULONONO] = true, [T.ZOPAGO] = true, [T.HANTILEON] = true, [T.BRUTUS] = true };
local CLUE_EVENTS   = { E.LETTER, E.RACE, E.JOB };

-- The third meeting teaches the trainer's story (key item ids checked against the client).
local STORIES =
{
    [T.HANTILEON] = 837, -- STORY_OF_AN_IMPATIENT_CHOCOBO
    [T.BRUTUS]    = 838, -- STORY_OF_A_CURIOUS_CHOCOBO
    [T.ZOPAGO]    = 839, -- STORY_OF_A_WORRISOME_CHOCOBO
    [T.PULONONO]  = 840, -- STORY_OF_A_YOUTHFUL_CHOCOBO
};
local DILIGENT = 850; -- STORY_OF_A_DILIGENT_CHOCOBO

-- trainer zone -> clerk csid / trainer report csid (Windurst clerk 761 confirmed on the client; the rest are LSB's)
CR.clerkCsid  = { [230] = 846, [234] = 534, [241] = 761 };
CR.reportCsid = { [230] = 852, [234] = 542, [241] = 766 };

-----------------------------------
-- State
-----------------------------------
function CR.unpackChick(value)
    local chick = { owner = bit.band(value, 0xF), clues = bit.band(bit.rshift(value, 4), 3),
        location = bit.band(bit.rshift(value, 6), 3), trainerClues = {},
        result = bit.band(bit.rshift(value, 16), 3), solved = bit.band(bit.rshift(value, 18), 1) == 1 };
    for trainerId in pairs(CLUE_TRAINERS) do
        chick.trainerClues[trainerId] = bit.band(bit.rshift(value, 8 + (trainerId - 1) * 2), 3);
    end
    return chick;
end

function CR.packChick(chick)
    local value = bit.bor(chick.owner, bit.lshift(chick.clues, 4), bit.lshift(chick.location, 6), bit.lshift(chick.result, 16));
    for trainerId, count in pairs(chick.trainerClues) do
        value = bit.bor(value, bit.lshift(count, 8 + (trainerId - 1) * 2));
    end
    if (chick.solved) then
        value = bit.bor(value, bit.lshift(1, 18));
    end
    return value;
end

local function getChick(player)
    return CR.unpackChick(player:getVar(CR.CHICK_VAR));
end

local function saveChick(player, chick)
    player:setVar(CR.CHICK_VAR, CR.packChick(chick));
end

function CR.meetings(saved, trainerId)
    return bit.band(bit.rshift(saved.walk_progress or 0, (trainerId - 1) * 2), 3);
end

local function setMeetings(saved, trainerId, count)
    local shift = (trainerId - 1) * 2;
    saved.walk_progress = bit.bor(bit.band(saved.walk_progress or 0, bit.bnot(bit.lshift(3, shift))), bit.lshift(count, shift));
end

-----------------------------------
-- Walk meetings
-----------------------------------
-- Owners present in each location (ids are the clerk's slot numbers; see the owner scripts)
CR.ownerSlots = { [1] = { 1, 2, 3, 4, 5, 6, 7, 8 }, [2] = { 1, 2, 3, 4, 5, 6 }, [3] = { 2, 4, 5, 6 } };

local function giveClue(chick, met, location, result)
    if (chick.owner == 0 or chick.location ~= location or not CLUE_TRAINERS[met]) then
        return false;
    end
    local given = chick.trainerClues[met];
    result.data = bit.bor(bit.lshift(chick.owner, 8), given);
    if (chick.clues >= #CLUE_EVENTS) then
        result.event = E.ALL_CLUES;
        return false;
    end
    chick.clues = chick.clues + 1;
    chick.trainerClues[met] = given + 1;
    result.event = CLUE_EVENTS[chick.clues];
    return true;
end

-- Returns { event, data, trainer, meeting } for reply p2, p3, p5, p6. pickItem() stores a found item and returns true.
function CR.walkMeeting(player, saved, arg, location, pickItem)
    local result = { event = 0, data = 0, trainer = 0, meeting = 0 };
    local chick  = getChick(player);
    local chickChanged = false;
    local met;

    if (arg == 43 and CR.meetings(saved, T.RIVALS) == 0) then
        met = T.RIVALS;
    else
        local bonus = math.floor(math.max((saved.receptivity or 0) - 63, 0) / 16); -- LSB guess
        local meetChance = CHANCE[arg][1] + bonus;
        local roll = math.random(1, 100);
        if (roll <= meetChance) then
            local list = TRAINERS[location][arg];
            met = list[math.random(1, #list)];
        elseif (roll <= meetChance + CHANCE[arg][2] and saved.held_item == 0) then
            if (pickItem()) then
                result.event = E.ITEM;
            end
        end
    end

    if (met == nil and result.event == 0 and arg == 42 and chick.owner == 0 and not chick.solved) then
        local slots = CR.ownerSlots[location];
        chick.owner    = slots[math.random(1, #slots)];
        chick.location = location;
        result.event   = E.LOST_CHICK;
        chickChanged   = true;
    end

    if (met ~= nil) then
        if (giveClue(chick, met, location, result)) then
            chickChanged = true;
        end
        local meetings = CR.meetings(saved, met);
        result.trainer = met;
        result.meeting = meetings;
        setMeetings(saved, met, math.min(meetings + 1, MAX_MEETINGS));
        if (meetings == STORY_MEETING and STORIES[met] ~= nil) then
            player:addKeyItem(STORIES[met]);
        end
    end

    if (chickChanged) then
        saveChick(player, chick);
    end
    return result;
end

-----------------------------------
-- Clerk and trainer report
-----------------------------------
-- Clerk params: p0 offers the review once a clue is known, p3-p5 the clues, p6 the owner.
function CR.startClerk(player, location)
    local chick = getChick(player);
    local p = { 0, 0, 0, 0, 0, 0, 0, 0 };
    if (chick.owner ~= 0 and chick.location == location and chick.clues > 0) then
        p[1] = 1;
        p[7] = chick.owner;
        for clue = 1, chick.clues do
            p[3 + clue] = 1;
        end
    end
    p[2] = math.floor(player:getSkillLevel(SKILL_DIG) / 10);
    player:startEvent(CR.clerkCsid[player:getZoneID()], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], 0, 0);
end

-- Guess at the owner: right ends the search with the diligent story, wrong ends it without. Returns true when right.
function CR.guessOwner(player, location, ownerSlot)
    local chick = getChick(player);
    if (chick.owner == 0 or chick.location ~= location) then
        return false;
    end
    local right = chick.owner == ownerSlot;
    local after = { owner = 0, clues = 0, location = 0, trainerClues = {}, solved = chick.solved or right,
        result = right and CR.chickResult.RETURNED or CR.chickResult.WRONG_OWNER };
    if (right) then
        player:addKeyItem(DILIGENT);
    end
    saveChick(player, after);
    return right;
end

-- Trainer report once a search has ended: true when it started the report event.
function CR.reportTrigger(player)
    local zone = player:getZoneID();
    local location = CR.location[zone];
    local chick = getChick(player);
    if (location == nil or chick.result == CR.chickResult.NONE) then
        return false;
    end
    local returned = chick.result == CR.chickResult.RETURNED and 1 or 0;
    player:startEvent(CR.reportCsid[zone], 1 - returned, returned, 0, 0, 0, 0, 0, location, 0, 0);
    return true;
end

function CR.reportFinish(player, csid)
    if (csid ~= CR.reportCsid[player:getZoneID()]) then
        return;
    end
    local chick = getChick(player);
    chick.result = CR.chickResult.NONE;
    saveChick(player, chick);
end
