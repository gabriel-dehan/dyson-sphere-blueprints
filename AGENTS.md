# Agent instructions

DSP Blueprints is a Rails application for sharing Dyson Sphere Program blueprints. Start with the [engineering logbook](documentation/README.md), then read [current-state.md](documentation/current-state.md). Load only the references and phase records relevant to the task.

## Standing rules

- **Never run Rails commands on Heroku or seed its database. Ask the user to execute those commands manually.**
- Get explicit approval and confirm the target database before running database restore/drop/anonymization tasks or seeds. Read the task implementation first.
- Keep `.env`, credentials and database dumps out of commits and output. Use `.env.sample` for shared configuration examples.
- Keep changes focused, follow surrounding code and `.rubocop.yml`, and run the checks relevant to the change. Report checks actually run and any blockers.
- Keep the root `README.md` human-facing. Agent guidance, source maps and session handoffs belong in the logbook.
- After significant progress, offer to update the logbook and wait for approval. Do not commit unless asked.
- Treat `AGENTS.local.md` and existing `.claude/` notes/plans as user-owned, read-only material; do not edit or bulk-import them during logbook maintenance.

## Task-specific context

- [Engineering guide](documentation/reference/engineering-guide.md): environment cautions, verification commands, domain pitfalls and maintenance tasks.
- [Key files](documentation/reference/key-files.md): source entrypoints, configuration, tests and external dependency pointers.
- [Project overview](documentation/project-overview.md): orientation and product-document status.
- [History](documentation/history.md): documentation decisions and their reasons.
