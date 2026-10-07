-----------------------------------
-- Area: Meriphataud Mountains (119)
--  MOB: Lord Asag (Voidwatch, Jade III / Windurst Stage III)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids + 3346 [V: z119 dialog.yml text-checked, 149 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11742;
local VW_MINUTES_REMAINING   = 11743;
local VW_SECONDS_REMAINING   = 11744;
local VW_TIME_UP             = 11745;
local VW_FADES               = 11746;
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

local VWMSG = {msgWeakElem = 11856, msgBlitzOn = 11863, msgBlitzOff = 11864, msgBlitzGain = 11865, msgBR = 11866, msgW = 11867};

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
    -- [F] high evasion; amount [D]. Ice/dark resist and magic damage cut [F]; amounts [D].
    mob:setMod(MOD_EVA, 60);
    mob:setMod(MOD_ICERES, 50);
    mob:setMod(MOD_DARKRES, 50);
    mob:setMod(MOD_UDMGMAGIC, -25);
end;

-- [J,F] spells by HP tier
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    local pool;
    if (mob:getHPP() >= 50) then
        pool = {359, 356, 286, 147, 176};
    else
        pool = {367, 148, 177, 496};
    end
    return pool[math.random(#pool)];
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17265130;
    vwOnKill(mob, player, {
        region = "THREE", stage = 3, -- [C] Jade III capture, 6000 cruor base; Windurst Stage III
        pyxisId = 17265318 + idx,
        drops = {18810, 18539, 3510}, -- Cadushi Grip, Tonatiuh Axe, Silver Mirror [F]; ids vs DSP item_basic
        keyitem = ATMACITE_OF_DESTRUCTION, -- DSP id 1812; client-id check pending
        msgKeyItem = 11840,
        msgCruor = 11836, msgFinalBR = 11833, msgFinalYG = 11831, msgFinalW = 11832,
    });
end;
