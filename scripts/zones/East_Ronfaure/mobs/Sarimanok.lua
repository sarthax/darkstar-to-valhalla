-----------------------------------
-- Area: East Ronfaure
--  MOB: Sarimanok (Voidwatch, Crimson I)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids from research/MESSAGE-IDS-SLICE-ZONES.md
-- (anchor verified, offsets inferred).
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11076;
local VW_MINUTES_REMAINING   = 11077;
local VW_SECONDS_REMAINING   = 11078;
local VW_TIME_UP             = 11079;
local VW_FADES               = 11080;
local LIMIT = 1800; -- 30 min [C]

local function notify(mob, msgid, param)
    local p = GetPlayerByID(mob:getLocalVar("VW_SPAWNER"));
    if (p == nil or p:getZoneID() ~= mob:getZoneID()) then return; end
    for _, m in pairs(p:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID()) then
            m:messageSpecial(msgid, param or 0);
        end
    end
end

local VWMSG = {msgWeakElem = 11190, msgBlitzOn = 11197, msgBlitzOff = 11198, msgBlitzGain = 11199, msgBR = 11200, msgW = 11201};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
end;

local function tick(mob)
    vwWeaknessTick(mob, VWMSG);
    local left = mob:getLocalVar("VW_DEADLINE") - os.time();
    if (left <= 0) then
        notify(mob, VW_TIME_UP);
        notify(mob, VW_FADES);
        mob:setLocalVar("VW_DEADLINE", 0);
        vwEndOperation(mob);
        DespawnMob(mob:getID());
        return;
    end
    local warned = mob:getLocalVar("VW_WARNED");
    local marks = {600, 300, 120, 60, 30, 10};
    for _, s in ipairs(marks) do
        if (left <= s and warned > s) then
            mob:setLocalVar("VW_WARNED", s);
            if (s >= 60) then notify(mob, VW_MINUTES_REMAINING, s / 60);
            else notify(mob, VW_SECONDS_REMAINING, s); end
            break;
        end
    end
end

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    mob:setMod(MOD_EVA, 150);          -- [W] "very high evasion"; amount is a [D] guess
    mob:setMod(MOD_TRIPLE_ATTACK, 10); -- [W] triple attack, "levels up at 50% and 25%"; 10% base is a [D] guess
    mob:setLocalVar("TA_TIER", 0);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    -- [W] Triple Attack trait levels up at 50% and 25% HP (BG wiki Sarimanok); +10 per tier is a [D] guess
    local hpp, tier = mob:getHPP(), mob:getLocalVar("TA_TIER");
    local want = (hpp < 25) and 2 or ((hpp < 50) and 1 or 0);
    if (want > tier) then
        mob:addMod(MOD_TRIPLE_ATTACK, 10 * (want - tier));
        mob:setLocalVar("TA_TIER", want);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17191335;
    vwOnKill(mob, player, {
        cruor = 5000, -- Crimson I base [W: Cottus T1 5000]; 0% alignment
        pyxisId = 17191580 + idx,
        drops = {11813}, -- Chimera Hairpin [BG thread #203, player drop report]; id checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_READINESS, -- 1796 [V client DAT]
        msgKeyItem = 11174,
        msgCruor = 11170, msgFinalBR = 11167, msgFinalYG = 11165, msgFinalW = 11166,
    });
end;
