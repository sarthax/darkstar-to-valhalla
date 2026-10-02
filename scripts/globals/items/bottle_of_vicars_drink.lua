-----------------------------------------
-- ID: 5439
-- Item: bottle_of_vicars_drink
-- Item Effect: Removes 2 random status ailments -- confirmed via real BG Wiki excerpt supplied
-- 2026-09-14. No Topaz source exists for this item (confirmed absent by direct file check); no
-- "remove N random effects" binding/precedent exists anywhere in old-dsp-reference either
-- (grep-verified) -- built from scratch: picks 2 distinct ailments (without replacement) from the
-- exact same real, already-confirmed ailment list old-dsp-reference's own
-- scripts/globals/items/flask_of_panacea.lua uses, then delStatusEffect's just those 2 (real,
-- already-real binding -- no invented mechanism).
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
local AILMENTS =
{
    EFFECT_PARALYSIS, EFFECT_BIND, EFFECT_WEIGHT, EFFECT_ADDLE, EFFECT_BURN, EFFECT_FROST,
    EFFECT_CHOKE, EFFECT_RASP, EFFECT_SHOCK, EFFECT_DROWN, EFFECT_DIA, EFFECT_BIO,
    EFFECT_STR_DOWN, EFFECT_DEX_DOWN, EFFECT_VIT_DOWN, EFFECT_AGI_DOWN, EFFECT_INT_DOWN,
    EFFECT_MND_DOWN, EFFECT_CHR_DOWN, EFFECT_MAX_HP_DOWN, EFFECT_MAX_MP_DOWN,
    EFFECT_ATTACK_DOWN, EFFECT_EVASION_DOWN, EFFECT_DEFENSE_DOWN, EFFECT_MAGIC_DEF_DOWN,
    EFFECT_INHIBIT_TP, EFFECT_MAGIC_ACC_DOWN, EFFECT_MAGIC_ATK_DOWN,
};

function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    -- Only offer/remove ailments the target actually has, so "removes 2 random status ailments"
    -- doesn't burn both picks on effects that were never present.
    local active = {};
    for _, effect in ipairs(AILMENTS) do
        if (target:hasStatusEffect(effect)) then
            table.insert(active, effect);
        end
    end

    for i = 1, math.min(2, #active) do
        local pick = math.random(1, #active);
        target:delStatusEffect(active[pick]);
        table.remove(active, pick);
    end
end;
