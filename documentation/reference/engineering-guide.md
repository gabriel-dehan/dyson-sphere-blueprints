# Engineering guide for agents

Read the [standing instructions](../../AGENTS.md) first. The [root README](../../README.md#setting-up) owns contributor setup instructions; this reference adds the cautions and verification choices useful during agent work. Paths in code spans are relative to the repository root; [key-files.md](key-files.md) links to their implementations.

## Choosing an environment

- Inspect `devenv.nix` or `docker-compose.yml` before starting services. They are alternative stacks with overlapping ports, not services to start together. They provide infrastructure; run the web and worker processes separately using `Procfile`.
- Entering `devenv shell` installs dependencies and attempts local S3 bucket creation. If S3 is unreachable, its bucket task skips setup; start the services and re-enter the shell to retry. Do not assume entering the shell is a read-only inspection.
- Preserve an existing `.env`. `PG_USER`, `PG_PASS` and `PG_HOST` select local/test PostgreSQL; `REDISCLOUD_URL` configures Sidekiq. Inspect the environment before commands that modify data, without printing credentials or dumping the whole environment.
- Local image uploads can use the configured S3 emulator. Tests use in-memory Shrine storage, so they do not require real AWS credentials or S3.
- Webpacker needs `NODE_OPTIONS=--openssl-legacy-provider` on the modern Node versions used by the configured environments. `.env.sample`, devenv and CI set it; export it when invoking Webpack outside Rails/dotenv.
- Devenv and CI disable Spring. `DISABLE_SPRING=1` can help diagnose stale local Rails processes.
- Inspect `bin/setup` before running it: it installs dependencies, prepares the database, clears logs/temp files and restarts Rails.
- Full seeds create a known-password admin, collections and initial game-version data. Use the README's [seeding instructions](../../README.md#seeding) when only game-version initialization is needed; do not run all seeds as an inspection step.
- Restore tasks in `lib/tasks/db.rake` drop and recreate the target database. `db:import_from_heroku` contacts Heroku even when invoked locally; not every database task has a production guard. Follow the approval rules in `AGENTS.md` before using them.

## Verification

Start with tests closest to the change, then run the relevant broader checks. Report actual results and environment blockers; an unexecuted suite is unverified.

```bash
# Non-system Minitest suite, one file, or one test by line
bin/rails test
bin/rails test test/models/blueprint_test.rb
bin/rails test test/models/blueprint_test.rb:10

# Browser suite: compile into the test-specific packs directory
RAILS_ENV=test bin/rails webpacker:compile
bin/rails test:system

# Ruby lint: avoid unrelated repository-wide auto-fixes
bundle exec rubocop app/models/blueprint.rb
bundle exec rubocop

# Translation checks
RUBYOPT="-rlogger" bundle exec i18n-tasks missing
RUBYOPT="-rlogger" bundle exec i18n-tasks unused
RUBYOPT="-rlogger" bundle exec i18n-tasks check-consistent-interpolations
# Rewrites YAML; review the diff
RUBYOPT="-rlogger" bundle exec i18n-tasks normalize
bin/rails test test/i18n_test.rb
```

- Browser tests need Chrome/Chromium. `config/webpacker.yml` uses a separate test output directory, so a development compile is not the CI-equivalent test build.
- `test/test_helper.rb` enables processor-count parallelization, loads all fixtures and supplies upload/blueprint samples and Devise integration helpers. Reuse `sample_cover_picture`, `sample_factory_code` and `sample_dyson_sphere_code` instead of inventing encoded strings.
- Preserve `gssencmode: disable` in local/test database configuration; it prevents ARM Mac PostgreSQL fork crashes.
- Check `.github/workflows/ci.yml` for the exact CI sequence and runtimes. It loads the schema, compiles assets and runs non-system and system suites separately; it does not provision Redis. RuboCop runs separately through reviewdog. Markdown-only pushes skip the test workflow, while PRs targeting `main` still run it.
- `package.json` declares no JavaScript test/lint scripts. For frontend changes, compile assets and use relevant browser tests rather than assuming `yarn test` exists.

## Domain pitfalls

### Blueprint and collection types

- Use `Blueprint::Factory`, `Blueprint::DysonSphere` or `Blueprint::Mecha` for subtype-specific creation and behavior; the shared `Blueprint` class is used for cross-type queries.
- Blueprint STI stores unqualified names via `find_sti_class` and subtype `sti_name` methods. Collection `type` is instead a Public/Private enum, with inheritance moved to `kind`. Do not treat the two `type` columns the same way.
- Preserve `light_query` on list/search paths: it deliberately excludes the potentially large encoded payload. The large-blueprint threshold belongs to factory/sphere implementations, not the base `large_bp?` method; inspect the subtype before changing it.
- Follow existing Pundit `authorize`/`policy_scope` usage and add policy tests when changing access behavior. `ApplicationController` verifies authorization/scoping except for explicit exclusions.

### Parsing and compatibility

- Validation is synchronous, but summary extraction is queued by subtype callbacks. A successful save alone does not prove background parsing or attachment processing works; inspect the relevant jobs and run a worker when testing the complete flow.
- `config/initializers/dsp_blueprint_parser.rb` patches version `-102` building content fields missing from the currently pinned parser gem. Remove it only after confirming an upgraded parser handles the field itself, with parser tests.
- Blueprint format changes can affect both Ruby parsers and browser parsing/preview. Inspect the wrapper, parser Stimulus controllers and external preview dependency linked in [key-files.md](key-files.md).
- `GameVersion#compatibility_range_for` uses semantic-version ordering and breaking-change boundaries. Add boundary tests in `test/models/game_version_test.rb`; lexical string sorting is incorrect.
- `lib/engine/` reads shared frontend JSON. English game names are used for storage; translated labels must not replace stored identifiers/names.

### Frontend and translations

- Match existing Stimulus controller filenames and markup identifiers; the loader auto-discovers `*_controller.js`, including camelCase filenames. Account for Turbolinks navigation when registering listeners or managing widgets.
- Update both supported locales, `en` and `zh-CN`, following the locale paths and write rules in `config/i18n-tasks.yml`.
- Rails YAML does not translate browser strings. JavaScript UI translations live in `app/javascript/i18n/index.js`; game entity/recipe translations use the corresponding JSON files under `app/javascript/data/`.
- Normalize locale YAML and run `test/i18n_test.rb`. The test checks missing/unused keys, normalization and interpolation consistency. Dynamic keys are accounted for in `config/i18n-tasks.yml`; inspect usage before deleting a key flagged as unused.

## Maintenance commands

Inspect the implementation and scope before using these commands. They mutate records, queue work or regenerate files. Quoted bracket arguments work in Bash and zsh; a running worker is needed for queued work.

```bash
# Enqueues a Steam version fetch; this is an example version argument
bundle exec rake 'game_version:fetch_latest[0.8.19.7662]'
# Flags an existing version as a compatibility boundary
bundle exec rake 'game_version:flag_breaking[0.8.19.7662]'

# Enqueues summary recomputation
bundle exec rake blueprint:recompute_data
bundle exec rake blueprint:recompute_factories
bundle exec rake blueprint:recompute_dyson_spheres
bundle exec rake blueprint:recompute_mechas

# Downloads FactorioLab data and rewrites app/javascript/data/entityPower.json
bundle exec rake power_data:sync
```

## Style

Use `.rubocop.yml` and nearby code as the style reference. It requires double-quoted Ruby strings, expanded empty methods, consistent trailing commas in multiline hashes and table-aligned hash rockets; frozen-string comments are optional. Its lint target is older than the runtime pin, so do not introduce unrelated runtime/linter upgrades as part of a feature fix.
