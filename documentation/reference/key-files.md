# Key files

Paths below are relative to the repository root; links resolve to the current source. Read the relevant implementation and tests before changing behavior.

## Source entrypoints

| Area | Start with |
| --- | --- |
| Routes, authentication and locale selection | [routes.rb](../../config/routes.rb), [application_controller.rb](../../app/controllers/application_controller.rb) |
| Blueprint shared behavior and STI types | [blueprint.rb](../../app/models/blueprint.rb), [subtypes](../../app/models/blueprint/) |
| Blueprint creation/editing | [subtype controllers](../../app/controllers/blueprint/) |
| Shared blueprint browsing/show and filtering | [blueprints_controller.rb](../../app/controllers/blueprints_controller.rb), [blueprints_filters.rb](../../app/controllers/concerns/blueprints_filters.rb) |
| Collections and permissions | [collection.rb](../../app/models/collection.rb), [collections_controller.rb](../../app/controllers/collections_controller.rb), [policies](../../app/policies/) |
| Blueprint decoding and summaries | [parsers](../../lib/parsers/), [blueprint_parser_job.rb](../../app/jobs/blueprint_parser_job.rb), [parser compatibility patch](../../config/initializers/dsp_blueprint_parser.rb) |
| Game-version compatibility and fetching | [game_version.rb](../../app/models/game_version.rb), [base_game_manager_job.rb](../../app/jobs/base_game_manager_job.rb), [game-version tasks](../../lib/tasks/game_version.rake) |
| Game entities, recipes and research | [engine classes](../../lib/engine/), [shared JSON](../../app/javascript/data/) |
| Usage metrics | [blueprint_usage_metric.rb](../../app/models/blueprint_usage_metric.rb), [usageTracker_controller.js](../../app/javascript/controllers/usageTracker_controller.js) |
| Views and styles | [views](../../app/views/), [application.scss](../../app/assets/stylesheets/application.scss) |
| Browser boot and behavior | [application.js](../../app/javascript/packs/application.js), [Stimulus loader](../../app/javascript/controllers/index.js), [controllers](../../app/javascript/controllers/) |
| Browser parsing and preview | [dspBlueprintParser.js](../../app/javascript/lib/dspBlueprintParser.js), [factory controller](../../app/javascript/controllers/factoryBlueprintParser_controller.js), [sphere controller](../../app/javascript/controllers/dysonSphereBlueprintParser_controller.js), [preview controller](../../app/javascript/controllers/preview_controller.js) |
| Uploads and background attachment work | [fileUpload.js](../../app/javascript/fileUpload.js), [uploaders](../../app/uploaders/), [Shrine configuration](../../config/initializers/shrine.rb), [attachment jobs](../../app/jobs/attachment/) |
| Translations | [Rails locales](../../config/locales/), [i18n-tasks configuration](../../config/i18n-tasks.yml), [browser translations](../../app/javascript/i18n/index.js) |

## Setup and verification sources

| Concern | Source |
| --- | --- |
| Runtime versions and external dependencies | [.ruby-version](../../.ruby-version), [Gemfile](../../Gemfile), [Gemfile.lock](../../Gemfile.lock), [package.json](../../package.json), [yarn.lock](../../yarn.lock) |
| Service stacks and environment examples | [devenv.nix](../../devenv.nix), [devenv.yaml](../../devenv.yaml), [docker-compose.yml](../../docker-compose.yml), [.env.sample](../../.env.sample) |
| Database targets and setup side effects | [database.yml](../../config/database.yml), [bin/setup](../../bin/setup), [seeds.rb](../../db/seeds.rb), [database tasks](../../lib/tasks/db.rake) |
| Web/worker commands and queues | [Procfile](../../Procfile), [sidekiq.yml](../../config/sidekiq.yml), [Redis initializer](../../config/initializers/redis.rb) |
| CI and lint | [test workflow](../../.github/workflows/ci.yml), [reviewdog](../../.github/workflows/reviewdog.yml), [.rubocop.yml](../../.rubocop.yml) |
| Test support and browser setup | [test_helper.rb](../../test/test_helper.rb), [application_system_test_case.rb](../../test/application_system_test_case.rb), [fixtures](../../test/fixtures/) |
| Translation checks | [i18n_test.rb](../../test/i18n_test.rb) |
| Test asset output | [webpacker.yml](../../config/webpacker.yml) |
| Bulk maintenance and generated power data | [blueprint tasks](../../lib/tasks/blueprint.rake), [power-data task](../../lib/tasks/power_data.rake) |

## Dependencies outside this tree

The Ruby `dsp_blueprint_parser` gem and the `brokenmass3dpreview` JavaScript dependency are external implementations; their exact versions/refs are in the manifests above. Check the local parser compatibility patch and browser wrapper before attributing parsing behavior entirely to either dependency.
