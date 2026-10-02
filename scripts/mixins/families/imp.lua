-----------------------------------
-- Imp family mixin -- 20% chance to break horn (AnimationSub 1) on taking a critical hit.
-----------------------------------
-- DSP-PORT (2026-09-14, rewritten): originally ported as a listener-based mixin
-- (`mob:addListener("CRITICAL_TAKE", ...)`, matching Topaz's own `mixins = {...}` auto-apply
-- pattern) -- confirmed that whole approach is dead code in old-dsp-reference: (1) nothing in
-- this codebase's C++ ever reads a mob script's `mixins` global and calls applyMixins on it (that
-- auto-apply only exists in Topaz's own luautils.cpp, confirmed absent here by grep -- zero
-- native old-dsp-reference scripts even use `mixins = {...}`), and (2) even if it were applied,
-- "CRITICAL_TAKE" is never a real triggered listener event here anyway (checked every real
-- EventHandler.triggerListener(...) call site under src/map/).
--
-- Real fix: old-dsp-reference has its own, different, already-working mechanism for exactly this
-- -- a direct per-mob-script callback, `onCriticalHit(mob)`, called straight from the real melee
-- critical-hit code path (luautils.cpp's OnCriticalHit(), invoked from battleentity.cpp right
-- where SPECEFFECT_CRITICAL_HIT is set on a landed crit). This is now a plain function a mob's
-- own onCriticalHit(mob) calls directly -- see Imp.lua for the reference integration.
-----------------------------------

ImpMix = ImpMix or {}

ImpMix.onCriticalHit = function(mob)
    if math.random(100) < 20 and mob:AnimationSub() == 0 then
        mob:AnimationSub(1)
    end
end

return ImpMix
