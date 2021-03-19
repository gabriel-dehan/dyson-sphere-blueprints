# DSP Blueprints

Community website to share Dyson Sphere Program blueprints.

Currently only supports the mod [MultiBuildBeta](https://dsp.thunderstore.io/package/brokenmass/MultiBuildBeta/), but will try to support other mods and native blueprints once they are out.

Official website: [https://www.dysonsphereblueprints.com](https://www.dysonsphereblueprints.com/)

## Roadmap

### Dev
- [ ] Handle password recover emails
- [ ] Setup staging pipeline
- [ ] Optimize, add includes, check for n+1 queries...
- [ ] Seo, sitemap...
- [ ] Add tests

### Features
- [x] Meta tags
- [x] Add a way to flag outdated blueprints and notify the users
- [x] Hide collections with no blueprints
- [x] Order collections by popularity
- [x] Add a favorites page
- [x] Fix wrong <Select> background color on windows
- [x] Add a reset button to homepage form
- [ ] Improve search by mod version (use bp format instead maybe?)
- [ ] Add smelters / assemblers recipes detail
- [ ] Way to add tags with icons in a cleaner fashion
- [ ] Search / filters for collections
- [ ] Blueprint preview
- [ ] Handle multiple blueprint mods and native blueprints once out (note to self: add js in the blueprint and search form to load versions according to the selected mod)
- [ ] Add filters and search to all blueprint related pages
- [ ] Localisation chinese
- [ ] Minimal responsive

## Changelog

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

# Deploy

Make sure the Gemfile has the proper platforms set:

```
$ bundle lock --add-platform x86_64-linux
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