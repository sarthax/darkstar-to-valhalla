# Valhalla DSP backport

Slice status for this repository. The source of truth is [`docs/slices/STATUS.json`](docs/slices/STATUS.json); update `status` there when a slice is finished, then regenerate this table. Workflow and branch rules are in `Topaz-Assault-Backport/BRANCH_PLAN.md`.

- **final**: finished and merged to `main`; the branch is kept as the slice's record.
- **active**: still being worked.
- **review**: not merged to `main`.

`main` is the integration line. `master` is the upstream default HEAD. Each slice also has `slice/<name>-vN` tags; the newest is listed as the final tag.

| Slice | Status | Branch | Final tag | In main |
|---|---|---|---|---|
| abyssea-lights-pyxis | active | `feature/abyssea-lights-pyxis` | `slice/abyssea-lights-pyxis-v2` | yes |
| ah-charges-fix | final | `feature/ah-charges-fix` | `slice/ah-charges-fix-v3` | yes |
| assault-gm-debug-tools | final | `feature/assault-gm-debug-tools` | `slice/assault-gm-debug-tools-v1` | yes |
| assault-ilrusi-atoll | active | `feature/assault-ilrusi-atoll` | `slice/assault-ilrusi-atoll-v1` | yes |
| assault-lebros-cavern | active | `feature/assault-lebros-cavern` | `slice/assault-lebros-cavern-v1` | yes |
| assault-leujaoam-sanctum | active | `feature/assault-leujaoam-sanctum` | `slice/assault-leujaoam-sanctum-v1` | yes |
| assault-lockbox-appraisal | active | `feature/assault-lockbox-appraisal` | `slice/assault-lockbox-appraisal-v1` | yes |
| assault-mamool-ja | active | `feature/assault-mamool-ja` | `slice/assault-mamool-ja-v1` | yes |
| assault-mercenary-ranks | active | `feature/assault-mercenary-ranks` | `slice/assault-mercenary-ranks-v1` | yes |
| assault-periqia | active | `feature/assault-periqia` | `slice/assault-periqia-v1` | yes |
| assault-sql-fixes | final | `feature/assault-sql-fixes` | `slice/assault-sql-fixes-v1` | yes |
| assault-timeout-blackscreen-fix | final | `feature/assault-timeout-blackscreen-fix` | `slice/assault-timeout-blackscreen-fix-v1` | yes |
| base-debug-print | final | `base/debug-print` | `slice/base-debug-print-v1` | yes |
| campaign-ops | active | `feature/campaign-ops`, `feature/WotG-campaign-ops` | `slice/campaign-ops-v1` | yes |
| dev-tools-sqlcheck | final | `feature/dev-tools-sqlcheck` | `slice/dev-tools-sqlcheck-v1` | yes |
| ephemeral-moogle | final | `feature/ephemeral-moogle` | `slice/ephemeral-moogle-v5` | yes |
| gardening | final | `feature/mog-house-gardening` | `slice/gardening-v3` | yes |
| heroines-holdfast | active | `feature/heroines-holdfast`, `feature/mumor-heroines-holdfast` | `slice/heroines-holdfast-v2` | yes |
| homepoint-audit-fixes | review | `feature/homepoint-audit-fixes` | `slice/homepoint-audit-fixes-v2` | yes |
| mog-house-2f-patio | final | `feature/mog-house-2f-patio` | `slice/mog-house-2f-patio-v1` | yes |
| mog-tablets-jugner-fix | active | `feature/mog-tablets-jugner-fix` | `slice/mog-tablets-jugner-fix-v1` | yes |
| mog-tablets-super-kupowers | active | `feature/mog-tablets-super-kupowers-v3` | `slice/mog-tablets-super-kupowers-v3` | yes |
| moghancement | final | `feature/mog-house-moghancement`, `feature/moghancement` | `slice/moghancement-v1` | yes |
| npc-id-realign | final | `feature/npc-id-realign-v3` | `slice/npc-id-realign-v3` | yes |
| nyzul-alzadaal | final | `feature/nyzul-alzadaal` | `slice/nyzul-alzadaal-v1` | yes |
| nyzul-investigation | final | `feature/nyzul-investigation` | `slice/nyzul-investigation-v1` | yes |
| nyzul-uncharted-survey | final | `feature/nyzul-uncharted-survey` | `slice/nyzul-uncharted-survey-v1` | yes |
| salvage-arrapago | review | `feature/salvage-arrapago-v4` | `slice/salvage-arrapago-v4` | yes |
| salvage-base | review | `feature/salvage-base-v2` | `slice/salvage-base-v2` | yes |
| salvage-bhaflau | review | `feature/salvage-bhaflau-v4` | `slice/salvage-bhaflau-v4` | yes |
| salvage-silversea | review | `feature/salvage-silversea-v4` | `slice/salvage-silversea-v4` | yes |
| salvage-zhayolm | review | `feature/salvage-zhayolm-v4` | `slice/salvage-zhayolm-v4` | yes |
| sunbreeze-event | review | `feature/sunbreeze-event-v2`, `feature/mumor-sunbreeze-festival` | `slice/sunbreeze-event-v1` | yes |
| survival-guides | final | `feature/survival-guides-v3` | `slice/survival-guides-v4` | yes |
| symphonic-curator | final | `feature/mog-house-symphonic-curator`, `feature/symphonic-curator` | `slice/symphonic-curator-v1` | yes |
| textids-256plus-survival-guides | final | `feature/textids-256plus-survival-guides` | `slice/textids-256plus-survival-guides-v1` | yes |
| textids-sweep | final | `feature/textids-sweep` | `slice/textids-sweep-v1` | yes |
| treasure-caskets | final | `feature/treasure-caskets-v3` | `slice/treasure-caskets-v14` | yes |
| voidwatch-officers | review | `feature/voidwatch-officers-v2` | `slice/voidwatch-officers-v6` | yes |
| voidwatch-vwnm | review | `feature/voidwatch-vwnm-v3` | `slice/voidwatch-vwnm-v4` | yes |
| vs2019-toolset | final | `feature/vs2019-toolset` | `slice/vs2019-toolset-v1` | yes |
| weapon-additional-effect-fixes | final | `feature/weapon-additional-effect-fixes` | `slice/weapon-additional-effect-fixes-v1` | yes |
| whitegate-set-fix | final | `feature/whitegate-set-fix` | `slice/whitegate-set-fix-v1` | yes |

The previous README (upstream Darkstar Project text) is in the git history before the commit that replaced it.
