-----------------------------------
-- Area: Tahrongi Canyon (117)
--  NPC: Planar Rift (Voidwatch) -- Smierc slice (first-pass, untested in-game)
-- Rift i (npcid 17257088+i) -> csid 6000+i -> spawns Smierc mob 17256919+i
-- Evidence tags: [C] capture  [V] client dat/fresh pull  [D] design choice (invented, flagged)
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");
require("scripts/globals/voidwatch");

-- Zone-local message ids [V] (z117 = z95 ids + 3051, text-checked 96 matches)
local VW_NOT_ELIGIBLE      = 11047;
local VW_CLEARANCE_EXPEND  = 11048;
local VW_FIEND_MATERIALIZE = 11068;
local VW_TOO_FAR = 11044;
local VW_ENGAGED = 11045;
local VW_UNCONSCIOUS = 11046;
local VW_NO_EXPEND = 11049;
local VW_CARRIED_OVER = 11050;
local RANGE = 50; -- [D] clearance range unverified
local VW_MINUTES_TO_COMPLETE = 11054;

local RIFT_FIRST = 17257088;   -- [V] client entities.yml (DB re-keyed by none needed (DB ids = client ids))
local MOB_FIRST  = 17256919;   -- [V] mob_spawn_points rows, group 13730 (i-th row <-> i-th rift) [LSB order]
-- Smierc needs White Stratum Abyssite V [C: White V capture] [W: wiki tier table]
local JADE = {WHITE_STRATUM_ABYSSITE, WHITE_STRATUM_ABYSSITE_II, WHITE_STRATUM_ABYSSITE_III, WHITE_STRATUM_ABYSSITE_IV, WHITE_STRATUM_ABYSSITE_V, WHITE_STRATUM_ABYSSITE_VI}; -- White ids 1444-1446,1450-1451
local MIN_TIER = 5;

local VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] ids 1539-1544

-- [C] Smierc capture (White V): params 2126,-1065873409,57,1302,170,0,cruor,1451. Non-standard (not the Jade 14,18 pair);
-- used verbatim, meaning of the extra params unknown.
local function riftParams()
    return 2126, -1065873409, 57, 1302, 170, 0;
end

local function highestJade(player)
    for t = 6, 1, -1 do
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
    local p0, p1, p2, p3, p4, p5 = riftParams();
    -- [C] 8 params: p0..p5,cruor,abyssiteKI
    player:startEvent(6000 + idx, p0, p1, p2, p3, p4, p5, player:getCurrency("cruor"), (tier > 0) and JADE[tier] or 0);
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
        -- clearance is per player [V 11732-11738]: in range, not engaged, alive; spawner expends the stone
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
                    -- [D] voidstone holders keep theirs (11738); others get limited spoils (11737)
                    m:messageSpecial((voidstoneCount(m) > 0) and VW_CARRIED_OVER or VW_NO_EXPEND, VOIDSTONES[1]);
                    vwGrantClearance(m, mob);
                end
            end
        end
    end);
    player:messageSpecial(VW_FIEND_MATERIALIZE);
    player:messageSpecial(VW_MINUTES_TO_COMPLETE, 30);
end;
