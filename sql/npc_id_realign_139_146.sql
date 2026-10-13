-- Live-DB equivalent of the npc_list.sql change: zone 139 slots 475-532 and zone 146 slots 505-537 move +78 to their client DAT slots
-- (names verified against fresh mission_toolkit pulls). Not needed if npc_list.sql is reimported. Idempotent.
UPDATE npc_list SET npcid=npcid+78 WHERE npcid BETWEEN 17347035 AND 17347092 AND ((npcid>>12)&4095)=139;
UPDATE npc_list SET npcid=npcid+78 WHERE npcid BETWEEN 17375737 AND 17375769 AND ((npcid>>12)&4095)=146;
