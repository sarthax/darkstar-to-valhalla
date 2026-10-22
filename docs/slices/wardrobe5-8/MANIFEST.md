# Source / revision manifest - wardrobe5-8 V1
Update at every test run. Nothing below has been tested yet unless marked.

| Item | Value | Verified |
|---|---|---|
| DSP `main` at branch cut | `86d4467d446569c741d76d296e640c3b844ad844` | yes (git) |
| Feature branch | `feature/wardrobe5-8-v1` | local |
| Deployed map-server revision / build hash | UNKNOWN | no - needs owner's server |
| MariaDB schema revision | UNKNOWN | no |
| Toolkit research head | `71184c0e992e2aecaf606e730fc277834cefc82c` (per handoff; branch `research/2019-wardrobe-backport-gates-20261021`) | not re-checked |
| Original `FFXiMain.dll` (owner backup, uploaded to cloud session) | 2,870,352 B, `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`; decoded `.text` prefix `af2126c057d8` | yes (sha256sum + scanner gate) |
| Installed client DLL hash | UNKNOWN | no |
| DLL supplied to the cloud session 2026-10-22 | 2,870,352 B, SHA-256 `53e91099d0d773ccde227c53ad57986126d969751514b05e96d39210b6dc699c` = the **Stage 3** smoke-test build, NOT the original. Not used for the audit (scanner gate refuses it). Suggests Stage 3 may still be installed/staged: restore + hash-check before any client test. | yes (sha256sum) |
| Stage 2 DLL | `27636cc5...923d2c` | outside repo |
| Stage 3 DLL | `53e91099...b699c` | outside repo |
| Modified-DLL output hash (V1) | none yet | - |
