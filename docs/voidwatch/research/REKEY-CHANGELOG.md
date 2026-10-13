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

## Part 2: Jugner Forest (104) tail, per-row review

Finding: DSP rows 597-734 sit uniformly 11 ids above the client (every named row matches by name: Treasure_Casket/Coffer/Achieve/Unity Master, Signposts, Alexius...Roido, Herald, Marshal, Pursuivants, Perevie, Rooks, Moogles, Logging Points, Semih, Shikaree, Beastmen's Banner, Carbuncle, Cavernous_Maw (697->686), Field Manuals, Humus-rich Earth, Lilisette, NMTreant, Field Parchment, Mogball, Mog-Tablet, Excenmille, Bostillette, Maxcimille, Alphonimile, gare, o01-o04, e01-e02, Kingslayer Doggvdegg, Pignoit, Fransont, Orcish Fodder, Zogbog, Metallic Hodgepodge). Placeholder rows (blank, qm1-5, csnpc, Conquest_Banner, NPC[59]/[5a]/[79]) move with the block unchanged. DSP Moogle 738 -> 729 (-9, matches client). No collisions; no mob_spawn_points (max targid 498), treasure_spawn_points or bcnm_treasure_chests rows in 101/104; no Lua references npc ids in these ranges. SQL: `sql/slices/voidwatch-vwnm/rekey_104_tail.sql` (apply after rekey_101_104.sql). Tested on a DB copy.

| Old targid | New targid | Name |
|---|---|---|
| 597 | 586 | Treasure_Casket |
| 598 | 587 | Treasure_Casket |
| 599 | 588 | Treasure_Casket |
| 600 | 589 | Treasure_Casket |
| 601 | 590 | Treasure_Casket |
| 602 | 591 | Treasure_Casket |
| 603 | 592 | Treasure_Casket |
| 604 | 593 | Treasure_Casket |
| 605 | 594 | Treasure_Casket |
| 606 | 595 | Treasure_Casket |
| 607 | 596 | Treasure_Casket |
| 608 | 597 | Treasure_Casket |
| 609 | 598 | Treasure_Casket |
| 610 | 599 | Treasure_Casket |
| 611 | 600 | Treasure_Casket |
| 612 | 601 | Treasure_Casket |
| 613 | 602 | Treasure_Coffer |
| 614 | 603 | Achieve_Master |
| 615 | 604 | Unity_Master |
| 618 | 607 | NPC[59] |
| 619 | 608 | NPC[5a] |
| 620 | 609 | Signpost |
| 621 | 610 | Signpost |
| 622 | 611 | Signpost |
| 623 | 612 | Signpost |
| 624 | 613 | Alexius |
| 625 | 614 | Stone_Monument |
| 626 | 615 | Crystwater_Spring |
| 627 | 616 | Ailbeche |
| 628 | 617 | Exoroche |
| 629 | 618 | Exoroche |
| 630 | 619 | Vilbert |
| 631 | 620 | OrcishFighter |
| 632 | 621 | Millechairale |
| 633 | 622 | Vijartal |
| 634 | 623 | Roido |
| 635 | 624 | qm1 |
| 636 | 625 | blank |
| 637 | 626 | Herald |
| 638 | 627 | Marshal |
| 639 | 628 | San_d_Orian_Pursuivant |
| 640 | 629 | Bastokan_Pursuivant |
| 641 | 630 | Windurstian_Pursuivant |
| 642 | 631 | Perevie |
| 643 | 632 | Rook |
| 644 | 633 | Rook |
| 645 | 634 | Rook |
| 646 | 635 | Rook |
| 647 | 636 | Rook |
| 648 | 637 | Rook |
| 649 | 638 | Rook |
| 650 | 639 | NPC[79] |
| 651 | 640 | Moogle |
| 652 | 641 | Moogle |
| 653 | 642 | Moogle |
| 654 | 643 | Moogle |
| 655 | 644 | Moogle |
| 656 | 645 | Moogle |
| 657 | 646 | Moogle |
| 658 | 647 | Moogle |
| 659 | 648 | Chaplion_RK |
| 660 | 649 | Takamoto_IM |
| 661 | 650 | Bubchu-Bibinchu_WW |
| 662 | 651 | Conquest_Banner |
| 663 | 652 | Conquest_Banner |
| 664 | 653 | Conquest_Banner |
| 665 | 654 | Conquest_Banner |
| 666 | 655 | Taumiale_RK |
| 667 | 656 | Pure_Heart_IM |
| 668 | 657 | Geruru_WW |
| 669 | 658 | Mionie |
| 670 | 659 | Conquest_Banner |
| 671 | 660 | Conquest_Banner |
| 672 | 661 | Conquest_Banner |
| 673 | 662 | Conquest_Banner |
| 674 | 663 | blank |
| 675 | 664 | Logging_Point |
| 676 | 665 | Logging_Point |
| 677 | 666 | Logging_Point |
| 678 | 667 | Logging_Point |
| 679 | 668 | Logging_Point |
| 680 | 669 | Logging_Point |
| 681 | 670 | Semih_Lafihna |
| 682 | 671 | Shikaree_M |
| 683 | 672 | qm2 |
| 684 | 673 | Beastmen_s_Banner |
| 685 | 674 | EFFECTER |
| 686 | 675 | Carbuncle |
| 687 | 676 | Talking_Doll |
| 688 | 677 | Ramblix |
| 689 | 678 | Goblin_Footprint |
| 690 | 679 | blank |
| 691 | 680 | qm3 |
| 692 | 681 | csnpc |
| 693 | 682 | Palometa |
| 694 | 683 | Luto_Mewrilah |
| 695 | 684 | qm4 |
| 696 | 685 | blank |
| 697 | 686 | Cavernous_Maw |
| 698 | 687 | Field_Manual |
| 699 | 688 | Field_Manual |
| 700 | 689 | Humus-rich_Earth |
| 701 | 690 | Lilisette |
| 702 | 691 | NMTreant |
| 703 | 692 | qm5 |
| 704 | 693 | blank |
| 706 | 695 | Field_Parchment |
| 710 | 699 | Mogball-Local |
| 711 | 700 | Mog-Tablet |
| 712 | 701 | blank |
| 713 | 702 | blank |
| 714 | 703 | Excenmille |
| 715 | 704 | csnpc |
| 716 | 705 | csnpc |
| 717 | 706 | blank |
| 718 | 707 | csnpc |
| 719 | 708 | csnpc |
| 720 | 709 | o01 |
| 721 | 710 | o02 |
| 722 | 711 | o03 |
| 723 | 712 | o04 |
| 724 | 713 | e01 |
| 725 | 714 | e02 |
| 726 | 715 | blank |
| 727 | 716 | blank |
| 728 | 717 | KingslayerDoggvdegg |
| 729 | 718 | Pignoit |
| 730 | 719 | Fransont |
| 731 | 720 | Orcishfodder |
| 732 | 721 | Zogbog |
| 733 | 722 | blank |
| 734 | 723 | MettalicHodgepodge |
| 738 | 729 | Moogle |
