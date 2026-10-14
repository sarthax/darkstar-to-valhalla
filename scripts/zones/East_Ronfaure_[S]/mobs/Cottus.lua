-----------------------------------
-- Area: East Ronfaure [S] (81)
--  MOB: Cottus (Voidwatch, Crimson I, [S] zone)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids -301 [V: z81 dialog.yml text-checked].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8095;
local VW_MINUTES_REMAINING   = 8096;
local VW_SECONDS_REMAINING   = 8097;
local VW_TIME_UP             = 8098;
local VW_FADES               = 8099;
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

local VWMSG = {msgWeakElem = 8209, msgBlitzOn = 8216, msgBlitzOff = 8217, msgBlitzGain = 8218, msgBR = 8219, msgW = 8220};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
    return 0;
end;

function onWeaponskillHit(mob, attacker, wsid)
    vwOnWeaponskillHit(mob, attacker, wsid, VWMSG);
    return 0;
end

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
    -- [J, BG #613/#646] Giant (Briareos-like), Double Attack, no spells; occasional ranged attack (auto). Stun sometimes fails [J].
    mob:setMod(MOD_DOUBLE_ATTACK, 10); -- [J] trait; amount [D]
end;

function onMobRoam(mob) tick(mob); end;

-- Mercurial Strike chain [W]: every ~45s, follow-up chosen by the damage value rolled (mercurial_strike.lua sets MS_VAL).
local FOLLOW = {[111]=664, [222]=665, [333]=665, [444]=666, [555]=1636, [666]=1636, [777]=2576, [888]=2578, [999]=2578};

function onMobFight(mob, target)
    tick(mob);
    local chain = mob:getLocalVar("MS_CHAIN");
    if (chain == 1 and mob:getTP() >= 0) then
        mob:setLocalVar("MS_CHAIN", 0);
        local v = mob:getLocalVar("MS_VAL");
        if (v == 1111) then
            mob:addStatusEffect(EFFECT_MEIKYO_SHISUI, 1, 0, 30);
            for i = 1, 3 do mob:useMobAbility(2578); end
        elseif (FOLLOW[v]) then
            if (v == 777) then target:resetRecasts(); end
            mob:useMobAbility(FOLLOW[v]);
        end
    elseif (os.time() - mob:getLocalVar("MS_T") >= 45 and mob:getHPP() < 100) then
        mob:setLocalVar("MS_T", os.time());
        mob:useMobAbility(2576);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17109718;
    vwOnKill(mob, player, {
        region = "THREE", stage = 1, -- [F] stage table; cruor/EXP base
        pyxisId = 17109853 + idx,
        drops = {11667}, -- Roller's Ring [BG #248/#289, F]; id checked vs DSP item_basic
        msgCruor = 8189, msgFinalBR = 8186, msgFinalYG = 8184, msgFinalW = 8185,
    });
    -- Periapt is guaranteed on every Pyxis [C Raguza 2021.03.27, BG #6]; granted here, not via the random cfg.keyitem path.
    for _, m in pairs(player:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID() and not m:hasKeyItem(VIVID_PERIAPT_OF_READINESS)) then
            m:addKeyItem(VIVID_PERIAPT_OF_READINESS); -- 1796 [J, BG]
            m:messageSpecial(8193, VIVID_PERIAPT_OF_READINESS);
        end
    end
end;
