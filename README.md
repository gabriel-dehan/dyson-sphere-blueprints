# DSP Blueprints

Community website to share Dyson Sphere Program blueprints.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Table of content
- [DSP Blueprints](#dsp-blueprints)
  - [Table of content](#table-of-content)
  - [Roadmap](#roadmap)
  - [Changelog](#changelog)
    - [Latest: 4.0.4](#latest-404)
    - [Previous versions](#previous-versions)
  - [Contribute](#contribute)
    - [Seeding](#seeding)
    - [Environment](#environment)
    - [Build development environment](#build-development-environment)
    - [Rake tasks](#rake-tasks)
  - [Our lovely sponsors](#our-lovely-sponsors)
  - [Contributors](#contributors)
  - [Deploy](#deploy)
    - [Staging](#staging)
- [License](#license)

## Roadmap

[See the roadmap/todo file](ROADMAP.md)

## Changelog

### Latest: 4.0.4
- Updated Help page
- Updated collection's "Download as ZIP" to work with mechas blueprints
- Fixed a bug with the "Download as ZIP" when a collection name or blueprint name contained a `\`
- Added filters to collections' pages

### Previous versions

Find the rest in the [CHANGELOG](CHANGELOG.md)

## Contribute

Pull requests are always welcome, if you want a copy of the production or staging database for development purposes (meaning all emails and passwords will be randomized, I am not just gonna give away personal information to whoever wants them), just send me an email or open a ticket and we'll see to that.

### Seeding

The main thing you'll need to setup is to create a `Mod` for the blueprints. Currently there are 3 mods in production, 2 are legacy and one is for the base game. A `Mod` contains a field `version` which is a JSON like that:

```ruby
{
  "0.8.19.7662" => {
    "uuid4" => "0.8.19.7662-1627063708",
    "breaking"=>true,
    "created_at"=>"2021-07-23T18:08:28.644+00:00"
  }
}
```
`breaking` is used for the display of blueprints compatibility from one version of the mod / game to another.
You can also go in lib/tasks/mod.rake and have a look at the tasks, those tasks were used to seed the mods in staging and production:

```
noglob rake 'mod:fetch_base_game_latest[0.8.19.7662]' # Forces a game version to be added
noglob rake 'mod:fetch_base_game_latest' # Fetches the latest game versions from the Steam News API
noglob rake 'mod:flag_breaking[Dyson Sphere Program, 0.8.19.7662]'
```
The task rake mod:fetch_latest used to be to retrieve MultiBuild version from the Thunderstore API but we don't need it anymore.

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
Most of those are not needed to be able to work on most features, but if you want images to display and be able to upload images for instance you will need to setup an AWS S3 and Cloudfront.
An example can be found in `.env.sample`

### Build development environment

You can also build a development environment with docker compose.

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

### Rake tasks

There are a few rake tasks that you can use:
```
rake mod:fetch_base_game_latest[PATCH] # creates a new version in the DB, use like this: rake 'mod:fetch_base_game_latest[0.8.19.7662]'
rake blueprint:recompute_data # updates all blueprints summary if you have made any changes to it
rake mod:fetch_latest # currently legacy, but fetches the latest versions of all mods handled (MultiBuild and MultiBuildBeta)
```

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
