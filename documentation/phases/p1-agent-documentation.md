# Phase 1 — Agent documentation and audience separation

Started: 2026-11-09

Status: Done — 2026-11-09

## Goal

Give a cold coding agent a reliable project entrypoint and session handoff, while keeping the root README written for people contributing to the project. This is documentation work only.

## Work

- [x] Audit existing documentation against source/configuration and identify outdated claims and missing workflow guidance.
- [x] Read the logbook skill and establish one logbook at `documentation/`.
- [x] Remove the coding-agent section and Heroku instructions addressed to agents from the root README; retain useful contributor corrections in a human-facing voice.
- [x] Move the detailed guide out of `AGENTS.md` into logbook references, keeping essential standing instructions and navigation at the root.
- [x] Check local links and heading anchors, referenced source paths, shell-block syntax, whitespace and Markdown diagnostics.
- [x] Close this phase and replace `current-state.md` with the final verification result.

## Outcome notes

### 2026-11-09 — Initial audit and audience correction

The initial audit compared the guide with dependency manifests, service configuration, GitHub Actions, translation checks, parser compatibility code and test helpers. It found a React claim inconsistent with the Stimulus frontend, missing devenv guidance, and inaccurate CI/restore descriptions. The original guide was expanded, and the README received both contributor corrections and agent-specific additions.

The user then asked to separate those audiences and initialize the project logbook. The agent-specific README entrypoint and deployment instructions were removed; detailed guidance now lives in [reference/engineering-guide.md](../reference/engineering-guide.md) and the source map in [reference/key-files.md](../reference/key-files.md). The README keeps useful runtime/setup, worker, local upload, CI, system-test and database-restore corrections for contributors.

The pre-existing `CLAUDE.md` deletion and replacement by `AGENTS.md` were preserved. Unrelated `.gitignore` and `db/schema.rb` changes were left untouched. Local `.claude/` plans and `AGENTS.local.md` were not imported or edited.

### 2026-11-09 — Verification and closure

- Checked all nine changed/new Markdown documents: root README, root AGENTS and seven logbook files.
- All 109 local links/heading anchors, 21 inline source-path references and 11 Bash blocks passed existence/anchor/syntax checks.
- Whitespace checks passed, including `git diff --check` and checks on untracked logbook content.
- Active Markdown diagnostics reported nine clean files with no findings.
- Re-read the logbook as a cold-agent handoff and confirmed the root README contains no agent-specific references.

Application tests were not run. No production commands, service startup, seeds, restores or migrations were performed by this documentation task. Nothing was staged or committed.
