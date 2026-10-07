-----------------------------------
-- Area: Tahrongi Canyon (117)
--  MOB: Smierc (Voidwatch, Jeuno Stage V / White V)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z118 ids - 393 [V: z117 dialog.yml text-checked, 96 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11054;
local VW_MINUTES_REMAINING   = 11055;
local VW_SECONDS_REMAINING   = 11056;
local VW_TIME_UP             = 11057;
local VW_FADES               = 11058;
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

local VWMSG = {msgWeakElem = 11168, msgBlitzOn = 11175, msgBlitzOff = 11176, msgBlitzGain = 11177, msgBR = 11178, msgW = 11179};

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

-- [F] Impact, Comet, Quick Magic Meteor, and -ja spells at low HP; Comet [C]. Rates/thresholds [D].
-- Quick Magic ability id unconfirmed -> Meteor is cast normally (see UNIMPLEMENTED.md).
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    if (mob:getHPP() < 30) then
        local ja = {496, 497, 498, 499, 500, 501};
        return ja[math.random(#ja)];
    end
    local pool = {503, 219, 218};
    return pool[math.random(#pool)];
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17256919;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 5, -- [C] White V; 7000 cruor base [W]
        pyxisId = 17257091 + idx,
        drops = {10501, 18907, 10453, 3500}, -- Athos's Gloves, Devourer, Praeco Doublet, Chunk of Riftsand [F]; ids vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_GLORY, -- DSP id 1790 [F]; client-id check pending
        msgKeyItem = 11152,
        msgCruor = 11148, msgFinalBR = 11145, msgFinalYG = 11143, msgFinalW = 11144,
    });
end;
