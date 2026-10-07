-----------------------------------
-- Voidwatch shared helpers (slice voidwatch-vwnm)
-- Pyxis item pool below is a FLAGGED PLACEHOLDER: the 14 item ids are real items seen in
-- retail Pyxis captures (research/CAPTURE-ANALYSIS-SIKNOZ-WEAKNESS.md) but are NOT
-- per-NM drop data; the selection rule is unknown.
-----------------------------------

require("scripts/globals/status");

VW_PYXIS_LIFETIME = 180; -- seconds [W: 3 min]
local PLACEHOLDER_POOL = {749, 695, 798, 866, 3508, 3510, 4118, 644, 690, 694, 815, 895, 645, 700};

local function allianceInZone(player)
    local list = {};
    for _, m in pairs(player:getAlliance()) do
        if (m:isPC() and m:getZoneID() == player:getZoneID()) then table.insert(list, m); end
    end
    return list;
end

-- cfg: {cruor=, pyxisId=, msgCruor=, msgFinalBR=, msgFinalYG=, msgFinalW=}
function vwOnKill(mob, player, cfg)
    local pyxis = GetNPCByID(cfg.pyxisId);
    if (pyxis == nil) then return; end
    pyxis:resetLocalVars();
    local items = {};
    local b, r = vwAlignment(mob);
    -- wiki: blue% = item count (100%/item, remainder = chance of +1); red% = chance of the rare drop [W].
    -- Rare chance base 10% x (1 + red/100) is a [D] guess; filler comes from the placeholder pool.
    local count = 1 + math.floor(b / 100) + ((math.random(0, 99) < (b % 100)) and 1 or 0);
    for i = 1, math.min(count, 7) do
        table.insert(items, PLACEHOLDER_POOL[math.random(1, #PLACEHOLDER_POOL)]);
    end
    if (cfg.drops and math.random() < 0.10 * (1 + r / 100)) then
        table.insert(items, 1, cfg.drops[math.random(1, #cfg.drops)]); -- rare goes top slot
    end
    if (cfg.keyitem) then
        local kiChance = 0.05 * (1 + r / 100); -- [D] unknown
        for _, m in pairs(allianceInZone(player)) do
            if (not m:hasKeyItem(cfg.keyitem) and math.random() < kiChance) then
                m:addKeyItem(cfg.keyitem);
                m:messageSpecial(cfg.msgKeyItem, cfg.keyitem);
            end
        end
    end
    for i = 1, 8 do pyxis:setLocalVar("ITEM" .. i, items[i] or 0); end
    pyxis:setLocalVar("TOKEN", os.time());
    for _, m in pairs(allianceInZone(player)) do
        pyxis:setLocalVar("ELIG" .. m:getID(), 1);
        local b, r, y, g, w = vwAlignment(mob);
        local cruor = math.floor(cfg.cruor * (100 + g) / 100); -- [D] green scaling formula unverified
        m:addCurrency("cruor", cruor);
        m:messageSpecial(cfg.msgCruor, cruor, m:getCurrency("cruor"));
        m:messageSpecial(cfg.msgFinalBR, b, 0, r, 0);
        m:messageSpecial(cfg.msgFinalYG, y, 0, g, 0);
        m:messageSpecial(cfg.msgFinalW, w);
    end
    -- Pyxis appears where the NM died (Nyzul armoury-crate pattern) [user spec; capture: appears ~2s after kill]
    local pos = mob:getPos();
    pyxis:AnimationSub(0);
    pyxis:setPos(pos.x, pos.y, pos.z, pos.rot);
    pyxis:setStatus(STATUS_NORMAL);
    pyxis:forceRespawn();
    local token = os.time();
    pyxis:timer(VW_PYXIS_LIFETIME * 1000, function(npc)
        if (npc:getLocalVar("TOKEN") == token) then npc:setStatus(STATUS_DISAPPEAR); end
    end);
end

-- Rift -> NM spawn [C: click t0, NM first seen t0+~4s]. The rift fades, then the NM appears on the rift.
-- Shared template for every Voidwatch NM. Returns nothing; claims for `player` once the NM is up.
VW_RIFT_FADE_DELAY = 3; -- seconds [C]
function vwSpawnAtRift(rift, mobId, player, after)
    local pos = rift:getPos();
    rift:setStatus(STATUS_DISAPPEAR);
    rift:timer(VW_RIFT_FADE_DELAY * 1000, function(npc)
        local m = SpawnMob(mobId);
        if (m == nil) then npc:setStatus(STATUS_NORMAL); return; end
        m:setPos(pos.x, pos.y, pos.z, pos.rot);
        m:setLocalVar("VW_RIFT", npc:getID());
        m:setLocalVar("VW_SPAWNER", player:getID());
        if (player ~= nil) then m:updateClaim(player); end
    end);
end

-- rift returns when the operation ends
local function vwRiftReturn(mob)
    local rid = mob:getLocalVar("VW_RIFT");
    if (rid ~= 0) then
        local rift = GetNPCByID(rid);
        if (rift ~= nil) then rift:setStatus(STATUS_NORMAL); end
        mob:setLocalVar("VW_RIFT", 0);
    end
end

function vwPyxisItems(npc)
    local t = {};
    for i = 1, 8 do t[i] = npc:getLocalVar("ITEM" .. i); end
    return t;
end

-- status 475 for a cleared participant; remembered on the mob so it can be removed at the end
function vwGrantClearance(player, mob)
    player:addStatusEffect(EFFECT_VOIDWATCHER, 0, 0, 1800); -- [D] duration/behavior unverified
    mob:setLocalVar("VW_CLR" .. player:getID(), 1);
end

function vwHasClearance(mob, player)
    return mob:getLocalVar("VW_CLR" .. player:getID()) == 1;
end

-- end of operation (kill or timeout): clear status 475 from everyone cleared in this zone
function vwEndOperation(mob)
    vwRiftReturn(mob);
    for _, p in pairs(mob:getZone():getPlayers()) do
        if (vwHasClearance(mob, p)) then
            p:delStatusEffect(EFFECT_VOIDWATCHER);
            mob:setLocalVar("VW_CLR" .. p:getID(), 0);
        end
    end
end

-----------------------------------
-- Weakness / stagger / blitz (SIMPLIFIED, FLAGGED)
-- Verified [C]: messages exist, caps blue/red 350, yellow/green 225, white 100, blitz commences->complete ->
-- "Alignment increases by N% across the spectrum". NOT known: retail weakness-set size/degree rule, per-hit
-- values (wiki: normal 20/40%), blitz trigger. Judgement: ONE random elemental-magic weakness per fight,
-- +20% blue/red per hit (+10% yellow/green), blitz starts every 3rd hit and lasts 15s.
-- Weapon-skill / JA / pet weaknesses are not hooked yet.
-----------------------------------
local CAP = {BLUE = 350, RED = 350, YELLOW = 225, GREEN = 225, WHITE = 100};
local BLITZ_LEN = 15;

local function vwNotify(mob, msgid, ...)
    local p = GetPlayerByID(mob:getLocalVar("VW_SPAWNER"));
    if (p == nil or p:getZoneID() ~= mob:getZoneID()) then return; end
    for _, m in pairs(p:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID()) then m:messageSpecial(msgid, ...); end
    end
end

local function bump(mob, key, amount)
    local v = math.min(mob:getLocalVar("VW_" .. key) + amount, CAP[key]);
    mob:setLocalVar("VW_" .. key, v);
end

function vwAlignment(mob)
    return mob:getLocalVar("VW_BLUE"), mob:getLocalVar("VW_RED"), mob:getLocalVar("VW_YELLOW"),
           mob:getLocalVar("VW_GREEN"), mob:getLocalVar("VW_WHITE");
end

function vwWeaknessInit(mob)
    mob:setLocalVar("VW_WEAK_ELEM", math.random(1, 8)); -- ELE_FIRE..ELE_DARK = 1..8
    for k in pairs(CAP) do mob:setLocalVar("VW_" .. k, 0); end
    mob:setLocalVar("VW_HITS", 0);
    mob:setLocalVar("VW_BLITZ_END", 0);
end

-- cfg: {msgWeakElem=7627, msgBlitzOn=7634, msgBlitzOff=7635, msgBlitzGain=7636, msgBR=7637, msgW=7638}
function vwOnMagicHit(mob, caster, spell, cfg)
    if (not caster:isPC() or spell:getSkillType() ~= 36) then return; end -- elemental magic only
    if (spell:getElement() ~= mob:getLocalVar("VW_WEAK_ELEM")) then return; end
    vwNotify(mob, cfg.msgWeakElem, spell:getElement(), 0);
    local blitz = mob:getLocalVar("VW_BLITZ_END") > os.time();
    local mult = blitz and 2 or 1;
    bump(mob, "BLUE", 20 * mult); bump(mob, "RED", 20 * mult);
    bump(mob, "YELLOW", 10 * mult); bump(mob, "GREEN", 10 * mult);
    local hits = mob:getLocalVar("VW_HITS") + 1;
    mob:setLocalVar("VW_HITS", hits);
    if (not blitz and hits % 3 == 0) then
        mob:setLocalVar("VW_BLITZ_END", os.time() + BLITZ_LEN);
        vwNotify(mob, cfg.msgBlitzOn);
    end
end

-- call from the mob's tick: ends a blitz window
function vwWeaknessTick(mob, cfg)
    local e = mob:getLocalVar("VW_BLITZ_END");
    if (e ~= 0 and e <= os.time()) then
        mob:setLocalVar("VW_BLITZ_END", 0);
        vwNotify(mob, cfg.msgBlitzOff);
        bump(mob, "BLUE", 20); bump(mob, "RED", 20); bump(mob, "YELLOW", 10); bump(mob, "GREEN", 10);
        vwNotify(mob, cfg.msgBlitzGain, 20);
        local b, r, y, g, w = vwAlignment(mob);
        vwNotify(mob, cfg.msgBR, b, r);
        vwNotify(mob, cfg.msgW, w);
    end
end
