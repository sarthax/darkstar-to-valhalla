-----------------------------------
-- Area: West Sarutabaruta [S] (95)
--  MOB: Pancimanci (Voidwatch, Jade I, [S] zone)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z115 ids - 3066 [V: z95 dialog.yml text-checked].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8396;
local VW_MINUTES_REMAINING   = 8397;
local VW_SECONDS_REMAINING   = 8398;
local VW_TIME_UP             = 8399;
local VW_FADES               = 8400;
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

local VWMSG = {msgWeakElem = 8510, msgBlitzOn = 8517, msgBlitzOff = 8518, msgBlitzGain = 8519, msgBR = 8520, msgW = 8521};

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
    -- [J wikiwiki.jp] monk-type: 2-3 attacks, counter/guard/kick; casts instantly (no cast time); immune to sleep (pool immunity)
    mob:setMod(MOD_COUNTER, 15);   -- [J] has counter; amount [D]
    mob:setMod(MOD_UFASTCAST, 100); -- [J] instant-cast spells
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17167113;
    vwOnKill(mob, player, {
        cruor = 5000, -- [D] same as Virvatuli (Jade I); no Pancimanci cruor capture checked
        pyxisId = 17167322 + idx,
        drops = {19761}, -- Impatiens [J loot page, F]; id checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_CONCENTRATION, -- 1788 [BG #137]
        msgKeyItem = 8494,
        msgCruor = 8490, msgFinalBR = 8487, msgFinalYG = 8485, msgFinalW = 8486,
    });
end;
