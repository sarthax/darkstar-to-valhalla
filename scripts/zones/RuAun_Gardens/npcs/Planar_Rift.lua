-----------------------------------
-- Area: Ru'Aun Gardens (130)
--  NPC: Planar Rift (Voidwatch) -- Aello slice (first-pass, untested in-game)
-- Rift i (npcid 17310111+i) -> csid 6000+i -> spawns Aello set 17309985+4*i (Aello + 3 handmaidens)
-- Evidence tags: [C] capture  [V] client dat/fresh pull  [D] design choice (invented, flagged)
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");
require("scripts/globals/voidwatch");

-- Zone-local message ids [V] (z101 dialog.yml; ids = Sarimanok(z101) ids - 291, spot-checked vs RuAun dialog.yml pulled 2026-10-06; do NOT use TextIDs.lua, stale)
local VW_NOT_ELIGIBLE      = 10778;
local VW_CLEARANCE_EXPEND  = 10779;
local VW_FIEND_MATERIALIZE = 10799;
local VW_TOO_FAR = 10775;
local VW_ENGAGED = 10776;
local VW_UNCONSCIOUS = 10777;
local VW_NO_EXPEND = 10780;
local VW_CARRIED_OVER = 10781;
local RANGE = 50; -- [D] clearance range unverified
local VW_MINUTES_TO_COMPLETE = 10785;

local RIFT_FIRST = 17310111;   -- [V] client events dat == DSP npc_list
local MOB_FIRST  = 17309985;   -- [C] Wiggo capture: Aello ids 985/989/993, handmaidens +1..+3 (stride 4); rift i -> MOB_FIRST+4*i
-- Aello needs Ashen Stratum Abyssite III [W: BG wiki Aello; C: Wiggo rift param p7 = 1449]
local CRIMSON = {ASHEN_STRATUM_ABYSSITE, ASHEN_STRATUM_ABYSSITE_II, ASHEN_STRATUM_ABYSSITE_III}; -- (name kept; Ashen tiers)
local MIN_TIER = 3;

local VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] ids 1539-1544

-- [C] captured (params[0], params[1]) for crimson abyssites: I-III = 14,16 ; IV = 14,18. Replay, meaning unproven.
local function riftFlags(tier)
    -- [D] Ashen params unverified: Wiggo capture (older era) shows packed p0-p5 (2158,3216867326,120,492162,4095,7710); using the Krabimanjaro-era form
    return 14, 16;
end

local function highestCrimson(player)
    for t = 3, 1, -1 do
        if (player:hasKeyItem(CRIMSON[t])) then return t; end
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
    local tier = highestCrimson(player);
    local p0, p1 = riftFlags(tier);
    -- [C] 8 params: p0,p1,0,0,0,0,cruor,abyssiteKI
    player:startEvent(6000 + idx, p0, p1, 0, 0, 0, 0, player:getCurrency("cruor"), (tier > 0) and CRIMSON[tier] or 0);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option,npc)
    if (csid < 6000 or csid > 6002 or option ~= 1) then return; end
    local idx = csid - 6000;
    local tier = highestCrimson(player);
    if (tier < MIN_TIER or voidstoneCount(player) == 0) then
        player:messageSpecial(VW_NOT_ELIGIBLE);
        return;
    end
    local mob = GetMobByID(MOB_FIRST + 4 * idx);
    local rift = GetNPCByID(RIFT_FIRST + idx);
    if (mob == nil or mob:isSpawned() or rift:getStatus() ~= STATUS_NORMAL) then return; end   -- already up / rift fading
    -- [D] voidstone is one KI per stock count: drop the highest-numbered one held (retail stock semantics unverified)
    player:delKeyItem(VOIDSTONES[voidstoneCount(player)]);
    -- NM spawns on the rift after it fades (template: vwSpawnAtRift) [C]
    vwSpawnAtRift(rift, MOB_FIRST + 4 * idx, player, function(mob)
        vwAelloResummon(mob, nil); -- 3 handmaidens beside Aello [C]
        -- clearance is per player [V 10775-10781]: in range, not engaged, alive; spawner expends the stone
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
                    -- [D] voidstone holders keep theirs (10781); others get limited spoils (10780)
                    m:messageSpecial((voidstoneCount(m) > 0) and VW_CARRIED_OVER or VW_NO_EXPEND, VOIDSTONES[1]);
                    vwGrantClearance(m, mob);
                end
            end
        end
    end);
    player:messageSpecial(VW_FIEND_MATERIALIZE);
    player:messageSpecial(VW_MINUTES_TO_COMPLETE, 30);
end;
