# Voidwatch NM data sources — MANDATORY cross-reference for every NM slice

Query ALL FOUR before writing any NM script/SQL. Record which source backed each value ([C]/[V]/[W]/[F]/[B]/[D]).

| # | Source | Tag | How to query |
|---|--------|-----|--------------|
| 1 | Retail captures (58 VW captures, `captures.mission_name` tagged) | [C] | `D:\Claude\Playthrough Captures\voidwatch_captures\extracted\VW - <NM>\`; DB `ffxi_zone_database.db` table `captures` |
| 2 | Client DATs (ids, message text, entities) | [V] | `mission_toolkit.py <zone>`; ids ALWAYS from our client, not capture |
| 3 | BG Wiki dump + BG forum notes | [W]/[B] | `FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz` (title match); forum: `docs/voidwatch/research/bluegartr/by_nm/<NM>.txt` |
| 4 | FFXIclopedia scrape (spell lists, drop rates, ability notes) | [F] | `mission_toolkit/ffxi_zone_database.db` table `reference_wiki_pages` (source_id='FFXIclopedia', cols title/norm_title/page_text); rescrape: `py -3 scrape_ffxiclopedia.py --preset voidwatch --db ffxi_zone_database.db` |

Rules: sources disagree often (Virvatuli: BG wiki spells were generic; FFXIclopedia had the full list incl. Graviga/Breakga/Dispelga, Corpse Breath 200-600 dmg, drop rates). Prefer [C] > [V] > [F]/[W]/[B]; flag conflicts in code comments; unknown = [D], never invent ids.
