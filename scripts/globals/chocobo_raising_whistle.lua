-----------------------------------
-- Chocobo Raising (VCS) - the Chocobo Whistle quest (slice 3, quest part).
-- Ported from LandSandBoat hiddenQuests/Chocobo_Whistle.lua, hobbies/chocobo_raising/event_vm.lua
-- (handleWhistleSearch, the walk reply) and model.lua (quest start at adult 1).
--
-- Flow: the chocobo grows to adult 1 -> quest starts (San d'Oria raisers go straight to SEARCH, the others must see
-- Hantileon first, scene 829) -> every walk reply says "searching" (p2 = 1) and command 88 (arg = walk length 1-3) is the
-- client asking whether this walk found it -> FOUND, Handkerchief key item -> Hantileon scene 830, option 222 ->
-- Chocobo Whistle item -> DONE.
--
-- EVIDENCE: event ids 829/830 exist in the client DAT of zone 230 (829 on Hantileon, 830 on the zone event entity,
-- mission_toolkit pull 2026-10-25). Everything else (command 88, option 222, reply shapes) follows LSB's client decoding;
-- no capture of this quest is on file. Key items HANDKERCHIEF 809 / DIRTY_HANDKERCHIEF 810 are the DSP keyitems.lua
-- names (id_bridge confirms the name; LSB's own id for it is 590, so never copy ids across).
-- NOT PORTED: the crying-handkerchief mechanic (so the plain HANDKERCHIEF is always the one found), the whistle
-- registration / recharge NPC events (844/845, 525/533, 752/760) which need the mount, and LSB's "whistle pending when the
-- bag is full" flag (here the whistle is simply not handed over until there is a free slot, quest stays FOUND).
-----------------------------------

require("scripts/globals/keyitems");

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

CR.WHISTLE_SEARCH_CMD = 88;  -- update command: arg = length of the walk that just ended
CR.WHISTLE_RECEIVE_OPT = 222; -- option of scene 830 that takes the whistle

CR.whistleProg = { NOT_STARTED = 0, SEE_HANTILEON = 1, SEARCH = 2, FOUND = 3, DONE = 4 };
local PROG = CR.whistleProg;

local PROG_VAR   = "ChocoboWhistleProg";
local HIDING_VAR = "ChocoboWhistleHidingWalk"; -- which walk length (1-3) hides the handkerchief, rolled once
local WALK_VAR   = "ChocoboWhistleSearchWalk"; -- walk length just taken, valid for the next command 88 only
local CHOCOBO_WHISTLE = 15533;

local SCENE_SEE_HANTILEON = 829;
local SCENE_HANDKERCHIEF  = 830;
local HANTILEON_ZONE      = 230;

function CR.getWhistleProg(player)
    return player:getVar(PROG_VAR);
end

function CR.setWhistleProg(player, prog)
    player:setVar(PROG_VAR, prog);
end

-- Quest start at adult 1 (effect queued by the day model). LSB: only when not started and no whistle owned.
function CR.startWhistleQuest(player, location)
    if (CR.getWhistleProg(player) ~= PROG.NOT_STARTED or player:hasItem(CHOCOBO_WHISTLE)) then
        return;
    end
    CR.setWhistleProg(player, location == CR.location[HANTILEON_ZONE] and PROG.SEARCH or PROG.SEE_HANTILEON);
end

-- p2 of the adult 1 growth scene: 1 while the quest is open.
function CR.whistleQuestOpen(player)
    local prog = CR.getWhistleProg(player);
    return (prog >= 1 and prog < PROG.DONE) and 1 or 0;
end

-- A walk while searching: remember its length and tell the client to ask (p2 = 1). Returns true when it replied.
function CR.whistleWalkReply(player, saved, arg, csid, weather)
    if (CR.getWhistleProg(player) ~= PROG.SEARCH or saved.stage < CR.stage.ADULT_1) then
        return false;
    end
    player:setLocalVar(WALK_VAR, arg - 41); -- arg 42/43/44 = short/regular/long
    local before = saved.energy;
    player:setChocoboRaisingInfo(saved);
    -- A nonzero p6 would be a meeting count, which skips the search.
    player:updateEvent(csid, saved.energy * 256 + before, 1, 0, saved.stage, 0, 0, weather);
    return true;
end

-- Command 88: does the walk that just ended (arg) hold the handkerchief?
function CR.handleWhistleSearch(player, saved, arg)
    if (player:getLocalVar(WALK_VAR) ~= arg or CR.getWhistleProg(player) ~= PROG.SEARCH) then
        return;
    end
    player:setLocalVar(WALK_VAR, 0);

    local hiding = player:getVar(HIDING_VAR);
    if (hiding == 0) then
        hiding = math.random(1, 3);
        player:setVar(HIDING_VAR, hiding);
    end

    if (arg ~= hiding) then
        player:updateEvent(0, 0, 0, 0, 0, 2, 0, 0);
        return;
    end

    player:updateEvent(HANDKERCHIEF, 0, 0, 0, 0, 1, 0, 0);
    CR.setWhistleProg(player, PROG.FOUND);
    player:setVar(HIDING_VAR, 0);
    player:addKeyItem(HANDKERCHIEF);
end

-- Hantileon (San d'Oria). Returns true when a quest scene was started.
function CR.whistleTrigger(player)
    if (player:getZoneID() ~= HANTILEON_ZONE) then
        return false;
    end
    local prog = CR.getWhistleProg(player);
    local saved = player:getChocoboRaisingInfo();
    local full, first, last = "", "", "";
    if (saved ~= nil) then
        first, last = saved.first_name, saved.last_name;
        full = first .. last;
    end

    if (prog == PROG.SEE_HANTILEON) then
        player:startEventString(SCENE_SEE_HANTILEON, full, first, last, "", VanadielTime(), 0, 0, 2);
        return true;
    elseif (prog == PROG.FOUND) then
        -- 1 = dirty handkerchief, 2 = brought by a worker (the key item is held)
        local variant = player:hasKeyItem(HANDKERCHIEF) and 2 or 1;
        player:startEventString(SCENE_HANDKERCHIEF, full, first, last, "", VanadielTime(), variant);
        return true;
    end
    return false;
end

function CR.whistleUpdate(player, csid, option)
    -- 244 is the scene asking to draw the chocobo
    if (csid == SCENE_SEE_HANTILEON and option == 244) then
        player:updateEvent(0, 0, 1, 0, 4, 1);
    end
end

function CR.whistleFinish(player, csid, option)
    if (csid == SCENE_SEE_HANTILEON and CR.getWhistleProg(player) == PROG.SEE_HANTILEON) then
        CR.setWhistleProg(player, PROG.SEARCH);
    elseif (csid == SCENE_HANDKERCHIEF and option == CR.WHISTLE_RECEIVE_OPT
        and CR.getWhistleProg(player) == PROG.FOUND) then
        if (player:getFreeSlotsCount() == 0) then
            return; -- stays FOUND, talk to Hantileon again with room in the bag
        end
        CR.setWhistleProg(player, PROG.DONE);
        player:delKeyItem(DIRTY_HANDKERCHIEF);
        player:delKeyItem(HANDKERCHIEF);
        player:addItem(CHOCOBO_WHISTLE);
        -- bare TextID globals can hold another zone's value: reload the one for this (San d'Oria) zone first
        package.loaded["scripts/zones/Southern_San_dOria/TextIDs"] = nil;
        require("scripts/zones/Southern_San_dOria/TextIDs");
        player:messageSpecial(ITEM_OBTAINED, CHOCOBO_WHISTLE);
    end
end
