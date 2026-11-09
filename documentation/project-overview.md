# Project overview

DSP Blueprints is a community website for sharing factory, Dyson sphere and mecha blueprints for Dyson Sphere Program. Users can browse, publish, tag, vote on and organize blueprints into collections.

The application uses Rails 6.1 with PostgreSQL, Redis/Sidekiq background work and server-rendered ERB. The browser layer uses Stimulus, Turbolinks and Webpacker; images use Shrine. See [key-files.md](reference/key-files.md) for the source map and dependency manifests rather than assuming a newer Rails/Hotwire stack.

## Product intent

There is no shared PRD in this logbook. The [root README](../README.md) describes the site and contributor workflow, and [CHANGELOG.md](../CHANGELOG.md) records shipped changes. [docs/ROADMAP.md](../docs/ROADMAP.md) labels itself legacy; use the user's current request and current source before treating an old unchecked item as planned work.

## Agent orientation

[AGENTS.md](../AGENTS.md) defines operational boundaries. [engineering-guide.md](reference/engineering-guide.md) covers setup references, verification and non-obvious conventions. [current-state.md](current-state.md) scopes what this handoff has actually verified.
