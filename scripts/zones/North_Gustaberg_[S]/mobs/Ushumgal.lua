-----------------------------------
-- Area: North Gustaberg [S] (88)
--  MOB: Ushumgal (Voidwatch, Indigo I)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight (open-zone mob, no instance).
-- Message ids anchored on "fiend materializes" = 8228 [V: z88 dialog.yml text-checked].
-- Evidence: [C] capture, [F] FFXIclopedia, [J] wikiwiki.jp, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
require("scripts/globals/keyitems");
local VW_MINUTES_TO_COMPLETE = 8214;
local VW_MINUTES_REMAINING   = 8215;
local VW_SECONDS_REMAINING   = 8216;
local VW_TIME_UP             = 8217;
local VW_FADES               = 8218;
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

local VWMSG = {msgWeakElem = 8328, msgBlitzOn = 8335, msgBlitzOff = 8336, msgBlitzGain = 8337, msgBR = 8338, msgW = 8339};

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

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);
    vwEndOperation(mob);
    local idx = mob:getID() - 17138408;
    vwOnKill(mob, player, {
        region = "THREE", stage = 1, -- stage = Indigo tier
        pyxisId = 17138609 + idx,
        drops = {11770, 2524, 703}, -- Accursed Belt, Peiste Stinger, Petrified Log [F]
        keyitem = VIVID_PERIAPT_OF_EXPLORATION, -- DSP keyitems.lua name; client-id check pending
        msgKeyItem = 8312,
        msgCruor = 8308, msgFinalBR = 8305, msgFinalYG = 8303, msgFinalW = 8304,
    });
end;
