-----------------------------------
-- Area: West Sarutabaruta
--  MOB: Virvatuli (Voidwatch, Jade I)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = Sarimanok + 386 [V: z115 dialog.yml text-checked].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11462;
local VW_MINUTES_REMAINING   = 11463;
local VW_SECONDS_REMAINING   = 11464;
local VW_TIME_UP             = 11465;
local VW_FADES               = 11466;
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

local VWMSG = {msgWeakElem = 11576, msgBlitzOn = 11583, msgBlitzOff = 11584, msgBlitzGain = 11585, msgBR = 11586, msgW = 11587};

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
    mob:setMod(MOD_DOUBLE_ATTACK, 10); -- [W] "Has Double Attack"; amount [D]
    mob:setMod(MOD_DMGMAGIC, -50);     -- [W] 60% reduced magic damage; engine caps at -50 [D]
end;

-- Spell tiers [J wikiwiki.jp Virvatuli]: common Slowga/Dispelga/Bindga/Graviga/Sleepga; HP>=50% Blizzard IV, Blizzaga III;
-- <50% Blizzard V, Blizzaga IV; <=30% + Blizzaja, Breakga, Death. No casting right after spawn. Silencega [C], Addle [F] added to common.
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end -- [J] no spells just after spawn; 10s is [D]
    local pool = {357, 360, 362, 366, 273, 359, 286};
    local hpp = mob:getHPP();
    local extra;
    if (hpp >= 50) then extra = {152, 181};
    elseif (hpp > 30) then extra = {153, 182};
    else extra = {153, 182, 497, 365, 367}; end
    for _, sp in ipairs(extra) do table.insert(pool, sp); end
    return pool[math.random(#pool)];
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17248625;
    vwOnKill(mob, player, {
        region = "THREE", stage = 1, -- [F] stage table; cruor/EXP base
        pyxisId = 17248947 + idx,
        drops = {11668}, -- Irrwisch Ring [BG thread #201]; id checked vs DSP item_basic
        petrifact = true, -- Jade (Windurst) path: Maddening Petrifact rare [U 2026-10-07]
        keyitem = VIVID_PERIAPT_OF_CONCENTRATION, -- 1788 [BG #137]
        msgKeyItem = 11560,
        msgCruor = 11556, msgFinalBR = 11553, msgFinalYG = 11551, msgFinalW = 11552,
    });
end;
