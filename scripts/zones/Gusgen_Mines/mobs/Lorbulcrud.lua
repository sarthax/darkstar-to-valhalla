-----------------------------------
-- Area: Gusgen Mines (196)
--  MOB: Lorbulcrud (Voidwatch, Indigo II)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight (open-zone mob, no instance).
-- Message ids anchored on "fiend materializes" = 7447 [V: z196 dialog.yml text-checked].
-- Evidence: [C] capture, [F] FFXIclopedia, [J] wikiwiki.jp, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
require("scripts/globals/keyitems");
local VW_MINUTES_TO_COMPLETE = 7433;
local VW_MINUTES_REMAINING   = 7434;
local VW_SECONDS_REMAINING   = 7435;
local VW_TIME_UP             = 7436;
local VW_FADES               = 7437;
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

local VWMSG = {msgWeakElem = 7547, msgBlitzOn = 7554, msgBlitzOff = 7555, msgBlitzGain = 7556, msgBR = 7557, msgW = 7558};

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

-- Spells [C capture]: 286, 172, 359, 186, 157
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    return vwPick(mob, target, {286, 172, 359, 186, 157});
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);
    vwEndOperation(mob);
    local idx = mob:getID() - 17580342;
    vwOnKill(mob, player, {
        region = "THREE", stage = 2, -- stage = Indigo tier
        pyxisId = 17580413 + idx,
        drops = {10930, 17112}, -- Veisa Collar, Fulcrum Pole [F]
        keyitem = DUSKY_PERIAPT_OF_READINESS, -- DSP keyitems.lua name; client-id check pending
        msgKeyItem = 7531,
        msgCruor = 7527, msgFinalBR = 7524, msgFinalYG = 7522, msgFinalW = 7523,
    });
end;
