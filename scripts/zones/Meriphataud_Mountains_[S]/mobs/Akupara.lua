-----------------------------------
-- Area: Meriphataud Mountains [S] (97)
--  MOB: Akupara (Voidwatch, Jade III)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z190 ids + 697 [V: z97 dialog.yml text-checked 2026-10-07].
-- Evidence: [J] wikiwiki.jp, [B] BG forum, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8078;
local VW_MINUTES_REMAINING   = 8079;
local VW_SECONDS_REMAINING   = 8080;
local VW_TIME_UP             = 8081;
local VW_FADES               = 8082;
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

local VWMSG = {msgWeakElem = 8192, msgBlitzOn = 8199, msgBlitzOff = 8200, msgBlitzGain = 8201, msgBR = 8202, msgW = 8203};

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
    -- [J] double attack, evasion not high. Amount [D].
    mob:setMod(MOD_DOUBLE_ATTACK, 20);
end;

-- Spells [J]: common Slowga/Breakga; >=50% Stone IV + Stonega III; <50% Stone V + Stonega IV + Stoneja.
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    local pool = {357, 365};
    if (mob:getHPP() >= 50) then
        table.insert(pool, 162); table.insert(pool, 191);
    else
        table.insert(pool, 163); table.insert(pool, 192); table.insert(pool, 499);
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
    local idx = mob:getID() - 17175250;
    vwOnKill(mob, player, {
        region = "THREE", stage = 3, -- cruor/EXP base by stage [F]
        pyxisId = 17175425 + idx,
        drops = {3448, 10970, 17923},
        keyitem = ATMACITE_OF_TEMPERANCE, -- DSP keyitems.lua name; client-id check pending
        msgKeyItem = 8176,
        msgCruor = 8172, msgFinalBR = 8169, msgFinalYG = 8167, msgFinalW = 8168,
    });
end;
