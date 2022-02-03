# Changelog

- [Changelog](#changelog)
  - [v4.1.0](#v410)
  - [v4.0.4](#v404)
  - [v4.0.3](#v403)
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

## v4.1.0
- Track blueprint usage (copies and downloads).
- Tracking is only counted once per hour when a user copies or downloads a blueprint ("cooldown" is per blueprint)
- Display usage on blueprints' cards
- Display usage on blueprints pages
- Add a filter to sort by "Most used"

## v4.0.4
- Updated Help page
- Updated collection's "Download as ZIP" to work with mechas blueprints
- Fixed a bug with the "Download as ZIP" when a collection name or blueprint name contained a `\`
- Added filters to collections' pages

## v4.0.3
- Changed minimum image upload size from 3 MB to 5 MB
- Updated home page filters

## v4.0.2
- Fixed a bug with mechas pictures not being promoted and instead being purged after 24h
- Updated "Support us" page with up to date information

## v4.0.1
- Fixed a few bugs with color extraction for specific colors
- Fixed a bug with the color picker not working when going back one page
- Sorting blueprints now automatically refresh the page, no need to submit the form

## v4.0.0
- Lots of code reorganization and refactoring
- Handle new blueprints types: Dyson Spheres and Mechas
- Validation for Dyson Spheres and Mechas blueprints
- Mechas preview extraction
- Ability to color search mechas blueprints
- New blueprints tags can be added by the users
- Small UI improvements

## v3.5.0
- Added game version: 0.9.24.11182
- Added new entities: Traffic monitor, Spray coater, Geothermal power station, Advanced mining machine and Automatic piler
- Added new recipes: Traffic monitor, Spray coater, Proliferator, Geothermal power station, Advanced mining machine and Automatic piler

## v.3.4.1
- If a blueprint is too large, a link to open the blueprint's code in a new page will be displayed instead of the copy button. - [sho918](https://github.com/sho918)
- Fixes a small bug that made some specific search crash

## v.3.4.0
- Blueprint breakdown preview - [sho918](https://github.com/sho918)
- Added a blueprint size warning for large blueprints

## v.3.3.1
- Added new supporters to the wall of fame page
- Fixed Mass Construction (2) to be 150 structures instead of 120

## v.3.3.0
- You can now support Dyson Sphere Blueprint via Github Sponsor / Patreon, a new page has been added to the website
- Fixed n+1 query issue introduced in 3.2.0
- Moved from malloc to jemalloc to optimise RAM consumption
- SQL optimisations

## v.3.2.4
- Fix issue with bulk blueprint download - [David Westerink](https://github.com/davidakachaos)
- You can now click on tags to search for them - [sho918](https://github.com/sho918)
- Minor style fixes

## v.3.2.3
- Add ability to bulk download blueprint collections as zip. Thanks to [David Westerink](https://github.com/davidakachaos)
- SMTP Setup
- Add back the "Forgot my password" page

## v.3.2.2
- Big code clean up by [sho918](https://github.com/sho918), thanks a lot to him.
- Added docker file for development purposes. Done by sho918 as well.

## v.3.2.1
- Added Plane Smelter recipe and renamed Smelter to Arc Smelter
- Now fetches the game versions from Steam News API

## v.3.2.0
- Added Plane Smelter and its icon
- Renamed Smelter into Arc Smelter
- Ability to search by maximum structure count
- Ability to search by author
- Displays the minimum "Mass Construction" research needed on the blueprints' cards on the homepage
- Fixed a bug where the "Mass Construction" tags would not display their icon properly in a blueprint's page
- Added game versions: 0.8.20.7962, 0.8.20.7996

## v.3.1.0
- New blueprint parser
- New help page
- Improved contribution documentation
- New tags for Mass Construction research
- Added game versions: 0.8.19.7677, 0.8.19.7715, 0.8.19.7757, 0.8.19.7815, 0.8.19.7863

## v.3.0.0
- Handle native blueprints minimaly for game version 0.8.19.7662

## v.2.0.0
- Rewrote all image handling code in the site
- Updated the blueprint creation form with a new image upload UI
- Moved all the pictures to the new host AWS S3

## v.1.1.0
- Rewrote the blueprint validators and parsers entirely.
- Improved the blueprint summary, blueprints "Requirements" will now also show [assemblers / smelters / refineries / colliders / chemical plants] recipes and the number of buildings that have been affected the recipe.
- Added new tags when creating blueprints: "Early-game", "Mid-game", "Late-game", "Lettering" and "Conveyor Belt Art".
- Small UI improvements / Optimizations and code cleanup.

## v.1.0.12
- Fix the multiple rendering of the blueprints data on a blueprints page, which was causing slow downs for big blueprints.
## v.1.0.11
- Multiple CSS improvements, especially in the overall coherence of button styles and hovers
- Image optimization
- Blueprints can now be prefixed with a name (my_blueprint_name:<BASE_64_ENCODED_BLUEPRINT>) without crashing the parser
- Added a button to quickly access "My collection" from the collections index page.

## v.1.0.10
- Added "Compatible with" mod version search, the search will now find any blueprint that is compatible with the specified mod version.

## v.1.0.9
- Fixed sentry issues
- Improved search UI

## v.1.0.8
- Added a page to display a user's favorites blueprints, accessible from the user menu as "My favorites".

## v.1.0.7

- Display a range of compatible mod versions for a blueprint instead of just the mod's version the blueprint was created for
- On a blueprint's page when hovering the version in the sidebar, it will display a "Compatibility summary"
- Fix crashes that happened when you deleted all your collections and tried to create a new blueprint
- Updated pagination UI

## v.1.0.1 - v.1.0.6

- Multiple bug fixes
- Fix some crashes
- UI/UX improvements

## v.1.0.0

- Release
