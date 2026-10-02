-----------------------------------------
-- ID: 5395
-- Item: bottle_of_clerics_drink
-- Item Effect: BG Wiki: "Divine Veil+Erase+Na-Spells" (removes most negative status ailments).
-- Ported from Topaz's own working scripts/globals/items/bottle_of_clerics_drink.lua, which reuses
-- Topaz's own already-real removable-effects list (same one as flask_of_panacea.lua) rather than
-- LandSandBoat's itemUtils.removableEffects (doesn't exist in either codebase). Topaz's version
-- applies this to nearby party members via forMembersInRange -- THAT BINDING DOES NOT EXIST in
-- old-dsp-reference (confirmed absent, grep-verified against src/map/lua/lua_baseentity.cpp), so
-- this port is intentionally SELF-ONLY, matching old-dsp-reference's own real
-- scripts/globals/items/flask_of_panacea.lua (which has the exact same self-only limitation in
-- this codebase already) -- a real, confirmed scope reduction versus the wiki's real party-wide
-- effect, not a bug.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    target:delStatusEffect(EFFECT_PARALYSIS);
    target:delStatusEffect(EFFECT_BIND);
    target:delStatusEffect(EFFECT_WEIGHT);
    target:delStatusEffect(EFFECT_ADDLE);
    target:delStatusEffect(EFFECT_BURN);
    target:delStatusEffect(EFFECT_FROST);
    target:delStatusEffect(EFFECT_CHOKE);
    target:delStatusEffect(EFFECT_RASP);
    target:delStatusEffect(EFFECT_SHOCK);
    target:delStatusEffect(EFFECT_DROWN);
    target:delStatusEffect(EFFECT_DIA);
    target:delStatusEffect(EFFECT_BIO);
    target:delStatusEffect(EFFECT_STR_DOWN);
    target:delStatusEffect(EFFECT_DEX_DOWN);
    target:delStatusEffect(EFFECT_VIT_DOWN);
    target:delStatusEffect(EFFECT_AGI_DOWN);
    target:delStatusEffect(EFFECT_INT_DOWN);
    target:delStatusEffect(EFFECT_MND_DOWN);
    target:delStatusEffect(EFFECT_CHR_DOWN);
    target:delStatusEffect(EFFECT_MAX_HP_DOWN);
    target:delStatusEffect(EFFECT_MAX_MP_DOWN);
    target:delStatusEffect(EFFECT_ATTACK_DOWN);
    target:delStatusEffect(EFFECT_EVASION_DOWN);
    target:delStatusEffect(EFFECT_DEFENSE_DOWN);
    target:delStatusEffect(EFFECT_MAGIC_DEF_DOWN);
    target:delStatusEffect(EFFECT_INHIBIT_TP);
    target:delStatusEffect(EFFECT_MAGIC_ACC_DOWN);
    target:delStatusEffect(EFFECT_MAGIC_ATK_DOWN);
end;
