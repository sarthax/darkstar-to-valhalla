-----------------------------------
-- Area: Vunkerl_Inlet_[S] (83)
--  NPC: Planar Rift (Voidwatch) -- Gaunab base build (first-pass, untested in-game)
-- Rift i (npcid 17118042+i) -> csid 6000+i [V events.yml, fresh pull] -> spawns Gaunab mob 17117891+i
-- Evidence tags: [C] capture  [V] client dat/fresh pull  [D] design choice (invented, flagged)
-- PLACEHOLDER GATING [D]: White Stratum Abyssite VI + a Voidstone, copied from Ig-Alima/Botulus. Real requirement unverified.
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");
require("scripts/globals/voidwatch");

-- Zone-local message ids [V] (Valkurm z103 -3298, text-matched in this zone's dialog.yml)
local VW_NOT_ELIGIBLE      = 8149;
local VW_CLEARANCE_EXPEND  = 8150;
local VW_FIEND_MATERIALIZE = 8170;
local VW_TOO_FAR = 8146;
local VW_ENGAGED = 8147;
local VW_UNCONSCIOUS = 8148;
local VW_NO_EXPEND = 8151;
local VW_CARRIED_OVER = 8152;
local RANGE = 50; -- [D] clearance range unverified
local VW_MINUTES_TO_COMPLETE = 8156;

local RIFT_FIRST = 17118042;   -- [V] client entities.yml
local MOB_FIRST  = 17117891;   -- [V] mob_spawn_points rows (i-th row <-> i-th rift)
local JADE = {WHITE_STRATUM_ABYSSITE, WHITE_STRATUM_ABYSSITE_II, WHITE_STRATUM_ABYSSITE_III, WHITE_STRATUM_ABYSSITE_IV, WHITE_STRATUM_ABYSSITE_V, WHITE_STRATUM_ABYSSITE_VI}; -- placeholder gate [D]
local MIN_TIER = 6;

local VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] ids 1539-1544

-- [D] Ig-Alima's captured rift params reused verbatim as a placeholder; this NM's own capture would differ.
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
    if (mob == nil or mob:isSpawned() or rift:getStatus() ~= STATUS_NORMAL) then return; end
    player:delKeyItem(VOIDSTONES[voidstoneCount(player)]); -- [D] stock semantics unverified
    vwSpawnAtRift(rift, MOB_FIRST + idx, player, function(mob)
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
                    m:messageSpecial((voidstoneCount(m) > 0) and VW_CARRIED_OVER or VW_NO_EXPEND, VOIDSTONES[1]);
                    vwGrantClearance(m, mob);
                end
            end
        end
    end);
    player:messageSpecial(VW_FIEND_MATERIALIZE);
    player:messageSpecial(VW_MINUTES_TO_COMPLETE, 30);
end;
