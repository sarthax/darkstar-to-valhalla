-- 2026-10-02: groupids renumbered (DSP mob_groups PK is bare groupid; the Topaz numbers overwrote original DSP groups). See dsp-fixes/mob_groups_collision_repair_2026-10-02.sql.
-- Converted from Topaz `mob_groups` to DSP's real column order/shape.
-- SQL-PORT-TODO: see warnings below -- 2 item(s) need review.

-- 2026-10-02: Nyzul Isle groups already exist at 18000-18165 (dsp-master sql/mob_groups.sql); spawns below point at them. Do not add 18300+ copies.
