-----------------------------------
-- Ability: flabra (Rune Fencer, Rune Enchantment rune)
-- Slice run-geo-jobs, ported from LSB.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    RUNEFENCER.useRuneEnchantment(player, target, ability, EFFECT_FLABRA);
end;
