-----------------------------------
-- Area: Outer Horutoto Ruins (194)
--  NPC: Planar Rift (Voidwatch) -- Voidwrought slice (first-pass, untested in-game)
-- Rift i (npcid 17572303+i) -> csid 6000+i -> spawns Voidwrought mob 17572219+i
-- Evidence tags: [C] capture  [V] client dat/fresh pull  [D] design choice (invented, flagged)
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");
require("scripts/globals/voidwatch");

-- Zone-local message ids [V] (z194 dialog.yml = z119 ids - 4349, text-checked)
local VW_NOT_ELIGIBLE      = 7386;
local VW_CLEARANCE_EXPEND  = 7387;
local VW_FIEND_MATERIALIZE = 7407;
local VW_TOO_FAR = 7383;
local VW_ENGAGED = 7384;
local VW_UNCONSCIOUS = 7385;
local VW_NO_EXPEND = 7388;
local VW_CARRIED_OVER = 7389;
local RANGE = 50; -- [D] clearance range unverified
local VW_MINUTES_TO_COMPLETE = 7393;

local RIFT_FIRST = 17572303;   -- [V] client entities.yml (DB re-keyed by rekey_119.sql)
local MOB_FIRST  = 17572219;   -- [V] mob_spawn_points rows, group 18226 (i-th row <-> i-th rift) [LSB order]
-- Voidwrought needs Jade Stratum Abyssite III or higher [C: Jade III capture] [W: wiki tier table]
local JADE = {JADE_STRATUM_ABYSSITE, JADE_STRATUM_ABYSSITE_II, JADE_STRATUM_ABYSSITE_III, JADE_STRATUM_ABYSSITE_IV}; -- Jade ids 374-377
local MIN_TIER = 4;

local VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] ids 1539-1544

-- [C] Voidwrought capture (Jade III): params 14,18 (KI 376).
local function riftFlags(tier)
    return 14, 18;
end

local function highestJade(player)
    for t = 4, 1, -1 do
        if (player:hasKeyItem(JADE[t])) then return t; end
    end
    return 0;
end

local function voidstoneCount(player)
    for n = 6, 1, -1 do
        if (player:hasKeyItem(VOIDSTONES[n])) then return n; end
    end
    return 0;
end

function onTrade(player,npc,trade)
    vwTradeCells(player, npc, trade); -- ascent cells [F]
end;

function onTrigger(player,npc)
    local idx = npc:getID() - RIFT_FIRST;
    local tier = highestJade(player);
    local p0, p1 = riftFlags(tier);
    -- [C] 8 params: p0,p1,0,0,0,0,cruor,abyssiteKI
    player:startEvent(6000 + idx, p0, p1, 0, 0, 0, 0, player:getCurrency("cruor"), (tier > 0) and JADE[tier] or 0);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option,npc)
    if (csid < 6000 or csid > 6002 or option ~= 1) then return; end
    local idx = csid - 6000;
    local tier = highestJade(player);
    if (tier < MIN_TIER or voidstoneCount(player) == 0) then
        player:messageSpecial(VW_NOT_ELIGIBLE);
        return;
    end
    local mob = GetMobByID(MOB_FIRST + idx);
    local rift = GetNPCByID(RIFT_FIRST + idx);
    if (mob == nil or mob:isSpawned() or rift:getStatus() ~= STATUS_NORMAL) then return; end   -- already up / rift fading
    -- [D] voidstone is one KI per stock count: drop the highest-numbered one held (retail stock semantics unverified)
    player:delKeyItem(VOIDSTONES[voidstoneCount(player)]);
    -- NM spawns on the rift after it fades (template: vwSpawnAtRift) [C]
    vwSpawnAtRift(rift, MOB_FIRST + idx, player, function(mob)
        -- clearance is per player [V 7383-7389]: in range, not engaged, alive; spawner expends the stone
        for _, m in pairs(player:getAlliance()) do
            if (m:isPC() and m:getZoneID() == player:getZoneID()) then
                if (m:getID() == player:getID()) then
                    m:messageSpecial(VW_CLEARANCE_EXPEND, VOIDSTONES[1]);
                    vwGrantClearance(m, mob);
                elseif (m:checkDistance(rift) > RANGE) then
                    m:messageSpecial(VW_TOO_FAR);
                elseif (m:getHP() == 0) then
                    m:messageSpecial(VW_UNCONSCIOUS);
                elseif (m:isEngaged()) then
                    m:messageSpecial(VW_ENGAGED);
                else
                    -- [D] voidstone holders keep theirs (7389); others get limited spoils (7388)
                    m:messageSpecial((voidstoneCount(m) > 0) and VW_CARRIED_OVER or VW_NO_EXPEND, VOIDSTONES[1]);
                    vwGrantClearance(m, mob);
                end
            end
        end
    end);
    player:messageSpecial(VW_FIEND_MATERIALIZE);
    player:messageSpecial(VW_MINUTES_TO_COMPLETE, 30);
end;
