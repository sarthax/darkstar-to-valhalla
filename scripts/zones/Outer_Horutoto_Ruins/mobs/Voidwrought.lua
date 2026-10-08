-----------------------------------
-- Area: Outer Horutoto Ruins (194)
--  MOB: Voidwrought (Voidwatch, Jade IV)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z190 ids + 12 [V: z194 dialog.yml text-checked 2026-10-07].
-- Evidence: [J] wikiwiki.jp, [B] BG forum, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 7393;
local VW_MINUTES_REMAINING   = 7394;
local VW_SECONDS_REMAINING   = 7395;
local VW_TIME_UP             = 7396;
local VW_FADES               = 7397;
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

local VWMSG = {msgWeakElem = 7507, msgBlitzOn = 7514, msgBlitzOff = 7515, msgBlitzGain = 7516, msgBR = 7517, msgW = 7518};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
    return 0;
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

function onMobInitialize(mob)
    -- BLM main job defaults to HP_STANDBACK 70: Voidwatch NMs must close to melee (precedent: Bahamut).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    -- [J] double attack, high attack/defense, shock spikes while casting; fire/ice resist, weak to water/lightning. Amounts [D].
    mob:setMod(MOD_DOUBLE_ATTACK, 20);
    mob:setMod(MOD_ATTP, 20);
    mob:setMod(MOD_DEFP, 20);
    mob:setMod(MOD_FIRERES, 50);
    mob:setMod(MOD_ICERES, 50);
    mob:setMod(MOD_SPIKES, 5);          -- SPIKE_SHOCK
    mob:setMod(MOD_SPIKES_DMG, 100);
end;

-- Spells [J]: common Silencega/Slowga/Paralyga/Bindga/Dispelga/Graviga/Sleepga/Stun/Addle;
-- >=75% Thunder IV + Thundaga III; <75% Thunder V + Thundaga IV; <=50% also Thundaja.
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    local pool = {359, 357, 356, 362, 360, 366, 273, 252, 286};
    local hpp = mob:getHPP();
    if (hpp >= 75) then
        table.insert(pool, 167); table.insert(pool, 196);
    else
        table.insert(pool, 168); table.insert(pool, 197);
        if (hpp <= 50) then table.insert(pool, 500); end
    end
    return vwPick(mob, target, pool);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17572219;
    vwOnKill(mob, player, {
        region = "THREE", stage = 4, -- cruor/EXP base by stage [F]
        pyxisId = 17572306 + idx,
        drops = {3447, 11669, 10971, 11856},
        keyitem = ATMACITE_OF_DISCIPLINE, -- DSP keyitems.lua name; client-id check pending
        msgKeyItem = 7491,
        msgCruor = 7487, msgFinalBR = 7484, msgFinalYG = 7482, msgFinalW = 7483,
    });
end;
