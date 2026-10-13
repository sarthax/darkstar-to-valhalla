-----------------------------------
-- Gated debug output. Set DEBUG_PRINT = true (e.g. from a GM command or here) to re-enable the
-- [RUNE/LAMP/HRT/ALDO/NYZUL ...DEBUG] traces; ON during backport testing; set to false once testing is done.
-----------------------------------
if DEBUG_PRINT == nil then DEBUG_PRINT = true end
function dbgPrint(...)
    if DEBUG_PRINT then print(...) end
end
