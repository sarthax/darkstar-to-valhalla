---------------------------------------------------------------------------------------------------
-- func: !chocobo <sub> {a} {b}
-- desc: Chocobo raising diagnostics and state editing (acts on yourself).
--   !chocobo info                 dump chocobo state, walk progress, vars, story key items
--   !chocobo age <days>           move the birthday back <days> days (negative = forward); next talk rolls days over
--   !chocobo set <field> <value>  numeric field: stage, location, strength, endurance, discernment, receptivity,
--                                 affection, energy, satisfaction, conditions, hunger, held_item, walk_progress, ...
--   !chocobo cond <bit> <0|1>     set/clear one condition bit (0-13 current, 16+ pending cure)
--   !chocobo meet <trainer 1-6> <0-3>   walk meeting count for a trainer (5 = rivals)
--   !chocobo wins <0-3>           compete win counter
--   !chocobo var <name> {value}   read/set a raising char var (lost, whistle, dietmund, or full name)
--   !chocobo ki <id> <add|del>    story key items (837-841, 850, 809)
--   !chocobo delete               remove the raised chocobo
---------------------------------------------------------------------------------------------------

require("scripts/globals/chocobo_raising");

cmdprops =
{
    permission = 1,
    parameters = "sss"
};

local FIELDS = {
    "sex", "last_update_age", "stage", "location", "color", "allele1", "allele2", "allele3",
    "strength", "endurance", "discernment", "receptivity", "affection", "energy", "satisfaction",
    "conditions", "ability1", "ability2", "personality", "weather_preference", "hunger",
    "care_plan", "held_item", "locked_plan", "appearance", "walk_progress",
};

local VARS = {
    lost     = "ChocoboRaisingLostChick",
    whistle  = "ChocoboWhistleProg",
    hiding   = "ChocoboWhistleHidingWalk",
    search   = "ChocoboWhistleSearchWalk",
    dietmund = "ChocoboMetDietmund",
    egg      = "ChocoBreedEggItem",
    genes    = "ChocoBreedEggGenes",
    ready    = "ChocoBreedEggReady",
};

local STORY_KI = { 837, 838, 839, 840, 841, 850, 809 };
local WINS_SHIFT = 12;

local function usage(player)
    player:PrintToPlayer("!chocobo <sub> {a} {b}: info | age <days> | set <field> <v> | cond <bit> <0|1> | meet <1-6> <0-3> | wins <0-3> | var <name> {v} | ki <id> <add|del> | delete");
end

local function varName(name)
    return VARS[name] or name;
end

local function dump(player, saved)
    if (saved == nil) then
        player:PrintToPlayer("No raised chocobo.");
    else
        local CR = CHOCOBO_RAISING;
        local age = CR.ageOf(saved);
        player:PrintToPlayer(string.format("age %d (stage %d, calc %d) last_update_age %d loc %d sex %d color %d",
            age, saved.stage, CR.ageToStage(age), saved.last_update_age, saved.location, saved.sex, saved.color));
        player:PrintToPlayer(string.format("STR %d END %d DIS %d REC %d  aff %d energy %d sat %d hunger %d",
            saved.strength, saved.endurance, saved.discernment, saved.receptivity,
            saved.affection, saved.energy, saved.satisfaction, saved.hunger));
        local on = {};
        for bit = 0, 31 do
            if (math.floor(saved.conditions / 2 ^ bit) % 2 == 1) then
                table.insert(on, bit);
            end
        end
        player:PrintToPlayer(string.format("conditions 0x%X bits {%s}  held_item %d plan 0x%X", saved.conditions, table.concat(on, ","), saved.held_item, saved.care_plan));
        local wp = saved.walk_progress;
        local meets = {};
        for t = 1, 6 do
            table.insert(meets, math.floor(wp / 4 ^ (t - 1)) % 4);
        end
        player:PrintToPlayer(string.format("walk_progress %d meetings P/Z/H/B/R/D {%s} wins %d",
            wp, table.concat(meets, ","), math.floor(wp / 2 ^ WINS_SHIFT) % 4));
    end
    local v = {};
    for name, var in pairs(VARS) do
        table.insert(v, string.format("%s=%d", name, player:getVar(var)));
    end
    table.sort(v);
    player:PrintToPlayer("vars: " .. table.concat(v, " "));
    local ki = {};
    for _, id in ipairs(STORY_KI) do
        if (player:hasKeyItem(id)) then
            table.insert(ki, id);
        end
    end
    player:PrintToPlayer("story key items: {" .. table.concat(ki, ",") .. "}");
    local ud = player:getChocoboUserData();
    if (ud ~= nil) then
        player:PrintToPlayer("chocobosRaised " .. ud.chocobosRaised);
    end
end

function onTrigger(player, sub, a, b)
    local saved = player:getChocoboRaisingInfo();

    if (sub == nil or sub == "info") then
        dump(player, saved);
        return;
    end

    if (sub == "var") then
        if (a == nil) then
            usage(player);
        elseif (b == nil) then
            player:PrintToPlayer(string.format("%s = %d", varName(a), player:getVar(varName(a))));
        else
            player:setVar(varName(a), tonumber(b) or 0);
            player:PrintToPlayer(string.format("%s = %d", varName(a), tonumber(b) or 0));
        end
        return;
    elseif (sub == "ki") then
        local id = tonumber(a);
        if (id == nil or (b ~= "add" and b ~= "del")) then
            usage(player);
        elseif (b == "add") then
            player:addKeyItem(id);
            player:PrintToPlayer("added key item " .. id);
        else
            player:delKeyItem(id);
            player:PrintToPlayer("removed key item " .. id);
        end
        return;
    end

    if (saved == nil) then
        player:PrintToPlayer("No raised chocobo.");
        return;
    end

    if (sub == "delete") then
        player:deleteRaisedChocobo();
        player:PrintToPlayer("Chocobo deleted.");
        return;
    elseif (sub == "age") then
        local days = tonumber(a);
        if (days == nil) then
            usage(player);
            return;
        end
        saved.created = saved.created - days * CHOCOBO_RAISING.dayLength;
    elseif (sub == "set") then
        local value = tonumber(b);
        local known = false;
        for _, f in ipairs(FIELDS) do
            known = known or f == a;
        end
        if (not known or value == nil) then
            player:PrintToPlayer("fields: " .. table.concat(FIELDS, " "));
            return;
        end
        saved[a] = value;
    elseif (sub == "cond") then
        local bit, on = tonumber(a), tonumber(b);
        if (bit == nil or on == nil or bit < 0 or bit > 31) then
            usage(player);
            return;
        end
        local mask = 2 ^ bit;
        local has = math.floor(saved.conditions / mask) % 2 == 1;
        if (on ~= 0 and not has) then
            saved.conditions = saved.conditions + mask;
        elseif (on == 0 and has) then
            saved.conditions = saved.conditions - mask;
        end
    elseif (sub == "meet") then
        local t, n = tonumber(a), tonumber(b);
        if (t == nil or n == nil or t < 1 or t > 6 or n < 0 or n > 3) then
            usage(player);
            return;
        end
        local shift = 4 ^ (t - 1);
        local cur = math.floor(saved.walk_progress / shift) % 4;
        saved.walk_progress = saved.walk_progress + (n - cur) * shift;
    elseif (sub == "wins") then
        local n = tonumber(a);
        if (n == nil or n < 0 or n > 3) then
            usage(player);
            return;
        end
        local shift = 2 ^ WINS_SHIFT;
        local cur = math.floor(saved.walk_progress / shift) % 4;
        saved.walk_progress = saved.walk_progress + (n - cur) * shift;
    else
        usage(player);
        return;
    end

    -- created is passed back explicitly so the table's ON UPDATE timestamp cannot reset the age
    if (player:setChocoboRaisingInfo(saved)) then
        player:PrintToPlayer("Done.");
        dump(player, player:getChocoboRaisingInfo());
    else
        player:PrintToPlayer("Update failed.");
    end
end
