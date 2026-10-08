-----------------------------------
-- Area: La Theine Plateau (102)
--  MOB: Stachysaurus (Voidwatch, Jeuno Stage V / White V)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z118 ids - 2 [V: z102 dialog.yml text-checked, 96 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11445;
local VW_MINUTES_REMAINING   = 11446;
local VW_SECONDS_REMAINING   = 11447;
local VW_TIME_UP             = 11448;
local VW_FADES               = 11449;
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

local VWMSG = {msgWeakElem = 11559, msgBlitzOn = 11566, msgBlitzOff = 11567, msgBlitzGain = 11568, msgBR = 11569, msgW = 11570};

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

-- No spells [F: no MP]; physical-only NM.
function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17195494;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 5, -- [C] White V; 7000 cruor base [W]
        pyxisId = 17195693 + idx,
        drops = {10500, 10881, 10879, 3500}, -- Ogier's Gauntlets, Brego Helm, Hreysti Helm, Chunk of Riftsand [F]; ids vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_GLORY, -- DSP id 1790 [F]; client-id check pending
        msgKeyItem = 11543,
        msgCruor = 11539, msgFinalBR = 11536, msgFinalYG = 11534, msgFinalW = 11535,
    });
end;
