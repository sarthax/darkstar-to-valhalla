-- Holdfast families: Mnejing 364/Ovjang 366 detects=2, Lilisette 484 detects=1 (match Topaz)
UPDATE `mob_family_system` SET `detects`=2 WHERE `familyid` IN (364,366);
UPDATE `mob_family_system` SET `detects`=1 WHERE `familyid`=484;
