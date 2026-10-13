"""Checks a DSP tree has every engine/data dependency the Salvage zone slices need.
Usage: py -3 verify_base.py [repo_root]   (exit 1 if anything is missing)"""
import sys, re, pathlib
R = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".")
CHECKS = [
    ("src/map/status_effect.h", r"EFFECT_ENCUMBRANCE\s*=\s*259", r"EFFECT_OBLIVISCENCE\s*=\s*260", r"EFFECT_IMPAIRMENT\s*=\s*261",
     r"EFFECT_OMERTA\s*=\s*262", r"EFFECT_DEBILITATION\s*=\s*263", r"EFFECT_PATHOS\s*=\s*264"),
    ("src/map/zone.h", r"ZONE_ZHAYOLM_REMNANTS\s*=\s*73", r"ZONE_ARRAPAGO_REMNANTS\s*=\s*74", r"ZONE_BHAFLAU_REMNANTS\s*=\s*75",
     r"ZONE_SILVER_SEA_REMNANTS\s*=\s*76"),
    ("src/map/ai/states/magic_state.cpp", r"EFFECT_OMERTA"),
    ("src/map/ai/states/ability_state.cpp", r"EFFECT_IMPAIRMENT"),
    ("src/map/ai/states/mobskill_state.cpp", r"EFFECT_IMPAIRMENT"),
    ("src/map/ai/controllers/player_controller.cpp", r"EFFECT_IMPAIRMENT"),
    ("src/map/entities/battleentity.cpp", r"EFFECT_OBLIVISCENCE"),
    ("src/map/ai/ai_container.cpp", r'triggerListener\("TICK"'),
    ("src/map/lua/lua_baseentity.cpp", r"CLuaBaseEntity,AnimationSub\)", r"CLuaBaseEntity,updateAnimationSub\)", r"CLuaBaseEntity,hideName\)",
     r"CLuaBaseEntity,untargetable\)", r"CLuaBaseEntity,pathThrough\)", r"CLuaBaseEntity,addListener\)"),
    ("sql/status_effects.sql", r"VALUES \(259,'encumbrance'", r"VALUES \(264,'pathos'"),
    ("scripts/globals/status.lua", r"EFFECT_ENCUMBRANCE_I\s*=\s*259", r"EFFECT_PATHOS\s*=\s*264", r"MOBMOD_SKILL_LIST"),
    ("scripts/globals/salvage.lua", r"salvageUtil"),
    ("scripts/mixins/families/gears.lua", r"g_mixins\.families\.gears"),
    ("scripts/mixins/families/rampart.lua", r"g_mixins\.families\.rampart"),
]
bad = 0
for f, *pats in CHECKS:
    p = R / f
    t = p.read_text(encoding="utf-8", errors="replace") if p.exists() else None
    for pat in pats:
        if t is None or not re.search(pat, t):
            print("MISSING", f, pat); bad += 1
print("ok" if not bad else "%d missing" % bad)
sys.exit(1 if bad else 0)
