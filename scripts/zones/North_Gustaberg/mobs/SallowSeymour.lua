-----------------------------------
-- Area: North Gustaberg (106)
--  MOB: Sallow Seymour (Voidwatch, Indigo I, [S] zone)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids +3198 [V: z106 dialog.yml text-checked].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11594;
local VW_MINUTES_REMAINING   = 11595;
local VW_SECONDS_REMAINING   = 11596;
local VW_TIME_UP             = 11597;
local VW_FADES               = 11598;
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

local VWMSG = {msgWeakElem = 11708, msgBlitzOn = 11715, msgBlitzOff = 11716, msgBlitzGain = 11717, msgBR = 11718, msgW = 11719};

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
    -- [J, F] Amorph/Worm (Entozoan): does not move, Double Attack, immune to Silence (pool immunity), Draw In [BG #7, J]
    mob:setMod(MOD_DOUBLE_ATTACK, 10); -- [J] trait; amount [D]
    mob:setMobMod(MOBMOD_DRAW_IN, 1);  -- [BG #7] uses Draw In; engine mod pulls the target when out of reach (retail trigger [D])
end;

-- Spells [J wikiwiki.jp Sallow Seymour]: Rasp, Slowga, Stonega II-III, Stone IV, Stoneja; + Breakga at HP <=30%. Cast rate/gaps [D].
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end -- [D] no spells just after spawn (as Virvatuli [J])
    local pool = {238, 357, 190, 191, 162, 499};
    if (mob:getHPP() <= 30) then table.insert(pool, 365); end
    return pool[math.random(#pool)];
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17211882;
    vwOnKill(mob, player, {
        cruor = 5000, -- [D] same as other tier-I NMs; no Sallow Seymour cruor capture checked
        pyxisId = 17212119 + idx,
        drops = {10929}, -- Apathy Gorget [F, J]; id checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_EXPLORATION, -- 1783 [J, BG]
        msgKeyItem = 11692,
        msgCruor = 11688, msgFinalBR = 11685, msgFinalYG = 11683, msgFinalW = 11684,
    });
end;
