# DSP Blueprints

Community website to share Dyson Sphere Program blueprints.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Roadmap

## IMPORTANT

- [ ] Remove multibuild & multibuild beta blueprints, either delete them all or hide them cleanly
- [ ] Clean up after MultiBuild removal?

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
- [ ] Blueprints on S3
- [ ] Preview editor
- [ ] Add power needed
- [ ] Downvote feature
- [ ] Clicking on a tag on the blueprints index will search for this tag
- [ ] Search / filters for collections
- [ ] Handle multiple blueprint mods and native blueprints once out (note to self: add js in the blueprint and search form to load versions according to the selected mod)
- [ ] Add filters and search to all blueprint related pages
- [ ] Localisation chinese

### TODO Blueprint Previewer:
- Memoize setTooltipContent so it doesn't get called every millisecond
- Colors:
```
Grid: 0xb0f566
Belts: 0x282828
```

## Changelog

### v.3.0.0
- Handle native blueprints minimaly

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

# Contributors

- [Brokenmass](https://github.com/brokenmass), wrote the 3D Preview renderer (as well as the blueprint mod).

# Deploy

Make sure the Gemfile has the proper platforms set:

```
$ bundle lock --add-platform x86_64-linux
```

## Staging

Copy prod DB to staging

```
heroku pg:backups:restore `heroku pg:backups:url --app dyson-sphere-blueprints` DATABASE_URL --app dyson-sphere-blueprints-stage
```

## License

**Important**: this license only applies to the logic and application in itself and does not pertain to any data or assets coming from the game Dyson Sphere Program which is the intellectual property of Youthcat Studio.

```
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE Version 2, December 2004

Copyright (C) 2004 Sam Hocevar sam@hocevar.net

Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

You just DO WHAT THE FUCK YOU WANT TO.
```