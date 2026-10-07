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
    -- [J, BG #613/#646] Giant (Briareos-like), Double Attack, no spells; occasional ranged attack (auto). Stun sometimes fails [J].
    mob:setMod(MOD_DOUBLE_ATTACK, 10); -- [J] trait; amount [D]
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17109718;
    vwOnKill(mob, player, {
        region = "THREE", stage = 1, -- [F] stage table; cruor/EXP base
        pyxisId = 17109853 + idx,
        drops = {11667}, -- Roller's Ring [BG #248/#289, F]; id checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_READINESS, -- 1796 [J, BG]
        msgKeyItem = 8193,
        msgCruor = 8189, msgFinalBR = 8186, msgFinalYG = 8184, msgFinalW = 8185,
    });
end;
