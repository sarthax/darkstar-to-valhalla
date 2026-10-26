-----------------------------------
-- Chocobo Raising (VCS) - slice 5: compete with others (care action 52) and Dietmund.
-- Ported from LandSandBoat hobbies/chocobo_raising (walks.compete, event_vm.handleCompete). No capture covers this.
-- Menu command 243 (the care menu mask) is not handled by DSP, so the action is gated here instead of hidden.
-----------------------------------
require("scripts/globals/keyitems");

local CR = CHOCOBO_RAISING;

CR.COMPETE_ARG = 52;
CR.DIETMUND    = 6; -- walk trainer id; the long walk can meet him once Save My Son is done

local FAILED_CARE_ACTION = 2 ^ 31;
local COMPETE_COST       = { 27, 34 };  -- LSB: clear weather, other weather
local WINS_SHIFT         = 12;          -- walk_progress bits 12-13 count wins after 2 bits per trainer
local WIN_CHANCE         = 50;          -- LSB GUESS: an even chance
local HAPPY_STORY_KI     = 841;         -- STORY_OF_A_HAPPY_CHOCOBO, awarded on the third win
local RIVAL_NAMES        = { "Best", "Fast", "Hero", "King" };
CR.DIETMUND_VAR          = "ChocoboMetDietmund";

function CR.canCompete(saved)
    return CR.meetings(saved, CR.trainer.RIVALS) > 0;
end

function CR.competeWins(saved)
    return bit.band(bit.rshift(saved.walk_progress or 0, WINS_SHIFT), 3);
end

local function setWins(saved, count)
    saved.walk_progress = bit.bor(bit.band(saved.walk_progress or 0, bit.bnot(bit.lshift(3, WINS_SHIFT))), bit.lshift(count, WINS_SHIFT));
end

function CR.canMeetDietmund(player)
    return player:getQuestStatus(JEUNO, SAVE_MY_SON) == QUEST_COMPLETED and player:getVar(CR.DIETMUND_VAR) == 0;
end

-- Cmd 242 arg 52. Reply: cutscene, (after<<8)|before, result (0 win, 2 loss, 3 third win), 0, stage, 0, 0, weather.
function CR.handleCompete(player, saved, csid)
    if (saved.stage < CR.stage.ADOLESCENT or not CR.canCompete(saved)) then
        return; -- LSB offers it from adolescence, once the rivals have been met
    end

    local weather = (GetZoneWeather ~= nil) and GetZoneWeather(player:getZoneID()) or 0;
    if (saved.energy < COMPETE_COST[2]) then
        player:updateEvent(csid, FAILED_CARE_ACTION + CR.COMPETE_ARG, 0, 0, saved.stage, 0, 0, weather);
        return;
    end

    local before = saved.energy;
    saved.energy = before - ((weather <= 1) and COMPETE_COST[1] or COMPETE_COST[2]);

    local result = 2;
    if (math.random(1, 100) <= WIN_CHANCE) then
        result = 0;
        local wins = CR.competeWins(saved);
        if (wins < 3) then
            setWins(saved, wins + 1);
            if (wins + 1 == 3) then
                result = 3;
                player:addKeyItem(HAPPY_STORY_KI);
            end
        end
    end

    -- LSB playout: affection +1, and the next rollover cures boredom
    saved.affection = math.min((saved.affection or 0) + 1, 255);
    saved.conditions = bit.bor(saved.conditions, bit.lshift(1, 16 + CR.conditions.BORED));
    player:setChocoboRaisingInfo(saved);

    local data = player:getChocoboUserData();
    local name = RIVAL_NAMES[(math.max(data.chocobosRaised, 1) - 1) % #RIVAL_NAMES + 1];
    local full = saved.first_name .. saved.last_name;
    player:updateEventString(full, name, "", "", 0, 0, 0, 0, 0, 0, 0, 0);
    player:updateEvent(csid, saved.energy * 256 + before, result, 0, saved.stage, 0, 0, weather);
end
