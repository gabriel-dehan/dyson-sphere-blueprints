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
- [ ] Add a reset button to homepage form
- [x] Hide collections with no blueprints
- [x] Order collections by popularity
- [ ] Way to add tags with icons in a cleaner fashion
- [ ] Search / filters for collections
- [ ] Blueprint preview
- [ ] Handle multiple blueprint mods and native blueprints once out (note to self: add js in the blueprint and search form to load versions according to the selected mod)
- [ ] Add filters and search to all blueprint related pages
- [ ] Add a way to flag outdated blueprints and notify the users
- [ ] Minimal responsive

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