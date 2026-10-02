-----------------------------------
-- Area: Halvung
-- MOB:  Wamouracampa
-----------------------------------
require("scripts/globals/status");
require("scripts/mixins/families/wamoura")

-- TODO: Damage resistances in streched and curled stances. Halting movement during stance change.
-- 2026-09-14: "Morph into Wamoura" -- was an unimplemented TODO on both Topaz and this codebase
-- (confirmed identical stub on both), never a DSP-specific regression. Wired to WamouraMix
-- (scripts/mixins/families/wamoura.lua) below -- see that file's header for the full real
-- mechanic/model-id/duration sourcing.

-----------------------------------
-- OnMobSpawn Action
-----------------------------------

function onMobSpawn(mob)
    mob:setLocalVar("formTime", os.time() + math.random(43,47));
    -- real level range for this zone's Wamouracampa group is 73-76 (sql/mob_groups.sql,
    -- groupid 2128/poolid 4281) -- only a spawn assigned the top of that range (76) is eligible
    -- to mature at all, per user direction.
    WamouraMix.onSpawn(mob, 76)
end;

-----------------------------------
-- onMobRoam Action
-- Autochange stance + check for maturation into Wamoura
-----------------------------------

function onMobRoam(mob)
    local roamTime = mob:getLocalVar("formTime");
    if (mob:AnimationSub() == 0 and os.time() > roamTime) then
        mob:AnimationSub(1);
        mob:setLocalVar("formTime", os.time() + math.random(43,47));
    elseif (mob:AnimationSub() == 1 and os.time() > roamTime) then
        mob:AnimationSub(0);
        mob:setLocalVar("formTime", os.time() + math.random(43,47));
    end
    WamouraMix.onRoam(mob)
end;

-----------------------------------
-- OnMobFight Action
-- Stance change in battle + delay maturation while engaged
-----------------------------------
function onMobFight(mob,target)
    local fightTime = mob:getLocalVar("formTime");
    if (mob:AnimationSub() == 0 and os.time() > fightTime) then
        mob:AnimationSub(1);
        mob:setLocalVar("formTime", os.time() + math.random(43,47));
    elseif (mob:AnimationSub() == 1 and os.time() > fightTime) then
        mob:AnimationSub(0);
        mob:setLocalVar("formTime", os.time() + math.random(43,47));
    end
    WamouraMix.onFight(mob, target)
end;

function onMobDeath(mob)
end;