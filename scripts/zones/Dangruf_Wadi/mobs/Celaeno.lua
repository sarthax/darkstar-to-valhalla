-----------------------------------
-- Area: Dangruf Wadi (191)
--  MOB: Celaeno (Voidwatch, Indigo IV)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight (open-zone mob, no instance).
-- Message ids anchored on "fiend materializes" = 7515 [V: z191 dialog.yml text-checked].
-- Evidence: [C] capture, [F] FFXIclopedia, [J] wikiwiki.jp, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
require("scripts/globals/keyitems");
local VW_MINUTES_TO_COMPLETE = 7501;
local VW_MINUTES_REMAINING   = 7502;
local VW_SECONDS_REMAINING   = 7503;
local VW_TIME_UP             = 7504;
local VW_FADES               = 7505;
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

local VWMSG = {msgWeakElem = 7615, msgBlitzOn = 7622, msgBlitzOff = 7623, msgBlitzGain = 7624, msgBR = 7625, msgW = 7626};

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
    -- BLM main job defaults to HP_STANDBACK 70; Voidwatch NMs must close to melee (precedent: Hahava).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
end;

-- Spells [C capture]: 498, 366, 187, 357, 359
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    return vwPick(mob, target, {498, 366, 187, 357, 359});
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);
    vwEndOperation(mob);
    local idx = mob:getID() - 17559871;
    vwOnKill(mob, player, {
        region = "THREE", stage = 4, -- stage = Indigo tier
        pyxisId = 17559932 + idx,
        dropRates = {[11856] = 0.76, [17360] = 1.76, [17273] = 13.8, [3449] = 0.82, [2875] = 0.06, [3510] = 27.5}, -- percent [U/F]
        keyitem = ATMACITE_OF_ENTICEMENT, -- DSP keyitems.lua name; client-id check pending
        msgKeyItem = 7599,
        msgCruor = 7595, msgFinalBR = 7592, msgFinalYG = 7590, msgFinalW = 7591,
    });
end;
