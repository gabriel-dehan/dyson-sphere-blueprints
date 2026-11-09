# DSP Blueprints

[![CI](https://github.com/gabriel-dehan/dyson-sphere-blueprints/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/gabriel-dehan/dyson-sphere-blueprints/actions/workflows/ci.yml)

Community website to share Dyson Sphere Program blueprints.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Table of content
- [DSP Blueprints](#dsp-blueprints)
  - [Table of content](#table-of-content)
  - [Roadmap](#roadmap)
  - [Changelog](#changelog)
  - [Contribute](#contribute)
  - [Our lovely sponsors](#our-lovely-sponsors)
  - [Contributors](#contributors)
  - [Deploy](#deploy)
- [License](#license)

## Roadmap

[Look at our list of issues to get an idea](https://github.com/gabriel-dehan/dyson-sphere-blueprints/issues)

## Changelog

### Latest: 4.10.0 (2025-12)
- Added Simplified Chinese (zh-CN) internationalization support ([#97](https://github.com/gabriel-dehan/dyson-sphere-blueprints/pull/97))

### Previous versions

Find the rest in the [CHANGELOG](CHANGELOG.md)

## Contribute

Pull requests are always welcome, if you want a copy of the production or staging database for development purposes (meaning all emails and passwords will be randomized, I am not just gonna give away personal information to whoever wants them), just send me an email or open a ticket and we'll see to that.

### Setting up

Use Ruby 3.2.9 (see `.ruby-version`). For JavaScript, CI uses Node 18 and the Nix environment uses Node 22. With modern Node versions, Webpacker 5 needs `NODE_OPTIONS=--openssl-legacy-provider`, which is included in `.env.sample`.

If you use Nix and devenv, start the local services with `devenv up`, then open `devenv shell` in another terminal. This sets up the runtimes and installs the Ruby and JavaScript dependencies. The configuration is in `devenv.nix`.

Otherwise, install Ruby, Bundler, Node, Yarn, PostgreSQL client libraries and ImageMagick, then install the dependencies:

```bash
bundle install
yarn install --frozen-lockfile
```

Set up your local services and `.env` as described in [Build development environment](#build-development-environment), then create the database and run the migrations:

```bash
bin/rails db:create db:migrate
```

See [Seeding](#seeding) to add the initial game-version data. The full `db/seeds.rb` script also creates an admin with a default password and collections, so it is only intended for a fresh local database.

You should then be able to run the application:

```
bin/rails server
```

In another terminal, start Sidekiq to process blueprint uploads, images and game-version updates:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

If you have Overmind installed (included with devenv), you can also run `overmind start` to start both processes from the `Procfile`.

### Seeding

The main thing you'll need to setup is to create a `GameVersion` for the blueprints. A `GameVersion` contains a field `versions` which is a JSON like this:

```ruby
{
  "0.8.19.7662" => {
    "uuid4" => "0.8.19.7662-1627063708",
    "breaking"=>true,
    "created_at"=>"2021-07-23T18:08:28.644+00:00"
  }
}
```
`breaking` is used for the display of blueprints compatibility from one game version to another.
You can also go in lib/tasks/game_version.rake and have a look at the tasks, those tasks were used to seed the game versions in staging and production:

```
noglob rake 'game_version:fetch_latest[0.8.19.7662]' # Forces a game version to be added
noglob rake 'game_version:fetch_latest' # Fetches the latest game versions from the Steam News API
noglob rake 'game_version:flag_breaking[0.8.19.7662]'
```

### Environment

For proper development, you also will need a `.env` file at the root of the project. It needs to have the following environment variables:
```
DISCORD_CLIENT_ID=XXX
DISCORD_CLIENT_SECRET=XXX
AWS_S3_ACCESS_ID_KEY=XXX
AWS_S3_ACCESS_SECRET_KEY=XXX
AWS_S3_REGION=eu-west-1
AWS_S3_BUCKET=dyson-sphere-blueprints
AWS_CLOUDFRONT_URL=https://XYZ.cloudfront.net
```
You'll need Discord credentials to use Discord sign-in. For local image uploads, you can use the S3 emulator with `AWS_S3_ENDPOINT` from `.env.sample`, without setting up an AWS account or CloudFront. Tests use in-memory upload storage.
An example can be found in `.env.sample`

### Build development environment

You can run the local services with Docker Compose and run Rails and Sidekiq on your machine. Use either Docker Compose or devenv for the services: both use the same ports, which may also conflict with an existing PostgreSQL or Redis installation.

Using the `docker-compose.yml`, will start the following services:
- PostgreSQL
- Redis
- AWS S3 (localstack)
- SMTP (mailhog)

```bash
$ docker compose up -d
```

to connect each service, use these credentials:
- PostgreSQL
  - User: `dev`
  - Password: `password`
  - Host: `127.0.0.1`
  - Database: `dspblueprints_development`
- Redis
  - URL: `redis://127.0.0.1:6379/0`
- AWS S3
  - Access key: `XXX` (some non-empty string)
  - Secret key: `XXX` (some non-empty string)
  - Region: `eu-west-1`
  - Bucket: `dyson-sphere-blueprints`
  - Endpoint: `http://localhost:4566`
- SMTP
  - SMTP Server: `localhost:1025`
  - HTTP Server: `localhost:8025` (You can see the emails you have sent with WebUI)

The above configuration is written in `.env.sample`.
You can simply copy it and it should be enough.

```bash
$ cp .env.sample .env
```

### Restoring Production Data

An anonymized production database dump is available in the [latest GitHub release](https://github.com/gabriel-dehan/dyson-sphere-blueprints/releases/latest). This dump contains production data with all emails and passwords randomized for development purposes.

**Prerequisites:**
- Docker compose services must be running (`docker compose up -d`)
- You have downloaded the `dspblueprints.dump.gz` file from the latest GitHub release

**Steps:**

1. Download the dump file from the [latest GitHub release](https://github.com/gabriel-dehan/dyson-sphere-blueprints/releases/latest) and place it in the `db/` directory:
```bash
# The file should be at db/dspblueprints.dump.gz
```

2. Restore the compressed dump:
```bash
bundle exec rake db:restore_compressed
```

**Warning:** This replaces your local development database, including any data already in it. Check your database configuration before running it.

After restoring, run `bin/rails db:migrate` to apply any migrations added since the dump was created. You can then start Rails and Sidekiq.

### Rake tasks

There are a few rake tasks that you can use:
```
rake game_version:fetch_latest[PATCH] # creates a new version in the DB, use like this: rake 'game_version:fetch_latest[0.8.19.7662]'
rake blueprint:recompute_data # updates all blueprints summary if you have made any changes to it
```

### Testing

The Minitest suite covers models, controllers, policies, parsers, translations, mailers and browser flows.

**Running tests:**
```bash
# Run all tests
rails test

# Run a specific test file
rails test test/models/blueprint_test.rb

# Run a specific test by line number
rails test test/models/blueprint_test.rb:10

# Run system tests (requires Chrome/Chromium and compiled assets)
RAILS_ENV=test bin/rails webpacker:compile
bin/rails test:system
```

**Test structure:**
- `test/models/` - Model unit tests
- `test/controllers/` - Controller tests
- `test/policies/` - Pundit authorization policy tests
- `test/system/` - End-to-end browser tests

### i18n-tasks

This project uses [i18n-tasks](https://github.com/glebm/i18n-tasks) to manage translations and ensure consistency across locales.

**Important:** Due to Ruby 3.2 compatibility issues with ActiveSupport, you must prefix all `i18n-tasks` commands with `RUBYOPT="-rlogger"`:

```bash
# Normalize translation files
RUBYOPT="-rlogger" i18n-tasks normalize

# Find missing translations
RUBYOPT="-rlogger" i18n-tasks missing

# Find unused translations
RUBYOPT="-rlogger" i18n-tasks unused

# Check for inconsistent interpolations
RUBYOPT="-rlogger" i18n-tasks check-consistent-interpolations
```

This ensures the `logger` gem is loaded before ActiveSupport, which is required for Ruby 3.2 compatibility.

### Continuous Integration

GitHub Actions runs the test workflow for pushes to `main` (except Markdown-only changes) and pull requests targeting `main`. The workflow configuration is in [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

The test workflow:
- Runs on Ubuntu with Ruby 3.2, Node 18, PostgreSQL 14 and Chrome
- Loads the test database schema
- Compiles Webpacker assets
- Runs the non-system and system test suites separately

RuboCop runs on pull requests in the separate [reviewdog workflow](.github/workflows/reviewdog.yml). The test workflow does not provision Redis.

**Before submitting a PR:**
1. Make sure all tests pass locally: `rails test`
2. Check code style: `rubocop` (or `rubocop -a` to auto-fix)
3. If you've added new functionality, please add corresponding tests

You can see the CI status on any PR or check the badge at the top of this README.

## Our lovely sponsors

- [Waylon](https://www.wecaretucson.org) - Checkout Waylon's project, [We Care Tucson](https://www.wecaretucson.org), a non-profit organization that refurbishes donated computers to resell at discounted prices to the community!
- [Sho918](https://github.com/sho918)
- Juo Nuevo

## Contributors

- [Sho918](https://github.com/sho918), code cleanup, docker setup and many incredible features and improvements
- [Brokenmass](https://github.com/brokenmass), Wrote the 3D Preview renderer (as well as the original blueprint mod).
- [LRFalk01](https://github.com/LRFalk01), DSP Blueprint Parser library and integration in the project
- [RandyCarrero](https://github.com/randycarrero), Help page and new tags for Mass construction
- [Glouel](https://github.com/glouel), Fixed some typos
- [David Westerink](https://github.com/davidakachaos), blueprint collections bulk download

## Deploy

This project is currently hosted on Heroku.
*Notes to self:*
`rubocop-daemon start`
Make sure the Gemfile has the proper platforms set:

```
$ bundle lock --add-platform x86_64-linux
```

### Staging

Copy prod DB to staging

```
heroku pg:backups:restore `heroku pg:backups:url --app dyson-sphere-blueprints` DATABASE_URL --app dyson-sphere-blueprints-stage
```

# License

**Important**: this license only applies to the logic and application in itself and does not pertain to any data or assets coming from the game Dyson Sphere Program which is the intellectual property of Youthcat Studio.

```
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE Version 2, December 2004

Copyright (C) 2004 Sam Hocevar sam@hocevar.net

Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

You just DO WHAT THE FUCK YOU WANT TO.
```
