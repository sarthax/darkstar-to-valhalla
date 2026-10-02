-----------------------------------
-- ID: 5348
-- Alzadaal Fireflies
-- Transports the user to Nyzul Isle Staging Point
-----------------------------------
-- 2026-09-14: this file's original draft used LandSandBoat-shaped references
-- (TELEPORT_ID.ALZADAAL, a NYZUL_ISLE bare-global zone constant) that don't exist in
-- old-dsp-reference -- corrected to match the real, already-working sibling
-- cage_of_zhayolm_fireflies.lua: bare FIREFLIES_* constant (teleports.lua) and a literal zone id
-- (77, confirmed via sql/zone_settings.sql: `Nyzul_Isle`), not a named zone constant (none exists
-- for per-zone ids in this codebase).
-----------------------------------
require("scripts/globals/teleports")
require("scripts/globals/status")
-----------------------------------
function onItemCheck(target)
    if (target:getZoneID() == 77) then
        return 0
    end
    return 56
end

function onItemUse(target)
    target:addStatusEffectEx(EFFECT_TELEPORT, 0, FIREFLIES_ALZADAAL, 0, 1)
end

