-----------------------------------
-- Voidwatch drop overrides. Managed by the Mission Toolkit Voidwatch domain (or edit by hand).
-- pool       : item ids ADDED to the shared Pyxis filler pool
-- poolRemove : item ids removed from the shared filler pool (including the built-in placeholder list)
-- nm[name]   : keyed by the mob's script name (mob:getName()); add = {[itemid] = percent}, remove = {itemid, ...}
-----------------------------------
VW_DROP_OVERRIDES = {
    pool = {},
    poolRemove = {},
    nm = {},
};
