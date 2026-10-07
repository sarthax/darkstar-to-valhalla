# Voidwatch NM data sources — MANDATORY cross-reference for every NM slice

Query ALL FIVE before writing any NM script/SQL. Record which source backed each value ([C]/[V]/[W]/[F]/[B]/[D]).

| # | Source | Tag | How to query |
|---|--------|-----|--------------|
| 1 | Retail captures (58 VW captures, `captures.mission_name` tagged) | [C] | `D:\Claude\Playthrough Captures\voidwatch_captures\extracted\VW - <NM>\`; DB `ffxi_zone_database.db` table `captures` |
| 2 | Client DATs (ids, message text, entities) | [V] | `mission_toolkit.py <zone>`; ids ALWAYS from our client, not capture |
| 3 | BG Wiki dump + BG forum notes | [W]/[B] | `FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz` (title match); forum: `docs/voidwatch/research/bluegartr/by_nm/<NM>.txt` |
| 4 | FFXIclopedia scrape (spell lists, drop rates, ability notes) | [F] | `mission_toolkit/ffxi_zone_database.db` table `reference_wiki_pages` (source_id='FFXIclopedia', cols title/norm_title/page_text); rescrape: `py -3 scrape_ffxiclopedia.py --preset voidwatch --db ffxi_zone_database.db` |
| 5 | wikiwiki.jp/ffxi (Japanese) — BEST for per-NM spell tiers by HP, ability effects, resists, behaviour, drops | [J] | table `reference_wiki_pages` source_id='WikiWikiJP'; pages `ヴォイドウォッチ/第N章/ルート：<route>` hold every NM (name in English, Rift grid refs, 戦利品 loot, 使用技 skills, 使用魔法 spells); loot pages `.../戦利品`; weakness `ヴォイドウォッチ/弱点`. Rescrape: `py -3 scrape_wikiwiki_jp.py --seed ヴォイドウォッチ --db ffxi_zone_database.db --skip-existing` (4s/page, 429 backoff, 27 pages) |

Rules: sources disagree often (Virvatuli: BG wiki spells were generic; FFXIclopedia had the full list incl. Graviga/Breakga/Dispelga, Corpse Breath 200-600 dmg, drop rates). Prefer [C] > [V] > [F]/[W]/[B]; flag conflicts in code comments; unknown = [D], never invent ids.
