-----------------------------------
-- Area: Ordelle's Caves (193)
--  NPC: Planar Rift (Voidwatch) -- DRAFT, NOT INSTALLED, NOT TESTED
-- Rift i (npcid 17568198+i) -> csid 6000+i -> spawns Krabimanjaro mob 17568142+i
-- Evidence tags: [C] capture  [V] client dat/fresh pull  [D] design choice (invented, flagged)
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");

-- Zone-local message ids [V] (z193 dialog.yml pulled 2026-10-06; do NOT use TextIDs.lua, stale)
local VW_NOT_ELIGIBLE      = 7506;
local VW_CLEARANCE_EXPEND  = 7507;
local VW_FIEND_MATERIALIZE = 7527;

local RIFT_FIRST = 17568198;   -- [V] client events dat == DSP npc_list
local MOB_FIRST  = 17568142;   -- [V] mob_spawn_points rows, group 13809 (i-th row <-> i-th rift) [LSB order]
-- Krabimanjaro needs Crimson Stratum Abyssite II or higher [W: wiki tier table]
local CRIMSON = {CRIMSON_STRATUM_ABYSSITE, CRIMSON_STRATUM_ABYSSITE_II, CRIMSON_STRATUM_ABYSSITE_III, CRIMSON_STRATUM_ABYSSITE_IV};
local MIN_TIER = 2;

local VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] ids 1539-1544

-- [C] captured (params[0], params[1]) for crimson abyssites: I-III = 14,16 ; IV = 14,18. Replay, meaning unproven.
local function riftFlags(tier)
    if (tier == 4) then return 14, 18; end
    return 14, 16;
end

local function highestCrimson(player)
    for t = 4, 1, -1 do
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

function onEventFinish(player,csid,option)
    if (csid < 6000 or csid > 6002 or option ~= 1) then return; end
    local idx = csid - 6000;
    local tier = highestCrimson(player);
    if (tier < MIN_TIER or voidstoneCount(player) == 0) then
        player:messageSpecial(VW_NOT_ELIGIBLE);
        return;
    end
    local mob = GetMobByID(MOB_FIRST + idx);
    if (mob == nil or mob:isSpawned()) then return; end   -- already up
    -- [D] voidstone is one KI per stock count: drop the highest-numbered one held (retail stock semantics unverified)
    player:delKeyItem(VOIDSTONES[voidstoneCount(player)]);
    player:messageSpecial(VW_CLEARANCE_EXPEND, VOIDSTONES[1]);  -- [V] 7507 param = keyitem; exact param form unverified
    player:messageSpecial(VW_FIEND_MATERIALIZE);
    SpawnMob(MOB_FIRST + idx):updateClaim(player);
    -- TODO [D]: 30 min timer via onInstanceTimeUpdate-style mob tick, status 475 on party, weakness/stagger/blitz, Pyxis
end;
