# DSP Auction House: "Partially depleted items cannot be put up for auction"

Reproduced on base DSP (`D:\Claude\dsp-master`), fixed and verified in-game 2026-10-04.
Brand-new charged items (Hi-Potion Tank 13688, Jugner Ring 15841, given with `!additem`)
could not be posted; the client answered "Partially depleted items cannot be put up for auction".

## Root cause
`CInventoryItemPacket` (packet 0x20) sends a per-item flag byte at offset 0x14 for charged items.
Base DSP hard-codes **0xD0** (ready) / **0x90** (recharging). Both values contain the **0x10 bit**,
which the client reads as "partially depleted", so it refuses to auction the item before the
server ever sees a request. Every charged item is affected, even at full charges.

Per LandSandBoat's `0x020_item_attr.cpp`: `0x80` always, `0x40` ready, `0x20` empty, `0x10` partially depleted.

Not the cause (checked): `item_basic.flags` NOAUCTION data, `item_usable.maxCharges`, and the
character's stored charges (`char_inventory.extra[1]` was 20/20 for the test item).

## Fix
1. **Packet**: compute the flag byte; set 0x10 only when `currentCharges < maxCharges`.
   -> `code/1_inventory_item.cpp.txt`
2. **Server gate**: base DSP had no server-side check, so once the packet is correct a used item
   would be listable. The AH stores only the item id and a purchased item is recreated with full
   charges, so listing a used item would silently refill it. Refuse partial items in
   `SmallPacket0x04E` cases 0x04 and 0x0B with error 197 (same as retail behaviour).
   -> `code/2_packet_system.cpp.txt`

Sibling packets checked: bazaar/trade/inspect packets don't use this flag for the AH decision; no
other change was needed for this bug. (LSB's bazaar/inspect still send 0x90/0xD0.)

## Verification (done on DSP)
New item -> post OK -> buy OK (full charges) -> use a charge -> repost refused. All as expected.
Server must be rebuilt as **Release|x64** (writes `DSGame-server_64.exe`) and the 64-bit servers restarted;
the Win32 config writes a different exe and will appear to "not work".
A post-build `get_git_ver_win.bat` error (exit 9009) just means git isn't on PATH; harmless.

## Applying to Valhalla
Valhalla's source wasn't available to me, so the changes are given as snippets with anchors rather than
a diff. Locate the same two functions (search for `CInventoryItemPacket::CInventoryItemPacket` and
`SmallPacket0x04E`). `reference_full_files/` holds the complete patched DSP files for comparison.
If Valhalla's flag-byte code differs from the description above, send me that file.

## Tools
`tools/inspect_char_charges.py` -- lists charged items in `char_inventory`, decodes `extra[1]` charges and
flags PARTIAL / ABOVE MAX / EXTRA TOO SHORT.
`py -3 inspect_char_charges.py --conf <map.conf> --char <name> --item 13688`

## Stack-size mismatches (12 vs 99)
Ground truth = the item DATs of the Valhalla client itself (`C:\ValhallaXI`; header `stack_size`, parsed the
same way as FFXI-Resources `parsers/items.py`, 30204 items). Compared against base DSP `sql/item_basic.sql`:

| DSP | client | items |
|----|----|----|
| 12 | 99 | 155 (pickaxe, sickle, hatchet, fewell orbs, mog kupons, crafting tools...) |
| 12 | 1  | 8 (craftsman's crystals 9308-9399) |
| 1  | 12 | 1 (ethereal_squama 2875) |

164 total. This matches the reported symptom: the server believes a stack is 12 while the client treats it as
99, so stack quantity checks (`getStackSize()==getQuantity()` on AH listing, buy gives `getStackSize()`) disagree
with what the client displays.
LSB is NOT a safe reference here: it differs from this client on 224 items, so use the client values.

**To apply:** run `stacksize_fix.sql` against the Valhalla DB, then restart the map server. It only touches rows
whose `stackSize` differs, so it is safe if Valhalla already fixed some of them. I did not have Valhalla's own
`item_basic` to diff, so after running it, re-run the check (`SELECT itemid,stackSize FROM item_basic WHERE itemid IN (605,1020,9308,2875)`
should return 99,99,1,12).
Note editing `sql/*.sql` alone has no effect; the UPDATE must be run (or `dbtool.py` reimport).

## AH buy/sell path review (base DSP `SmallPacket0x04E`)
No independent stack-size code bug found; every quantity comes from `item_basic.stackSize` (so the data is the bug):
- List (0x0B): stack lot requires `getStackSize() == getQuantity()`. Client allows 99, server says 12 -> refused
  ("Incorrect quantity"); a 12-stack passes. Deducts `getStackSize()`.
- Buy (0x0E): `AddItem(..., quantity==0 ? getStackSize() : 1)`. Cancel (0x0C) returns the same. DB stores only `stack` 0/1.
- **Consequence for the SQL fix:** because the quantity is not stored, existing stack listings change size when
  `stackSize` changes (12->99 = 87 extra items per lot). `stacksize_fix.sql` opens with a PRE-CHECK SELECT; clear any
  returned rows first. (12->1 items can't legitimately have stack lots.)
- Minor, unrelated to stack size: the buy path marks the row sold *before* `AddItem`; if `AddItem` fails the listing is
  consumed with no item and no gil charged (pre-checks for free slot / rare make it unlikely). Not wrapped in a
  transaction like cancel is. Also buyer is charged the client-sent `price`, not the listing's actual price.
- Buying singles of a stackable item creates one slot per item (`AddItem` never merges) -- stock DSP behaviour.
Valhalla's own AH code is unreviewed; check it matches.
