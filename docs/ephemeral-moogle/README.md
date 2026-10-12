# Ephemeral Moogle (crystal storage)
Ported from Topaz `scripts/globals/ephemeral.lua`. DSP had NPC rows but no scripts and no `char_points` crystal columns.

Event ids (trigger/trade/fail) are the 2nd/3rd/4th event of each moogle entity in the client's events DAT, verified via `mission_reports/<zone>/events_disasm.txt`:
SSD 3549/3550/3551, NSD Wood 913/915/917, NSD Smith 914/916/918 (Topaz used 917 for Smith - wrong), Bastok Mines & Markets 617/618/619, Windurst Waters 1098/1099/1100, Windurst Woods Bone 895/897/899, Cloth 896/898/900.

NPC ids corrected to the client dat ids (SSD 17719927, Bastok Markets 17740169, Windurst Waters 17752531, Windurst Woods 17764826/27).

Apply to an existing DB: `sql/slices/ephemeral-moogle/ephemeral_moogle.sql`, then restart map server.
Test: trade crystals/clusters to a moogle; talk to it and withdraw; check `char_points`.
