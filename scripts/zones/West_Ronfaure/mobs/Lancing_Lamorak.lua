-----------------------------------
-- Area: West Ronfaure (100)
--  MOB: Lancing Lamorak (Voidwatch, Jeuno Stage IV / White IV)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids + 3051 [V: z100 dialog.yml text-checked, spot-checked 11550/11554/11564/11641/11644/11648/11664/11671/11675].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11550;
local VW_MINUTES_REMAINING   = 11551;
local VW_SECONDS_REMAINING   = 11552;
local VW_TIME_UP             = 11553;
local VW_FADES               = 11554;
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

local VWMSG = {msgWeakElem = 11664, msgBlitzOn = 11671, msgBlitzOff = 11672, msgBlitzGain = 11673, msgBR = 11674, msgW = 11675};

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
    -- BLM main job defaults to HP_STANDBACK 70 (mobutils SetupJob): mob would stay at range above 70% HP.
    -- Voidwatch NMs must close to melee; -1 disables standback (precedent: Bahamut).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
end;

-- [F] casts Aero V, Aeroga IV, Aeroja, Silencega; gains 5+ shadows after any TP move or spell. Spell choice [D].
-- Shadows are applied here for spells and in rhinowrecker.lua for that TP move [D: 3 images; count unconfirmed].
local function addShadows(mob)
    mob:delStatusEffect(EFFECT_COPY_IMAGE);
    mob:addStatusEffect(EFFECT_COPY_IMAGE, 3, 0, 300);
end

function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    addShadows(mob);
    local pool = {158, 187, 498, 359};
    return vwPick(mob, target, pool);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17187289;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 4, -- [C] White IV; 6500 cruor base [W], -- [C] White IV; 
        pyxisId = 17187590 + idx,
        drops = {10601, 10988, 10503, 3500}, -- Athos's Boots, Blithe Mantle, Brego Gloves, Chunk of Riftsand [F]; ids vs DSP item_basic
        dropRates = {[10601]=5.2, [10988]=26.5, [10503]=2.6, [3500]=25.8}, -- Athos's Boots, Blithe Mantle, Brego Gloves, Riftsand [U 2026-10-07, % per item]
        keyitem = VIVID_PERIAPT_OF_CATALYSIS, -- DSP id 1781 [F]; client-id check pending
        msgKeyItem = 11648,
        msgCruor = 11644, msgFinalBR = 11641, msgFinalYG = 11639, msgFinalW = 11640,
    });
end;
