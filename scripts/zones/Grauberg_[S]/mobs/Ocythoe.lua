-----------------------------------
-- Area: Grauberg_[S] (89)
--  MOB: Ocythoe (Voidwatch, Jeuno Stage VI / White VI [S] -- BASE NM, PLACEHOLDER)
-- Base build: timer/cleanup/weakness/lights framework only. NO drops. Skills/spells: see sql/slices/voidwatch-vwnm/jeuno_vi_s_skills.sql (effects [D]).
-- Message ids = Valkurm z103 ids -3033, every id text-matched against this zone's fresh dialog.yml [V 2026-10-09].
-- UNVERIFIED [D]: abyssite/stone gating (placeholder = White VI like Ig-Alima/Botulus), level, HP, mods, skill/spell lists.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/voidwatch_ki");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8421;
local VW_MINUTES_REMAINING   = 8422;
local VW_SECONDS_REMAINING   = 8423;
local VW_TIME_UP             = 8424;
local VW_FADES               = 8425;
local LIMIT = 1800; -- 30 min [C, Ig-Alima/Botulus]; unverified for this NM

local function notify(mob, msgid, param)
    local p = GetPlayerByID(mob:getLocalVar("VW_SPAWNER"));
    if (p == nil or p:getZoneID() ~= mob:getZoneID()) then return; end
    for _, m in pairs(p:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID()) then
            m:messageSpecial(msgid, param or 0);
        end
    end
end

local VWMSG = {msgWeakElem = 8535, msgBlitzOn = 8542, msgBlitzOff = 8543, msgBlitzGain = 8544, msgBR = 8545, msgW = 8546};

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
end;

-- Spells [B forum, tiers [D]]: Thunder/Water IV + -ga III at >=50% HP; V + -ga IV + -ja below.
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    return vwPick(mob, target, (mob:getHPP() >= 50) and {167, 196} or {168, 197, 500});
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17142449;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 6, -- White VI [D placeholder]; cruor base per Ig-Alima (forum says 7,500 for this NM, unverified)
        atmacite = {1824}, -- white-light drop ATMACITE_OF_SKYBLAZE [W/J, ATMACITE-DATA.md]
        pyxisId = 17142621 + idx,
        -- NO drops / dropRates: base NM (pyxis contents added once drop tables are sourced)
        msgKeyItem = 8519,
        msgCruor = 8515, msgFinalBR = 8512, msgFinalYG = 8510, msgFinalW = 8511,
    });
end;
