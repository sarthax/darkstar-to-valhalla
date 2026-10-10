# Test plan: salvage-bhaflau
1. Apply Zhayolm, Silver Sea, then Bhaflau SQL (00..05); restart map server.
2. Enter instance 68 with a party; confirm entry position, temp item, SALVAGE_START text, timer messages.
3. Confirm mobs spawn in all areas, no Lua errors in the map log.
4. Doors `_230`..`_23y`: unseal sequence works as mobs die; Dormant_Rampart reveals (Mad Bomber path expected; Empathic Flan path expected NOT to work).
5. Armoury Crate, Slot, Socket: trigger text matches (6430-ish block: SOCKET_TRIGGER 7430, SLOT_TRIGGER 7431).
6. Archaic Gear: melee hit despawns it after 4s; ranged does not (known).
7. Time-up and party-fallen failure messages, then exit.
