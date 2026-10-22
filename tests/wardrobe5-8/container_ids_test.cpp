// Offline test: container ID table invariants for wardrobe5-8. No server, DB or client needed.
// Build/run: g++ -std=c++17 -Isrc -Isrc/map -o /tmp/w58_ids tests/wardrobe5-8/container_ids_test.cpp && /tmp/w58_ids
#include <cstdio>
#include "map/item_container.h"

static int fails = 0;
#define CHECK(c) do { if (!(c)) { std::printf("FAIL line %d: %s\n", __LINE__, #c); ++fails; } } while (0)

int main()
{
    // Legacy layout must not change: these values are baked into the 2019 client.
    CHECK(LOC_INVENTORY == 0 && LOC_MOGSAFE == 1 && LOC_STORAGE == 2 && LOC_TEMPITEMS == 3);
    CHECK(LOC_MOGLOCKER == 4 && LOC_MOGSATCHEL == 5 && LOC_MOGSACK == 6 && LOC_MOGCASE == 7);
    CHECK(LOC_WARDROBE == 8 && LOC_MOGSAFE2 == 9);
    CHECK(LOC_WARDROBE2 == 10 && LOC_WARDROBE3 == 11 && LOC_WARDROBE4 == 12);
    CHECK(MAX_CONTAINER_ID == 13);

    // New wardrobes
    CHECK(LOC_WARDROBE5 == 13 && LOC_WARDROBE6 == 14 && LOC_WARDROBE7 == 15 && LOC_WARDROBE8 == 16);
    CHECK(MAX_CONTAINER_ID_EXTENDED == 17);
    CHECK(MAX_CONTAINER_SIZE >= 80);

    // Session gating: legacy sessions never see 13-16; nobody sees >= 17.
    for (int id = 0; id < 256; ++id)
    {
        CHECK(IsValidContainerID((uint8)id, false) == (id <= 12));
        CHECK(IsValidContainerID((uint8)id, true) == (id <= 16));
    }
    std::printf(fails ? "FAILED (%d)\n" : "OK\n", fails);
    return fails != 0;
}
