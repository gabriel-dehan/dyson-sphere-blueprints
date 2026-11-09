# Structuring decisions

| Date | Decision | Why and references |
| --- | --- | --- |
| 2026-11-09 | Keep the root README human-facing; put detailed agent guidance and session handoffs in `documentation/`, reached through a short root `AGENTS.md`. | The user rejected agent-specific additions to the contributor README and requested a logbook using the logbook skill. Useful contributor setup, test, CI and restore corrections remain in the README in a human-facing voice. See [phase 1](phases/p1-agent-documentation.md). |
| 2026-11-09 | Start one logbook without importing local plans or inventing a product roadmap. | No existing logbook or shared PRD was found. The skill defaults to `documentation/` for a single logbook; the existing `docs/ROADMAP.md` is explicitly legacy. User-owned local material remains untouched; see [ownership rules](README.md#ownership-and-maintenance). |
