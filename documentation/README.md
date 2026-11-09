# Engineering logbook

This is the session handoff for coding agents working on DSP Blueprints. The root [README](../README.md) is for human contributors; [AGENTS.md](../AGENTS.md) holds standing agent instructions.

## Read only what the task needs

1. Start with [current-state.md](current-state.md) for status, verification limits and next steps.
2. Read [project-overview.md](project-overview.md) for orientation.
3. Use [reference/key-files.md](reference/key-files.md) to find source entrypoints and [reference/engineering-guide.md](reference/engineering-guide.md) for workflow and pitfalls.
4. Read the relevant [phase](phases/p1-agent-documentation.md) when continuing that work, or [history.md](history.md) when tracing a documentation decision.

## Ownership and maintenance

- Keep agent guidance and session handoffs here, not in the root README. Contributor setup and testing instructions can remain there in a human-facing voice.
- Status belongs in `current-state.md`; execution outcomes belong in phase files; decisions about direction belong in `history.md`; durable pointers and working guidance belong in `reference/`.
- Source, tests and Git remain the truth about application behavior. Link to them rather than copying implementation details or dependency versions into the logbook.
- After significant progress, offer to update this logbook and wait for the user's approval. This initial creation was explicitly requested. Do not commit logbook files unless asked.
- `AGENTS.local.md` and the existing `.claude/` notes, plans and investigations are user-owned local material: read when relevant, never edit or bulk-import them during logbook maintenance.
- No shared PRD or active product plan has been established for this logbook. Create `plans/` only when the user requests a product document or implementation plan; do not turn the legacy roadmap into one.
- Add `research/` or `reference/local-environment.md` only when there are measurements or machine-specific facts worth keeping.

## Phases

| Phase | Record |
| --- | --- |
| 1 — Agent documentation and audience separation | [p1-agent-documentation.md](phases/p1-agent-documentation.md) |
