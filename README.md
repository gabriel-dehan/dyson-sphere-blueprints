# DSP Blueprints

Community website to share Dyson Sphere Program blueprints.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Table of content
- [DSP Blueprints](#dsp-blueprints)
  - [Table of content](#table-of-content)
  - [Roadmap](#roadmap)
  - [Changelog](#changelog)
    - [v4.0.2](#v402)
    - [v4.0.1](#v401)
    - [v4.0.0](#v400)
    - [v3.5.0](#v350)
    - [v.3.4.1](#v341)
    - [v.3.4.0](#v340)
    - [v.3.3.1](#v331)
    - [v.3.3.0](#v330)
    - [v.3.2.4](#v324)
    - [v.3.2.3](#v323)
    - [v.3.2.2](#v322)
    - [v.3.2.1](#v321)
    - [v.3.2.0](#v320)
    - [v.3.1.0](#v310)
    - [v.3.0.0](#v300)
    - [v.2.0.0](#v200)
    - [v.1.1.0](#v110)
    - [v.1.0.12](#v1012)
    - [v.1.0.11](#v1011)
    - [v.1.0.10](#v1010)
    - [v.1.0.9](#v109)
    - [v.1.0.8](#v108)
    - [v.1.0.7](#v107)
    - [v.1.0.1 - v.1.0.6](#v101---v106)
    - [v.1.0.0](#v100)
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

### v4.0.2
- Fixed a bug with mechas pictures not being promoted and instead being purged after 24h
- Updated "Support us" page with up to date information

### v4.0.1
- Fixed a few bugs with color extraction for specific colors
- Fixed a bug with the color picker not working when going back one page
- Sorting blueprints now automatically refresh the page, no need to submit the form

### v4.0.0
- Lots of code reorganization and refactoring
- Handle new blueprints types: Dyson Spheres and Mechas
- Validation for Dyson Spheres and Mechas blueprints
- Mechas preview extraction
- Ability to color search mechas blueprints
- New blueprints tags can be added by the users
- Small UI improvements

### v3.5.0
- Added game version: 0.9.24.11182
- Added new entities: Traffic monitor, Spray coater, Geothermal power station, Advanced mining machine and Automatic piler
- Added new recipes: Traffic monitor, Spray coater, Proliferator, Geothermal power station, Advanced mining machine and Automatic piler

### v.3.4.1
- If a blueprint is too large, a link to open the blueprint's code in a new page will be displayed instead of the copy button. - [sho918](https://github.com/sho918)
- Fixes a small bug that made some specific search crash

### v.3.4.0
- Blueprint breakdown preview - [sho918](https://github.com/sho918)
- Added a blueprint size warning for large blueprints

### v.3.3.1
- Added new supporters to the wall of fame page
- Fixed Mass Construction (2) to be 150 structures instead of 120

### v.3.3.0
- You can now support Dyson Sphere Blueprint via Github Sponsor / Patreon, a new page has been added to the website
- Fixed n+1 query issue introduced in 3.2.0
- Moved from malloc to jemalloc to optimise RAM consumption
- SQL optimisations

### v.3.2.4
- Fix issue with bulk blueprint download - [David Westerink](https://github.com/davidakachaos)
- You can now click on tags to search for them - [sho918](https://github.com/sho918)
- Minor style fixes

### v.3.2.3
- Add ability to bulk download blueprint collections as zip. Thanks to [David Westerink](https://github.com/davidakachaos)
- SMTP Setup
- Add back the "Forgot my password" page

### v.3.2.2
- Big code clean up by [sho918](https://github.com/sho918), thanks a lot to him.
- Added docker file for development purposes. Done by sho918 as well.

### v.3.2.1
- Added Plane Smelter recipe and renamed Smelter to Arc Smelter
- Now fetches the game versions from Steam News API

### v.3.2.0
- Added Plane Smelter and its icon
- Renamed Smelter into Arc Smelter
- Ability to search by maximum structure count
- Ability to search by author
- Displays the minimum "Mass Construction" research needed on the blueprints' cards on the homepage
- Fixed a bug where the "Mass Construction" tags would not display their icon properly in a blueprint's page
- Added game versions: 0.8.20.7962, 0.8.20.7996

### v.3.1.0
- New blueprint parser
- New help page
- Improved contribution documentation
- New tags for Mass Construction research
- Added game versions: 0.8.19.7677, 0.8.19.7715, 0.8.19.7757, 0.8.19.7815, 0.8.19.7863

### v.3.0.0
- Handle native blueprints minimaly for game version 0.8.19.7662

### v.2.0.0
- Rewrote all image handling code in the site
- Updated the blueprint creation form with a new image upload UI
- Moved all the pictures to the new host AWS S3

### v.1.1.0
- Rewrote the blueprint validators and parsers entirely.
- Improved the blueprint summary, blueprints "Requirements" will now also show [assemblers / smelters / refineries / colliders / chemical plants] recipes and the number of buildings that have been affected the recipe.
- Added new tags when creating blueprints: "Early-game", "Mid-game", "Late-game", "Lettering" and "Conveyor Belt Art".
- Small UI improvements / Optimizations and code cleanup.

### v.1.0.12
- Fix the multiple rendering of the blueprints data on a blueprints page, which was causing slow downs for big blueprints.
### v.1.0.11
- Multiple CSS improvements, especially in the overall coherence of button styles and hovers
- Image optimization
- Blueprints can now be prefixed with a name (my_blueprint_name:<BASE_64_ENCODED_BLUEPRINT>) without crashing the parser
- Added a button to quickly access "My collection" from the collections index page.

### v.1.0.10
- Added "Compatible with" mod version search, the search will now find any blueprint that is compatible with the specified mod version.

### v.1.0.9
- Fixed sentry issues
- Improved search UI

### v.1.0.8
- Added a page to display a user's favorites blueprints, accessible from the user menu as "My favorites".

### v.1.0.7

- Display a range of compatible mod versions for a blueprint instead of just the mod's version the blueprint was created for
- On a blueprint's page when hovering the version in the sidebar, it will display a "Compatibility summary"
- Fix crashes that happened when you deleted all your collections and tried to create a new blueprint
- Updated pagination UI

### v.1.0.1 - v.1.0.6

- Multiple bug fixes
- Fix some crashes
- UI/UX improvements

### v.1.0.0

- Release

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
