# DSP Blueprints

Community website to share Dyson Sphere Program blueprints.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Roadmap

### Dev
- [x] Setup staging pipeline
- [x] Move image hosting to S3
- [x] Move database to new host
- [~] Optimize, add includes, check for n+1 queries...
- [~] Seo, sitemap...
- [ ] Handle password recover emails
- [ ] Add tests

### Features / Bugs
- [x] Meta tags
- [x] Add a way to flag outdated blueprints and notify the users
- [x] Hide collections with no blueprints
- [x] Order collections by popularity
- [x] Add a favorites page
- [x] Fix wrong `<Select>` background color on windows
- [x] Add a reset button to homepage form
- [x] Improve search by mod version, should find all compatible versions
- [x] Remove blueprint name when parsing blueprint
- [x] Add a link to "my collections" page from the collection page
- [x] Fix rendering of blueprints 3 times in show page
- [x] Add smelters / assemblers recipes detail
- [x] Way to add tags with icons in a cleaner fashion
- [x] Add tag "Lettering" / "Conveyor Belt Art" / "Early-game" / "Mid-game" / "Late-game"
- [x] Blueprint preview
- [x] Blueprint preview loader
- [x] Add tabs for preview / description / render preview only when needed
- [x] Remove cloudinary and active storage entirely
- [ ] Find and fix memory leak
- [ ] Optimize bundle size
- [ ] Add preview in blueprint creation form
- [ ] Preview editor
- [ ] Add power needed
- [ ] Downvote feature
- [ ] Clicking on a tag on the blueprints index will search for this tag
- [ ] Add filters and search to all blueprint related pages
- [ ] Localisation chinese

## Changelog

### v.3.1.0
- New blueprint parser
- New help page
- Improved contribution documentation
- New tags for Mass Construction research
- Added versions: 0.8.19.7677, 0.8.19.7715, 0.8.19.7757, 0.8.19.7815, 0.8.19.7863

### v.3.0.0
- Handle native blueprints minimaly for version 0.8.19.7662

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
noglob rake 'mod:fetch_base_game_latest[0.8.19.7662]'
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

## Contributors

- [Brokenmass](https://github.com/brokenmass), Wrote the 3D Preview renderer (as well as the original blueprint mod).
- [LRFalk01](https://github.com/LRFalk01), DSP Blueprint Parser library and integration in the project
- [RandyCarrero](https://github.com/randycarrero), Help page and new tags for Mass construction
- [Glouel](https://github.com/glouel), Fixed some typos
## Deploy

This project is currently hosted on Heroku.
Notes to self:

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