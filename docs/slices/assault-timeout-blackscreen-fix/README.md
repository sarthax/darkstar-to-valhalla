# Assault instance-timeout black-screen fix
Removes empty `onEventFinish` stubs from 11 Assault NPC scripts (Ilrusi, Lebros, Leujaoam, Mamool Ja, Periqia).
An empty-but-defined stub pins `m_event.Script` to the NPC, so the instance Zone.lua csid 102 handler never runs on
timeout/mission-failed and the player sticks on a black screen. Lua only; no SQL/C++.
Test: click a listed NPC, then let the instance time out (or fail the mission) -> player is ejected normally.
