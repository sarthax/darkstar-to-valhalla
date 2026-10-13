-----------------------------------
-- Voidwatch shared helpers (slice voidwatch-vwnm)
-- Pyxis item pool below is a FLAGGED PLACEHOLDER: the 14 item ids are real items seen in
-- retail Pyxis captures (research/CAPTURE-ANALYSIS-SIKNOZ-WEAKNESS.md) but are NOT
-- per-NM drop data; the selection rule is unknown.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/voidwatch_officer");
require("scripts/globals/voidwatch_drops"); -- VW_DROP_OVERRIDES: server-specific drop additions/removals, managed by the Mission Toolkit Voidwatch domain

VW_PYXIS_LIFETIME = 180; -- seconds [W: 3 min]
local PLACEHOLDER_POOL = {749, 695, 798, 866, 3508, 3510, 4118, 644, 690, 694, 815, 895, 645, 700};

-- Base EXP / cruor per stage [F: ffxiclopedia Category:Voidwatch, Rewards]; Three Nations III = 6000 cruor confirmed [C].
-- Scaled at the end by the player's yellow (EXP) / green (cruor) alignment.
VW_REWARD = {
    THREE = {{5000, 5000}, {5500, 5500}, {6000, 6000}, {6500, 6500}},
    JEUNO = {{6000, 6000}, {6500, 6500}, {7000, 7000}, {6500, 6500}, {7000, 7000}, {10000, 10000}},
    JEUNO_S = {[6] = {7500, 7500}},
    ZILART = {{5000, 7000}, {5000, 7500}, {5000, 8000}},
};
function vwBaseReward(region, stage)
    local r = VW_REWARD[region] and VW_REWARD[region][stage];
    if (r == nil) then return nil, nil; end
    return r[1], r[2]; -- exp, cruor
end

-- Ascent cells (Planar Rift trade, per player, max 3 each) [F]. Item ids from DSP item_basic (client id check pending).
-- Bonus per cell: blue/red +50%, yellow/green +25% [F]. White has no cell.
VW_CELLS = {[3434] = {"BLUE", 50}, [3435] = {"RED", 50}, [3436] = {"YELLOW", 25}, [3437] = {"GREEN", 25}};
local CELL_MAX = 3;

local function cellKey(player, color) return "CELL" .. player:getID() .. color; end

function vwCellBonus(rift, player, color)
    if (rift == nil) then return 0; end
    local n = rift:getLocalVar(cellKey(player, color));
    for _, v in pairs(VW_CELLS) do
        if (v[1] == color) then return n * v[2]; end
    end
    return 0;
end

-- Planar Rift onTrade: accept cells up to 3 per colour. No message ids are known [D], so silent.
function vwTradeCells(player, rift, trade)
    local add = {};
    for id, v in pairs(VW_CELLS) do
        local have = trade:getItemQty(id);
        if (have > 0) then
            local cur = rift:getLocalVar(cellKey(player, v[1]));
            if (cur + have > CELL_MAX) then return false; end
            add[v[1]] = {have, cur};
        end
    end
    local total = 0;
    for _, a in pairs(add) do total = total + a[1]; end
    if (total == 0 or trade:getItemCount() ~= total) then return false; end
    for color, a in pairs(add) do rift:setLocalVar(cellKey(player, color), a[2] + a[1]); end
    player:tradeComplete();
    return true;
end

local function allianceInZone(player)
    local list = {};
    for _, m in pairs(player:getAlliance()) do
        if (m:isPC() and m:getZoneID() == player:getZoneID()) then table.insert(list, m); end
    end
    return list;
end

-- cfg: {cruor=, pyxisId=, msgCruor=, msgFinalBR=, msgFinalYG=, msgFinalW=}
-- Petrifact key items (1556-1558 [U]). region matches cfg.region; city = also drops from every three-nation NM (region THREE: Indigo/Crimson/Jade)
-- Hyacinth (Tavnazia) and Amber (Aht Urhgan) NMs not built yet.
VW_PETRIFACT_RATE = 0.05; -- [D] 'rare'; tune here
VW_PETRIFACTS = {
    {ki = BEGUILING_PETRIFACT, region = "ZILART", city = true},   -- Ashen, city, Jeuno
    {ki = BEGUILING_PETRIFACT, region = "JEUNO"},
    {ki = SEDUCTIVE_PETRIFACT, region = "HYACINTH", city = true}, -- Hyacinth, city, Jeuno
    {ki = SEDUCTIVE_PETRIFACT, region = "JEUNO"},
    {ki = MADDENING_PETRIFACT, region = "AMBER", city = true},    -- Aht Urhgan, city, Jeuno
    {ki = MADDENING_PETRIFACT, region = "JEUNO"},
};

function vwOnKill(mob, player, cfg)
    vwoMarkKill(mob, player); -- officer tier tracking (scripts/globals/voidwatch_officer.lua)
    local pyxis = GetNPCByID(cfg.pyxisId);
    print(string.format('[VW] vwOnKill mob=%d pyxisId=%d found=%s', mob:getID(), cfg.pyxisId, tostring(pyxis ~= nil)));
    if (pyxis == nil) then
        local r0 = GetNPCByID(mob:getLocalVar("VW_RIFT_LAST"));
        if (r0 ~= nil) then r0:setStatus(STATUS_NORMAL); end
        return;
    end
    pyxis:resetLocalVars();
    local items = {};
    local rift = GetNPCByID(mob:getLocalVar("VW_RIFT_LAST"));
    local b, r = vwAlignment(mob);
    -- Blue/red cells are per player but the Pyxis item list is shared: use the best bonus among participants [D]
    local bestB, bestR = 0, 0;
    for _, m in pairs(allianceInZone(player)) do
        bestB = math.max(bestB, vwCellBonus(rift, m, "BLUE"));
        bestR = math.max(bestR, vwCellBonus(rift, m, "RED"));
    end
    b = b + bestB; r = r + bestR;
    -- wiki: blue% = item count (100%/item, remainder = chance of +1); red% = chance of the rare drop [W].
    -- Rare chance base 10% x (1 + red/100) is a [D] guess; filler comes from the placeholder pool.
    local count = 1 + math.floor(b / 100) + ((math.random(0, 99) < (b % 100)) and 1 or 0);
    -- Server-specific overrides (voidwatch_drops.lua): shared pool additions/removals, per-NM added drops and removed script drops.
    local ov = (VW_DROP_OVERRIDES.nm or {})[mob:getName()] or {};
    local rm = {};
    for _, id in ipairs(ov.remove or {}) do rm[id] = true; end
    local pool = {};
    local poolRm = {};
    for _, id in ipairs(VW_DROP_OVERRIDES.poolRemove or {}) do poolRm[id] = true; end
    for _, id in ipairs(PLACEHOLDER_POOL) do if (not poolRm[id]) then table.insert(pool, id); end end
    for _, id in ipairs(VW_DROP_OVERRIDES.pool or {}) do if (not poolRm[id]) then table.insert(pool, id); end end
    if (#pool > 0) then
        for i = 1, math.min(count, 7) do
            table.insert(items, pool[math.random(1, #pool)]);
        end
    end
    if (cfg.dropRates) then -- per-item measured rates in percent, rolled independently [W/F/U]; red cells scale them [D]
        for id, pct in pairs(cfg.dropRates) do
            if (not rm[id] and math.random() * 100 < pct * (1 + r / 100)) then table.insert(items, 1, id); end
        end
    elseif (cfg.drops and math.random() < 0.10 * (1 + r / 100)) then
        local keep = {};
        for _, id in ipairs(cfg.drops) do if (not rm[id]) then table.insert(keep, id); end end
        if (#keep > 0) then table.insert(items, 1, keep[math.random(1, #keep)]); end -- rare goes top slot
    end
    for id, pct in pairs(ov.add or {}) do -- per-NM additions, percent, rolled independently like dropRates
        if (math.random() * 100 < pct * (1 + r / 100)) then table.insert(items, 1, id); end
    end
    -- White light = chance of the NM's periapt / atmacite, rolled per alliance member; 100% white = guaranteed [W/J: ATMACITE-DATA.md].
    -- JP wiki: a Void Stone must be held when the NM dies (not enforced here). Red no longer scales this roll.
    local white = select(5, vwAlignment(mob));
    local whiteKIs = {};
    if (cfg.keyitem) then table.insert(whiteKIs, cfg.keyitem); end
    for _, ki in ipairs(cfg.atmacite or {}) do table.insert(whiteKIs, ki); end
    for _, ki in ipairs(whiteKIs) do
        for _, m in pairs(allianceInZone(player)) do
            if (not m:hasKeyItem(ki) and math.random(1, 100) <= white) then
                m:addKeyItem(ki);
                m:messageSpecial(cfg.msgKeyItem, ki);
            end
        end
    end
    -- Petrifacts: rare per alliance member [U 2026-10-07]; paths in VW_PETRIFACTS, rate VW_PETRIFACT_RATE [D, adjustable]
    for _, pf in ipairs(VW_PETRIFACTS) do
        if (cfg.region == pf.region or (pf.city and cfg.region == "THREE")) then
            for _, m in pairs(allianceInZone(player)) do
                if (not m:hasKeyItem(pf.ki) and math.random() < VW_PETRIFACT_RATE * (1 + r / 100)) then
                    m:addKeyItem(pf.ki);
                    m:messageSpecial(cfg.msgKeyItem, pf.ki);
                end
            end
        end
    end
    for i = 1, 8 do pyxis:setLocalVar("ITEM" .. i, items[i] or 0); end
    pyxis:setLocalVar("TOKEN", os.time());
    for _, m in pairs(allianceInZone(player)) do
        pyxis:setLocalVar("ELIG" .. m:getID(), 1);
        local b, r, y, g, w = vwAlignment(mob);
        b = b + vwCellBonus(rift, m, "BLUE"); r = r + vwCellBonus(rift, m, "RED");
        y = y + vwCellBonus(rift, m, "YELLOW"); g = g + vwCellBonus(rift, m, "GREEN");
        local exp, baseCruor = nil, cfg.cruor;
        if (cfg.region ~= nil) then exp, baseCruor = vwBaseReward(cfg.region, cfg.stage); end
        local cruor = math.floor(baseCruor * (100 + g) / 100); -- stage base x green [F]
        if (exp ~= nil) then m:addExp(math.floor(exp * (100 + y) / 100)); end -- stage base x yellow [F]
        if (rift ~= nil) then -- cells are consumed when the Pyxis is claimed [F]
            for _, v in pairs(VW_CELLS) do rift:setLocalVar(cellKey(m, v[1]), 0); end
        end
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
    -- The Pyxis sits exactly on the rift position; keep the rift hidden until the Pyxis is gone,
    -- otherwise the overlapping entities make the Pyxis untargetable.
    if (rift ~= nil) then
        vwHoldRift(rift:getID(), cfg.pyxisId, os.time() + VW_PYXIS_LIFETIME + 10);
    end
end

-- Hide the rift and restore it once the Pyxis is gone (claimed/expired) or `untilT` passes.
-- Closures capture ids only (no entity userdata).
local vwRiftPoll;
vwRiftPoll = function(riftId, pyxisId, untilT)
    local rift = GetNPCByID(riftId);
    local pyxis = GetNPCByID(pyxisId);
    if (rift == nil) then return; end
    if (pyxis == nil or pyxis:getStatus() == STATUS_DISAPPEAR or os.time() >= untilT) then
        rift:setStatus(STATUS_NORMAL);
        return;
    end
    pyxis:timer(5000, function() vwRiftPoll(riftId, pyxisId, untilT); end);
end

function vwHoldRift(riftId, pyxisId, untilT)
    local rift = GetNPCByID(riftId);
    if (rift == nil) then return; end
    rift:setStatus(STATUS_DISAPPEAR);
    vwRiftPoll(riftId, pyxisId, untilT);
end

-- Rift -> NM spawn [C: click t0, NM first seen t0+~4s]. The rift fades, then the NM appears on the rift.
-- Shared template for every Voidwatch NM. Returns nothing; claims for `player` once the NM is up.
VW_RIFT_FADE_DELAY = 3; -- seconds [C]
function vwSpawnAtRift(rift, mobId, player, after)
    local pos = rift:getPos();
    local riftId = rift:getID();
    local playerId = player:getID();
    rift:setStatus(STATUS_DISAPPEAR);
    -- Do NOT capture entity userdata (player/rift/pos) in the closure: it runs 3s later and a stale
    -- pointer crashes the map server. Capture plain values and re-resolve by id.
    local x, y, z, rot = pos.x, pos.y, pos.z, pos.rot;
    rift:timer(VW_RIFT_FADE_DELAY * 1000, function()
        local r = GetNPCByID(riftId);
        local m = SpawnMob(mobId);
        if (m == nil) then
            if (r ~= nil) then r:setStatus(STATUS_NORMAL); end
            return;
        end
        m:setPos(x, y, z, rot);
        m:setLocalVar("VW_RIFT", riftId);
        m:setLocalVar("VW_SPAWNER", playerId);
        local p = GetPlayerByID(playerId);
        if (p ~= nil and p:getZoneID() == m:getZoneID()) then m:updateClaim(p); end
    end);
end

-- rift returns when the operation ends
local function vwRiftReturn(mob)
    local rid = mob:getLocalVar("VW_RIFT");
    if (rid ~= 0) then
        local rift = GetNPCByID(rid);
        -- on a kill (HP 0) vwOnKill keeps the rift hidden until the Pyxis is gone
        if (rift ~= nil and mob:getHP() > 0) then rift:setStatus(STATUS_NORMAL); end
        mob:setLocalVar("VW_RIFT_LAST", rid); -- vwOnKill reads cells from the rift after cleanup
        mob:setLocalVar("VW_RIFT", 0);
    end
end

-- Aello: handmaidens are the 3 mob ids after her. Shrieking Gale resummons dead ones on her position [forum #1140]
AELLO_HM_OFFSET = {{0.805, 0.113}, {0.807, 0.126}, {1.277, 0.438}};
function vwAelloResummon(aello, target)
    local pos = aello:getPos();
    for i = 1, 3 do
        local h = GetMobByID(aello:getID() + i);
        if (h ~= nil and not h:isSpawned()) then
            local m = SpawnMob(aello:getID() + i);
            if (m ~= nil) then
                local o = AELLO_HM_OFFSET[i]; -- [C] Wiggo capture offsets from Aello at the rift
                m:setPos(pos.x + o[1], pos.y, pos.z + o[2], pos.rot);
                if (target ~= nil) then m:updateEnmity(target); end
            end
        end
    end
end

function vwPyxisItems(npc)
    local t = {};
    for i = 1, 8 do t[i] = npc:getLocalVar("ITEM" .. i); end
    return t;
end

-- Pyxis menu [C]: option 1-8 = take that slot's item, 10 = obtain all, 9 = relinquish/done.
-- After a pick retail re-sends the same csid with the taken slot zeroed (captures: params 4141,4273 -> 4141,0).
-- Returns true if the option was a take (1-8, 10) so the caller skips its other branches.
function vwPyxisTake(player, pyxis, csid, option, msgObtain)
    local taken = (option >= 1 and option <= 8) or option == 10;
    if (not taken) then return false; end
    local slots = (option == 10) and {1, 2, 3, 4, 5, 6, 7, 8} or {option};
    for _, i in ipairs(slots) do
        local item = pyxis:getLocalVar("ITEM" .. i);
        if (item ~= 0 and player:addItem(item, 1)) then
            player:messageSpecial(msgObtain, item);
            pyxis:setLocalVar("ITEM" .. i, 0);
        end
    end
    local it = vwPyxisItems(pyxis);
    local left = false;
    for i = 1, 8 do if (it[i] ~= 0) then left = true; end end
    if (left) then
        player:startEvent(csid, it[1], it[2], it[3], it[4], it[5], it[6], it[7], it[8]);
    else
        pyxis:setLocalVar("TAKEN" .. player:getID(), 1);
    end
    return true;
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
    if (mob:getName() == "Aello") then
        for i = 1, 3 do DespawnMob(mob:getID() + i); end
    end
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
-- Weapon skills hooked (vwOnWeaponskillHit, one random weapon type, [D]). JA / pet / avatar weaknesses are not hooked yet.
-----------------------------------
local CAP = {BLUE = 350, RED = 350, YELLOW = 225, GREEN = 225, WHITE = 100};
local BLITZ_LEN = 15;
-- job-ability weakness pool (ability ids from sql/abilities.sql): Provoke, Weapon Bash, Jump, High Jump, Chi Blast, Shield Bash,
-- Shadowbind, six Quick Draw shots, Quickstep, Stutter Step, Box Step, four Flourishes. Not in this server: Enmity Douse,
-- Feather Step, Spirit/Soul Jump, Libra, Bully.
-- Client weakness-message params [V: RuAun_Gardens dialog.yml 10897-10903, choice lists start with an EMPTY index 0].
-- Message ids are relative to cfg.msgWeakElem (= the 10899 "elemental magic" line): weapon -2, job ability -1, element+blood pact +2.
local CLIENT_ELE = {[1] = 1, [2] = 4, [3] = 6, [4] = 3, [5] = 2, [6] = 5, [7] = 7, [8] = 8}; -- DSP ELE_* -> client element index
local CLIENT_WS_TYPE = {[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10, [11] = 11, [12] = 12, [25] = 13, [26] = 14};
local VW_JA_JOB = {[19] = 1, [61] = 8, [50] = 14, [51] = 14, [66] = 2, [30] = 7, [41] = 11, [109] = 17, [110] = 17, [111] = 17,
                   [112] = 17, [113] = 17, [114] = 17, [185] = 19, [187] = 19, [186] = 19, [188] = 19, [189] = 19, [191] = 19, [190] = 19}; -- ability id -> job id (== client job index)
local VW_JA_POOL = {19, 61, 50, 51, 66, 30, 41, 109, 110, 111, 112, 113, 114, 185, 187, 186, 188, 189, 191, 190};
local VW_WS_TYPES = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 25, 26}; -- SKILL_H2H..SKILL_STF, SKILL_ARC, SKILL_MRK

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
    mob:setLocalVar("VW_WEAK_JA", VW_JA_POOL[math.random(1, #VW_JA_POOL)]);
    mob:setLocalVar("VW_WEAK_AVATAR", math.random(1, 6)); -- element of the avatar "<Element> IV" blood pact (fire..water)
    local cats = {"ELEM", "WS", "JA", "AVATAR"};
    for _, c in ipairs(cats) do mob:setLocalVar("VW_TIER_" .. c, 0); end
    local e = math.random(1, 4); local h = math.random(1, 3); if (h >= e) then h = h + 1; end
    mob:setLocalVar("VW_TIER_" .. cats[e], 2); mob:setLocalVar("VW_TIER_" .. cats[h], 1);
    mob:setLocalVar("VW_WEAK_WS", VW_WS_TYPES[math.random(1, #VW_WS_TYPES)]);
    for k in pairs(CAP) do mob:setLocalVar("VW_" .. k, 0); end
    mob:setLocalVar("VW_HITS", 0);
    mob:setLocalVar("VW_BLITZ_END", 0);
    mob:setLocalVar("VW_NO_REBUFF", 1); -- see vwBuffActive
end

-- cfg: {msgWeakElem=7627, msgBlitzOn=7634, msgBlitzOff=7635, msgBlitzGain=7636, msgBR=7637, msgW=7638}
-- Tiers [D]: 4 weakness categories (ELEM, WS, JA, AVATAR); at fight start one is extreme (tier 2), one high (tier 1), the rest
-- normal (0). Retail is 6 normal / 2 high / 1 extreme out of 9 specific triggers; we only have 4 slots. Per hit [bg-wiki digest]:
-- normal 20 (blue/red), high 100, extreme 250; yellow/green are half of that, white +25 / +25 / +100 (forum: white only from
-- "highly" procs, ~4 = 100%). Blitz doubles everything except white. Extreme can hit once (then it becomes normal); a high
-- weakness moves to a random normal category after it is hit. The tier is also the "degree" param (0/1/2) of the client line.
local TIER_BLUE = {[0] = 20, [1] = 100, [2] = 250};
local TIER_WHITE = {[0] = 0, [1] = 25, [2] = 100};

-- msgid: weakness line (or nil); ... = its params WITHOUT the trailing degree, which is appended from the category tier
local function vwWeaknessHit(mob, cfg, cat, msgid, ...)
    local tier = mob:getLocalVar("VW_TIER_" .. cat);
    if (msgid ~= nil and msgid > 0) then
        local args = {...}; -- NB: "..." in the middle of an arg list is truncated to one value in Lua
        table.insert(args, tier);
        vwNotify(mob, msgid, unpack(args));
    end
    local blitz = mob:getLocalVar("VW_BLITZ_END") > os.time();
    local mult = blitz and 2 or 1;
    local v = TIER_BLUE[tier];
    bump(mob, "BLUE", v * mult); bump(mob, "RED", v * mult);
    bump(mob, "YELLOW", v / 2 * mult); bump(mob, "GREEN", v / 2 * mult);
    bump(mob, "WHITE", TIER_WHITE[tier]);
    if (tier > 0) then -- extreme: one-shot; high: moves to another (normal) category
        mob:setLocalVar("VW_TIER_" .. cat, 0);
        if (tier == 1) then
            local normal = {};
            for _, c in ipairs({"ELEM", "WS", "JA", "AVATAR"}) do
                if (c ~= cat and mob:getLocalVar("VW_TIER_" .. c) == 0) then table.insert(normal, c); end
            end
            if (#normal > 0) then mob:setLocalVar("VW_TIER_" .. normal[math.random(1, #normal)], 1); end
        end
    end
    local hits = mob:getLocalVar("VW_HITS") + 1;
    mob:setLocalVar("VW_HITS", hits);
    if (not blitz and hits % 3 == 0) then
        mob:setLocalVar("VW_BLITZ_END", os.time() + BLITZ_LEN);
        vwNotify(mob, cfg.msgBlitzOn);
    end
end

-- Periapt hints [D]: bg-wiki says an offensive action by a holder has "a chance" to reveal one weakness (rate unknown; HINT_CHANCE is
-- a guess). Guidance (1777) -> weapon-skill / job-ability weakness, Percipience (1778) -> magic element. The reveal prints the same
-- client line as a hit but raises no lights. Clarity (school) and Sapience (avatar element) are not built.
local HINT_CHANCE = 15;
local function vwPeriaptHint(mob, player, kind, cfg)
    if (math.random(1, 100) > HINT_CHANCE) then return; end
    local tier = mob:getLocalVar("VW_TIER_" .. kind);
    if (kind == "ELEM" and player:hasKeyItem(PERIAPT_OF_PERCIPIENCE)) then
        vwNotify(mob, cfg.msgWeakElem, CLIENT_ELE[mob:getLocalVar("VW_WEAK_ELEM")] or 0, tier);
    elseif (kind == "WS" and player:hasKeyItem(PERIAPT_OF_GUIDANCE)) then
        vwNotify(mob, cfg.msgWeakElem - 2, CLIENT_WS_TYPE[mob:getLocalVar("VW_WEAK_WS")] or 0, 0, tier);
    elseif (kind == "JA" and player:hasKeyItem(PERIAPT_OF_GUIDANCE)) then
        vwNotify(mob, cfg.msgWeakElem - 1, VW_JA_JOB[mob:getLocalVar("VW_WEAK_JA")] or 0, tier);
    end
end

function vwOnMagicHit(mob, caster, spell, cfg)
    if (not caster:isPC() or spell:getSkillType() ~= 36) then return; end -- elemental magic only
    if (spell:getElement() ~= mob:getLocalVar("VW_WEAK_ELEM")) then vwPeriaptHint(mob, caster, "ELEM", cfg); return; end
    vwWeaknessHit(mob, cfg, "ELEM", cfg.msgWeakElem, CLIENT_ELE[spell:getElement()] or 0);
end

-- Weapon skills [D]: ONE random weapon type per fight (retail: 8-12 specific WS per type, per bg-wiki; the
-- specific lists are not sourced, so any WS of the weakness type counts; Relic/Mythic/Empyrean/Aeonic exclusion
-- not implemented). Weakness line: msgWeakElem-2 [V].
-- Call from the mob's onWeaponskillHit(mob, attacker, wsid); the hook must return 0.
function vwOnWeaponskillHit(mob, attacker, wsid, cfg)
    if (not attacker:isPC()) then return; end
    if (attacker:getWeaponSkillType(SLOT_MAIN) ~= mob:getLocalVar("VW_WEAK_WS")) then vwPeriaptHint(mob, attacker, "WS", cfg); return; end
    vwWeaknessHit(mob, cfg, "WS", cfg.msgWeakElem - 2, CLIENT_WS_TYPE[mob:getLocalVar("VW_WEAK_WS")] or 0, 0); -- type, kind 0 = weapon skills
end

-- Job abilities [D]: ONE random ability from VW_JA_POOL per fight. Called from the ability scripts themselves (the engine
-- has no mob-side ability hook). Retail's "no effect / full resist / miss doesn't count" rule is NOT checked. Weakness line: msgWeakElem-1 [V].
-- No-op on non-Voidwatch targets.
function vwOnAbility(user, target, ability)
    if (target == nil or not user:isPC() or target:getLocalVar("VW_NO_REBUFF") ~= 1) then return; end
    local w = target:getLocalVar("VW_MSG_WEAK");
    if (ability:getID() ~= target:getLocalVar("VW_WEAK_JA")) then
        if (w > 0) then vwPeriaptHint(target, user, "JA", {msgWeakElem = w}); end
        return;
    end
    vwWeaknessHit(target, {msgBlitzOn = target:getLocalVar("VW_MSG_BLITZON")}, "JA", w > 0 and w - 1 or 0, VW_JA_JOB[ability:getID()] or 0);
end

-- Avatar blood pacts [D]: ONE random element among the six "<Element> IV" pacts (bg-wiki: Ifrit/Shiva/Garuda/Titan/Ramuh/
-- Leviathan). Light/Dark pacts (Holy Mist, Night Terror, Lunar Bay) have no pet script on this server, so can't trigger.
-- Called from the top of each pets/<element>_iv.lua onPetAbility. Needs a PC master. Miss/resist not checked; weakness line: msgWeakElem+2 [V].
function vwOnPetAbility(target, pet, element)
    if (target == nil or target:getLocalVar("VW_NO_REBUFF") ~= 1) then return; end
    local master = pet:getMaster();
    if (master == nil or not master:isPC()) then return; end
    if (element ~= target:getLocalVar("VW_WEAK_AVATAR")) then return; end
    local w = target:getLocalVar("VW_MSG_WEAK");
    vwWeaknessHit(target, {msgBlitzOn = target:getLocalVar("VW_MSG_BLITZON")}, "AVATAR", w > 0 and w + 2 or 0, CLIENT_ELE[element], 0); -- element, kind 0 = blood pacts
end

-- call from the mob's tick: ends a blitz window
function vwWeaknessTick(mob, cfg)
    mob:setLocalVar("VW_MSG_BLITZON", cfg.msgBlitzOn);
    mob:setLocalVar("VW_MSG_WEAK", cfg.msgWeakElem); -- lets ability scripts (no cfg) announce a blitz
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

-----------------------------------
-- No redundant self-buffs [D]. Voidwatch NMs must not re-use a self-buff (spell or mob skill) while its effect
-- is still on them; only after it expires or is dispelled. Debuffs on players are NOT filtered.
-- Spells: vwPick() drops self-buff spells already active (only Ig-Alima's spikes are self-buff spells).
-- Mob skills: the engine shuffles the skill list and takes the first whose onMobSkillCheck returns 0, so the
-- self-buff skill scripts call vwBuffActive(mob, effect) and return 1 to make it pick another skill.
-- vwBuffActive is false for non-Voidwatch mobs (flag set in vwWeaknessInit), so shared skill scripts are unchanged for them.
-----------------------------------
local VW_SELF_SPELL_EFFECT = {
    [249] = {EFFECT_BLAZE_SPIKES, EFFECT_ICE_SPIKES, EFFECT_SHOCK_SPIKES}, -- any spikes up blocks all three
    [250] = {EFFECT_BLAZE_SPIKES, EFFECT_ICE_SPIKES, EFFECT_SHOCK_SPIKES},
    [251] = {EFFECT_BLAZE_SPIKES, EFFECT_ICE_SPIKES, EFFECT_SHOCK_SPIKES},
};

function vwBuffActive(mob, ...)
    if (mob:getLocalVar("VW_NO_REBUFF") ~= 1) then return false; end
    for _, eff in ipairs({...}) do
        if (mob:hasStatusEffect(eff)) then return true; end
    end
    return false;
end

-- Random spell from pool, skipping self-buffs that are still up; nil if nothing is left.
function vwPick(mob, target, pool)
    local ok = {};
    for _, s in ipairs(pool) do
        local e = VW_SELF_SPELL_EFFECT[s];
        if (e == nil or not vwBuffActive(mob, unpack(e))) then table.insert(ok, s); end
    end
    if (#ok == 0) then return nil; end
    return ok[math.random(#ok)];
end
