-----------------------------------
-- Ability: Odyllic Subterfuge (slice run-geo-jobs)
-- Greatly reduces the target's magic accuracy; job points add a Magic Attack Bonus reduction.
-- LSB has no script, so values are designed from the BG Wiki and are tunable.
-----------------------------------

require("scripts/globals/status");

local ODYLLIC_DURATION     = 30;   -- seconds
local ODYLLIC_MACC_DOWN    = 100;  -- magic accuracy reduction (tunable)
local ODYLLIC_MATT_PER_JP  = 2;    -- magic attack bonus reduction per job point rank
local ODYLLIC_MATT_MAX     = 40;

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    local jp = player:getJobPointLevel(JP_ODYLLIC_SUBTER_EFFECT or 0) or 0;
    local matt = math.min(jp * ODYLLIC_MATT_PER_JP, ODYLLIC_MATT_MAX);
    if (target:hasStatusEffect(EFFECT_ODYLLIC_SUBTERFUGE)) then
        target:delStatusEffectSilent(EFFECT_ODYLLIC_SUBTERFUGE);
    end
    target:addStatusEffect(EFFECT_ODYLLIC_SUBTERFUGE, ODYLLIC_MACC_DOWN, 0, ODYLLIC_DURATION, 0, matt);
    return EFFECT_ODYLLIC_SUBTERFUGE;
end;
