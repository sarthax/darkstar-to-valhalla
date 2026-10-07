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
    for i = 1, math.random(1, 3) do
        table.insert(items, PLACEHOLDER_POOL[math.random(1, #PLACEHOLDER_POOL)]);
    end
    for i = 1, 8 do pyxis:setLocalVar("ITEM" .. i, items[i] or 0); end
    pyxis:setLocalVar("TOKEN", os.time());
    for _, m in pairs(allianceInZone(player)) do
        pyxis:setLocalVar("ELIG" .. m:getID(), 1);
        m:addCurrency("cruor", cfg.cruor);
        m:messageSpecial(cfg.msgCruor, cfg.cruor, m:getCurrency("cruor"));
        -- no weakness/stagger yet, so all alignment values are 0 (TODO step 4)
        m:messageSpecial(cfg.msgFinalBR, 0, 0, 0, 0);
        m:messageSpecial(cfg.msgFinalYG, 0, 0, 0, 0);
        m:messageSpecial(cfg.msgFinalW, 0);
    end
    pyxis:setStatus(STATUS_NORMAL);
    local token = os.time();
    pyxis:timer(VW_PYXIS_LIFETIME * 1000, function(npc)
        if (npc:getLocalVar("TOKEN") == token) then npc:setStatus(STATUS_DISAPPEAR); end
    end);
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
    for _, p in pairs(mob:getZone():getPlayers()) do
        if (vwHasClearance(mob, p)) then
            p:delStatusEffect(EFFECT_VOIDWATCHER);
            mob:setLocalVar("VW_CLR" .. p:getID(), 0);
        end
    end
end
