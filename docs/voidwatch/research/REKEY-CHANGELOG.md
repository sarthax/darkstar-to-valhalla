# Voidwatch Re-key Change Log (zones 101, 104)

Generated 2026-10-07. SQL: `sql/slices/voidwatch-vwnm/rekey_101_104.sql` (tested on a copy DB; 42 statements, all rowcount=1). `sql/npc_list.sql` edited to match.

Scope: **101 East Ronfaure** full tail re-key (+2, no collisions). **104 Jugner Forest**: Voidwatch cluster only (DSP 744-756 -> client 735-747, uniform -9). The rest of the 104 tail is NOT touched: DSP uses placeholder names there (Conquest_Banner/qm/csnpc/blank), so name matching would collide with real rows; needs per-row review. Also deferred: 104 Maw at 697 (client 686 is occupied by Carbuncle).

| Zone | Action | Old id (targid) | Name | New id (targid) |
|---|---|---|---|---|
| 101 | MOVED | 17191581 (669) | Geomantic_Reservoir | 17191583 (671) |
| 101 | MOVED | 17191580 (668) | Riftworn_Pyxis | 17191582 (670) |
| 101 | MOVED | 17191579 (667) | Riftworn_Pyxis | 17191581 (669) |
| 101 | MOVED | 17191578 (666) | Riftworn_Pyxis | 17191580 (668) |
| 101 | MOVED | 17191577 (665) | Planar_Rift | 17191579 (667) |
| 101 | MOVED | 17191576 (664) | Planar_Rift | 17191578 (666) |
| 101 | MOVED | 17191575 (663) | Planar_Rift | 17191577 (665) |
| 101 | MOVED | 17191571 (659) | Debug | 17191573 (661) |
| 101 | MOVED | 17191570 (658) | Smile_Helper | 17191572 (660) |
| 101 | MOVED | 17191569 (657) | Smile_Helper | 17191571 (659) |
| 101 | MOVED | 17191568 (656) | Smile_Helper | 17191570 (658) |
| 101 | MOVED | 17191567 (655) | Smile_Helper | 17191569 (657) |
| 101 | MOVED | 17191566 (654) | Smile_Helper | 17191568 (656) |
| 101 | MOVED | 17191565 (653) | Smile_Helper | 17191567 (655) |
| 101 | MOVED | 17191564 (652) | Smile_Helper | 17191566 (654) |
| 101 | MOVED | 17191563 (651) | Smile_Helper | 17191565 (653) |
| 101 | MOVED | 17191562 (650) | Smile_Helper | 17191564 (652) |
| 101 | MOVED | 17191561 (649) | Smile_Helper | 17191563 (651) |
| 101 | MOVED | 17191560 (648) | Stampeding_Bison | 17191562 (650) |
| 101 | MOVED | 17191559 (647) | Magivore_Ternion | 17191561 (649) |
| 101 | MOVED | 17191555 (643) | Moogle | 17191557 (645) |
| 101 | MOVED | 17191547 (635) | Moogle | 17191549 (637) |
| 104 | DELETED placeholder | 17203935 (735) | blank |  |
| 104 | DELETED placeholder | 17203937 (737) | blank |  |
| 104 | DELETED placeholder | 17203939 (739) | blank |  |
| 104 | DELETED placeholder | 17203940 (740) | blank |  |
| 104 | DELETED placeholder | 17203941 (741) | blank |  |
| 104 | DELETED placeholder | 17203942 (742) | blank |  |
| 104 | DELETED placeholder | 17203943 (743) | blank |  |
| 104 | DELETED placeholder | 17203945 (745) | blank |  |
| 104 | DELETED placeholder | 17203947 (747) | blank |  |
| 104 | MOVED | 17203944 (744) | Cavernous_Maw_2 | 17203935 (735) |
| 104 | MOVED | 17203946 (746) | Moniquaurie | 17203937 (737) |
| 104 | MOVED | 17203948 (748) | Planar_Rift | 17203939 (739) |
| 104 | MOVED | 17203949 (749) | Planar_Rift | 17203940 (740) |
| 104 | MOVED | 17203950 (750) | Planar_Rift | 17203941 (741) |
| 104 | MOVED | 17203951 (751) | Riftworn_Pyxis | 17203942 (742) |
| 104 | MOVED | 17203952 (752) | Riftworn_Pyxis | 17203943 (743) |
| 104 | MOVED | 17203953 (753) | Riftworn_Pyxis | 17203944 (744) |
| 104 | MOVED | 17203954 (754) | Arfdrick | 17203945 (745) |
| 104 | MOVED | 17203955 (755) | Geomagnetic_Fount | 17203946 (746) |
| 104 | MOVED | 17203956 (756) | Survival_Guide | 17203947 (747) |
