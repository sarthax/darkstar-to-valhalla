-----------------------------------
-- Area: Ru'Aun Gardens
--  MOB: Aello (Voidwatch, Ashen III)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids from research/MESSAGE-IDS-SLICE-ZONES.md
-- (anchor verified, offsets inferred).
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 10785;
local VW_MINUTES_REMAINING   = 10786;
local VW_SECONDS_REMAINING   = 10787;
local VW_TIME_UP             = 10788;
local VW_FADES               = 10789;
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

local VWMSG = {msgWeakElem = 10899, msgBlitzOn = 10906, msgBlitzOff = 10907, msgBlitzGain = 10908, msgBR = 10909, msgW = 10910};

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
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    -- Handmaiden resummon: when any is dead Aello uses Shrieking Gale (dispel + hate reset + resummon) [forum #1140]
    if (os.time() - mob:getLocalVar("GALE_T") >= 30) then
        for i = 1, 3 do
            local h = GetMobByID(mob:getID() + i);
            if (h ~= nil and not h:isSpawned()) then
                mob:setLocalVar("GALE_T", os.time());
                mob:useMobAbility(2726); -- shrieking_gale
                break;
            end
        end
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = (mob:getID() - 17309985) / 4;
    vwOnKill(mob, player, {
        cruor = 6000, -- [D] Zilart base 5000/7000-8000 per wiki digest; exact Ashen III value unverified (Wiggo capture p6 holds cruor total, not reward)
        pyxisId = 17310114 + idx,
        drops = {11035, 11964}, -- Strophadic Earring, Whirlwind Dirs [W: BG wiki Aello 5% each]; ids checked vs DSP item_basic
        msgKeyItem = 10883,
        msgCruor = 10879, msgFinalBR = 10876, msgFinalYG = 10874, msgFinalW = 10875,
    });
end;
