-----------------------------------
-- Ferry deck mobs: logic. Data (slots, deck polygons) lives in ferry_data.lua.
-- Port of LSB scripts/globals/ferry.lua without onZoneTick / onTransportVoyageEnd:
--   * the 60 s tick is a self-rescheduling timer on a hidden zone NPC (Ferry.zones[z].anchor)
--   * the "voyage end" clear is done from Zone.lua onTransportEvent and on a fresh ride's first zone-in
-- UNTESTED in game.
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/weather");
require("scripts/globals/ferry_data");

Ferry.TICK_MS     = 60000;
Ferry.BOARD_SKIP  = 180;   -- s after a boarding before the next roll (capture: gaps >= 180 s)
Ferry.FADE_UNIT   = 70;    -- s; day mobs fade after 3-9 units
-- percent chance the lottery boards a mob, by how many deck mobs are already up
Ferry.rollChance  = { [0] = 30, [1] = 20, [2] = 8 };
Ferry.ELEMENTAL_CHANCE = 30;

Ferry.state = Ferry.state or {};   -- [zoneid] = { gen, nextRoll, spawnedAt = {[mobid]=t}, fadeAt = {[mobid]=t} }

local function st(zoneid)
    if (Ferry.state[zoneid] == nil) then
        Ferry.state[zoneid] = { gen = 0, nextRoll = 0, lastTick = 0, fadeAt = {} };
    end
    return Ferry.state[zoneid];
end

local function contains(tbl, v)
    for _, x in ipairs(tbl) do
        if (x == v) then return true; end
    end
    return false;
end

-- random point inside the deck polygon (rejection sampling over its bounding box)
local function randomDeckPoint(poly)
    local minx, maxx, minz, maxz = 1e9, -1e9, 1e9, -1e9;
    for _, p in ipairs(poly) do
        if (p[1] < minx) then minx = p[1]; end
        if (p[1] > maxx) then maxx = p[1]; end
        if (p[3] < minz) then minz = p[3]; end
        if (p[3] > maxz) then maxz = p[3]; end
    end
    for _ = 1, 40 do
        local x = minx + math.random() * (maxx - minx);
        local z = minz + math.random() * (maxz - minz);
        local inside = false;
        local j = #poly;
        for i = 1, #poly do
            local xi, zi, xj, zj = poly[i][1], poly[i][3], poly[j][1], poly[j][3];
            if (((zi > z) ~= (zj > z)) and (x < (xj - xi) * (z - zi) / (zj - zi) + xi)) then
                inside = not inside;
            end
            j = i;
        end
        if (inside) then return x, poly[1][2], z; end
    end
    return poly[1][1], poly[1][2], poly[1][3];
end

local function isUp(mob)
    return mob ~= nil and mob:isSpawned();
end

-- Despawn every deck mob in the zone; cancel any pending respawn.
function Ferry.clear(zoneid)
    local cfg = Ferry.zones[zoneid];
    if (cfg == nil) then return; end
    for _, slot in ipairs(cfg.slots) do
        local mob = GetMobByID(slot.id);
        if (mob ~= nil) then
            mob:setRespawnTime(0);
            if (mob:isSpawned()) then DespawnMob(slot.id); end
        end
    end
    local s = st(zoneid);
    s.fadeAt = {};
    s.nextRoll = 0;
end

function Ferry.spawnSlot(zoneid, slot)
    local mob = GetMobByID(slot.id);
    if (mob == nil) then return false; end
    local x, y, z = randomDeckPoint(Ferry.zones[zoneid].poly);
    mob:setSpawn(x, y, z, math.random(0, 255));
    SpawnMob(slot.id);
    return true;
end

function Ferry.tick(zoneid)
    local cfg = Ferry.zones[zoneid];
    local s   = st(zoneid);
    local now = os.time();
    s.lastTick = now;

    -- fade day mobs
    for id, t in pairs(s.fadeAt) do
        if (now >= t) then
            if (isUp(GetMobByID(id))) then DespawnMob(id); end
            s.fadeAt[id] = nil;
        end
    end

    -- night mobs leave at 04:00 and elementals leave when their weather ends
    local hour    = VanadielHour();
    local npc     = GetNPCByID(cfg.anchor);
    local weather = npc ~= nil and npc:getWeather() or 0;
    local visible, lottery, elementals = 0, {}, {};
    for _, slot in ipairs(cfg.slots) do
        local mob = GetMobByID(slot.id);
        if (isUp(mob)) then
            if ((slot.night and hour >= 4 and hour < 20) or (slot.weather and not contains(slot.weather, weather))) then
                DespawnMob(slot.id);
            else
                visible = visible + 1;
            end
        elseif (mob ~= nil and not mob:isSpawned() and (not slot.night or hour >= 20 or hour < 4)
                and (not slot.weather or contains(slot.weather, weather))) then
            if (slot.weather) then table.insert(elementals, slot); else table.insert(lottery, slot); end
        end
    end

    if (now < s.nextRoll) then return; end
    s.nextRoll = now + 60;

    if (#lottery > 0 and math.random(1, 100) <= (Ferry.rollChance[visible] or 0)) then
        local slot = lottery[math.random(1, #lottery)];
        if (Ferry.spawnSlot(zoneid, slot)) then
            if (not slot.night) then s.fadeAt[slot.id] = now + Ferry.FADE_UNIT * math.random(3, 9); end
            s.nextRoll = now + Ferry.BOARD_SKIP;
        end
        return;
    end

    for _, slot in ipairs(elementals) do
        if (math.random(1, 100) <= Ferry.ELEMENTAL_CHANCE) then
            if (Ferry.spawnSlot(zoneid, slot)) then s.nextRoll = now + Ferry.BOARD_SKIP; end
            return;
        end
    end
end

-- self-rescheduling tick; a newer generation (zone re-entry after a stall) kills older chains
local function schedule(zoneid, gen)
    local npc = GetNPCByID(Ferry.zones[zoneid].anchor);
    if (npc == nil) then return; end
    npc:timer(Ferry.TICK_MS, function(entity)
        local s = st(zoneid);
        if (s.gen ~= gen) then return; end
        Ferry.tick(zoneid);
        schedule(zoneid, gen);
    end);
end

-- call from Zone.lua onZoneIn
function Ferry.onZoneIn(player)
    local zoneid = player:getZoneID();
    local cfg = Ferry.zones[zoneid];
    if (cfg == nil) then return; end
    local s = st(zoneid);
    local now = os.time();
    -- chain is considered dead if it has not ticked for 3 ticks (zone was empty and the NPC stopped ticking)
    if (now - s.lastTick > 3 * Ferry.TICK_MS / 1000) then
        Ferry.clear(zoneid);  -- a fresh ride starts with an empty deck
        s.gen = s.gen + 1;
        s.lastTick = now;
        schedule(zoneid, s.gen);
    end
end

-- call from Zone.lua onTransportEvent (ship docking): voyage over
function Ferry.onVoyageEnd(player)
    local zoneid = player:getZoneID();
    if (Ferry.zones[zoneid] ~= nil) then
        Ferry.clear(zoneid);
        local s = st(zoneid);
        s.gen = s.gen + 1;   -- stop the tick chain
        s.lastTick = 0;
    end
end
