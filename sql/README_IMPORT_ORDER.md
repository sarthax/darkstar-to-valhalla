# npc_list import order (read before importing anything)

`sql/npc_list.sql` is the SINGLE SOURCE OF TRUTH for npc_list. It already contains every overlay row
(Ephemeral/Sunbreeze Moogles, Nyzul, Heroines' Holdfast, Voidwatch rifts, caskets, guides) and every id
is the client-DAT id (npcid = 0x01000000 + zone<<12 + slot).

It DROPs and recreates the table, so after importing it run, in order:
1. `casket_realign_apply.sql`   (stale-id cleanup, safe to re-run)
2. `treasure_caskets.sql`, `treasure_spawn_points.sql`
3. `survival_guides_apply.sql`
4. `py -3 apply_overlays.py <host> <user> <pw> <db>` (idempotent safety net; normally a no-op)
5. `py -3 tools/check_npc_ids.py ...` and fix anything it reports BEFORE starting the map server.

Rules
- Never edit the live DB npc_list by hand without also putting the row in `npc_list.sql` in the same change.
- Never change an npcid without running `tools/check_npc_ids.py` (finds Lua / spawn-point references to missing ids).
- `slices/voidwatch-vwnm/rekey_*.sql` and `npc_id_realign_190_208.sql` are RETIRED, do not run.

7. `mob_id_realign_apply.sql` (after `mob_spawn_points.sql` is imported): moves 28 battlefield/campaign mob rows onto client DAT slots. Run before `tools/check_mob_ids.py`.
