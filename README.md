# DSP Blueprints

WIP - Community website to share Dyson Sphere Program blueprints.

## Roadmap

- [x] Add versionning of blueprints with a mod version attribute
- [x] Decoded blueprint
- [x] Index of all public blueprints
  - [x] Search bar
  - [x] Search by tags
  - [x] Search by mod version
- [x] Show page for a blueprint
- [x] Parsing the blueprint to display data
- [ ] Creating a new collection
- [ ] Updating a collection
- [ ] Index of public collections
- [ ] User's collection page (index with update / delete actions)
- [ ] User's blueprints page (index with update / delete actions)
- [ ] Add a mailer
- [ ] Handle multipe blueprint mods, add js in the blueprint and search form to load versions according to the selected mod
- [ ] Add filters and search to all blueprint related pages
- [ ] Add a way to flag outdated blueprints and notify the users
- [ ] Optimize, add includes, check for n+1 queries...

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